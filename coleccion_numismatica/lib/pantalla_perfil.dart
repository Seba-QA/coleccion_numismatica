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

class PantallaPerfil extends StatefulWidget {
  final List<Map<String, String>>? monedas;
  final VoidCallback? onDatosCambiados;

  const PantallaPerfil({
    super.key,
    this.monedas,
    this.onDatosCambiados,
  });

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

  Future<void> _exportarDatos() async {
    try {
      final jsonData = jsonEncode(widget.monedas);
      final tempDir = await getTemporaryDirectory();
      final fileName = 'coleccion_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonData);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mi colección numismática',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al exportar los datos')),
      );
    }
  }

  Future<List<Map<String, String>>> _obtenerMonedasDeFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final snapshot = await FirebaseFirestore.instance
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
      // Seleccionar archivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final contenido = await file.readAsString();
      final List<dynamic> importedList = jsonDecode(contenido);
      final List<Map<String, String>> nuevasMonedas = importedList
          .map((e) => Map<String, String>.from(e as Map<dynamic, dynamic>))
          .toList();

      // Diálogo de opción: reemplazar o fusionar
      final opcion = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importar datos'),
          content: const Text('¿Cómo deseas combinar los datos importados con tu colección actual?'),
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

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (opcion == 'reemplazar') {
        // Eliminar todos los documentos existentes
        final snapshot = await collectionRef.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        // Agregar los nuevos
        for (var moneda in nuevasMonedas) {
          await collectionRef.add(moneda);
        }
      } else if (opcion == 'fusionar') {
        // Obtener claves existentes (país + denominación + año)
        final snapshot = await collectionRef.get();
        final Set<String> clavesExistentes = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final clave = '${data['pais']}_${data['denominacion']}_${data['anio']}';
          clavesExistentes.add(clave);
        }
        // Añadir solo las monedas que no existan
        for (var moneda in nuevasMonedas) {
          final clave = '${moneda['pais']}_${moneda['denominacion']}_${moneda['anio']}';
          if (!clavesExistentes.contains(clave)) {
            await collectionRef.add(moneda);
          }
        }
      }

      // Cerrar indicador de carga
      Navigator.pop(context); // cierra el diálogo de progreso

      // Recargar los datos en la pantalla principal
      if (widget.onDatosCambiados != null) {
        widget.onDatosCambiados!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importación completada con éxito')),
      );
    } catch (e) {
      print('Error en importación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al importar los datos. Archivo inválido.')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    await _auth.cerrarSesion();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _obtenerMetodoAutenticacion() {
    if (_user.isAnonymous) return 'anonimo';
    if (_user.providerData.isNotEmpty) return _user.providerData.first.providerId;
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

  @override
  Widget build(BuildContext context) {
    final email = _user.email ?? 'Sin email';
    final providerId = _obtenerMetodoAutenticacion();
    final metodoString = _metodoString(providerId);
    final esAnonimo = _user.isAnonymous;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Método de autenticación'),
                subtitle: Text(metodoString),
              ),
            ),
            const SizedBox(height: 20),
            // Botón exportar
            ElevatedButton.icon(
              onPressed: _exportarDatos,
              icon: const Icon(Icons.download),
              label: const Text('Exportar colección'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            ),
            const SizedBox(height: 12),
            // Botón importar
            ElevatedButton.icon(
              onPressed: _importarDatos,
              icon: const Icon(Icons.upload),
              label: const Text('Importar colección'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            ),
            if (esAnonimo) ...[
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Estás en modo invitado. Tus datos no están vinculados a una cuenta y podrías perderlos al desinstalar la app.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaAuth(isLinking: true)),
                  );
                },
                icon: const Icon(Icons.link),
                label: const Text('Vincular cuenta (Registrarse o Iniciar sesión)'),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _cerrarSesion,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}