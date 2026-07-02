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
  ## Recuperación de contraseña
- Desde la pantalla de login, el usuario puede tocar el enlace "¿Olvidaste tu contraseña?".
- Se abre un diálogo donde debe ingresar su correo electrónico.
- Al enviar, Firebase envía un correo con un enlace para restablecer la contraseña.
- Se muestran mensajes de éxito o error según el resultado.

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

## Tema visual (claro/oscuro)
- La app soporta modo claro y oscuro, siguiendo la configuración del sistema operativo.
- Los colores principales están definidos en `ThemeData` en `main.dart`:
  - Primario: `#1A2A4A` (azul marino)
  - Secundario: `#C9A03D` (dorado)
  - Error: `#C53030` (rojo ladrillo)
- Todos los widgets (botones, campos de texto, tarjetas, AppBar) heredan estilos del tema global, eliminando estilos inline para mantener consistencia.

## Navegación inferior (BottomNavigationBar)

- La app utiliza un menú inferior con dos pestañas principales:
  - **Mi Colección**: muestra la lista de monedas (pantalla principal).
  - **Perfil**: muestra la pantalla de perfil del usuario.
- El menú inferior está visible cuando el usuario está autenticado (incluyendo modo invitado).
- Al cambiar de pestaña, el `AppBar` superior actualiza su título dinámicamente ("Mi Colección" o "Mi Perfil").
- No se incluyen iconos de perfil en el `AppBar` de la lista, ya que el acceso al perfil es desde el menú inferior.

## Pantalla de detalle de moneda/billete (rediseñada)

  ### Estructura general
  - **AppBar**: Título con la denominación de la pieza y un botón de editar (lápiz) que abrirá el formulario de edición (pendiente de implementar).
  - **Cabecera**:
    - Miniatura del anverso a la izquierda (cuadrada para monedas, rectangular para billetes).
    - Denominación en negrita (tamaño 28) y país · año debajo (tamaño 16), alineados a la izquierda.
  - **Miniaturas de fotos**: Anverso y reverso en una fila debajo de la cabecera, con formato cuadrado para monedas y rectangular para billetes.
  - **Pestañas**: Actualmente solo dos: **General** y **Físicas** (la pestaña "Adicional" está comentada para futura expansión; "Fotos" no se usa por ahora).
    - **General**: Muestra denominación, país, año y cantidad.
    - **Físicas**: Muestra composición, peso (g) y diámetro (mm) (solo visible para monedas; para billetes muestra un mensaje informativo).
  - **Modo oscuro**: Todos los colores se adaptan al tema del sistema.
  ### Interacción
  - Al tocar una pieza en la lista, se abre esta pantalla de detalle.
  - El botón de editar (lápiz) en el AppBar está preparado para futura implementación (por ahora muestra un mensaje temporal).

  ## Edición desde la pantalla de detalle (mejora)
  - El usuario puede editar una moneda o billete directamente desde su pantalla de detalle.
  - Al tocar el ícono de lápiz (✏️) en el `AppBar` del detalle, se abre el formulario de edición **sin cerrar** la pantalla de detalle.
  - El formulario se muestra como un diálogo sobre el detalle, manteniendo el contexto visual.
  - Al guardar los cambios:
    - Firestore se actualiza correctamente (usando el `_id` del documento, sin depender de índices).
    - La pantalla de detalle se actualiza en tiempo real gracias a un `StreamBuilder` que escucha cambios en Firestore.
  - La vista de detalle ya no se cierra al iniciar la edición, mejorando la experiencia de usuario.
  ### Comportamiento técnico
  - `PantallaDetalle` usa `StreamBuilder` para escuchar el documento específico de Firestore (basado en `monedaId`).
  - El formulario de edición (`_mostrarFormulario`) se abre con la moneda actual, y al guardar, el `Stream` notifica el cambio y la UI se reconstruye automáticamente.
  - Se corrigió el overflow al abrir el teclado durante la edición (`resizeToAvoidBottomInset: false`).

  ## Formulario de datos obligatorios (diálogo)
- **Título**: "Nueva pieza".
- **Selector de tipo**: `SegmentedButton` con opciones "Moneda" y "Billete" (estilo moderno, color primario al seleccionar).
- **Campos**:
  - Denominación (hint: "Ej: 5 Pesos, 1 Real, ½ Crown...").
  - País (hint: "México").
  - Año (hint: "1957").
  - Cantidad (hint: "1").
