# Etapa 3 — fuentes y herramientas

Consulta: 19/11/2026. Las instrucciones de instalación se adaptan al workspace pnpm de GPB. No se cambiaron herramientas globales.

## Cloudinary SDK 2.11.0

SDK de gestión de imágenes: GPB lo usa exclusivamente en Express para subir buffers validados y eliminar recursos por identificador asignado en el servidor. Las imágenes usan entrega HTTPS pública; los secretos nunca llegan a React ni a Electron.

- Getting Started: https://cloudinary.com/documentation/node_quickstart
- Carga con upload_stream: https://cloudinary.com/documentation/node_image_and_video_upload
- Eliminación e invalidación: https://cloudinary.com/documentation/image_upload_api_reference
- Requisitos: cuenta con producto Image & Video, cloud name, API key y API secret; el paquete declara Node >=9, GPB fija Node 26.13.1.
- Instalación desde `gpb-dev/guia-03`: `pnpm --filter @gpb/server add --save-exact cloudinary@2.11.0`.
- Versión: `pnpm --filter @gpb/server list --depth 0`; no tiene CLI de versión propia.
- Funcionamiento local: adaptador simulado en pruebas. Funcionamiento real: verificador de imágenes aprobado con Atlas y Cloudinary, tanto en referencia como en reproducción. Una instalación correcta no demuestra conectividad ni permisos de la cuenta.

## Multer 2.5.0

Middleware multipart de Express. Recibe un único campo `image`, sin campos de texto adicionales. GPB aplica autenticación, CSRF y propiedad antes de reservar memoria. Dos cargas por proceso como máximo; un bloqueo persistente adicional serializa operaciones de imágenes del mismo Gunpla.

- Getting Started e instalación: https://expressjs.com/en/resources/middleware/multer/
- Requisito publicado: Node >=10.16.0; GPB usa Node 26.13.1.
- Instalación desde `gpb-dev/guia-03`: `pnpm --filter @gpb/server add --save-exact multer@2.5.0`.
- Versión: `pnpm --filter @gpb/server list --depth 0`.
- Funcionamiento: pruebas HTTP reales contra API temporal; rechazo de exceso de 5 MiB, archivos múltiples, campos extra y cargas simultáneas.

## Sharp 0.35.5

Procesador nativo de imágenes. GPB verifica el formato real, decodifica el archivo y lo reexporta a WebP sin metadatos, antes de enviarlo a Cloudinary. Evita confiar en el nombre y MIME aportados por el navegador.

- Getting Started: https://sharp.pixelplumbing.com/install/
- Constructor, límites y validación: https://sharp.pixelplumbing.com/api-constructor/
- Requisitos del paquete: Node >=20.9.0. Se comprobó instalación nativa en macOS arm64 con Node 26.13.1.
- Instalación desde `gpb-dev/guia-03`: `pnpm --filter @gpb/server add --save-exact sharp@0.35.5`.
- Versión: `pnpm --filter @gpb/server list --depth 0`.
- Funcionamiento: PNG/JPEG/WebP decodificados en las pruebas; rechazo de extensión falsa, MIME discordante y archivos dañados. Límite de 25 megapíxeles, una página, salida hasta 2400 × 2400 conservando proporciones, calidad WebP 85: decisiones de GPB para memoria y tamaño; no son límites obligatorios del proveedor.

Las tres dependencias se instalaron juntas mediante `pnpm --filter @gpb/server add --save-exact cloudinary@2.11.0 multer@2.5.0 sharp@0.35.5`, y luego `pnpm install --frozen-lockfile` completó el workspace. Node 26.13.1, pnpm 12.18.0 y Vite+ 1.6.0 se conservan de la etapa anterior.

## YouTube

Se construye el iframe desde un identificador validado de once caracteres; no se acepta HTML. Se utiliza youtube-nocookie.com, carga diferida y no se activa reproducción automática. Un enlace válido no demuestra que el video exista ni permita inserción.

- Reproductor integrado: https://developers.google.com/youtube/player_parameters
- El navegador de pruebas sustituye únicamente la respuesta externa para no depender de anuncios, disponibilidad ni consentimiento. Esa prueba comprueba la URL construida y la interfaz; no demuestra reproducción remota del video.
