import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'formulario_opcional.dart';
import 'pantalla_detalle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_auth.dart';
import 'pantalla_perfil.dart';
import 'servicio_auth.dart';
import 'pantalla_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Esperando acción del usuario (login o invitado)');
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    runApp(const ColeccionNumismaticaApp());
  } catch (e, stack) {
    print('Error en main: $e');
    print(stack);
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Error: $e')))));
  }
}

class ColeccionNumismaticaApp extends StatelessWidget {
  const ColeccionNumismaticaApp({super.key});
  // TEMA CLARO
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A2A4A), // Primario
      secondary: Color(0xFFC9A03D), // Dorado
      tertiary: Color(0xFFB95C3A), // Terracota (Acento)
      surface: Color(0xFFFFFFFF), // Superficie
      surfaceTint: Color(0xFFE8E4DE), // Superficie alt.
      background: Color(0xFFF0EDE8), // Fondo
      error: Color(0xFFC53030), // Error
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A2A4A), // Texto principal
      onSurfaceVariant: Color(0xFF718096), // Texto secundario
      onBackground: Color(0xFF1A2A4A),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1A2A4A),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1A2A4A),
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF1A2A4A)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFF1A2A4A).withOpacity(0.13), // Borde
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A2A4A),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A2A4A),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1A2A4A)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF718096)),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A2A4A),
      ),
    ),
  );

  // TEMA OSCURO
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFC9A03D), // Dorado (Primario en oscuro)
      secondary: Color(0xFF1E3260), // Azul secundario
      tertiary: Color(0xFFB95C3A), // Terracota (Acento)
      surface: Color(0xFF1A2A4A), // Superficie
      surfaceTint: Color(0xFF1E3260), // Superficie alt.
      background: Color(0xFF0E1824), // Fondo
      error: Color(0xFFC53030), // Error
      onPrimary: Color(0xFF0E1824), // Texto sobre primario (oscuro)
      onSecondary: Colors.white,
      onSurface: Color(0xFFF0EDE8), // Texto principal
      onSurfaceVariant: Color(0xFFA0AEC0), // Texto secundario
      onBackground: Color(0xFFF0EDE8),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1A2A4A),
      foregroundColor: Color(0xFFF0EDE8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Color(0xFF1A2A4A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFC9A03D),
        foregroundColor: const Color(0xFF0E1824),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFC9A03D)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1A2A4A),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFFF0EDE8).withOpacity(0.10), // Borde
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF0EDE8),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF0EDE8),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFF0EDE8)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFA0AEC0)),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFC9A03D),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final authService = ServicioAuth();
    return MaterialApp(
      title: 'Colección Numismática',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      //themeMode: ThemeMode.dark,
      //themeMode: ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: authService.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              // No hay usuario autenticado (ni anónimo) → mostrar login
              return const PantallaAuth();
            } else {
              // Hay usuario (anónimo o con email) → mostrar lista
              return const PantallaPrincipal();
            }
          } else {
            // Cargando
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
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
  String _tipoSeleccionado = 'moneda';
  List<Map<String, String>> _filteredMonedas = [];
  String _searchQuery = '';
  String? _filterTipo;
  int? _anioDesde; // null = sin límite inferior
  int? _anioHasta; // null = sin límite superior
  String _composicionQuery = '';
  String? _validarCampoObligatorio(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'El campo $nombreCampo es obligatorio';
    }
    return null;
  }

  String? _validarNumeroEntero(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'El campo $nombreCampo es obligatorio';
    }
    if (int.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }
    return null;
  }

  String? _validarCantidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es obligatoria';
    }
    final cantidad = int.tryParse(value);
    if (cantidad == null || cantidad <= 0) {
      return 'Ingresa una cantidad mayor a 0';
    }
    return null;
  }

  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _denominacionController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _anioDesdeController = TextEditingController();
  final TextEditingController _anioHastaController = TextEditingController();
  final TextEditingController _composicionQueryController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _paisController.dispose();
    _anioController.dispose();
    _denominacionController.dispose();
    _cantidadController.dispose();
    _searchController.dispose();
    _anioDesdeController.dispose();
    _anioHastaController.dispose();
    _composicionQueryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<Map<String, String>> _filtrarLista(
      List<Map<String, String>> listaCompleta,
    ) {
      List<Map<String, String>> resultado = List.from(listaCompleta);

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        resultado =
            resultado.where((moneda) {
              return moneda['denominacion']!.toLowerCase().contains(query) ||
                  moneda['pais']!.toLowerCase().contains(query) ||
                  moneda['anio']!.toLowerCase().contains(query);
            }).toList();
      }

      if (_filterTipo != null) {
        resultado =
            resultado.where((moneda) => moneda['tipo'] == _filterTipo).toList();
      }

      if (_anioDesde != null) {
        resultado =
            resultado.where((moneda) {
              final anio = int.tryParse(moneda['anio'] ?? '');
              return anio != null && anio >= _anioDesde!;
            }).toList();
      }
      if (_anioHasta != null) {
        resultado =
            resultado.where((moneda) {
              final anio = int.tryParse(moneda['anio'] ?? '');
              return anio != null && anio <= _anioHasta!;
            }).toList();
      }

      if (_composicionQuery.isNotEmpty) {
        final query = _composicionQuery.toLowerCase();
        resultado =
            resultado.where((moneda) {
              if (moneda['tipo'] != 'moneda') return false;
              final comp = moneda['composicion']?.toLowerCase() ?? '';
              return comp.contains(query);
            }).toList();
      }

      return resultado;
    }
  }

  void _refrescarFiltros() {
    setState(() {});
  }

  void _editarDesdeDetalle(Map<String, String> moneda) {
    _mostrarFormulario(monedaEditada: moneda);
  }

  List<Map<String, String>> _filtrarLista(
    List<Map<String, String>> listaCompleta,
  ) {
    List<Map<String, String>> resultado = List.from(listaCompleta);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      resultado =
          resultado.where((moneda) {
            return moneda['denominacion']!.toLowerCase().contains(query) ||
                moneda['pais']!.toLowerCase().contains(query) ||
                moneda['anio']!.toLowerCase().contains(query);
          }).toList();
    }

    if (_filterTipo != null) {
      resultado =
          resultado.where((moneda) => moneda['tipo'] == _filterTipo).toList();
    }

    if (_anioDesde != null) {
      resultado =
          resultado.where((moneda) {
            final anio = int.tryParse(moneda['anio'] ?? '');
            return anio != null && anio >= _anioDesde!;
          }).toList();
    }
    if (_anioHasta != null) {
      resultado =
          resultado.where((moneda) {
            final anio = int.tryParse(moneda['anio'] ?? '');
            return anio != null && anio <= _anioHasta!;
          }).toList();
    }

    if (_composicionQuery.isNotEmpty) {
      final query = _composicionQuery.toLowerCase();
      resultado =
          resultado.where((moneda) {
            if (moneda['tipo'] != 'moneda') return false;
            final comp = moneda['composicion']?.toLowerCase() ?? '';
            return comp.contains(query);
          }).toList();
    }

    return resultado;
  }

  // ===================== CONSTRUCTOR DE VISTA =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mi Colección Numismática'),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por país, denominación o año',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _refrescarFiltros();
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _refrescarFiltros();
                },
              ),
            ),
            // Filtros de tipo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Text('Mostrar:'),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filterTipo == null,
                    onSelected: (selected) {
                      setState(() {
                        _filterTipo = null;
                      });
                      _refrescarFiltros();
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Monedas'),
                    selected: _filterTipo == 'moneda',
                    onSelected: (selected) {
                      setState(() {
                        _filterTipo = selected ? 'moneda' : null;
                      });
                      _refrescarFiltros();
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Billetes'),
                    selected: _filterTipo == 'billete',
                    onSelected: (selected) {
                      setState(() {
                        _filterTipo = selected ? 'billete' : null;
                      });
                      _refrescarFiltros();
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            // Filtros avanzados (ExpansionTile)
            ExpansionTile(
              title: const Text('Filtros avanzados'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _anioDesdeController,
                          decoration: const InputDecoration(
                            labelText: 'Año desde',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _anioDesde =
                                value.isEmpty ? null : int.tryParse(value);
                            _refrescarFiltros();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _anioHastaController,
                          decoration: const InputDecoration(
                            labelText: 'Año hasta',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _anioHasta =
                                value.isEmpty ? null : int.tryParse(value);
                            _refrescarFiltros();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _composicionQueryController,
                    decoration: InputDecoration(
                      labelText: 'Composición (ej: oro, plata, bronce)',
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          _composicionQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _composicionQuery = '';
                                    _composicionQueryController.clear();
                                  });
                                  _refrescarFiltros();
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _composicionQuery = value ?? '';
                      });
                      _refrescarFiltros();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _anioDesdeController.clear();
                      _anioHastaController.clear();
                      _composicionQueryController.clear();
                      setState(() {
                        _anioDesde = null;
                        _anioHasta = null;
                        _composicionQuery = '';
                      });
                      _refrescarFiltros();
                    },
                    child: const Text('Limpiar filtros'),
                  ),
                ),
              ],
            ),
            // Lista con StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('monedas')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay monedas en tu colección.'),
                    );
                  }

                  // Convertir datos
                  final List<Map<String, String>> listaCompleta =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final moneda = Map<String, String>.from(data);
                        moneda['_id'] = doc.id;
                        return moneda;
                      }).toList();

                  final listaFiltrada = _filtrarLista(listaCompleta);

                  if (listaFiltrada.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay monedas que coincidan con los filtros.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final moneda = listaFiltrada[index];
                      final esMoneda = moneda['tipo'] == 'moneda';
                      return GestureDetector(
                        onTap: () {
                          final id = moneda['_id'];
                          if (id == null) return; // no navegar si no hay ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaDetalle(
                                monedaId: id,
                                monedaInicial: moneda,
                                onEditar: _editarDesdeDetalle,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    esMoneda
                                        ? Icons.monetization_on
                                        : Icons.attach_money,
                                    color: const Color(0xFFC9A03D),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        moneda['denominacion']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        '${moneda['pais']} - año ${moneda['anio']}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _mostrarFormulario(
                                          indice: index,
                                          monedaEditada: moneda,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final monedaAEliminar =
                                            listaFiltrada[index];
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null &&
                                            monedaAEliminar.containsKey(
                                              '_id',
                                            )) {
                                          await FirebaseFirestore.instance
                                              .collection('usuarios')
                                              .doc(user.uid)
                                              .collection('monedas')
                                              .doc(monedaAEliminar['_id'])
                                              .delete();
                                        }
                                        // No es necesario recargar, el StreamBuilder se actualiza solo
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  // ===================== FORMULARIO OBLIGATORIOS =====================
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
        String tipoLocal = _tipoSeleccionado;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nueva pieza'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TIPO DE PIEZA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'moneda', label: Text('Moneda')),
                          ButtonSegment(
                            value: 'billete',
                            label: Text('Billete'),
                          ),
                        ],
                        selected: {tipoLocal},
                        onSelectionChanged: (Set<String> selection) {
                          setStateDialog(() {
                            tipoLocal = selection.first;
                            _tipoSeleccionado = selection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.primary;
                            }
                            return Theme.of(context).colorScheme.surface;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.onPrimary;
                            }
                            return Theme.of(context).colorScheme.onSurface;
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _denominacionController,
                        decoration: const InputDecoration(
                          labelText: 'Denominación *',
                          hintText: 'Ej: 5 Pesos, 1 Real, ½ Crown...',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                _validarCampoObligatorio(value, 'denominación'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _paisController,
                        decoration: const InputDecoration(
                          labelText: 'País *',
                          hintText: 'Ej: España, México...',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => _validarCampoObligatorio(value, 'país'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _anioController,
                        decoration: const InputDecoration(
                          labelText: 'Año *',
                          hintText: '1957',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => _validarNumeroEntero(value, 'año'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cantidadController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad *',
                        ),
                        validator: (value) => _validarCantidad(value),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
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
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===================== FORMULARIO OPCIONAL Y GUARDADO =====================
  void _mostrarFormularioOpcional({
    required Map<String, String> datosObligatorios,
    int? indice,
    Map<String, String>? monedaEditada,
  }) async {
    print('=== _mostrarFormularioOpcional iniciado ===');
    String? idExistente;
    Map<String, String>? datosOpcionales;
    if (monedaEditada != null) {
      idExistente = monedaEditada['_id'];
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
        builder:
            (context) => FormularioOpcional(
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
      // Si estamos editando y el _id no está en monedaParaGuardar, lo añadimos
      if (indiceEdit != null &&
          idExistente != null &&
          !monedaParaGuardar.containsKey('_id')) {
        monedaParaGuardar['_id'] = idExistente;
        print('Se agregó _id a la moneda editada: $idExistente');
      }
      final user = FirebaseAuth.instance.currentUser;
      print('=== Resultado recibido, indiceEdit=$indiceEdit ===');

      if (idExistente != null) {
        // === EDITAR ===
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('monedas')
              .doc(idExistente)
              .update(monedaParaGuardar);
          print('✅ DOCUMENTO ACTUALIZADO EN FIRESTORE: $idExistente');
        } else {
          print('Error: usuario no autenticado');
        }
      } else {
        // === CREAR NUEVA ===
        if (user != null) {
          final docRef = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('monedas')
              .add(monedaParaGuardar);
          print('Moneda guardada en Firestore con id: ${docRef.id}');
        }
      }
    }
  }
}
