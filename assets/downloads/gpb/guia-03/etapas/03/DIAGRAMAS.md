# Diagramas de la guía 3

19/11/2026. Dos secuencias conceptuales del procedimiento de imágenes:

- [Sustitución de portada](../../../.archify/sequence-gpb-imagenes-guia-3-20261119-090000/gpb-sustitucion-guia-3.html?theme=dark).
- [Recuperación y limpieza](../../../.archify/sequence-gpb-imagenes-guia-3-20261119-090000/gpb-limpieza-guia-3.html?theme=dark).

PNG y SVG: `diagramas-publicacion/`. Se exportaron usando los controles nativos, con visor oscuro y la opción **SVG · Oscuro**. Se comprobó data-theme="dark" en ambos SVG y se inspeccionaron visualmente ambos PNG: textos, conexiones y notas legibles, sin recortes. Los HTML incluyen ?theme=dark en los enlaces docentes.

Los candidatos pasaron validación, entrega, comprobación estricta y navegador. La primera ejecución no pudo abrir Chrome con restricciones; se repitió con ejecución local autorizada. Los recibos finales están en el directorio .archify: review-2 para sustitución y review-limpieza-2 para limpieza. La segunda revisión de limpieza retiró una respuesta al cliente que no corresponde a la tarea de fondo.

Estos diagramas explican el algoritmo, no son trazas medidas ni acreditan conectividad con el proveedor. No incluyen fuentes de un commit de etapa 3 porque el docente no ha autorizado crear ese commit. No se presenta el código sin confirmar como si perteneciera al HEAD anterior. La correspondencia de lectura actual es:

| Elemento | Fuente local actual |
|---|---|
| Sesión, CSRF y protección de ruta | gpb-dev/guia-03/server/src/app.js |
| Propiedad y validación antes de subir | server/src/media-routes.js y media-input.js, dentro de guia-03 |
| Registro previo, sustitución y limpieza | server/src/media-service.js |
| Bloqueo atómico y actualización condicional | server/src/media-repository.js |
| Carga y eliminación externas | server/src/cloudinary.js |
| Arranque y temporizador de reintentos | server/src/index.js |

El inventario SHA-256 conserva las fuentes exactas de esta entrega. Cuando se autorice un punto de control, podrá añadirse procedencia vinculada a ese commit sin atribuirla al anterior.
