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

## Decisión: Implementar filtros avanzados (rango de años y composición libre)
- **Fecha**: 15/06/2026
- **Motivo**: Mejorar la búsqueda de monedas por criterios numismáticos específicos (años y material).

## Decisión: Unificar el filtro de composición como texto libre
- **Fecha**: 15/06/2026
- **Motivo**: La colección numismática puede tener composiciones muy variadas (aleaciones, descripciones específicas) que no se adaptan a una lista predefinida.

## Decisión: Implementar tema global con `ThemeData`
- **Fecha**: 15/06/2026
- **Motivo**: Centralizar la apariencia de la app (colores, tipografía, bordes) y facilitar el mantenimiento, además de permitir modo claro/oscuro.

## Decisión: Alinear botones del diálogo de datos obligatorios horizontalmente
- **Fecha**: 15/06/2026
- **Motivo**: Mejorar la usabilidad y la estética, evitando que los botones queden uno encima del otro.

# Decisión: Implementar menú inferior (BottomNavigationBar) con pestañas Colección y Perfil
- **Fecha**: 16/06/2026
- **Motivo**: Facilitar la navegación entre la lista de monedas y el perfil de usuario, además de preparar la app para futuras secciones como estadísticas o catálogo.

## Decisión: Rediseñar formularios de agregar/editar moneda
- **Fecha**: 16/06/2026
- **Motivo**: Alinear los formularios con el diseño de Figma, mejorar la usabilidad y la estética.

## Decisión: Rediseñar la tarjeta de moneda en la lista
- **Fecha**: 16/06/2026
- **Motivo**: Mejorar la claridad visual y alinearse con el diseño de Figma.

## Decisión: Selectores de imagen circulares para monedas
- **Fecha**: 16/06/2026
- **Motivo**: Mejorar la identidad visual de monedas y billetes.

## Decisión: Rediseñar la pantalla de detalle con pestañas y formato de imágenes diferenciado
- **Fecha**: 17/06/2026
- **Motivo**: Mejorar la experiencia de usuario al visualizar la información completa de una pieza, organizada por categorías, y adaptar el formato de las imágenes según el tipo (moneda/billete).

## Decisión: Mantener solo dos pestañas en detalle (General y Físicas)
- **Fecha**: 17/06/2026
- **Motivo**: Simplificar la interfaz mientras no se utilizan las otras secciones (Fotos). Se dejan comentadas para futuras expansiones.

## Decisión: Rediseñar la pantalla de perfil con estilo de lista y tarjetas
- **Fecha**: 18/06/2026
- **Motivo**: Alinear el perfil con el diseño de Figma, mejorando la legibilidad y organización de la información.

## Decisión: Aplazar estadísticas de perfil a una vista dedicada
- **Fecha**: 18/06/2026
- **Motivo**: El cálculo de total de piezas y países no es crítico en el perfil y tiene más sentido en una vista de estadísticas (con gráficos, distribución por país, etc.).

## Decisión: Implementar pantalla de estadísticas con gráficos
- **Fecha**: 19/06/2026
- **Motivo**: Proporcionar una visión visual y resumida de la colección (totales, distribución por tipo, país y década).

## Decisión: Migrar lista de colección a `StreamBuilder` para actualización en tiempo real
- **Fecha**: 19/06/2026
- **Motivo**: La lista no se actualizaba tras importar datos o realizar cambios. Se necesitaba sincronización automática con Firestore.

## Decisión: Eliminar selector manual de tema y usar solo tema del sistema
- **Fecha**: 19/06/2026
- **Motivo**: El selector manual causaba errores transitorios de `unmounted` al reconstruir `MaterialApp`. En lugar de parchear el error, se optó por simplificar y usar el tema del sistema (`ThemeMode.system`), que ya funcionaba correctamente.

## Decisión: Migrar lista de colección a `StreamBuilder` para actualización en tiempo real
- **Fecha**: 19/06/2026
- **Motivo**: La lista no se actualizaba tras importar datos o realizar cambios. Se necesitaba sincronización automática con Firestore.

## Decisión: Implementar recuperación de contraseña
- **Fecha**: 19/06/2026
- **Motivo**: Permitir al usuario restablecer su contraseña si la olvida.

## Decisión: Normalizar y capitalizar nombres de países en estadísticas
- **Fecha**: 20/06/2026
- **Motivo**: El campo "país" es texto libre y el usuario puede ingresar variaciones (mayúsculas, tildes, espacios, puntos). Esto fragmentaba los datos en el gráfico de países.

