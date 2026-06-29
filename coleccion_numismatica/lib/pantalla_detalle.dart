import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaDetalle extends StatefulWidget {
  final String monedaId;
  final Map<String, String>? monedaInicial;
  final void Function(Map<String, String>)? onEditar;

  const PantallaDetalle({
    super.key,
    required this.monedaId,
    this.monedaInicial,
    this.onEditar,
  });

  @override
  State<PantallaDetalle> createState() => _PantallaDetalleState();
}

class _PantallaDetalleState extends State<PantallaDetalle>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------- Contenido principal (con la moneda ya cargada) ----------
  Widget _buildContent(BuildContext context, Map<String, String> moneda) {
    final esMoneda = moneda['tipo'] == 'moneda';
    final colorScheme = Theme.of(context).colorScheme;
    print('📦 _buildContent llamado con moneda: ${moneda['denominacion']}');
    return Column(
      children: [
        // Cabecera: foto + denominación + país/año
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          tabs: const [Tab(text: 'General'), Tab(text: 'Físicas')],
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
    );
  }

  // ---------- Widgets auxiliares (igual que antes, sin cambios) ----------

  Widget _buildMiniatura(
    String titulo,
    String? ruta,
    bool esMoneda, {
    bool circular = false,
    bool expand = true,
  }) {
    // ... (tu código existente, sin cambios)
    // Para no alargar, dejo el mismo código que tenías
    double alto;
    double ancho;

    if (circular) {
      final double size = expand ? (esMoneda ? 120.0 : 80.0) : 80.0;
      alto = size;
      ancho = size;
    } else {
      if (expand) {
        alto = esMoneda ? 120.0 : 80.0;
        ancho = double.infinity;
      } else {
        if (esMoneda) {
          alto = 120.0;
          ancho = 120.0;
        } else {
          alto = 80.0;
          ancho = 120.0;
        }
      }
    }

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
                  'Sin imagen',
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
                  'Sin imagen',
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
          'Sin imagen',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

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

    if (circular) {
      contenedor = SizedBox(width: alto, height: alto, child: contenedor);
    }

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

  // ---------- Pestañas (iguales, sin cambios) ----------

  Widget _buildGeneralTab(Map<String, String> moneda) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildTabla([
          _buildCampo('Tipo', moneda['tipo']),
          _buildCampo('Denominación', moneda['denominacion']),
          _buildCampo('País', moneda['pais']),
          _buildCampo('Año', moneda['anio']),
          _buildCampo('Año Gregoriano', moneda['anioGregoriano']),
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
                child: const Center(child: Text('Sin imagen')),
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

  // ---------- BUILD PRINCIPAL (con StreamBuilder) ----------
  String _lastUpdate = '';
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }
    print('📌 PantallaDetalle construida con monedaId: ${widget.monedaId}');
    final stream =
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('monedas')
            .doc(widget.monedaId)
            .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        print(
          '🔄 StreamBuilder ejecutado. snapshot: ${snapshot.connectionState}',
        );
        // Determinar la moneda a mostrar (inicial o desde Firestore)
        Map<String, String>? moneda;
        if (snapshot.connectionState == ConnectionState.waiting) {
          moneda = widget.monedaInicial;
        } else if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final m = Map<String, String>.from(data);
          m['_id'] = snapshot.data!.id;
          moneda = m;
        }

        if (moneda == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(moneda!['denominacion'] ?? 'Detalle'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  if (widget.onEditar != null) {
                    widget.onEditar!(moneda!);
                    // No cerramos el detalle, el diálogo se abre sobre él
                  }
                },
              ),
            ],
          ),
          body: _buildContent(context, moneda!),
        );
      },
    );
  }
}
