# Etapa 3 — registro técnico

Inicio: 19/11/2026. Base: `gpb-dev/guia-02` en el commit raíz `5e34cf3`; la aplicación raíz y las versiones anteriores se conservan. La etapa se desarrolla en `gpb-dev/guia-03`, sin Git anidado. No se autorizan commits ni publicaciones por iniciar el trabajo.

## Incrementos

1. Copia selectiva de fuentes, manifiestos, lock y pruebas, sin dependencias, dist, perfiles, evidencias ni credenciales. Se excluyó el README de la etapa anterior para redactar el de esta entrega.
2. SDK de Cloudinary sólo en servidor; Multer por ruta; Sharp comprueba el contenido y reexporta a WebP sin metadatos.
3. Diario persistente y bloqueo en el propio Gunpla. La imagen nueva tiene identificador aleatorio del servidor, registrado antes de la llamada externa. La portada anterior se conserva hasta que MongoDB confirme la sustitución.
4. Portada, galería de ocho imágenes, eliminación individual y eliminación lógica del Gunpla con limpieza posterior. Las consultas y actualizaciones normales ocultan los registros eliminados.
5. Etiquetas (máximo 20, 30 caracteres cada una, espacios recortados y duplicados sin distinguir mayúsculas) y URL HTTPS de YouTube validada; sólo se conserva el identificador. Límites de etiquetas adicionales adoptados para acotar el cuerpo, manteniendo el máximo JSON de 8 KB.
6. Interfaz oscura, formularios de carga, confirmación, avisos de limpieza pendiente, galería y reproductor; portada de reemplazo también ante fallo de descarga.

## Decisiones de consistencia

El campo privado mediaJobs conserva cada publicId asignado antes de subir. Las imágenes vinculadas se mantienen en el diario y nunca se borran mientras el registro esté activo. Una imagen desvinculada se elimina con destroy e invalidación; sólo después se retira la tarea confirmada. Las tareas de una llamada incierta o caída del proceso se vuelven a eliminar durante una ventana de 24 h. No es una transacción distribuida ni garantiza una latencia de CDN; los fallos permanecen registrados y se reintentan.

Bloqueo MongoDB por registro de cinco minutos, mediante adquisición atómica y token. Una escritura con token o plazo vencido no puede confirmar imágenes. Liberación condicional por token. Dos cargas máximas por proceso, contadas hasta terminar la operación incluso si se cierra la respuesta; cada solicitud admite un archivo de hasta 5 MiB. La identidad y propiedad se comprueban antes de Multer y nuevamente al adquirir el bloqueo.

Una eliminación externa por pasada y registro limita la espera: hasta 30 s de subida y 10 s de eliminación. Las restantes tareas quedan pendientes. El servidor ejecuta la recuperación al iniciar y cada minuto, sin superponer pasadas. Cada pasada considera hasta 100 documentos y el diario admite 32 entradas; si se acumulan fallos se rechazan nuevas subidas hasta recuperar el servicio. El comando images:cleanup permite una pasada manual. Los registros eliminados se purgan sólo al vaciar el diario. La eliminación de un Gunpla puede confirmar su desaparición de la colección mientras sus archivos esperan al proveedor.

Salida de imágenes normalizada a WebP, calidad 85, hasta 2400 × 2400 sin ampliar, límite de entrada 25 megapíxeles y una página. Se admiten originales JPG/JPEG, PNG y WebP con MIME y extensión coincidentes. No se almacena el nombre del archivo original.

## Comandos reales

Carpeta salvo indicación: `/Users/jrguevara/Developer/MERN-electron/gpb-dev/guia-03`.

| Comando | Resultado observado |
|---|---|
| node --version; pnpm --version, desde raíz | 26.13.1 y 12.18.0 |
| pnpm view cloudinary version engines --json; equivalente para multer y sharp | 2.11.0 (Node >=9), 2.5.0 (>=10.16.0), 0.35.5 (>=20.9.0) |
| pnpm --filter @gpb/server add --save-exact cloudinary@2.11.0 multer@2.5.0 sharp@0.35.5 | Instalación correcta; Argon2 operativo; lock actualizado |
| pnpm install --frozen-lockfile | Workspace completo instalado sin cambiar lock |
| pnpm --filter @gpb/server list --depth 0 | Versiones exactas confirmadas |
| pnpm --filter @gpb/client exec vp --version | Vite+ 1.6.0, Vite 8.3.7 |
| pnpm --filter @gpb/client exec vp check --fix | 11 archivos revisados sin errores ni advertencias; formato corregido |
| pnpm build | Aprobado; 207 módulos |
| pnpm test | 20/20 aprobadas: autenticación, colección y ocho casos de imágenes/concurrencia/fallos/etiquetas/video |
| GPB_CAPTURE_DIR=…/docs/etapas/03/capturas pnpm test:transport | 4/4 aprobadas en 8,3 s; navegador, móvil, imágenes y transporte Electron |

Las fuentes oficiales, requisitos y comprobaciones de las herramientas están en FUENTES.md. Se está preparando la reproducción editorial; estos resultados verifican implementación, no todavía el recorrido desde el Markdown.

## Diagnósticos y correcciones