## Decisión: Mejorar legibilidad de gráficos de barras
- **Fecha**: 20/06/2026
- **Motivo**: Los gráficos de barras no mostraban valores numéricos claros y tenían redundancia de información.

## Decisión: Extraer lógica de edición a función reutilizable
- **Fecha**: 21/06/2026
- **Motivo**: Evitar duplicar código y permitir que la edición se dispare desde múltiples lugares (lista y detalle).

## Decisión: Permitir edición desde la pantalla de detalle
- **Fecha**: 21/06/2026
- **Motivo**: Mejorar la experiencia de usuario permitiendo editar una pieza directamente desde su vista de detalle, sin necesidad de volver a la lista.
- **Problema conocido**: Al abrir el formulario desde el detalle, este se muestra sobre la lista de colección en lugar de sobre el detalle. Se corregirá en la próxima sesión (usando `showDialog` en el contexto correcto o una ruta de navegación separada).
- **Solución planificada**: Mantener el detalle abierto mientras se edita (abrir el diálogo sobre el detalle) o, alternativamente, usar una ruta de navegación separada para la edición.

## Decisión: Usar `StreamBuilder` en `PantallaDetalle` para actualización en tiempo real
- **Fecha**: 23/06/2026
- **Motivo**: La pantalla de detalle no se actualizaba automáticamente tras editar una moneda desde el detalle, ni al cambiar datos desde otros lugares.

## Decisión: Corregir lógica de edición para usar `_id` en lugar de `indice`
- **Fecha**: 23/06/2026
- **Motivo**: La edición desde detalle fallaba porque `indice` era `null` y no se ejecutaba la actualización en Firestore.

## Decisión: Extraer lógica de edición a función reutilizable
- **Fecha**: 21/06/2026
- **Motivo**: Evitar duplicar código y permitir que la edición se dispare desde múltiples lugares (lista y detalle).

## Decisión: Prevenir overflow al editar con teclado
- **Fecha**: 23/06/2026
- **Problema**: Al abrir el formulario de edición desde el detalle, el teclado redimensionaba la vista de fondo causando `bottom overflowed`.

## Decisión: Mejorar iconos de la app (diferenciación moneda/billete)
- **Fecha**: 23/06/2026
- **Problema**: Los iconos de moneda y billete eran demasiado similares (`monetization_on` vs `attach_money`), dificultando la identificación visual en la lista de colección.

## Decisión: Implementar exportación a PDF (texto y números)
- **Fecha**: 23/06/2026
- **Motivo**: Ofrecer al usuario una forma de generar un catálogo legible y compartible de su colección, complementando la exportación JSON (que es para respaldo e importación).

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
16. - Inicialmente se intentó un `DropdownButton` fijo, pero se descartó por no ser práctico (composiciones variables). Se optó por texto libre.
17. Conflictos de nulabilidad en `_composicionQuery` resueltos usando `String` no nullable con valor inicial vacío.
18. Se eliminó código redundante que mezclaba `DropdownButton` con `TextField`.
19. Tras la limpieza de estilos inline, se perdió el borde visual que indicaba el área del selector. Se restauró en `selector_imagen.dart` con `BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8))`.
20. Se corrigió el tipo de `onEditar` de `VoidCallback?` a `void Function(Map<String, String>)?` para que coincida con `_editarDesdeDetalle`.
21. Se usó `WidgetsBinding.instance.addPostFrameCallback` para asegurar que el detalle se cierre antes de abrir el diálogo de edición.
22. Se corrigió edición desde detalle no persistía (segunda edición) usando `_id` en lugar de `indice` para la actualización en Firestore.
23. El detalle no se actualizaba tras editar, por lo que, se implementó `StreamBuilder` para escuchar cambios en Firestore.
24. Se desactivó la redimensión del `Scaffold` con `resizeToAvoidBottomInset: false` al editar.


## Pendientes para próxima sesión
- Verificar que las fotos copiadas al directorio permanente no se pierdan al cerrar/abrir la app✅
- Login con email/Google para compartir colección entre dispositivos✅
- Búsqueda y filtros (país, año, tipo, denominación)✅
- Exportar/importar datos (JSON/CSV)✅
- Mejoras visuales (modo oscuro, animaciones)✅
- Pruebas en modo release (APK sin conexión al PC)✅
- Mejora interfaz de las distintas pantallas⌚
- Creacion de estadisticas