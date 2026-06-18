# Colección Numismática

App móvil para gestionar tu colección de monedas y billetes de forma fácil, segura y sincronizada en la nube.

---

## 📱 Características principales

- **CRUD completo**: Agrega, edita, elimina y visualiza cada pieza de tu colección.
- **Fotos desde cámara o galería**: Toma o selecciona imágenes para el anverso y reverso.
- **Diferenciación Moneda / Billete**: Campos y formatos de imagen adaptados a cada tipo.
- **Almacenamiento local**: Usa Hive para persistencia local (rápido y sin internet).
- **Sincronización en la nube**: Guarda tu colección en Firebase Firestore y accede desde cualquier dispositivo.
- **Autenticación**: Login con email/contraseña, Google o modo invitado (anónimo).
- **Vinculación de cuenta**: Convierte tu cuenta anónima en permanente sin perder datos.
- **Búsqueda y filtros**: Encuentra piezas por país, denominación, año, composición o rango de años.
- **Exportación / Importación**: Respalda tu colección en JSON o restaura desde un archivo (con opción de fusionar).
- **Modo oscuro**: Se adapta automáticamente al tema del sistema o se puede forzar.
- **Diseño moderno**: Interfaz inspirada en Material 3 con paleta de colores numismática.

---

## 🛠️ Tecnologías utilizadas

| Tecnología            | Propósito                                         |
|-----------------------|---------------------------------------------------|
| **Flutter / Dart**    | Framework principal                               |
| **Firebase Auth**     | Autenticación (email, Google, anónimo)            |
| **Cloud Firestore**   | Base de datos en tiempo real                      |
| **Firebase Storage**  | (futuro) Almacenamiento de imágenes en la nube    |
| **Hive**              | Base de datos local                               |
| **Image Picker**      | Selección de imágenes desde cámara/galería        |
| **Image Cropper**     | Recorte de imágenes con relación de aspecto fija  |
| **Share Plus**        | Compartir archivos (exportación)                  |
| **File Picker**       | Selección de archivos para importación            |

