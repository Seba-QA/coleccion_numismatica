import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'servicio_catalogos.dart';
import 'models/catalogo.dart';
import 'models/catalogo_pieza.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaDetalleCatalogo extends StatefulWidget {
  final String catalogoId;
  const PantallaDetalleCatalogo({super.key, required this.catalogoId});

  @override
  State<PantallaDetalleCatalogo> createState() =>
      _PantallaDetalleCatalogoState();
}

class _PantallaDetalleCatalogoState extends State<PantallaDetalleCatalogo> {
  final ServicioCatalogos _servicio = ServicioCatalogos();
  bool _sincronizando = false;
  int _progresoActual = 0;
  int _totalPiezas = 0;
  late Future<Catalogo?> _catalogoFuture;
  late Future<List<Map<String, dynamic>>> _monedasFuture;
  Map<String, bool> _manualCompletado = {};
  bool _progresoInicializado = false;

  @override
  void initState() {
    super.initState();
    _catalogoFuture = _servicio.obtenerCatalogoPorId(widget.catalogoId);
    _monedasFuture = _obtenerMonedasFuturo(widget.catalogoId);
  }

  Future<List<Map<String, dynamic>>> _obtenerMonedasFuturo(
    String catalogoId,
  ) async {
    final relaciones = await _servicio.obtenerRelacionesPorCatalogo(catalogoId);
    if (relaciones.isEmpty) return [];

    final monedaIds = relaciones.map((r) => r.monedaId).toList();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final List<Map<String, dynamic>> todas = [];
    for (var i = 0; i < monedaIds.length; i += 10) {
      final batch = monedaIds.skip(i).take(10).toList();
      final snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('monedas')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['_id'] = doc.id;
        todas.add(data);
      }
    }
    return todas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmarEliminar,
            tooltip: 'Eliminar catálogo',
          ),
        ],
      ),
      body: FutureBuilder<Catalogo?>(
        future: _servicio.obtenerCatalogoPorId(widget.catalogoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar el catálogo'));
          }
          final catalogo = snapshot.data!;
          // Inicializar estados manuales solo la primera vez o cuando no existan.
          if (_manualCompletado.isEmpty && catalogo.estadosManuales != null) {
            _manualCompletado = Map<String, bool>.from(
              catalogo.estadosManuales!,
            );
          }
          return _buildContent(catalogo);
        },
      ),
    );
  }

  Widget _buildContent(Catalogo catalogo) {
    final tieneLista =
        catalogo.listaOficial != null && catalogo.listaOficial!.isNotEmpty;
    final total = tieneLista ? catalogo.listaOficial!.length : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            key: ValueKey(
              _progresoActual,
            ), // Forzar reconstrucción al cambiar progreso
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalogo.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (catalogo.descripcion != null &&
                    catalogo.descripcion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      catalogo.descripcion!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tieneLista
                                ? 'Progreso: $_progresoActual / $total'
                                : 'Piezas asociadas: ${_totalPiezas}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (tieneLista)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : _progresoActual / total,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  catalogo.completado
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (catalogo.completado)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _sincronizando ? null : () => _sincronizar(catalogo),
                    icon:
                        _sincronizando
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.sync),
                    label: Text(
                      _sincronizando ? 'Sincronizando...' : 'Sincronizar',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista oficial
          if (tieneLista) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.list, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Lista oficial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            _buildListaOficial(catalogo),
            const Divider(),
          ],

          // Lista de piezas asociadas (expandible)
          ExpansionTile(
            title: Text(
              'Piezas asociadas (${_totalPiezas})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            leading: const Icon(Icons.account_balance),
            initiallyExpanded: false,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _buildListaPiezas(catalogo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaPiezas(Catalogo catalogo) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _monedasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Error al cargar las piezas asociadas'),
          );
        }
        final monedas = snapshot.data!;
        if (monedas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay piezas asociadas a este catálogo.\nAsigna tags desde el detalle de cada pieza.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: monedas.length,
          itemBuilder: (context, index) {
            final moneda = monedas[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(
                  moneda['denominacion'] ?? 'Sin denominación',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${moneda['pais'] ?? ''} - ${moneda['anio'] ?? ''}',
                ),
                trailing: _buildEstadoIcon(moneda, catalogo),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListaOficial(Catalogo catalogo) {
    final lista = catalogo.listaOficial!;

    // Inicializar estado manual si no existe
    for (var elemento in lista) {
      if (!_manualCompletado.containsKey(elemento)) {
        _manualCompletado[elemento] = false;
      }
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _monedasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error al cargar el estado de la lista oficial.'),
          );
        }
        final monedas = snapshot.data!;
        final campoComparacion = catalogo.campoComparacion ?? 'anio';
        final valoresEnColeccion =
            monedas
                .map((m) => m[campoComparacion]?.toString())
                .where((v) => v != null)
                .toSet();

        // Recalcular estado manual basado en la colección (para sincronización)
        for (var elemento in lista) {
          final completadoAutomatico = valoresEnColeccion.contains(elemento);
          if (!_manualCompletado.containsKey(elemento)) {
            _manualCompletado[elemento] = completadoAutomatico;
          }
        }

        // Inicializar el progreso solo la primera vez que tengamos datos
        if (!_progresoInicializado) {
          _progresoInicializado = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _actualizarProgreso(catalogo, monedas);
          });
        }

        // Asegurar que el progreso se calcule una vez tras cargar monedas
        return Column(
          //key: ValueKey(_manualCompletado.length),
          key: ValueKey(_manualCompletado.hashCode),
          children:
              lista.map((elemento) {
                final completadoManual = _manualCompletado[elemento] ?? false;
                final completadoAutomatico = valoresEnColeccion.contains(
                  elemento,
                );
                final completado = completadoManual || completadoAutomatico;

                return ListTile(
                  key: ValueKey('$elemento-$completado'),
                  dense: true,
                  onTap: () async {
                    setState(() {
                      _manualCompletado[elemento] = !completadoManual;
                    });
                    // Actualizar progreso en UI
                    _actualizarProgreso(catalogo, monedas);
                    // Guardar estados manuales en Firestore y esperar al resultado
                    try {
                      await _servicio.guardarEstadosManuales(
                        catalogo.id,
                        _manualCompletado,
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error guardando estado: $e')),
                        );
                      }
                    }
                  },
                  leading: Icon(
                    completado ? Icons.check_circle : Icons.circle_outlined,
                    color: completado ? Colors.green : Colors.grey.shade400,
                  ),
                  title: Text(
                    elemento,
                    style: TextStyle(
                      decoration:
                          completado ? TextDecoration.lineThrough : null,
                      color: completado ? Colors.green : null,
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildEstadoIcon(Map<String, dynamic> moneda, Catalogo catalogo) {
    if (catalogo.listaOficial == null || catalogo.listaOficial!.isEmpty) {
      return const Icon(Icons.link, color: Colors.blue);
    }
    final campoComparacion = catalogo.campoComparacion ?? 'anio';
    final valorMoneda = moneda[campoComparacion]?.toString();
    if (valorMoneda != null && catalogo.listaOficial!.contains(valorMoneda)) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }

  Future<void> _sincronizar(Catalogo catalogo) async {
    setState(() => _sincronizando = true);

    try {
      final resultado = await _servicio.sincronizarCatalogo(catalogo.id);
      final monedas = await _obtenerMonedasFuturo(catalogo.id);
      final campoComparacion = catalogo.campoComparacion ?? 'anio';
      final valoresEnColeccion =
          monedas
              .map((m) => m[campoComparacion]?.toString())
              .where((v) => v != null)
              .toSet();

      // Actualizar _manualCompletado: conservar los manuales
      if (catalogo.listaOficial != null) {
        for (var elemento in catalogo.listaOficial!) {
          final enColeccion = valoresEnColeccion.contains(elemento);
          // Si está en la colección, lo marcamos como completado (a menos que el usuario lo haya desmarcado manualmente)
          if (enColeccion && _manualCompletado[elemento] != false) {
            _manualCompletado[elemento] = true;
          }
          // Si no está en la colección, no lo cambiamos (el usuario puede haberlo marcado manualmente)
        }
      }

      // Guardar estados manuales actualizados
      await _servicio.guardarEstadosManuales(catalogo.id, _manualCompletado);

      _actualizarProgreso(catalogo, monedas);
      _monedasFuture = _obtenerMonedasFuturo(catalogo.id);
      _progresoActual = resultado['coincidencias'] ?? 0;
      _totalPiezas = await _servicio
          .obtenerRelacionesPorCatalogo(catalogo.id)
          .then((r) => r.length);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensaje']),
            backgroundColor:
                resultado['completado'] == true ? Colors.green : Colors.orange,
          ),
        );
        setState(() => _sincronizando = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _sincronizando = false);
      }
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar catálogo'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este catálogo? '
              'Esta acción no se puede deshacer. Las piezas asociadas no se eliminarán.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _servicio.eliminarCatalogo(widget.catalogoId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Catálogo eliminado correctamente.'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _actualizarProgreso(
    Catalogo catalogo,
    List<Map<String, dynamic>> monedas,
  ) {
    if (catalogo.listaOficial == null || catalogo.listaOficial!.isEmpty) {
      if (mounted) setState(() => _progresoActual = 0);
      _servicio.actualizarProgreso(catalogo.id, 0, false);
      return;
    }

    final lista = catalogo.listaOficial!;
    final campoComparacion = catalogo.campoComparacion ?? 'anio';
    final valoresEnColeccion =
        monedas
            .map((m) => m[campoComparacion]?.toString())
            .where((v) => v != null)
            .toSet();

    int completados = 0;
    for (var elemento in lista) {
      final completadoManual = _manualCompletado[elemento] ?? false;
      final completadoAutomatico = valoresEnColeccion.contains(elemento);
      if (completadoManual || completadoAutomatico) completados++;
    }

    final total = lista.length;
    final completado = completados >= total;

    if (mounted) {
      setState(() => _progresoActual = completados);
    }

    // Guardar progreso y completado en Firestore
    _servicio.actualizarProgreso(catalogo.id, completados, completado);
  }
}
