# Traspaso — guía 2: gestión de la colección

Fecha: 18 de noviembre de 2026. Idioma: español, Markdown. Objetivo: cada usuario administra únicamente sus Gunpla, con grados/escalas consultados desde MongoDB. Base: guía 1 conservada en `gpb-dev/guia-01`, commit 91c189e. Código comprobado inicial: 86f4719169abde00082a9caacc5620565e8ac23d en `gpb-dev/guia-02`.

El docente autorizó en este chat que Codex redacte, reproduzca y publique la guía 2; el documento resultante está en `docs/guias/02-GESTION-DE-LA-COLECCION.md`. Este traspaso permite posteriores revisiones en ChatGPT y no sustituye la guía.

## Conocimientos y límites

JavaScript ES Modules, React y HTTP; autenticación de guía 1 terminada. Descripción y notas son los opcionales de esta entrega. Fotografías, galería, etiquetas y video se incorporan en guía 3; dashboard, búsqueda y filtros en guía 4. Mantener CSRF, cookies y límites de sesión. No solicitar instalación global ni credenciales en el chat.

## Incrementos enseñables

1. Derivar fuentes sin sobrescribir guía 1 ni copiar dependencias, secretos o compilaciones. Instalar con el lock anterior y comprobar versiones.
2. Modelos y catálogos con índice único por nombre, order y carga idempotente.
3. Validación Zod, router protegido y consultas por propietario; 404 indistinguible para ajenos/inexistentes.
4. Tarjetas, páginas de 12, detalle, formulario compartido, portada de reemplazo y confirmación.
5. Pruebas locales y Atlas, reproducción del texto, diagramas y publicación del material docente.

## Archivos que deben adjuntarse

ChatGPT no tiene acceso implícito a rutas locales ni a este chat. Adjuntar el ZIP de código, la guía, REGISTRO.md, FUENTES.md, VERIFICACION.md y DIAGRAMAS.md. Estos son los 15 archivos nuevos o sustituidos por los bloques de la guía, relativos a guia-02:

- `server/src/catalogs.js`
- `server/src/gunpla.js`
- `server/scripts/seed-catalogs.js`
- `server/package.json`
- `server/src/collection-routes.js`
- `server/src/app.js`
- `server/src/index.js`
- `client/src/collection/Collection.jsx`
- `client/src/App.jsx`
- `client/src/index.css`
- `server/test/collection-helpers.js`
- `server/test/collection.test.js`
- `tests/local-api.js`
- `tests/collection.spec.js`
- `server/scripts/check-collection-atlas.js`

Se mantienen el resto de archivos de guía 1: configuración y pruebas de autenticación, transporte Electron, componentes shadcn/ui, lib/api.js, AuthContext.jsx, manifiestos raíz/cliente y lock. README.md de guia-02 añade las instrucciones de uso. El inventario SHA-256 y el ZIP identifican todos los archivos de la versión entregada.

## Comandos y resultados

El orden reproducible completo se conserva en la guía (carpeta por comando). Preparación con rsync selectivo, instalación congelada, configuración privada propia, transcripción de los 15 bloques, carga doble de catálogos, check/build, 12 pruebas API, tres de navegador/Electron, check:atlas y check:collection:atlas. Reproducción completa aprobada; el informe incluye la corrección de un escape en el comando del secreto. No inventar un requisito de Cloudinary, Render ni paquete para esta entrega.

## Revisión editorial

Conservar las fichas de herramientas en el orden exigido por PLANIFICACION.md, los enlaces a diagramas y la distinción entre pruebas locales, Atlas, publicación del blog y despliegue de la aplicación. No sustituir los pasos por el registro técnico. No añadir código que no figure en el inventario.
