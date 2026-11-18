# Diagramas — guía 2

1. [Datos de la colección](../../../.archify/erd-gpb-datos-guia-2-20261118-120000/gpb-datos-guia-2.html): users, gunplas, grades y scales, campos y referencias ObjectId.
2. [Crear y proteger un Gunpla](../../../.archify/sequence-gpb-coleccion-guia-2-20261118-120000/gpb-coleccion-guia-2.html): consulta de opciones, sesión/CSRF, validación de referencias, creación con propietario del servidor y apertura del detalle.

Fuentes exactas: commit 86f4719169abde00082a9caacc5620565e8ac23d del repositorio https://github.com/jrguevara/MERN-electron.git. Cada nodo/entidad contiene referencias a rutas y líneas inspeccionadas. El mapa omite sesiones para centrarse en datos de colección. La secuencia omite el salto del proxy; no presenta ese salto como inexistente. MongoDB no impone claves foráneas SQL: la comprobación de existencia la hace la API.

Archify 3.2.0, sin actualización. Desde raíz del repositorio se ejecutó, para cada pareja tipo/carpeta:

```sh
node .agents/skills/archify/bin/archify.mjs finalize erd .archify/erd-gpb-datos-guia-2-20261118-120000/candidate.json .archify/erd-gpb-datos-guia-2-20261118-120000/gpb-datos-guia-2.html --repo-root . --quality showcase --out-dir .archify/erd-gpb-datos-guia-2-20261118-120000/review-2 --json
node .agents/skills/archify/bin/archify.mjs finalize sequence .archify/sequence-gpb-coleccion-guia-2-20261118-120000/candidate.json .archify/sequence-gpb-coleccion-guia-2-20261118-120000/gpb-coleccion-guia-2.html --repo-root . --quality showcase --out-dir .archify/sequence-gpb-coleccion-guia-2-20261118-120000/review-2 --json
```

Validación, entrega, procedencia y navegador aprobados en ambos. El primer intento restringido no pudo comunicarse con Chrome; los recibos finales son los de review-2. Se conservaron ocho capturas de visual-check (1440×900 y 2048×1320, claro/oscuro), con contención, legibilidad y controles aprobados. Se inspeccionaron visualmente el ERD claro a 1440×900, la secuencia oscura a 1440×900 y la captura completa de secuencia clara para revisar los pasos inferiores: sin cortes o superposiciones del contenido. La secuencia larga requiere desplazamiento vertical. No se confunde la captura automática con la inspección visual.

Exportaciones PNG y SVG obtenidas mediante los controles nativos de Exportar, conservadas en diagramas-publicacion/. La guía incluye imágenes, enlaces interactivos y SVG. Los HTML son autónomos; no necesitan ejecutar GPB.
