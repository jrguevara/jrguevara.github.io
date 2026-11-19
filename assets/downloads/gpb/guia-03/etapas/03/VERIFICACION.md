# Verificación de la guía 3

19/11/2026. **Reproducción local y comprobación real con Atlas y Cloudinary aprobadas.**

## Base y método

Base conservada: `gpb-dev/guia-02`, commit raíz 5e34cf3. Reproducción aislada en `/var/folders/qq/2qlr_fjx58b03t363tpk3ck80000gn/T/gpb-reproduccion-03-7V0q3l/gpb-dev/guia-03`. Se copió únicamente la base, se ejecutó literalmente el bloque de preparación de la guía y se transcribieron los 24 bloques marcados como archivo desde el Markdown. No se copió la aplicación final como sustituto de ese recorrido.

Los 24 archivos y el lock resultante coinciden byte por byte con la referencia `gpb-dev/guia-03`. El README de la carpeta es documentación complementaria, no un bloque ejecutable de la guía. Registro de comandos y salidas sin secretos en REPRODUCCION-LOCAL.log, ignorado por Git por su extensión; su resumen se conserva aquí.

## Resultados

| Comprobación en la copia aislada | Resultado |
|---|---|
| Preparación literal e instalación de versiones exactas | Aprobadas |
| Entorno | Node 26.13.1, pnpm 12.18.0, macOS arm64, Vite+ 1.6.0 |
| Creación de .env desde ejemplo y secreto propio | Aprobada, sin imprimir valores |
| pnpm install --frozen-lockfile | Aprobado, sin cambios al lock |
| pnpm check | Aprobado, 11 archivos sin errores ni advertencias |
| pnpm build | Aprobado, 207 módulos |
| pnpm test | 21/21 aprobadas |
| Instalación de Chromium y binario Electron | Disponibles |
| pnpm test:transport | 4/4 aprobadas |
| check-atlas.js con configuración heredada en memoria | Aprobado; MongoDB 8.0.39, índices, hash, persistencia y revocación |
| check-images-atlas.js --provider-memory | Aprobado; Atlas real, imágenes con proveedor simulado |
| Cloudinary real | Aprobado en referencia y copia reconstruida: carga, sustitución, galería, propiedad, CSRF y limpieza |

Las pruebas locales abarcan identidad y propiedad con dos usuarios, CSRF, origen, tamaño, formato y contenido falso, sustitución, galería de ocho imágenes, eliminación de Gunpla, concurrencia, fallos de proveedor y MongoDB, etiquetas y enlaces inválidos. El recorrido de React utiliza la API real con adaptadores de memoria y reemplaza expresamente las respuestas externas de imágenes y video. No acredita reproducción de un video remoto.

Atlas real usa los modelos y el repositorio MongoDB de la etapa. Se comprobó escritura de campos nuevos, adquisición de bloqueo, diario persistente, sustitución, galería, propiedad, CSRF y eliminación/purga. No se copió MONGODB_URI a la reproducción ni se imprimió. Sus cuentas, sesiones e imágenes simuladas de prueba se limpiaron. La primera configuración de Cloudinary no pasó la validación de cloud name; el docente la corrigió localmente y después se completaron las pruebas reales en referencia y copia reconstruida. Se eliminaron cuentas, sesiones y recursos temporales exclusivos del recorrido.

## Correcciones de reproducción

El primer borrador insertaba el README completo como bloque de Markdown con cercas triples internas. El extractor detectó una transcripción incompleta. Se retiró ese bloque del recorrido: el README queda como material complementario, como en guía 2. La versión final tiene 24 bloques completos, sin cercas anidadas ambiguas, y se volvió a transcribir y comparar. La instalación, check, build, 21 pruebas y cuatro recorridos ya habían pasado con esos mismos archivos de aplicación; la corrección sólo afectó al bloque documental retirado.

La revisión real de Atlas informó que la opción new de Mongoose está deprecada. Se reemplazó por returnDocument: 'after' en los dos archivos afectados antes de generar y reproducir la guía final.

## Pendientes y límites

Cloudinary real y su limpieza se completaron en referencia y reproducción. Guía técnicamente comprobada para grabación, dentro del alcance de etapa 3; no equivale a desplegar GPB ni a empaquetar Electron. Diagramas y exportaciones oscuras revisados por separado en DIAGRAMAS.md. Sitio pendiente de fecha editorial y autorización antes de publicar. Canvas pendiente de datos de sesión, foro y URL real. Render y empaquetado macOS continúan en etapas 5/6; la prueba Electron sigue siendo preparatoria.

## Cierre de la suite y del material

La prueba adicional de bloqueo vencido y respuesta tardía se transcribió desde el Markdown final y se ejecutó en la copia aislada: 21/21 aprobadas. Se conserva la portada confirmada por la operación nueva, se rechaza la antigua y se recupera su recurso mediante el diario. La corrección UTF-8 del mensaje externo simulado se reprodujo en ambos proyectos con el recorrido de imágenes aprobado. Todos los bloques y el lock mantienen igualdad con la referencia.

El verificador de regresión de colección con Atlas pasó también en la referencia final: CRUD React, catálogos idempotentes, aislamiento entre usuarios, persistencia tras reinicios, autenticación y limpieza. La disponibilidad y reproducción real de un video YouTube no se certifican: se valida el enlace y el iframe, y la disponibilidad depende del proveedor y del autor.

La copia temporal se eliminó al terminar, incluido su .env generado y perfiles. La comparación final antes de retirarla confirmó los 24 bloques y el lock idénticos. La versión permanente permanece en gpb-dev/guia-03, sin copiar credenciales anteriores. Los verificadores de esta sesión heredaron MongoDB en memoria; para arrancar directamente con pnpm dev:server, completar MONGODB_URI en el .env propio de guia-03. Cloudinary y su secreto de sesión propio ya quedan configurados localmente.
