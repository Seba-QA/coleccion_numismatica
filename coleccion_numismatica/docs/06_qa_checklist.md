# QA Checklist - Colección Numismática

## Fecha de última actualización: 20/06/2026

---

## 1. Pruebas de autenticación

### Registro e inicio de sesión
- [ ] Registro con email/contraseña (usuario nuevo)
- [ ] Inicio de sesión con email/contraseña (usuario existente)
- [ ] Inicio de sesión con Google
- [ ] Seguir como invitado (usuario anónimo)
- [ ] Vincular cuenta anónima con email (datos previos se conservan)
- [ ] Vincular cuenta anónima con Google (datos previos se conservan)
- [ ] Cerrar sesión y volver a iniciar con cuenta vinculada (datos siguen ahí)
- [ ] Cerrar sesión y reiniciar app → mostrar pantalla login (sin invitado automático)

### Recuperación de contraseña
- [ ] Al tocar "¿Olvidaste tu contraseña?" se abre el diálogo.
- [ ] Al ingresar un email válido registrado, se envía el correo y se muestra mensaje de éxito.
- [ ] Al ingresar un email no registrado, se muestra mensaje de error.
- [ ] Al ingresar un email vacío o inválido, se muestra mensaje de validación.

### Mensajes de error
- [ ] Mensajes de error en español con diseño amigable (SnackBar flotante)

---

## 2. Pruebas de CRUD (monedas/billetes)

### Agregar Moneda
- [ ] Agregar con solo campos obligatorios (denominación, país, año, cantidad, tipo)
- [ ] Agregar con todos los campos opcionales (composición, peso, diámetro, marca de ceca, fotos)
- [ ] Validar que no guarda si falta denominación
- [ ] Validar que no guarda si falta país
- [ ] Validar que no guarda si falta año
- [ ] Validar que no guarda si falta cantidad
- [ ] Validar que el año debe ser numérico
- [ ] Validar que la cantidad debe ser numérica y mayor a 0

### Agregar Billete
- [ ] Agregar billete con solo campos obligatorios
- [ ] Agregar billete con todos los campos disponibles
- [ ] Verificar que los campos físicos (composición, peso, diámetro) no aparecen para billetes

### Edición
- [ ] Editar moneda (todos los campos)
- [ ] Editar billete
- [ ] Editar y cambiar foto
- [ ] Cancelar edición (sin cambios)
- [ ] Datos precargados correctamente en el formulario de edición

### Eliminación
- [ ] Eliminar moneda
- [ ] Eliminar billete
- [ ] Eliminar todas las piezas (mensaje "No hay monedas o billetes")

### Persistencia
- [ ] Cerrar y abrir app (datos preservados)
- [ ] Reiniciar dispositivo (datos preservados)

---

## 3. Pruebas de navegación (menú inferior)

- [ ] Al abrir la app, la pestaña "Colección" está seleccionada por defecto.
- [ ] Al tocar "Estadísticas", se muestra la pantalla de estadísticas sin errores.
- [ ] Al tocar "Perfil", se muestra la pantalla de perfil sin errores.
- [ ] El `AppBar` cambia el título según la pestaña activa.
- [ ] El menú inferior desaparece al cerrar sesión (vuelve a pantalla de login).

---

## 4. Pruebas de búsqueda y filtros

### Búsqueda por texto
- [ ] Buscar por denominación (ej. "5 Pesos")
- [ ] Buscar por país (ej. "Chile")
- [ ] Buscar por año (ej. "1947")
- [ ] Búsqueda insensible a mayúsculas/minúsculas
- [ ] Limpiar búsqueda con botón "X"

### Filtros de tipo
- [ ] Filtrar por "Monedas" (solo muestra monedas)
- [ ] Filtrar por "Billetes" (solo muestra billetes)
- [ ] Filtrar por "Todos" (muestra ambos)