Dos invocaciones preliminares se ejecutaron desde la raíz y fallaron por no poder abrir sus servidores locales; no son evidencia de la etapa 3 ni alteraron la aplicación raíz. Se repitieron desde guia-03 con ejecución local autorizada. La primera prueba de imágenes importaba una ruta interna de Sharp que ya no existe; se corrigió usando createRequire con el manifiesto del servidor. La prueba posterior encontró dos controles con el mismo nombre accesible; se distinguió la etiqueta de archivo de la acción de subir, y el recorrido completo pasó.

La primera comprobación del diagrama no pudo abrir Chrome con las restricciones de ejecución. Los controles de esquema, entrega y procedencia pasaron; se repite el navegador con la autorización apropiada. No se considera aprobado el diagrama hasta terminar ese control y su revisión visual.

## Recursos externos y límites

Al iniciar, no había variables Cloudinary en los archivos privados revisados; se solicitó configuración local sin exponer valores. Se conserva el archivo privado de guía 1; su configuración puede leerse en memoria para comprobar Atlas sin copiarla a la nueva versión. La prueba real de Cloudinary aún no se declara aprobada. Render/HTTPS y el paquete macOS corresponden a etapas 5/6.

No se tocaron los archivos existentes de Canvas ni del demo de video. No se crearon commits ni se publicaron cambios.

## Avance de reproducción y Atlas

La guía se reprodujo en copia temporal desde guía 2, transcribiendo 24 archivos del Markdown. Instalación, check/build, 20 pruebas y cuatro recorridos aprobados; archivos y lock idénticos. Atlas real comprobado desde esa copia: MongoDB 8.0.39, índices, hash, persistencia y revocación. El verificador de imágenes con --provider-memory también pasó con repositorio real y proveedor simulado. Detalles en VERIFICACION.md.

Se recibieron variables de Cloudinary en el archivo de ejemplo. Se trasladaron al .env privado con permisos 0600 y se restauró el ejemplo sin secretos; git check-ignore confirma que el archivo privado está ignorado. No se copiaron esas variables al material docente ni a la reproducción. La primera validación informó invalid_format exclusivamente para CLOUDINARY_CLOUD_NAME; se solicitó corregirlo localmente. No se imprimieron valores ni se inició conexión externa con esa configuración inválida.

## Cierre de servicios reales

El docente corrigió CLOUDINARY_CLOUD_NAME localmente. Desde `gpb-dev/guia-03/server`: `node --env-file=.env --env-file=../../guia-01/server/.env scripts/check-images-atlas.js` aprobó con Atlas y Cloudinary reales. El segundo archivo aporta MongoDB en memoria, sin copiar su URI al nuevo proyecto; el verificador sustituye el secreto de sesión por uno efímero. Se comprobaron carga, sustitución, eliminación individual, propiedad/CSRF, persistencia y purga con varios recursos. Se limpiaron las cuentas, sesiones e imágenes exclusivas de la prueba.

Desde la reproducción aislada se ejecutó el mismo verificador transcrito, con rutas absolutas de ambos archivos privados como fuentes de entorno, sin copiarlos: también aprobado. La selección real de tareas del repositorio MongoDB se comprobó antes con proveedor simulado y después con Cloudinary real. `check-collection-atlas.js` pasó en referencia: carga idempotente, CRUD React, aislamiento y reinicios de navegador/API, autenticación y cierre; limpieza confirmada.

La revisión final encontró que un fallo incierto durante la prueba no debía borrar prematuramente su diario: el bloque finally del verificador ahora conserva el documento oculto y sus tareas cuando no hay confirmación de subida, para permitir reintentos seguros. El recorrido exitoso y su limpieza pasaron con ese bloque final en la reproducción.

Las exportaciones PNG y SVG oscuras de ambos diagramas se completaron con los controles nativos y se revisaron visualmente. Capturas finales de React renovadas tras ajustar espaciado y la altura mínima del reproductor; recorrido de imágenes aprobado (1/1, 3,4 s). El video externo de la prueba está sustituido por un mensaje explícito, no se afirma reproducción de contenido remoto.

## Comprobaciones finales adicionales

Se añadió una prueba significativa de bloqueo vencido: una carga queda pendiente, otra adquiere el bloqueo vencido y confirma una portada nueva, y la respuesta tardía de la primera se rechaza con 409 sin perder su tarea de limpieza. La pasada posterior elimina el recurso tardío y conserva la portada vigente. Suite final en referencia y en los bloques transcritos: **21/21 aprobadas**. El total anterior de 20 se conserva en este registro como historial de los incrementos.

Se corrigió la codificación UTF-8 del HTML que sustituye al video externo en la prueba de navegador. El recorrido de imágenes pasó en referencia (1/1, 4,0 s) y reproducción (1/1, 3,0 s), y se renovaron las capturas. No cambió la lógica de la aplicación.

Se preparó el borrador del sitio como _drafts, sin fecha editorial y con published:false/hidden:true. Jekyll y HTML-Proofer aprobaron la salida temporal (134 páginas); revisión de 24 bloques, imágenes y enlaces locales en curso de cierre documental en PUBLICACION.md. La publicación de la aplicación en Render sigue fuera de esta etapa.


## Publicación editorial autorizada

19/11/2026: publicación de guía 3 autorizada con fecha editorial 14/11/2026. Sitio: commit ad79b7d, Automatic build 44613832685 y Pages 44613932023 aprobados. Página pública HTTP 200, 24 bloques idénticos y 12 recursos verificados. Detalles en PUBLICACION.md y evidencia inicial en COMPROBACION-PUBLICA.json. Se actualizan las descargas con el cierre documental; no se modifica código de aplicación ni se publica en Canvas.
