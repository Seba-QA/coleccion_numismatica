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