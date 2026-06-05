import 'dart:io';
import 'package:flutter/material.dart';

class DetalleMoneda extends StatelessWidget {
  final Map<String, String> moneda;

  const DetalleMoneda({super.key, required this.moneda});

  @override
  Widget build(BuildContext context) {
    final esMoneda = moneda['tipo'] == 'moneda';

    return Scaffold(
      appBar: AppBar(
        title: Text(moneda['denominacion'] ?? 'Detalle'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccion('Fotos', [
              _buildFoto('Anverso', moneda['fotoAnverso'], esMoneda),
              const SizedBox(height: 8),
              _buildFoto('Reverso', moneda['fotoReverso'], esMoneda),
            ]),
            const SizedBox(height: 24),
            _buildSeccion('Información general', [
              _buildCampo('Tipo', esMoneda ? 'Moneda' : 'Billete'),
              _buildCampo('Denominación', moneda['denominacion']),
              _buildCampo('País', moneda['pais']),
              _buildCampo('Año', moneda['anio']),
              _buildCampo('Cantidad', moneda['cantidad']),
            ]),
            if (esMoneda) ...[
              const SizedBox(height: 24),
              _buildSeccion('Características físicas', [
                _buildCampo('Composición', moneda['composicion']),
                _buildCampo('Peso (g)', moneda['peso']),
                _buildCampo('Diámetro (mm)', moneda['diametro']),
              ]),
            ],
            const SizedBox(height: 24),
            _buildSeccion('Información adicional', [
              _buildCampo('Año gregoriano', moneda['anioGregoriano']),
              _buildCampo('Marca de ceca', moneda['marcaCeca']),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> campos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...campos,
      ],
    );
  }

  Widget _buildCampo(String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor != null && valor.isNotEmpty ? valor : '—',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoto(String titulo, String? ruta, bool esMoneda) {
    if (ruta == null || ruta.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 120,
              child: Text('', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const Expanded(child: Text('—')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(ruta),
              height: esMoneda ? 200 : 120,
              width: esMoneda ? 200 : double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
