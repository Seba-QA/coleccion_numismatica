import 'dart:io';
import 'package:flutter/material.dart';

class DetalleMoneda extends StatefulWidget {
  final Map<String, String> moneda;

  const DetalleMoneda({super.key, required this.moneda});

  @override
  State<DetalleMoneda> createState() => _DetalleMonedaState();
}

class _DetalleMonedaState extends State<DetalleMoneda>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moneda = widget.moneda;
    final esMoneda = moneda['tipo'] == 'moneda';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(moneda['denominacion'] ?? 'Detalle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implementar edición desde detalle
              // Por ahora solo muestra un mensaje
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edición desde detalle (próximamente)'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // ← Alineación superior
              children: [
                _buildMiniatura(
                  '',
                  moneda['fotoAnverso'],
                  esMoneda,
                  circular: esMoneda,
                  expand: false,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moneda['denominacion'] ?? '',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${moneda['pais'] ?? ''} · año ${moneda['anio'] ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Físicas'),
              Tab(text: 'Adicional'),
            ],
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(moneda),
                _buildFisicasTab(moneda),
                _buildAdicionalTab(moneda),
                _buildFotosTab(moneda, esMoneda),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Widgets auxiliares ----------

  Widget _buildMiniatura(
    String titulo,
    String? ruta,
    bool esMoneda, {
    bool circular = false,
    bool expand = true,
  }) {
    // Definir alto y ancho según el contexto
    double alto;
    double ancho;

    if (circular) {
      // Si es circular, siempre cuadrado
      final double size = expand ? (esMoneda ? 120.0 : 80.0) : 80.0;
      alto = size;
      ancho = size;
    } else {
      // No circular: rectangular
      if (expand) {
        // En fila de miniaturas: alto fijo, ancho expandido
        alto = esMoneda ? 120.0 : 80.0;
        ancho = double.infinity;
      } else {
        // En cabecera: tamaños fijos diferenciados
        if (esMoneda) {
          alto = 120.0;
          ancho = 120.0; // cuadrado para moneda
        } else {
          alto = 80.0;
          ancho = 120.0; // rectangular para billete
        }
      }
    }

    // Construir la imagen
    Widget imagenWidget;
    if (ruta != null && ruta.isNotEmpty) {
      if (circular) {
        imagenWidget = ClipOval(
          child: Image.file(
            File(ruta),
            fit: BoxFit.cover,
            width: ancho,
            height: alto,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              );
            },
          ),
        );
      } else {
        imagenWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(ruta),
            fit: BoxFit.cover,
            width: ancho,
            height: alto,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              );
            },
          ),
        );
      }
    } else {
      imagenWidget = Center(
        child: Text(
          'Sin $titulo',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    // Contenedor con borde
    Widget contenedor = Container(
      height: alto,
      width: ancho,
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: circular ? null : BorderRadius.circular(8),
      ),
      child: imagenWidget,
    );

    // Si es circular, forzamos el tamaño con un SizedBox para evitar deformaciones
    if (circular) {
      contenedor = SizedBox(width: alto, height: alto, child: contenedor);
    }

    // Si expand es true, envolvemos en Expanded y añadimos el título
    if (expand) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (titulo.isNotEmpty) ...[
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Center(child: contenedor),
          ],
        ),
      );
    } else {
      // Para la cabecera: sin Expanded, tamaño fijo
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo.isNotEmpty) ...[
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
          ],
          contenedor,
        ],
      );
    }
  }

  Widget _buildCampo(String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              valor != null && valor.isNotEmpty ? valor : '—',
              textAlign: TextAlign.end,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Pestañas ----------

  Widget _buildGeneralTab(Map<String, String> moneda) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildTabla([
          _buildCampo('Denominación', moneda['denominacion']),
          _buildCampo('País', moneda['pais']),
          _buildCampo('Año', moneda['anio']),
          _buildCampo('Cantidad', moneda['cantidad']),
        ]),
      ),
    );
  }

  Widget _buildFisicasTab(Map<String, String> moneda) {
    final esMoneda = moneda['tipo'] == 'moneda';
    if (!esMoneda) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay características físicas para billetes'),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildTabla([
          _buildCampo('Composición', moneda['composicion']),
          _buildCampo('Peso (g)', moneda['peso']),
          _buildCampo('Diámetro (mm)', moneda['diametro']),
        ]),
      ),
    );
  }

  Widget _buildAdicionalTab(Map<String, String> moneda) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampo('Casa de moneda', moneda['marcaCeca']),
          const SizedBox(height: 24),
          const Text(
            'Notas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFC9A03D),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Espacio para notas (próximamente)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotosTab(Map<String, String> moneda, bool esMoneda) {
    final anverso = moneda['fotoAnverso'];
    final reverso = moneda['fotoReverso'];

    if ((anverso == null || anverso.isEmpty) &&
        (reverso == null || reverso.isEmpty)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay fotos disponibles'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (anverso != null && anverso.isNotEmpty)
            _buildFotoGrande('Anverso', anverso, esMoneda),
          const SizedBox(height: 16),
          if (reverso != null && reverso.isNotEmpty)
            _buildFotoGrande('Reverso', reverso, esMoneda),
        ],
      ),
    );
  }

  Widget _buildFotoGrande(String titulo, String ruta, bool esMoneda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(ruta),
            height: esMoneda ? 300 : 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: esMoneda ? 300 : 200,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(child: Text('Error al cargar la imagen')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabla(List<Widget> campos) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            campos.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < campos.length - 1)
                    Container(
                      height: 1.0,
                      color: borderColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