- **Validaciones**:
  - Todos los campos son obligatorios.
  - Año y cantidad deben ser números válidos.
  - Mensajes de error se muestran debajo de cada campo.
- **Botones**: "Cancelar" (texto) y "Continuar →" (primario) en la misma fila.

  ## Lista de colección (actualización en tiempo real)
  - La lista de monedas ahora usa `StreamBuilder` para escuchar cambios en Firestore.
  - Cualquier modificación (importación, edición, eliminación, adición) se refleja automáticamente sin necesidad de recargar la app.
  - Los filtros (búsqueda, tipo, rango de años, composición) se aplican sobre los datos en tiempo real.
  - Se eliminó la dependencia de Hive para la lista principal (ahora solo se usa Firestore como fuente de verdad).

## Formulario de datos opcionales (pantalla completa)
- **Subtítulo**: "Puedes completarlo más adelante".
- **Sección FOTOGRAFÍAS**:
  - Selectores de foto "Anverso" y "Reverso" en fila.
  - Para **monedas**, los selectores son circulares (círculo).
  - Para **billetes**, los selectores son rectangulares con bordes redondeados.
  - Dentro del selector: icono y texto "Tocar para agregar" (con `FittedBox` para evitar desbordes).
- **Sección CARACTERÍSTICAS FÍSICAS**:
  - Campo "Composición" con hint "Ej: Plata .720, Cobre, Cuproníquel...".
  - Campos "Peso (g)" y "Diámetro (mm)" en la misma fila, cada uno con sufijo fijo ("g" y "mm") dentro del campo.
- **Botón**: "Guardar pieza" (primario, ancho completo).
- **Nota**: No incluye sección de "Información adicional" (se omite por ahora).

## Pantalla de perfil (rediseñada)
-**Cabecera**
  - **Avatar**: Círculo con la inicial del nombre de usuario (o del email, o "?" si es anónimo).
  - **Nombre**: Muestra el nombre del usuario (obtenido del email, displayName, o "Invitado" para anónimos).
  - **Estadísticas**:
    - Los contadores de "Piezas" y "Países" se actualizan automáticamente mediante un `StreamBuilder` que escucha la colección del usuario en Firestore.
  - No dependen de datos pasados desde la lista, lo que garantiza que siempre estén sincronizados con la base de datos.
-**Tarjetas de información**
  - **Correo electrónico**: Muestra el email del usuario autenticado.
  - **Método de autenticación**: Muestra el proveedor usado (Google, Email/Contraseña, Anónimo).
-**Sección "DATOS DE COLECCIÓN"**
  - **Exportar colección**: Botón que permite exportar la colección a JSON (compartir archivo).
  - **Importar colección**: Botón que permite importar un archivo JSON con opciones de reemplazar o fusionar.
-**Sección "CUENTA"**
  - **Vincular cuenta**: (solo visible para usuarios anónimos) Muestra una advertencia y un botón para vincular la cuenta anónima a una cuenta permanente (email/Google).
  - **Cerrar sesión**: Botón en rojo que cierra la sesión del usuario y vuelve a la pantalla de login.
-**Exportación a PDF**
  - El usuario puede exportar un catálogo en formato PDF desde la pantalla de perfil.
  - El PDF incluye:
    - **Encabezado**: "Mi Colección Numismática" y fecha de exportación.
    - **Resumen**: tarjetas con totales de piezas, países, monedas y billetes.
    - **Tabla detallada**: lista de todas las piezas con columnas: N°, Denominación, País, Año, Tipo, Cantidad.
  - El archivo se genera en el directorio temporal y se comparte mediante el selector nativo del sistema (correo, almacenamiento, mensajería).
  - **Nota**: Por ahora, el PDF solo incluye texto y números. La inclusión de imágenes se considera una mejora futura.


## Pantalla de estadísticas

