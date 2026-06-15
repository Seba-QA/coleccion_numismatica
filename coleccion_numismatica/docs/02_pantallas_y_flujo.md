# Pantallas y flujo de navegación

## Pantallas actuales

### 1. ListaMonedas (principal)
- Muestra todas las monedas en tarjetas
- Cada tarjeta muestra: denominación (título), país - año (subtítulo)
- Acciones: 
  - Editar (ícono lápiz azul)
  - Eliminar (ícono basurero rojo)
  - Ver detalles (tap en la tarjeta)

### 2. FormularioOpcional
- Segunda pantalla al crear/editar
- Campos: tipo, composición, peso, diámetro, año gregoriano, marca de ceca
- Selectores de foto: anverso y reverso

### 3. DetalleMoneda
- Muestra toda la información organizada en secciones:
  - Información general
  - Características físicas
  - Información adicional
  - Fotos (anverso y reverso)

### 4. PantallaAuth
- Pantalla de login/registro con dos modos (iniciar sesión / registrarse).
- Campos: email, contraseña (y confirmar contraseña en registro).
- Botones: Ingresar, Registrarse, Continuar con Google, Seguir como invitado.
- Validación de campos y mensajes de error en español.

### 5. PantallaPerfil
- Muestra email del usuario y método de autenticación (Google, Email, Anónimo).
- Si es anónimo: muestra advertencia sobre pérdida de datos y botón para vincular cuenta.
- Botón para cerrar sesión.

## Flujo principal
- Agregar: + → Pantalla1 (obligatorios) → Siguiente → Pantalla2 (opcionales + fotos) → Guardar
- Editar: lápiz → Pantalla1 (precargada) → Siguiente → Pantalla2 (precargada) → Guardar
- Eliminar: basurero → eliminación inmediata
- Ver detalles: tap en tarjeta → pantalla de detalles

## Sincronización con Firestore (versión actual)
- **Fuente de verdad:** Firestore (nube).
- **Operaciones:** Crear, editar, eliminar se ejecutan directamente en Firestore.
- **Carga inicial:** `_cargarMonedas()` lee desde Firestore y actualiza la UI.
- **Hive:** Se mantiene solo como respaldo local (lectura inicial o sin internet), pero las escrituras en Hive ya no se usan activamente.

### Flujo de autenticación
- Al iniciar app sin usuario → muestra PantallaAuth.
- Al elegir "Seguir como invitado" → crea usuario anónimo y navega a ListaMonedas.
- Al registrar/iniciar sesión con email o Google → vincula cuenta anónima si existe, o crea nueva.
- Al cerrar sesión → vuelve a PantallaAuth.

## Exportar / Importar colección (desde el perfil)

### Exportar
- El usuario puede exportar toda su colección a un archivo JSON.
- El archivo se guarda temporalmente y se comparte mediante el selector nativo del sistema (correo, almacenamiento, mensajería).
- El nombre del archivo incluye la fecha y hora (ej. `coleccion_1744567890123.json`).

### Importar
- El usuario puede seleccionar un archivo JSON previamente exportado.
- Se muestran dos opciones:
  - **Reemplazar**: elimina la colección actual y la sustituye por la importada.
  - **Fusionar**: añade solo las monedas que no existan en la colección actual. La duplicación se evita comparando la combinación de `país + denominación + año`.
- Después de la importación, la lista principal se recarga automáticamente.

## Filtros avanzados en la lista principal

- **Rango de años**: permite filtrar por año mínimo (desde) y máximo (hasta). Los campos son numéricos y opcionales.
- **Composición (texto libre)**: filtro que busca coincidencias parciales (insensible a mayúsculas) en el campo `composicion` de las monedas. Solo afecta a monedas (los billetes se excluyen automáticamente).
- **Botón "Limpiar filtros"**: restablece todos los filtros avanzados (años y composición) sin afectar la búsqueda por texto ni el filtro por tipo.
- Todos los filtros se combinan de forma AND (la lista muestra solo los elementos que cumplen todas las condiciones activas).

### Comportamiento de los filtros
- Los filtros se aplican en tiempo real al escribir o cambiar valores.
- El filtro de composición es de texto libre, permitiendo buscar términos como "oro", "plata", "billón", "cuproníquel", etc.
- Si el campo de búsqueda principal está vacío, no filtra por texto.
- Los filtros de rango de años ignoran valores no numéricos o vacíos.