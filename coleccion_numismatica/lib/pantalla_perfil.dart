import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'servicio_auth.dart';
import 'pantalla_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PantallaPerfil extends StatefulWidget {
  final VoidCallback? onDatosCambiados;

  const PantallaPerfil({super.key, this.onDatosCambiados});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final ServicioAuth _auth = ServicioAuth();
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

  // ---------- Funciones existentes (sin cambios) ----------
  Future<void> _exportarDatos() async {
    try {
      final jsonData = jsonEncode(_obtenerMonedasDeFirestore());
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'coleccion_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonData);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Mi colección numismática');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al exportar los datos')),
      );
    }
  }

  Future<List<Map<String, String>>> _obtenerMonedasDeFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final snapshot =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('monedas')
            .get();
    final List<Map<String, String>> lista = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final moneda = Map<String, String>.from(data);
      moneda['_id'] = doc.id;
      lista.add(moneda);
    }
    return lista;
  }

  Future<void> _importarDatos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final contenido = await file.readAsString();
      final List<dynamic> importedList = jsonDecode(contenido);
      final List<Map<String, String>> nuevasMonedas =
          importedList
              .map((e) => Map<String, String>.from(e as Map<dynamic, dynamic>))
              .toList();

      final opcion = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Importar datos'),
              content: const Text(
                '¿Cómo deseas combinar los datos importados con tu colección actual?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'reemplazar'),
                  child: const Text('Reemplazar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'fusionar'),
                  child: const Text('Fusionar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'cancelar'),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
      );

      if (opcion == 'cancelar' || opcion == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final collectionRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('monedas');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (opcion == 'reemplazar') {
        final snapshot = await collectionRef.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        for (var moneda in nuevasMonedas) {
          await collectionRef.add(moneda);
        }
      } else if (opcion == 'fusionar') {
        final snapshot = await collectionRef.get();
        final Set<String> clavesExistentes = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final clave =
              '${data['pais']}_${data['denominacion']}_${data['anio']}';
          clavesExistentes.add(clave);
        }
        for (var moneda in nuevasMonedas) {
          final clave =
              '${moneda['pais']}_${moneda['denominacion']}_${moneda['anio']}';
          if (!clavesExistentes.contains(clave)) {
            await collectionRef.add(moneda);
          }
        }
      }

      Navigator.pop(context);
      if (widget.onDatosCambiados != null) {
        widget.onDatosCambiados!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importación completada con éxito')),
      );
    } catch (e) {
      print('Error en importación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al importar los datos. Archivo inválido.'),
        ),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    await _auth.cerrarSesion();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _exportarPDF() async {
    try {
      // 1. Obtener datos
      final monedas = await _obtenerMonedasDeFirestore();

      if (monedas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay datos para exportar.')),
        );
        return;
      }

      // 2. Calcular totales
      final totalPiezas = monedas.length;
      final paises =
          monedas
              .map((m) => m['pais'] ?? '')
              .where((p) => p.isNotEmpty)
              .toSet();
      final totalPaises = paises.length;
      final totalMonedas = monedas.where((m) => m['tipo'] == 'moneda').length;
      final totalBilletes = monedas.where((m) => m['tipo'] == 'billete').length;

      // 3. Crear documento PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build:
              (context) => [
                // Encabezado
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Mi Colección Numismática',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Exportado: ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                    pw.Divider(),
                  ],
                ),
                // Resumen
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 16),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard('Piezas', '$totalPiezas'),
                      _buildSummaryCard('Países', '$totalPaises'),
                      _buildSummaryCard('Monedas', '$totalMonedas'),
                      _buildSummaryCard('Billetes', '$totalBilletes'),
                    ],
                  ),
                ),
                pw.Divider(),
                // Tabla de piezas
                pw.SizedBox(height: 16),
                pw.Text(
                  'Listado de piezas',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildTable(monedas),
              ],
        ),
      );

      // 4. Guardar temporalmente
      final output = await getTemporaryDirectory();
      final fileName = 'coleccion_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // 5. Compartir
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Mi colección numismática');
    } catch (e) {
      print('Error exportando PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al generar el PDF.')));
    }
  }

  // Widgets auxiliares para el PDF
  pw.Widget _buildSummaryCard(String label, String value) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTable(List<Map<String, String>> monedas) {
    final headers = ['#', 'Denominación', 'País', 'Año', 'Tipo', 'Cantidad'];
    final rows =
        monedas.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final m = entry.value;
          return [
            index.toString(),
            m['denominacion'] ?? '',
            m['pais'] ?? '',
            m['anio'] ?? '',
            m['tipo'] == 'moneda' ? 'Moneda' : 'Billete',
            m['cantidad'] ?? '1',
          ];
        }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: pw.FixedColumnWidth(30),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FixedColumnWidth(50),
        4: pw.FixedColumnWidth(60),
        5: pw.FixedColumnWidth(50),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children:
              headers
                  .map(
                    (h) => pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
        ),
        ...rows.map(
          (row) => pw.TableRow(
            children:
                row
                    .map(
                      (cell) => pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(cell),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  // ---------- Funciones auxiliares ----------
  String _obtenerMetodoAutenticacion() {
    if (_user.isAnonymous) return 'anonimo';
    if (_user.providerData.isNotEmpty)
      return _user.providerData.first.providerId;
    return 'desconocido';
  }

  String _metodoString(String provider) {
    switch (provider) {
      case 'google.com':
        return 'Google';
      case 'password':
        return 'Email/Contraseña';
      case 'anonimo':
        return 'Invitado (anónimo)';
      default:
        return 'Desconocido';
    }
  }

  String _obtenerNombreUsuario() {
    if (_user.isAnonymous) return 'Invitado';
    if (_user.displayName != null && _user.displayName!.isNotEmpty) {
      return _user.displayName!;
    }
    final email = _user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final esAnonimo = _user.isAnonymous;
    final nombre = _obtenerNombreUsuario();
    final email = _user.email ?? 'Sin email';
    final metodoString = _metodoString(_obtenerMetodoAutenticacion());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- CABECERA ----------
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombre,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // "Coleccionista desde" no disponible, omitimos
                  const SizedBox(height: 8),
                  // Estadísticas: piezas y países
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('monedas')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem('...', 'Piezas'),
                            const SizedBox(width: 24),
                            _buildStatItem('...', 'Países'),
                          ],
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem('0', 'Piezas'),
                            const SizedBox(width: 24),
                            _buildStatItem('0', 'Países'),
                          ],
                        );
                      }

                      final List<Map<String, String>> monedas =
                          snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final moneda = Map<String, String>.from(data);
                            moneda['_id'] = doc.id;
                            return moneda;
                          }).toList();

                      final totalPiezas = monedas.length;
                      final paises =
                          monedas
                              .map((m) => m['pais'] ?? '')
                              .where((p) => p.isNotEmpty)
                              .toSet();
                      final totalPaises = paises.length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem('$totalPiezas', 'Piezas'),
                          const SizedBox(width: 24),
                          _buildStatItem('$totalPaises', 'Países'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ---------- TARJETAS DE INFORMACIÓN ----------
            _buildInfoCard(icon: Icons.email, title: 'CORREO', subtitle: email),
            _buildInfoCard(
              icon: Icons.security,
              title: 'AUTENTICACIÓN',
              subtitle: metodoString,
            ),
            const SizedBox(height: 24),
            const Text(
              'DATOS DE COLECCIÓN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFC9A03D),
              ),
            ),
            const SizedBox(height: 4),
            _buildActionCard(
              icon: Icons.download,
              title: 'Exportar colección',
              subtitle: 'JSON',
              onTap: _exportarDatos,
            ),
            _buildActionCard(
              icon: Icons.upload,
              title: 'Importar colección',
              subtitle: 'Desde archivo JSON',
              onTap: _importarDatos,
            ),
            _buildActionCard(
              icon: Icons.picture_as_pdf,
              title: 'Exportar a PDF',
              subtitle: 'Catálogo en texto',
              onTap: _exportarPDF,
            ),
            const SizedBox(height: 4),
            const Text(
              'CUENTA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFC9A03D),
              ),
            ),
            const SizedBox(height: 12),

            // Si es anónimo, mostrar advertencia y botón vincular
            if (esAnonimo) ...[
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estás en modo invitado. Tus datos no están vinculados a una cuenta y podrías perderlos al desinstalar la app.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.link,
                title: 'Vincular cuenta',
                subtitle: 'Registrarse o iniciar sesión',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaAuth(isLinking: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // Cerrar sesión
            _buildActionCard(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              subtitle: 'Salir de tu cuenta',
              onTap: _cerrarSesion,
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets auxiliares ----------

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? Colors.red : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
