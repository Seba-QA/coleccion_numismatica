import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'servicio_catalogos.dart';
import 'models/catalogo.dart';
import 'pantalla_crear_catalogo.dart';
import 'pantalla_detalle_catalogo.dart';

class PantallaCatalogos extends StatefulWidget {
  const PantallaCatalogos({super.key});

  @override
  State<PantallaCatalogos> createState() => _PantallaCatalogosState();
}

class _PantallaCatalogosState extends State<PantallaCatalogos> {
  final ServicioCatalogos _servicio = ServicioCatalogos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Catalogo>>(
        stream: _servicio.obtenerCatalogos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes catálogos aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer catálogo con el botón +',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final catalogos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: catalogos.length,
            itemBuilder: (context, index) {
              final catalogo = catalogos[index];
              return _buildCatalogoCard(catalogo);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaCrearCatalogo()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCatalogoCard(Catalogo catalogo) {
    final tieneLista =
        catalogo.listaOficial != null && catalogo.listaOficial!.isNotEmpty;
    final total = tieneLista ? catalogo.listaOficial!.length : 0;
    final progreso = catalogo.progreso ?? 0;
    final completado = catalogo.completado;

    Color estadoColor;
    if (completado) {
      estadoColor = Colors.green;
    } else if (tieneLista && progreso > 0) {
      estadoColor = Colors.orange;
    } else {
      estadoColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: estadoColor, width: 2),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaDetalleCatalogo(catalogoId: catalogo.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder, color: estadoColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      catalogo.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (catalogo.descripcion != null &&
                  catalogo.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 36),
                  child: Text(
                    catalogo.descripcion!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tieneLista
                              ? '$progreso / $total completados'
                              : '${_contarPiezas(catalogo)} piezas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        if (completado)
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Completado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (tieneLista)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : progreso / total,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completado ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _contarPiezas(Catalogo catalogo) {
    // Por ahora dummy, se puede implementar más adelante
    return 0;
  }
}