### Filtros avanzados
- [ ] Filtrar por rango de años: desde 1950 hasta 1960 → mostrar monedas de esos años
- [ ] Filtrar por composición: escribir "oro" → mostrar solo monedas con "oro" en su composición (insensible a mayúsculas)
- [ ] Combinar rango de años + composición → resultados correctos
- [ ] Usar "Limpiar filtros" → restablece años y composición, pero mantiene búsqueda por texto y tipo
- [ ] Verificar que el filtro de composición no afecte a billetes (debe ignorarlos)
- [ ] Escribir texto en composición y luego borrar con el botón "X" → se limpia y se actualiza la lista

---

## 5. Pruebas de exportación/importación

### Exportación
- [ ] Exportar colección a JSON (archivo se genera y se comparte)
- [ ] El archivo contiene todos los campos de las piezas

### Importación
- [ ] Importar archivo con opción **Reemplazar** (borra los actuales y pone los importados)
- [ ] Importar archivo con opción **Fusionar** (solo añade nuevas monedas, sin duplicar)
- [ ] Importar archivo mal formado → mensaje de error
- [ ] Importar archivo vacío o sin datos → manejo adecuado
- [ ] Después de importar, la lista principal se recarga correctamente
- [ ] Después de importar, las estadísticas se actualizan correctamente
- [ ] Los campos omitidos en el JSON se manejan como vacíos (sin errores)

---

## 6. Pruebas de estadísticas

### Carga de datos
- [ ] Al abrir la pestaña Estadísticas, se cargan los datos correctamente.
- [ ] Si no hay datos, se muestra un mensaje informativo.
- [ ] Si hay datos, se muestran todas las secciones.

### Tarjetas resumen
- [ ] Total de piezas: muestra el número correcto.
- [ ] Total de países: muestra el número de países únicos.
- [ ] Total de monedas: muestra el número correcto.
- [ ] Total de billetes: muestra el número correcto.

### Gráfico de tarta (monedas vs billetes)
- [ ] Muestra correctamente la proporción de monedas y billetes.
- [ ] Los colores se adaptan al modo oscuro.

### Gráfico de barras (Top 5 países)
- [ ] Los nombres de los países se muestran en el eje X (debajo de las barras).
- [ ] El eje Y muestra una escala numérica (cantidad de piezas).
- [ ] Los nombres de los países se capitalizan automáticamente (ej. "peru" → "Peru").
- [ ] Los países con variaciones de escritura se agrupan correctamente (ej. "Chile" y "chile" se suman en una sola barra).
- [ ] Las barras tienen colores que se adaptan al tema.

### Gráfico de barras (distribución por década)
- [ ] Muestra solo la década en el eje X (sin números redundantes).
- [ ] El eje Y muestra una escala numérica.
- [ ] Las barras tienen colores que se adaptan al tema.
- [ ] Los valores de las barras se pueden leer en el eje Y.

### Actualización en tiempo real
- [ ] Al agregar una pieza, los gráficos se actualizan automáticamente.
- [ ] Al editar una pieza, los gráficos se actualizan automáticamente.
- [ ] Al eliminar una pieza, los gráficos se actualizan automáticamente.
- [ ] Al importar datos, los gráficos se actualizan automáticamente.

---

## 7. Pruebas de la lista de colección (actualización en tiempo real)

- [ ] Al importar datos, la lista se actualiza automáticamente (sin reiniciar).
- [ ] Al agregar una pieza, la lista se actualiza automáticamente.
- [ ] Al editar una pieza, la lista se actualiza automáticamente.
- [ ] Al eliminar una pieza, la lista se actualiza automáticamente.
- [ ] Los filtros (búsqueda, tipo, años, composición) funcionan correctamente con los datos actualizados.

---

## 8. Pruebas de la pantalla de perfil

