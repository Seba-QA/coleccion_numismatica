# Cambios y decisiones importantes

## Decisión: Dos pantallas en formulario
- **Fecha**: 05/06/2026
- **Motivo**: Demasiados campos para un solo diálogo
- **Alternativa descartada**: Un formulario largo que se desplaza

## Decisión: Botón editar (lápiz) separado del tap
- **Fecha**: 05/06/2026
- **Motivo**: Tap debería mostrar detalles, no editar
- **Cambio**: Se movió edición a ícono azul

## Decisión: Fotos guardadas como rutas absolutas
- **Fecha**: 05/06/2026
- **Nota**: Las rutas son temporales. Si la app borra caché, las fotos se pierden. Pendiente migrar a almacenamiento permanente.

## Decisión: Agregar campo "Tipo" (Moneda / Billete)
- **Fecha**: 05/06/2026
- **Motivo**: Una colección numismática incluye ambos; afecta:
  - Formato de fotos (cuadrado vs rectangular)
  - Campos específicos (billetes no tienen peso/diámetro)
  - Filtros futuros
- **Implementación**: RadioListTile en primera pantalla

## Decisión: Formato de fotos según tipo
- **Fecha**: 05/06/2026
- **Moneda**: cuadrado (150x150 en selector, 200x200 en detalles)
- **Billete**: rectangular (ancho completo, 100px alto en selector, 120px en detalles)

## Decisión: Persistencia local primero, nube después
- **Fecha**: 05/06/2026
- **Motivo**: Aprender conceptos por separado
- **Estado actual**: Hive funcionando como respaldo local, Firestore como fuente de verdad desde el 08/06/2026

## Decisión: Migrar a Firestore como fuente de verdad
- **Fecha**: 08/06/2026
- **Motivo**: Los datos no persistían correctamente al editar/eliminar porque Hive y Firestore estaban desincronizados.
- **Cambio**: Se eliminaron las operaciones de escritura en Hive (add, putAt, deleteAt) y ahora todo se hace directamente en Firestore.
- **Resultado**: La edición y eliminación funcionan correctamente, y los cambios persisten al reiniciar la app.

## Decisión: Función `_cargarMonedas` como `Future<void>`
- **Fecha**: 08/06/2026
- **Motivo**: El uso de `await` en funciones `void` generaba errores. Se cambió a `Future<void>` para permitir esperar su finalización.

## Decisión: Implementar recorte de imágenes con image_cropper
- **Fecha**: 09/06/2026
- **Motivo**: Mejorar la experiencia de usuario al ajustar fotos de monedas y billetes.
- **Resultado**: El usuario puede recortar la imagen con relación de aspecto fija (1:1 para monedas, 3:2 para billetes) antes de guardarla.

## Decisión: Implementar autenticación completa (email/Google) y perfil de usuario
- **Fecha**: 10/06/2026
- **Motivo**: Permitir a los usuarios guardar su colección en la nube y acceder desde cualquier dispositivo.
- **Implementación**:
  - Servicio centralizado `ServicioAuth` con métodos: iniciarSesionEmail, registrarEmail, iniciarSesionGoogle, vincularCuentaAnonima, cerrarSesion.

## Decisión: Implementar búsqueda y filtros en la lista principal
- **Fecha**: 11/06/2026
- **Motivo**: Mejorar la experiencia de usuario permitiendo localizar rápidamente una moneda o billete específico dentro de la colección.

## Decisión: Exportar e importar datos (JSON) con opción de fusión
- **Fecha**: 12/06/2026
- **Motivo**: Permitir al usuario realizar respaldos manuales, compartir su colección o restaurar datos sin depender exclusivamente de la nube.

Ahora que el login y perfil están funcionando, el usuario puede registrarse y vincular su cuenta anónima. Esto completa una de las tareas más importantes. Vamos a actualizar la documentación y luego definir los próximos pasos.

## Problemas resueltos
1. ADB no reconocido → agregar platform-tools al PATH
2. INSTALL_FAILED_USER_RESTRICTED → desactivar Play Protect temporalmente
3. pubspec.yaml mal indentado → respetar espacios YAML
4. Hive type cast error → usar Box sin tipo genérico y convertir manualmente
5. Lista no actualizaba → crear función _recargarLista()
6. Al usar `if` dentro de `Column`, los elementos se pegaban visualmente → agregar `Divider(height: 32)` o `SizedBox(height: 16)` entre secciones lógicas
7. Firestore API deshabilitada → habilitar desde Google Cloud Console y crear base de datos en modo nativo
8. Edición/eliminación no persistían → migrar a Firestore como fuente de verdad y recargar lista con `_cargarMonedas()`
9. `_id` faltante en monedas antiguas → reinstalar app y crear nuevos registros; en código, verificar existencia antes de editar
10. Superposición de botones en pantalla de recorte (Android 15 edge-to-edge) → crear tema personalizado `CropTheme` con `android:windowOptOutEdgeToEdgeEnforcement` y asignarlo a `UCropActivity`
11. `Bad state: No element` en perfil para usuarios anónimos → verificar que `providerData` no esté vacío antes de acceder a `.first`.
12. Inconsistencia de nombres entre español e inglés → estandarizar nombres (se optó por mantener español en la app, pero los métodos internos pueden ser en inglés para compatibilidad; se ajustó `pantalla_perfil.dart` para usar `signOut` e `isLinking` según la implementación real).
13. Pantalla negra post-login (solución con `Navigator.pushReplacement`), `Bad state: No element` en perfil (verificación segura de `providerData`).
14. Al fusionar, se evitan duplicados gracias a la clave compuesta.
15. La importación no bloquea la UI (se usa `CircularProgressIndicator`).

## Pendientes para próxima sesión
- Verificar que las fotos copiadas al directorio permanente no se pierdan al cerrar/abrir la app✅
- Login con email/Google para compartir colección entre dispositivos✅
- Búsqueda y filtros (país, año, tipo, denominación)✅
- Exportar/importar datos (JSON/CSV)
- Mejoras visuales (modo oscuro, animaciones)
- Pruebas en modo release (APK sin conexión al PC)