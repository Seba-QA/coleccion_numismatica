import 'package:flutter/material.dart';
import 'selector_imagen.dart';

class FormularioOpcional extends StatefulWidget {
  final Map<String, String> datosObligatorios;
  final Map<String, String>? datosOpcionalesExistentes;
  final int? indice;

  const FormularioOpcional({
    super.key,
    required this.datosObligatorios,
    this.datosOpcionalesExistentes,
    this.indice,
  });

  @override
  State<FormularioOpcional> createState() => _FormularioOpcionalState();
}

class _FormularioOpcionalState extends State<FormularioOpcional> {
  final _composicionController = TextEditingController();
  final _pesoController = TextEditingController();
  final _diametroController = TextEditingController();
  final _anioGregorianoController = TextEditingController();
  final _marcaCecaController = TextEditingController();

  String? _rutaAnverso;
  String? _rutaReverso;

  @override
  void initState() {
    super.initState();
    if (widget.datosOpcionalesExistentes != null) {
      _composicionController.text =
          widget.datosOpcionalesExistentes!['composicion'] ?? '';
      _pesoController.text = widget.datosOpcionalesExistentes!['peso'] ?? '';
      _diametroController.text =
          widget.datosOpcionalesExistentes!['diametro'] ?? '';
      _anioGregorianoController.text =
          widget.datosOpcionalesExistentes!['anioGregoriano'] ?? '';
      _marcaCecaController.text =
          widget.datosOpcionalesExistentes!['marcaCeca'] ?? '';
      _rutaAnverso = widget.datosOpcionalesExistentes!['fotoAnverso'];
      _rutaReverso = widget.datosOpcionalesExistentes!['fotoReverso'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = widget.datosObligatorios['tipo'] ?? 'moneda';
    final esMoneda = tipo == 'moneda';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos opcionales',
            ),
            Text(
              'Puedes completarlo más adelante',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ]
        ),
        //const Text('Datos opcionales')
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: SelectorImagen(
                      titulo: 'Foto anverso',
                      tipo: tipo,
                      rutaImagenActual: _rutaAnverso,
                      onImagenSeleccionada: (ruta) {
                        setState(() {
                          _rutaAnverso = ruta;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SelectorImagen(
                      titulo: 'Foto reverso',
                      tipo: tipo,
                      rutaImagenActual: _rutaReverso,
                      onImagenSeleccionada: (ruta) {
                        setState(() {
                          _rutaReverso = ruta;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Campos específicos para moneda
              if (esMoneda) ...[
                const Text(
                  'Composición',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                TextField(
                  controller: _composicionController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Oro, Plata, Bronce',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peso (g)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _pesoController,
                            decoration: const InputDecoration(
                              hintText: 'Ej: 18.05',
                              border: OutlineInputBorder(),
                              suffixText: 'g',  // ← fijo
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diámetro (mm)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _diametroController,
                            decoration: const InputDecoration(
                              hintText: 'Ej: 34.5',
                              border: OutlineInputBorder(),
                              suffixText: 'mm', // ← fijo
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Campos específicos para billete
                const Text('Características de billete'),
                const SizedBox(height: 16),
                // Por ahora solo un placeholder, luego puedes agregar más campos
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF1A2A4A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Próximamente: dimensiones, watermark, etc.',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Año gregoriano',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              TextField(
                controller: _anioGregorianoController,
                decoration: const InputDecoration(
                  hintText: 'Si es moneda antigua',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Marca de ceca',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              TextField(
                controller: _marcaCecaController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Mo, S, So',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarCompleto,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'GUARDAR ${esMoneda ? 'MONEDA' : 'BILLETE'}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarCompleto() {
    final monedaCompleta = {
      ...widget.datosObligatorios,
      'composicion': _composicionController.text,
      'peso': _pesoController.text,
      'diametro': _diametroController.text,
      'anioGregoriano': _anioGregorianoController.text,
      'marcaCeca': _marcaCecaController.text,
      'fotoAnverso': _rutaAnverso ?? '',
      'fotoReverso': _rutaReverso ?? '',
    };

    Navigator.pop(context, {'moneda': monedaCompleta, 'indice': widget.indice});
  }
}
