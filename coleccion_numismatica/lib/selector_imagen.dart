import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SelectorImagen extends StatelessWidget {
  final String? rutaImagenActual;
  final Function(String) onImagenSeleccionada;
  final String titulo;
  final String tipo; // 'moneda' o 'billete'

  const SelectorImagen({
    super.key,
    this.rutaImagenActual,
    required this.onImagenSeleccionada,
    required this.titulo,
    required this.tipo,
  });

  Future<String> _copiarImagenPermanente(File imagenTemp) async {
    final directorioApp = await getApplicationDocumentsDirectory();
    final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString() + path.extension(imagenTemp.path);
    final rutaDestino = path.join(directorioApp.path, 'fotos', nombreArchivo);
    
    final dir = Directory(path.join(directorioApp.path, 'fotos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final destino = File(rutaDestino);
    await imagenTemp.copy(destino.path);
    return destino.path;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _mostrarOpciones(context),
          child: Container(
            height: tipo == 'moneda' ? 150 : 100,
            width: tipo == 'moneda' ? 150 : double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: rutaImagenActual != null && rutaImagenActual!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(rutaImagenActual!),
                      fit: BoxFit.cover,
                      width: tipo == 'moneda' ? 150 : double.infinity,
                      height: tipo == 'moneda' ? 150 : 100,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Tocar para agregar $titulo'),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto con cámara'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  final rutaPermanente = await _copiarImagenPermanente(File(image.path));
                  onImagenSeleccionada(rutaPermanente);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final rutaPermanente = await _copiarImagenPermanente(File(image.path));
                  onImagenSeleccionada(rutaPermanente);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}