Accesible desde la tercera pestaña del menú inferior (icono de gráfico).

  ### Datos mostrados
  - **Tarjetas resumen**: Total de piezas, países únicos, cantidad de monedas y billetes.
  - **Gráfico de tarta**: Distribución entre monedas y billetes.
  - **Gráfico de barras (Top 5 países)**: Países con mayor número de piezas en la colección.
  - **Gráfico de barras (distribución por década)**: Agrupación de piezas por década (ej. 1940, 1950, 1960...).

  ### Comportamiento
  - Los datos se cargan directamente desde Firestore al abrir la pestaña.
  - La vista se actualiza automáticamente al agregar, editar o eliminar piezas (gracias a `StreamBuilder`).
  - Si no hay datos, se muestra un mensaje informativo.
  - Los gráficos usan los colores del tema (primario, secundario, terracota) y se adaptan al modo oscuro.

  ## Mejoras visuales
  - **Escala numérica en eje Y**: Se agregó una escala numérica en el eje izquierdo para que el usuario pueda leer fácilmente la cantidad de piezas representada por cada barra.
  - **Nombres de países en eje X**: Los nombres de los países se muestran debajo de las barras, con capitalización automática (primera letra mayúscula) y normalización de texto para agrupar correctamente variaciones ortográficas (mayúsculas, minúsculas, tildes, espacios, caracteres especiales).
  - **Eje X limpio para décadas**: En el gráfico de distribución por décadas, solo se muestra el año de la década (sin números redundantes). La cantidad se lee en el eje Y.
  - **Agrupación de países**: Los países se normalizan y agrupan, evitando duplicados por diferencias de escritura. El nombre mostrado se capitaliza automáticamente.
  
## Nueva pestaña: Catálogos

La app ahora cuenta con una cuarta pestaña en el menú inferior: **Catálogos**.

### Pantalla de lista de catálogos (`PantallaCatalogos`)
- **Propósito**: Mostrar todos los catálogos creados por el usuario.
- **Comportamiento**:
  - Carga automática mediante `StreamBuilder` que escucha la colección `catalogos` en Firestore.
  - Cada catálogo se muestra en una tarjeta con:
    - Nombre y descripción (si existe).
    - Progreso: `X/Y completados` (si tiene lista oficial) o `X piezas` (si no tiene lista).
    - Barra de progreso visual.
    - Borde de color según el estado: 🟢 Verde (completado), 🟠 Naranja (pendiente), ⚪ Gris (sin datos).
  - Botón flotante (FAB) con icono `+` para crear un nuevo catálogo (pendiente de implementar en Sesión 3).
  - Al tocar una tarjeta, navega al detalle del catálogo (pendiente de implementar en Sesión 4).

### Navegación
- El menú inferior ahora tiene 4 ítems: **Colección**, **Catálogos**, **Estadísticas**, **Perfil**.

## Pantalla de creación de catálogos (`PantallaCrearCatalogo`)

### Acceso
- Desde la pantalla de lista de catálogos, tocando el botón flotante (FAB) con icono `+`.

### Campos
- **Nombre del catálogo** (obligatorio): Texto único que identifica el catálogo. A partir de este nombre se genera automáticamente el `tag` (minúsculas, sin tildes, espacios reemplazados por guiones bajos).
- **Descripción** (opcional): Texto adicional para describir el propósito del catálogo.
- **Lista oficial** (opcional): Activable mediante un `Switch`.
  - Si está activada, se despliega una sección con:
    - **Campo de texto + botón `+`**: Permite agregar elementos uno a uno (ej. años, países, estados).
    - **Lista visual de elementos agregados**: Cada elemento muestra un botón `-` (rojo) para eliminarlo.
    - **Campo de comparación** (obligatorio si la lista oficial está activa): Menú desplegable con opciones: `Año`, `País`, `Denominación`. Define con qué campo de las monedas se comparará la lista oficial durante la sincronización.

### Comportamiento
- **Validaciones**:
  - El nombre no puede estar vacío.
  - Si la lista oficial está activa, debe tener al menos un elemento.
  - Si la lista oficial está activa, debe seleccionarse un campo de comparación.
- **Guardado**:
  - Al tocar "Guardar", se crea un nuevo documento en la colección `catalogos` en Firestore.
  - El `tag` se genera automáticamente a partir del nombre.
  - Si el `tag` ya existe para el usuario, se muestra un error y se permite cambiar el nombre.
- **Feedback**:
  - SnackBar de éxito al crear el catálogo.
  - SnackBar de error si falla la creación (ej. tag duplicado, problemas de red).