- [ ] El avatar muestra la inicial del email (o "?" si no hay email).
- [ ] El nombre se muestra correctamente (email, displayName o "Invitado").
- [ ] Las tarjetas de Correo y Autenticación muestran la información correcta.
- [ ] Exportar colección abre el selector de aplicación para compartir el archivo JSON.
- [ ] Importar colección abre el selector de archivos y muestra el diálogo de reemplazar/fusionar.
- [ ] Si el usuario es anónimo, se muestra la advertencia y el botón de vincular cuenta.
- [ ] Cerrar sesión cierra la sesión y redirige a la pantalla de login.
- [ ] El modo oscuro se aplica correctamente a todos los elementos.

---

## 9. Pruebas de la pantalla de detalle

- [ ] Al abrir el detalle de una moneda, se muestra la cabecera con miniatura, denominación y país·año correctamente alineados.
- [ ] Para monedas, la miniatura de la cabecera es cuadrada; para billetes es rectangular.
- [ ] Las miniaturas de anverso y reverso (en la fila debajo de la cabecera) son circulares para monedas y rectangulares para billetes.
- [ ] Las pestañas "General" y "Físicas" son visibles y navegables.
- [ ] En la pestaña "General" se muestran denominación, país, año y cantidad.
- [ ] En la pestaña "Físicas" se muestran composición, peso y diámetro (solo para monedas; para billetes se muestra un mensaje).
- [ ] El modo oscuro se aplica correctamente a todos los elementos.
- [ ] No hay desbordamiento (overflow) en la pantalla.
- [ ] El botón de editar en el AppBar está presente (aunque aún sin funcionalidad completa).
- [ ] Al tocar el lápiz en la pantalla de detalle, se cierra el detalle y se abre el formulario de edición.
- [ ] El formulario de edición carga correctamente los datos de la pieza.
- [ ] Al guardar los cambios, la pieza se actualiza en Firestore y la lista se refresca automáticamente.
- [ ] La edición desde la lista (lápiz en tarjeta) sigue funcionando correctamente.
---

## 10. Pruebas de tema visual (claro/oscuro)

- [ ] La app sigue el tema del sistema (claro/oscuro) correctamente.
- [ ] Verificar que los textos tengan suficiente contraste en ambos modos.
- [ ] Comprobar que los botones (`ElevatedButton`, `OutlinedButton`, `TextButton`) mantengan los colores del tema.
- [ ] Confirmar que los `TextField` tengan bordes redondeados y fondo adecuado.
- [ ] Validar que el `AppBar` use el color primario definido en el tema.

---

## 11. Pruebas de diálogos y formularios

- [ ] En el diálogo de datos obligatorios, los botones "Cancelar" y "Continuar →" aparecen en la misma fila, con separación.
- [ ] Los selectores de foto en `formulario_opcional.dart` muestran un borde gris y área táctil.
- [ ] Al tomar o seleccionar una foto, el recorte funciona correctamente.
- [ ] Las validaciones del formulario obligatorio muestran mensajes de error debajo de cada campo.

---

## 12. Pruebas de recuperación de contraseña

- [ ] Al tocar "¿Olvidaste tu contraseña?" se abre el diálogo.
- [ ] Al ingresar un email válido registrado, se envía el correo y se muestra mensaje de éxito.
- [ ] Al ingresar un email no registrado, se muestra mensaje de error.
- [ ] Al ingresar un email vacío o inválido, se muestra mensaje de validación.

---

## 13. Pruebas de rendimiento y estabilidad

- [ ] La app no muestra errores `unmounted` en consola al cambiar de tema (ya silenciado).
- [ ] La navegación entre pestañas es fluida sin reinicios innecesarios.
- [ ] Los gráficos de estadísticas se renderizan correctamente con volúmenes grandes de datos.
- [ ] La lista de colección maneja sin problemas colecciones de 50+ piezas.

---

## 📝 Resultado final

| Fecha | Estado | Notas |
|-------|--------|-------|
| (fecha) | [ ] TODAS LAS PRUEBAS PASADAS | - |

---

**Nota:** Marcar cada ítem con ✅ o ❌ según corresponda. Si alguna prueba falla, describe el error en la sección de notas.

**Falla:** Descripcion