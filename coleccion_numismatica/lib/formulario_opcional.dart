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
      _composicionController.text = widget.datosOpcionalesExistentes!['composicion'] ?? '';
      _pesoController.text = widget.datosOpcionalesExistentes!['peso'] ?? '';
      _diametroController.text = widget.datosOpcionalesExistentes!['diametro'] ?? '';
      _anioGregorianoController.text = widget.datosOpcionalesExistentes!['anioGregoriano'] ?? '';
      _marcaCecaController.text = widget.datosOpcionalesExistentes!['marcaCeca'] ?? '';
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
        title: const Text('Datos opcionales'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SelectorImagen(
              titulo: 'Foto anverso',
              tipo: tipo,
              rutaImagenActual: _rutaAnverso,
              onImagenSeleccionada: (ruta) {
                setState(() {
                  _rutaAnverso = ruta;
                });
              },
            ),
            const SizedBox(height: 16),
            SelectorImagen(
              titulo: 'Foto reverso',
              tipo: tipo,
              rutaImagenActual: _rutaReverso,
              onImagenSeleccionada: (ruta) {
                setState(() {
                  _rutaReverso = ruta;
                });
              },
            ),
            const SizedBox(height: 16),
            // Campos específicos para moneda
            if (esMoneda) ...[
              TextField(
                controller: _composicionController,
                decoration: const InputDecoration(
                  labelText: 'Composición',
                  hintText: 'Ej: Oro, Plata, Bronce',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso (g)',
                  hintText: 'Ej: 12.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _diametroController,
                decoration: const InputDecoration(
                  labelText: 'Diámetro (mm)',
                  hintText: 'Ej: 23',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              // Campos específicos para billete
              const Text('Características de billete'),
              const SizedBox(height: 16),
              // Por ahora solo un placeholder, luego puedes agregar más campos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Próximamente: dimensiones, watermark, etc.'),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _anioGregorianoController,
              decoration: const InputDecoration(
                labelText: 'Año gregoriano',
                hintText: 'Si es moneda antigua',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _marcaCecaController,
              decoration: const InputDecoration(
                labelText: 'Marca de ceca',
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
              child: Text('GUARDAR ${esMoneda ? 'MONEDA' : 'BILLETE'} COMPLETO'),
            ),
          ],
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

    Navigator.pop(context, {
      'moneda': monedaCompleta,
      'indice': widget.indice,
    });
  }
}