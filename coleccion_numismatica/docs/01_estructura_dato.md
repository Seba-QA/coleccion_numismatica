# Estructura de datos de una moneda

## Campos obligatorios
| Campo         | Tipo     | Ejemplo    |
|---------------|----------|------------|
| denominacion  | String   | "5 Pesos"  |
| pais          | String   | "México"   |
| anio          | String   | "1947"     |
| cantidad      | String   | "2"        |

### Campo `_id` (interno)
| Campo | Tipo   | Origen                 | Uso                                                        |
|-------|--------|------------------------|------------------------------------------------------------|
| _id   | String | Firestore (automático) | Identificador único del documento en la nube. Se usa para
                                                            editar/eliminar. No se muestra al usuario. |

## Campos opcionales
| Campo         | Tipo      | Ejemplo                   |
|---------------|-----------|---------------------------|
| composicion   | String    | "Plata"                   |
| peso          | String    | "12.5"                    |
| diametro      | String    | "23"                      |
| anioGregoriano| String    | "1947"                    |
| marcaCeca     | String    | "Mo"                      |
| fotoAnverso   | String    | "/ruta/de/la/imagen.jpg"  |
| fotoReverso   | String    | "/ruta/de/la/imagen.jpg"  |
| tipo          | String    | 'moneda' o 'billete'      |

## Campos específicos según tipo

### Moneda
- composicion
- peso
- diametro

### Billete
- (futuro: dimensiones, watermark, etc.)

### Ambos
- denominacion
- pais
- anio
- cantidad
- anioGregoriano
- marcaCeca
- fotoAnverso
- fotoReverso

## Almacenamiento
- Usa Hive (base de datos NoSQL local)
- Clave: 'monedas' (box name)
- Cada moneda se guarda como Map<String, String>

## Tabla `catalogos` (nueva)
Catálogos temáticos creados por el usuario para organizar su colección.

| Campo                 | Tipo          | Descripción                                       |
|-----------------------|---------------|---------------------------------------------------|
| `id`                  | String        | Autogenerado por Firestore                        |
| `nombre`              | String        | Nombre del catálogo                               |
| `descripcion`         | String        | Descripción opcional                              |
| `tag`                 | String        | Identificador único generado automáticamente (ej. "10_pesos_chilenos"). No editable.                                                          |
| `usuarioId`           | String        | ID del propietario (para reglas de seguridad)     |
| `fechaCreacion`       | Timestamp     | Fecha de creación                                 |
| `listaOficial`        | List<String>  | Lista de valores esperados (ej. años 1990-2026)   |
| `campoComparacion`    | String        | Campo de la moneda a comparar (`anio`, `pais`, `denominacion`) cuando existe `listaOficial`                                                                |
| `completado`          | Bool          | `true` cuando el progreso alcanza el 100%         |

## Tabla `catalogo_piezas` (nueva - tabla transitoria)
Relación muchos a muchos entre catálogos y piezas (monedas/billetes).

| Campo             | Tipo      | Descripción                               |
|-------------------|-----------|-------------------------------------------|
| `id`              | String    | Clave compuesta: `monedaId_catalogoId`    |
| `monedaId`        | String    | ID de la pieza en `monedas`               |
| `catalogoId`      | String    | ID del catálogo en `catalogos`            |
| `fechaAgregada`   | Timestamp | Fecha de asociación                       |
| `eliminado`       | Bool      | Eliminación lógica. `true` si la relación fue removida (para preservar historial).                                                                 |

## Campo `tags` en tabla `monedas` (modificación)
Se agregó el campo `tags` (List<String>) a la colección `monedas` para almacenar los tags de los catálogos a los que pertenece la pieza. Esto permite búsquedas rápidas (`whereArrayContains`) y es la clave para la sincronización.