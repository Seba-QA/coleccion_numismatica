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