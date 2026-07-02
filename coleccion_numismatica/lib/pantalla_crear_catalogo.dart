import 'package:flutter/material.dart';
import 'servicio_catalogos.dart';

class PantallaCrearCatalogo extends StatefulWidget {
  const PantallaCrearCatalogo({super.key});

  @override
  State<PantallaCrearCatalogo> createState() => _PantallaCrearCatalogoState();
}

class _PantallaCrearCatalogoState extends State<PantallaCrearCatalogo> {
  final ServicioCatalogos _servicio = ServicioCatalogos();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _elementoController = TextEditingController();

  final List<String> _listaOficial = [];
  bool _tieneListaOficial = false;
  String? _campoComparacion;
  bool _cargando = false;

  final List<String> _opcionesComparacion = ['anio', 'pais', 'denominacion'];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _elementoController.dispose();
    super.dispose();
  }

  void _agregarElemento() {
    final texto = _elementoController.text.trim();
    if (texto.isEmpty) return;
    if (_listaOficial.contains(texto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este elemento ya está en la lista.')),
      );
      return;
    }
    setState(() {
      _listaOficial.add(texto);
      _elementoController.clear();
    });
  }

  String _generarTag(String nombre) {
    final Map<String, String> acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'a',
      'É': 'e',
      'Í': 'i',
      'Ó': 'o',
      'Ú': 'u',
    };
    return nombre
        .toLowerCase()
        .split('')
        .map((char) => acentos[char] ?? char)
        .join()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim()
        .replaceAll(' ', '_');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tieneListaOficial && _listaOficial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La lista oficial no puede estar vacía. Agrega al menos un elemento.',
          ),
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      await _servicio.crearCatalogo(
        nombre: _nombreController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
        tag: _generarTag(_nombreController.text.trim()),
        listaOficial: _tieneListaOficial ? _listaOficial : null,
        campoComparacion: _tieneListaOficial ? _campoComparacion : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catálogo creado correctamente.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo catálogo'),
        actions: [
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _guardar,
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del catálogo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Switch: Lista oficial
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lista oficial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Switch(
                      value: _tieneListaOficial,
                      onChanged: (value) {
                        debugPrint('Switch Lista oficial cambiado a: $value');
                        setState(() {
                          _tieneListaOficial = value;
                          if (!value) {
                            _campoComparacion = null;
                            _listaOficial.clear();
                            _elementoController.clear();
                          }
                        });
                        debugPrint(
                          'Estado actualizado -> _tieneListaOficial: $_tieneListaOficial',
                        );
                      },
                    ),
                  ],
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: Builder(
                    builder: (context) {
                      debugPrint(
                        'Construyendo bloque de lista oficial. Estado: $_tieneListaOficial',
                      );
                      return _tieneListaOficial
                          ? SizedBox(
                            key: const ValueKey('lista-oficial-activa'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _elementoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Agregar elemento',
                                          hintText:
                                              'Ej: 1990, Virginia, ½ Crown...',
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (_) => _agregarElemento(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _agregarElemento,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 14,
                                          ),
                                        ),
                                        child: const Text('+'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                if (_listaOficial.isNotEmpty)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children:
                                          _listaOficial.asMap().entries.map((
                                            entry,
                                          ) {
                                            final index = entry.key;
                                            final elemento = entry.value;
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              dense: true,
                                              title: Text(elemento),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _listaOficial.removeAt(index);
                                                  });
                                                },
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'Aún no has agregado elementos a la lista oficial.',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  value: _campoComparacion,
                                  decoration: const InputDecoration(
                                    labelText: 'Campo de comparación *',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      _opcionesComparacion.map((opcion) {
                                        return DropdownMenuItem(
                                          value: opcion,
                                          child: Text(
                                            opcion[0].toUpperCase() +
                                                opcion.substring(1),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _campoComparacion = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (_tieneListaOficial &&
                                        (value == null || value.isEmpty)) {
                                      return 'Debes seleccionar un campo de comparación.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(
                              key: ValueKey('lista-oficial-inactiva'),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
