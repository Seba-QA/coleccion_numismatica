import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'formulario_opcional.dart';
import 'detalle_moneda.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  runApp(const ColeccionNumismaticaApp());
}

class ColeccionNumismaticaApp extends StatelessWidget {
  const ColeccionNumismaticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colección Numismática',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ListaMonedas(),
    );
  }
}

class ListaMonedas extends StatefulWidget {
  const ListaMonedas({super.key});

  @override
  State<ListaMonedas> createState() => _ListaMonedasState();
}

class _ListaMonedasState extends State<ListaMonedas> {
  late Box _monedasBox;
  List<Map<String, String>> _monedas = [];

  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _denominacionController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  
  String _tipoSeleccionado = 'moneda'; // NUEVO: para moneda o billete

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  void _cargarMonedas() async {
    _monedasBox = await Hive.openBox('monedas');
    print('Box abierto, contiene: ${_monedasBox.length} monedas');
    _recargarLista();
  }

  void _recargarLista() {
    final List<Map<String, String>> lista = [];
    for (var i = 0; i < _monedasBox.length; i++) {
      final raw = _monedasBox.getAt(i);
      if (raw != null) {
        final moneda = Map<String, String>.from(raw as Map);
        lista.add(moneda);
      }
    }
    setState(() {
      _monedas = lista;
    });
    print('Lista recargada: ${_monedas.length} monedas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección Numismática'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _monedas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_bitcoin, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay monedas o billetes', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Toca el botón + para agregar', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _monedas.length,
              itemBuilder: (context, index) {
                final moneda = _monedas[index];
                final esMoneda = moneda['tipo'] == 'moneda';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(esMoneda ? Icons.monetization_on : Icons.attach_money, color: Colors.amber),
                    title: Text(moneda['denominacion']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${moneda['pais']} - ${moneda['anio']} - ${esMoneda ? "Moneda" : "Billete"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _mostrarFormulario(indice: index, monedaEditada: moneda);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _monedasBox.deleteAt(index);
                            _recargarLista();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetalleMoneda(moneda: moneda)),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormulario({int? indice, Map<String, String>? monedaEditada}) {
    if (monedaEditada != null) {
      _denominacionController.text = monedaEditada['denominacion'] ?? '';
      _paisController.text = monedaEditada['pais'] ?? '';
      _anioController.text = monedaEditada['anio'] ?? '';
      _cantidadController.text = monedaEditada['cantidad'] ?? '1';
      _tipoSeleccionado = monedaEditada['tipo'] ?? 'moneda';
    } else {
      _denominacionController.clear();
      _paisController.clear();
      _anioController.clear();
      _cantidadController.clear();
      _tipoSeleccionado = 'moneda';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Variable local para el tipo dentro del diálogo
        String tipoLocal = _tipoSeleccionado;
        
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Datos obligatorios'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selector de tipo (Moneda / Billete)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Moneda'),
                            value: 'moneda',
                            groupValue: tipoLocal,
                            onChanged: (value) {
                              setStateDialog(() {
                                tipoLocal = value!;
                                _tipoSeleccionado = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Billete'),
                            value: 'billete',
                            groupValue: tipoLocal,
                            onChanged: (value) {
                              setStateDialog(() {
                                tipoLocal = value!;
                                _tipoSeleccionado = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _denominacionController, decoration: const InputDecoration(labelText: 'Denominación *'),),
                    const SizedBox(height: 12),
                    TextField(controller: _paisController, decoration: const InputDecoration(labelText: 'País *'),),
                    const SizedBox(height: 12),
                    TextField(controller: _anioController, decoration: const InputDecoration(labelText: 'Año *'), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: _cantidadController, decoration: const InputDecoration(labelText: 'Cantidad *'), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (_denominacionController.text.isNotEmpty &&
                        _paisController.text.isNotEmpty &&
                        _anioController.text.isNotEmpty &&
                        _cantidadController.text.isNotEmpty) {
                      final datosObligatorios = {
                        'denominacion': _denominacionController.text,
                        'pais': _paisController.text,
                        'anio': _anioController.text,
                        'cantidad': _cantidadController.text,
                        'tipo': tipoLocal,
                      };
                      Navigator.pop(context);
                      _mostrarFormularioOpcional(
                        datosObligatorios: datosObligatorios,
                        indice: indice,
                        monedaEditada: monedaEditada,
                      );
                    }
                  },
                  child: const Text('Siguiente →'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarFormularioOpcional({
    required Map<String, String> datosObligatorios,
    int? indice,
    Map<String, String>? monedaEditada,
  }) async {
    Map<String, String>? datosOpcionales;
    if (monedaEditada != null) {
      datosOpcionales = {
        'composicion': monedaEditada['composicion'] ?? '',
        'peso': monedaEditada['peso'] ?? '',
        'diametro': monedaEditada['diametro'] ?? '',
        'anioGregoriano': monedaEditada['anioGregoriano'] ?? '',
        'marcaCeca': monedaEditada['marcaCeca'] ?? '',
        'fotoAnverso': monedaEditada['fotoAnverso'] ?? '',
        'fotoReverso': monedaEditada['fotoReverso'] ?? '',
      };
    }

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioOpcional(
          datosObligatorios: datosObligatorios,
          datosOpcionalesExistentes: datosOpcionales,
          indice: indice,
        ),
      ),
    );

    if (resultado != null) {
      final monedaCompleta = resultado['moneda'] as Map<String, String>;
      final indiceEdit = resultado['indice'] as int?;

      final monedaParaGuardar = Map<String, String>.from(monedaCompleta);

      if (indiceEdit != null) {
        await _monedasBox.putAt(indiceEdit, monedaParaGuardar);
      } else {
        await _monedasBox.add(monedaParaGuardar);
      }

      _recargarLista();
    }
  }
}
