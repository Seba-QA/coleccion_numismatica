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
- Moneda: cuadrado (150x150 en selector, 200x200 en detalles)
- Billete: rectangular (ancho completo, 100px alto en selector, 120px en detalles)

## Decisión: Persistencia local primero, nube después
- **Motivo**: Aprender conceptos por separado
- **Estado actual**: Hive funcionando

## Problemas resueltos
1. ADB no reconocido → agregar platform-tools al PATH
2. INSTALL_FAILED_USER_RESTRICTED → desactivar Play Protect temporalmente
3. pubspec.yaml mal indentado → respetar espacios YAML
4. Hive type cast error → usar Box sin tipo genérico y convertir manualmente
5. Lista no actualizaba → crear función _recargarLista()
6. Al usar `if` dentro de `Column`, los elementos se pegaban visualmente -> Agregar `Divider(height: 32)` o `SizedBox(height: 16)` entre secciones lógicas