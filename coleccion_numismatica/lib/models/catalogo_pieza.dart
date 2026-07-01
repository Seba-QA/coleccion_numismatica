import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogoPieza {
  final String id; // clave compuesta: monedaId_catalogoId
  final String monedaId;
  final String catalogoId;
  final DateTime fechaAgregada;
  final bool eliminado;

  CatalogoPieza({
    required this.id,
    required this.monedaId,
    required this.catalogoId,
    required this.fechaAgregada,
    this.eliminado = false,
  });

  factory CatalogoPieza.fromFirestore(Map<String, dynamic> data, String id) {
    return CatalogoPieza(
      id: id,
      monedaId: data['monedaId'] ?? '',
      catalogoId: data['catalogoId'] ?? '',
      fechaAgregada: (data['fechaAgregada'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eliminado: data['eliminado'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'monedaId': monedaId,
      'catalogoId': catalogoId,
      'fechaAgregada': Timestamp.fromDate(fechaAgregada),
      'eliminado': eliminado,
    };
  }
}