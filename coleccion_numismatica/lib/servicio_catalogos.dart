import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/catalogo.dart';
import 'models/catalogo_pieza.dart';

class ServicioCatalogos {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ---------- CATÁLOGOS ----------

  // Stream de todos los catálogos del usuario
  Stream<List<Catalogo>> obtenerCatalogos() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('catalogos')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Catalogo.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Obtener un catálogo por ID
  Future<Catalogo?> obtenerCatalogoPorId(String catalogoId) async {
    if (_userId == null) return null;
    final doc = await _firestore.collection('catalogos').doc(catalogoId).get();
    if (doc.exists) {
      return Catalogo.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Crear un nuevo catálogo
  Future<Catalogo> crearCatalogo({
    required String nombre,
    String? descripcion,
    required String tag,
    List<String>? listaOficial,
    String? campoComparacion,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    // Verificar que el tag sea único
    final tagQuery =
        await _firestore
            .collection('catalogos')
            .where('usuarioId', isEqualTo: _userId)
            .where('tag', isEqualTo: tag)
            .get();

    if (tagQuery.docs.isNotEmpty) {
      throw Exception('Ya existe un catálogo con este tag. Elige otro nombre.');
    }

    final nuevoCatalogo = Catalogo(
      id: '', // se asignará en Firestore
      nombre: nombre,
      descripcion: descripcion,
      tag: tag,
      usuarioId: _userId!,
      fechaCreacion: DateTime.now(),
      listaOficial: listaOficial,
      campoComparacion: campoComparacion,
      completado: false,
    );

    final docRef = await _firestore
        .collection('catalogos')
        .add(nuevoCatalogo.toFirestore());

    return Catalogo.fromFirestore((await docRef.get()).data()!, docRef.id);
  }

  // Eliminar un catálogo (y sus relaciones en cascada)
  Future<void> eliminarCatalogo(String catalogoId) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    // Eliminar relaciones
    final relaciones =
        await _firestore
            .collection('catalogo_piezas')
            .where('catalogoId', isEqualTo: catalogoId)
            .get();

    for (var doc in relaciones.docs) {
      await doc.reference.delete();
    }

    // Eliminar el catálogo
    await _firestore.collection('catalogos').doc(catalogoId).delete();
  }

  // ---------- RELACIONES ----------

  // Obtener las piezas asociadas a un catálogo (activas)
  Future<List<CatalogoPieza>> obtenerRelacionesPorCatalogo(
    String catalogoId,
  ) async {
    if (_userId == null) return [];
    final snapshot =
        await _firestore
            .collection('catalogo_piezas')
            .where('catalogoId', isEqualTo: catalogoId)
            .where('eliminado', isEqualTo: false)
            .get();

    return snapshot.docs.map((doc) {
      return CatalogoPieza.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  // Crear o reactivar una relación
  Future<void> asignarTag({
    required String monedaId,
    required String catalogoId,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    final id = '${monedaId}_${catalogoId}';
    final docRef = _firestore.collection('catalogo_piezas').doc(id);

    final doc = await docRef.get();

    if (doc.exists) {
      // Reactivar si estaba eliminado
      await docRef.update({
        'eliminado': false,
        'fechaAgregada': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      // Crear nueva relación
      await docRef.set({
        'monedaId': monedaId,
        'catalogoId': catalogoId,
        'fechaAgregada': Timestamp.fromDate(DateTime.now()),
        'eliminado': false,
      });
    }
  }

  // Eliminar una relación (lógico)
  Future<void> quitarTag({
    required String monedaId,
    required String catalogoId,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    final id = '${monedaId}_${catalogoId}';
    await _firestore.collection('catalogo_piezas').doc(id).update({
      'eliminado': true,
    });
  }

  // Sincronizar catálogo (auto-tachar)
  Future<Map<String, dynamic>> sincronizarCatalogo(String catalogoId) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    // Obtener el catálogo
    final catalogo = await obtenerCatalogoPorId(catalogoId);
    if (catalogo == null) throw Exception('Catálogo no encontrado');

    // Si no tiene lista oficial, no hay sincronización que hacer
    if (catalogo.listaOficial == null || catalogo.listaOficial!.isEmpty) {
      return {
        'mensaje': 'Este catálogo no tiene lista oficial.',
        'coincidencias': 0,
        'total': 0,
      };
    }

    // Obtener relaciones activas
    final relaciones = await obtenerRelacionesPorCatalogo(catalogoId);
    final monedaIds = relaciones.map((r) => r.monedaId).toList();

    if (monedaIds.isEmpty) {
      return {
        'mensaje': 'No hay piezas asociadas a este catálogo.',
        'coincidencias': 0,
        'total': catalogo.listaOficial!.length,
      };
    }

    // Obtener las monedas (usando whereIn con hasta 30 IDs, dividir en lotes si es necesario)
    // Por simplicidad, asumimos que son menos de 30
    final monedasSnapshot =
        await _firestore
            .collection('usuarios')
            .doc(_userId)
            .collection('monedas')
            .where(FieldPath.documentId, whereIn: monedaIds)
            .get();

    final monedas =
        monedasSnapshot.docs.map((doc) {
          final data = doc.data();
          data['_id'] = doc.id;
          return data;
        }).toList();

    // Contar coincidencias según campoComparacion
    final campo = catalogo.campoComparacion ?? 'anio';
    final listaOficial = catalogo.listaOficial!;
    final Set<String> valoresEncontrados = {};

    for (var moneda in monedas) {
      final valor = moneda[campo]?.toString();
      if (valor != null && listaOficial.contains(valor)) {
        valoresEncontrados.add(valor);
      }
    }

    final coincidencias = valoresEncontrados.length;
    final total = listaOficial.length;
    final completado = coincidencias >= total;

    // Actualizar el catálogo
    await _firestore.collection('catalogos').doc(catalogoId).update({
      'completado': completado,
    });

    return {
      'mensaje': 'Se encontraron $coincidencias coincidencias de $total.',
      'coincidencias': coincidencias,
      'total': total,
      'completado': completado,
    };
  }

  // Guardar los estados manuales de un catálogo
  Future<void> guardarEstadosManuales(
    String catalogoId,
    Map<String, bool> estados,
  ) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    // Guardar estados manuales y recalcular si el catálogo está completado.
    final catalogoDocRef = _firestore.collection('catalogos').doc(catalogoId);
    final catalogoSnapshot = await catalogoDocRef.get();
    if (!catalogoSnapshot.exists) {
      // Si no existe, sólo guardamos los estados (esto usualmente no debería pasar)
      await catalogoDocRef.update({'estadosManuales': estados});
      return;
    }

    final catalogoData = catalogoSnapshot.data();
    final listaOficial =
        (catalogoData != null && catalogoData['listaOficial'] != null)
            ? List<String>.from(catalogoData['listaOficial'])
            : null;
    final campoComparacion =
        (catalogoData != null && catalogoData['campoComparacion'] != null)
            ? catalogoData['campoComparacion'].toString()
            : 'anio';

    bool completado = false;

    if (listaOficial == null || listaOficial.isEmpty) {
      // No hay lista oficial: no está completado por definición
      completado = false;
    } else {
      // Obtener relaciones activas para este catálogo y consultar las monedas del usuario
      final relaciones = await obtenerRelacionesPorCatalogo(catalogoId);
      final monedaIds = relaciones.map((r) => r.monedaId).toList();

      final Set<String> valoresEnColeccion = {};
      // Consultar monedas en lotes
      for (var i = 0; i < monedaIds.length; i += 10) {
        final batch = monedaIds.skip(i).take(10).toList();
        final snapshot =
            await _firestore
                .collection('usuarios')
                .doc(_userId)
                .collection('monedas')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final valor = data[campoComparacion]?.toString();
          if (valor != null) valoresEnColeccion.add(valor);
        }
      }

      // Calcular si cada elemento de la lista oficial está completo (manual o automático)
      bool todos = true;
      for (var elemento in listaOficial) {
        final manual = estados[elemento] == true;
        final automatico = valoresEnColeccion.contains(elemento);
        if (!(manual || automatico)) {
          todos = false;
          break;
        }
      }
      completado = todos;
    }

    // Actualizar documento con estados y campo completado
    await catalogoDocRef.update({
      'estadosManuales': estados,
      'completado': completado,
    });
  }

  // Actualizar el estado 'completado' de un catálogo
  Future<void> actualizarCompletado(String catalogoId, int progreso, bool completado) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    await _firestore
        .collection('catalogos')
        .doc(catalogoId)
        .update({
          'progreso': progreso,
          'completado': completado,
        });
  }

  // Actualizar el progreso y el estado completado de un catálogo
Future<void> actualizarProgreso(String catalogoId, int progreso, bool completado) async {
  if (_userId == null) throw Exception('Usuario no autenticado');
  await _firestore
      .collection('catalogos')
      .doc(catalogoId)
      .update({
        'progreso': progreso,
        'completado': completado,
      });
}
}
