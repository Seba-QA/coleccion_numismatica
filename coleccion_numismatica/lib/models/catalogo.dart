import 'package:cloud_firestore/cloud_firestore.dart';

class Catalogo {
  final String id;
  final String nombre;
  final String? descripcion;
  final String tag;
  final String usuarioId;
  final DateTime fechaCreacion;
  final List<String>? listaOficial;
  final String? campoComparacion;
  final bool completado;

  Catalogo({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tag,
    required this.usuarioId,
    required this.fechaCreacion,
    this.listaOficial,
    this.campoComparacion,
    this.completado = false,
  });

  factory Catalogo.fromFirestore(Map<String, dynamic> data, String id) {
    return Catalogo(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'],
      tag: data['tag'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      listaOficial: data['listaOficial'] != null ? List<String>.from(data['listaOficial']) : null,
      campoComparacion: data['campoComparacion'],
      completado: data['completado'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tag': tag,
      'usuarioId': usuarioId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'listaOficial': listaOficial,
      'campoComparacion': campoComparacion,
      'completado': completado,
    };
  }
}