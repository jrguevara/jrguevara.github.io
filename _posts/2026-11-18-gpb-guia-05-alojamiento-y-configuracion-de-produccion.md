---
title: GPB — Gunpla Personal Builds | Guía 5 - Alojamiento y configuración de producción
date: 2026-11-18
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, nodeJS, mongodb, render, cloudinary, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

En la [guía 4](https://jrguevara.github.io/posts/gpb-guia-04-dashboard-y-exploracion/) completaste la búsqueda, los filtros y el dashboard de tu colección. En esta entrega vas a servir React por HTTPS y ejecutar Express en otro servicio de Render. Atlas conservará los datos y las sesiones, y Cloudinary entregará las fotografías.

Tu aplicación estará lista para esta etapa cuando puedas iniciar sesión desde la URL web, administrar un Gunpla con fotos y ver el cambio en el dashboard. Puedes ver la [instalación del curso](https://gpb-web.onrender.com/login). Para el ejercicio usa tus propias cuentas y despliegues.

## 1. Preparar la copia de la guía 4

Necesitas la guía 4 terminada, Git, Node.js 26.13.1 y pnpm 12.18.0. Para reproducir el ensayo HTTPS local necesitas Chromium para Playwright, OpenSSL y los puertos 3000, 5173 y 5443 libres. La compilación usa Vite+ 1.6.0 y las versiones fijadas en el lock anterior. Conserva las carpetas de las entregas previas.

Descarga [los archivos nuevos y modificados de la etapa 5]({{ '/assets/downloads/gpb/guia-05/GPB-GUIA-05.zip' | relative_url }}) a Descargas. Desde `gpb-dev`, crea una carpeta nueva y superpone esos archivos sobre las fuentes de la guía anterior.

```sh
mkdir guia-05 &&
rsync -a --exclude=node_modules --exclude=dist --exclude='.env*' --exclude=test-results --exclude=playwright-report --exclude='*.log' --exclude=.DS_Store guia-04/client guia-04/server guia-04/electron guia-04/tests guia-05/ &&
cp guia-04/package.json guia-04/pnpm-lock.yaml guia-04/pnpm-workspace.yaml guia-04/playwright.config.js guia-04/.gitignore guia-04/.node-version guia-05/ &&
unzip -o "$HOME/Downloads/GPB-GUIA-05.zip" -d guia-05 &&
cd guia-05
```

Los comandos locales restantes parten de `gpb-dev/guia-05` salvo que se indique otra carpeta.

## 2. Revisar los cambios y probar la aplicación

- `server/src/config.js` exige que `WEB_ORIGIN` sea un origen HTTPS exacto en producción y que estén presentes las tres variables de Cloudinary. `server/src/index.js` anuncia la fase fallida del arranque y los nombres de variables inválidas sin registrar sus valores. Express escucha en el puerto que proporciona Render tras conectar con MongoDB y preparar los índices.
- `client/src/lib/api.js` mantiene las llamadas en `/api` y rechaza redirecciones. El sondeo inicial de `/api/health` espera hasta 90 segundos. Las escrituras se realizan una sola vez. `client/src/auth/AuthContext.jsx` espera la salud antes de cargar la sesión y `client/src/App.jsx` muestra la espera y el botón de reintento.
- `playwright.https.config.js` y `tests/local-https.js` prueban `client/dist` con una terminación HTTPS local. `tests/local-api.js` configura la API de prueba y `tests/production.spec.js` comprueba la cookie segura, CSRF y la recuperación. `playwright.config.js` conserva los recorridos de desarrollo. `server/.env.example` documenta las variables, mientras que `README.md` y `render.yaml` describen las comprobaciones y la configuración de producción.

Desde la raíz de la etapa:

```sh
node --version
pnpm --version
pnpm install --frozen-lockfile
pnpm check
pnpm build
pnpm test
```

Se esperan 22 pruebas de API aprobadas. La compilación debe crear `client/dist/index.html`.

Para probar el cliente compilado por HTTPS local, **OpenSSL** genera un certificado efímero y **Playwright** abre Chromium con las cookies de terceros bloqueadas. En el ensayo se usaron OpenSSL 3.1.1 y Playwright 1.65.0. Comprueba que OpenSSL esté instalado y descarga Chromium con el comando de Playwright si todavía falta. [OpenSSL](https://openssl-library.org/source/) · [Primeros pasos con Playwright](https://playwright.dev/docs/intro).

```sh
openssl version
pnpm exec playwright install chromium
pnpm exec playwright test -c playwright.https.config.js
```

Se esperan cinco recorridos aprobados. Las pruebas automatizadas de este paso usan un certificado temporal y datos ficticios. Éste es el aspecto de la recuperación tras una indisponibilidad simulada.

![Reintento en la prueba HTTPS local, vista móvil]({{ '/assets/downloads/gpb/guia-05/capturas/reintentar-movil.png' | relative_url }})

[Abrir PNG completo — Reintento en la prueba HTTPS local, vista móvil]({{ '/assets/downloads/gpb/guia-05/capturas/reintentar-movil.png' | relative_url }})

## 3. Preparar los datos y las imágenes

**Atlas** aloja la base de datos de GPB. Reutiliza el acceso de la guía 3 o prepara una base propia y un usuario con permiso de lectura y escritura sobre ella. Guarda su URI en `MONGODB_URI` dentro de `server/.env`, usando el ejemplo como referencia. Autoriza tu IP para ejecutar la carga local. Los secretos van en el archivo privado local y en **Environment** de la API de Render. [Conectar a un clúster Atlas](https://www.mongodb.com/docs/atlas/connect-to-database-deployment/).

```sh
cp -n server/.env.example server/.env
```

Completa el archivo privado con la URI de tu base y las demás variables que valida la API. Desde la raíz de la etapa, carga los catálogos de la base que usarás en Render.

```sh
pnpm --filter @gpb/server seed:catalogs
```

Se esperan 12 grados y 5 escalas. Puedes repetir el comando sin duplicar entradas. Comprueba también estos tamaños en el formulario publicado.

**Cloudinary** almacena las fotografías y las entrega por HTTPS. Reutiliza el SDK 2.11.0 del lock y prepara el nombre de nube, la clave y el secreto de tu cuenta. Van en `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY` y `CLOUDINARY_API_SECRET` de la API. Verifica la versión con el gestor y comprueba el servicio al subir una portada en el paso 7. [Primeros pasos con el SDK de Node.js](https://cloudinary.com/documentation/node_integration).

```sh
pnpm --filter @gpb/server list cloudinary --depth 0
```

## 4. Crear el sitio web en Render

**Render** construye el cliente desde Git y ejecuta la API Express en un servicio separado. Para el ejercicio se usó un Static Site y un Web Service Free en una cuenta del docente. Necesitas una rama con la etapa 5 en un repositorio al que Render pueda acceder. El [inicio oficial de Render](https://render.com/docs/your-first-deploy) explica cómo conectar el proveedor Git. Las fuentes oficiales se consultaron el 19/11/2026.

En Render, crea un **Static Site** con un nombre propio. El dominio exacto se asigna al crear el servicio. Esta tabla supone que la copia está en `gpb-dev/guia-05` dentro del repositorio.

| Campo de Render | Valor |
|---|---|
| Root Directory | `gpb-dev/guia-05` |
| Publish Directory | `client/dist` |
| NODE_VERSION | `26.13.1` |
| SKIP_INSTALL_DEPS | `true` |

Usa como **Build Command**, que Render ejecuta en el directorio raíz indicado:

```sh
npx --yes pnpm@12.18.0 --filter @gpb/client install --prod=false --frozen-lockfile && npx --yes pnpm@12.18.0 --filter @gpb/client build
```

Espera el estado **Live**, guarda la URL asignada y confirma en los registros la compilación y la versión de Node. Los datos privados se configuran en el servicio de API. [Sitios estáticos](https://render.com/docs/static-sites) · [Versiones de Node en Render](https://render.com/docs/node-version).

## 5. Crear el servicio de API en Render

Crea un **Web Service** de Node, selecciona la misma rama y el plan **Free**. En **Advanced**, configura `/api/health` como **Health Check Path**. En la instalación del curso se desactivaron los despliegues automáticos para poder verificar cada cambio antes de enviarlo.

| Campo de Render | Valor |
|---|---|
| Root Directory | `gpb-dev/guia-05` |
| NODE_VERSION | `26.13.1` |
| NODE_ENV | `production` |
| SKIP_INSTALL_DEPS | `true` |
| WEB_ORIGIN | El origen HTTPS exacto del sitio web, sin ruta ni barra final |
| MONGODB_URI | URI privada que apunta a la base donde cargaste los catálogos |
| SESSION_SECRET | Valor estable generado con **Generate** |
| CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY y CLOUDINARY_API_SECRET | Valores de tu cuenta ingresados en **Environment** |

**Build Command** y **Start Command**, respectivamente:

```sh
npx --yes pnpm@12.18.0 --filter @gpb/server install --prod --frozen-lockfile
```

```sh
node server/src/index.js
```

En **Connect → Outbound IP Addresses** de la API, localiza los rangos que Render asignó a tu servicio. Agrégalos en **Database & Network Access → IP Access List** del proyecto Atlas y espera a que figuren activos. Esos rangos son compartidos por servicios de la región. MongoDB sigue exigiendo las credenciales de base. Render suministra `PORT`; en la referencia la API escuchó en el puerto 10000. Abre por HTTPS `/api/health` en el dominio de la API. Debe devolver `{"status":"ok"}`. [IP saliente de Render](https://render.com/docs/outbound-ip-addresses) · [Lista de acceso Atlas](https://www.mongodb.com/docs/atlas/security/ip-access-list/) · [Comprobaciones de salud](https://render.com/docs/health-checks).

El archivo `render.yaml` de los adjuntos recoge la configuración como plantilla de Blueprint. En la práctica se configuraron los servicios en el panel de Render, con los dominios realmente asignados. Si usas la plantilla, personaliza ambos nombres y el destino de la regla antes de aplicarla. [Inicio de Blueprints](https://render.com/docs/infrastructure-as-code).

## 6. Conectar el navegador a la API bajo el mismo origen

En **Redirects/Rewrites** del Static Site, guarda estas reglas en orden, con el dominio de tu propia API.

| Acción | Source | Destination |
|---|---|---|
| Rewrite | `/api/*` | `https://<host-de-tu-api>/api/*` |
| Rewrite | `/*` | `/index.html` |

El navegador pide `/api` al mismo origen de la web. Render reenvía al servicio Express por HTTPS. La primera regla evita que React responda a una llamada de API. La segunda permite abrir directamente `/login` o `/registro` y recargar la página. [Reglas de Render](https://render.com/docs/redirects-rewrites).

En la instalación pública se verificó que el proxy conserve el `Origin` del navegador y que devuelva `Set-Cookie`. La cookie pertenece al host web, tiene `Secure`, `HttpOnly`, `SameSite=Lax` y `Path=/api`. La API exige el origen exacto y un token CSRF válido al escribir. El bloqueo de cookies de terceros está activado en la comprobación de navegador local.

## 7. Verificar la aplicación publicada

1. Abre el sitio por HTTPS, visita directamente `/registro` y recarga. Consulta `/api/health` bajo el dominio web. Debe responder JSON con estado 200.
2. Crea una cuenta de prueba. Abre las herramientas del navegador y confirma que el registro se envía al dominio web y que la cookie se conserva al recargar. Para guardar evidencia, anota únicamente estados y nombres de atributos. Cierra sesión y vuelve a entrar.
3. Abre **Mi colección**, elige un grado y una escala, y guarda un Gunpla. Edita su estado y comprueba que puedes encontrarlo con la búsqueda y los filtros. Comprueba que el dashboard refleja la modificación.
4. Sube una portada y una foto de galería que tengas permiso de usar. Verifica que se carguen desde Cloudinary por HTTPS. Sustituye la portada y retira una foto. Con una segunda cuenta comprueba que el Gunpla no aparece y que la URL directa no da acceso. Al terminar, elimina el Gunpla de prueba.

![Formulario de edición local, vista móvil]({{ '/assets/downloads/gpb/guia-05/capturas/formulario-editar-movil.png' | relative_url }})

[Abrir PNG completo — Formulario de edición local, vista móvil]({{ '/assets/downloads/gpb/guia-05/capturas/formulario-editar-movil.png' | relative_url }})

![Detalle local del RG MS-06F Zaku II con portada y galería]({{ '/assets/downloads/gpb/guia-05/capturas/detalle-escritorio.png' | relative_url }})

[Abrir PNG completo — Detalle local del RG MS-06F Zaku II con portada y galería]({{ '/assets/downloads/gpb/guia-05/capturas/detalle-escritorio.png' | relative_url }})

![Dashboard local con datos ficticios]({{ '/assets/downloads/gpb/guia-05/capturas/dashboard-escritorio.png' | relative_url }})

[Abrir PNG completo — Dashboard local con datos ficticios]({{ '/assets/downloads/gpb/guia-05/capturas/dashboard-escritorio.png' | relative_url }})

Estas tres capturas del recorrido se hicieron con datos ficticios en el ensayo local. En el despliegue se verificaron también el aislamiento entre cuentas, el rechazo de entradas inválidas, el CRUD, el dashboard y las imágenes reales en Cloudinary. Las fotos del RG MS-06F Zaku II son de Gravis y se redujeron bajo CC BY-SA 4.0. [Caja del kit](https://commons.wikimedia.org/wiki/File:Gunpla_model_packed.jpg) · [Pieza montada](https://commons.wikimedia.org/wiki/File:Gunpla_foot_assembly.jpg) · [Licencia](https://creativecommons.org/licenses/by-sa/4.0/).

## 8. Observar la reactivación y diagnosticar fallos

Render puede suspender el Web Service Free tras 15 minutos sin tráfico. Cierra las pestañas que estén usando GPB y deja de enviar peticiones de prueba. Al volver a abrir `/login`, observa el mensaje de conexión y mide el tiempo hasta que aparezca el formulario. En la comprobación pública, tras más de 16 minutos sin peticiones de prueba, salud respondió a los 23,22 segundos y el formulario apareció a los 24,45 segundos. Render registró un nuevo arranque de Express. Es el tiempo de ese ensayo. [Límites del plan gratuito](https://render.com/docs/free).

![Espera durante la reactivación real en Render]({{ '/assets/downloads/gpb/guia-05/capturas/render-reactivacion-escritorio.png' | relative_url }})

[Abrir PNG completo — Espera durante la reactivación real en Render]({{ '/assets/downloads/gpb/guia-05/capturas/render-reactivacion-escritorio.png' | relative_url }})

![Formulario de acceso público después de la reactivación]({{ '/assets/downloads/gpb/guia-05/capturas/render-acceso-escritorio.png' | relative_url }})

[Abrir PNG completo — Formulario de acceso público después de la reactivación]({{ '/assets/downloads/gpb/guia-05/capturas/render-acceso-escritorio.png' | relative_url }})

| Síntoma | Qué revisar |
|---|---|
| El build pasa y Express sale con código 1 | Lee la fase del registro. Si falla al validar, revisa los nombres de variables y el origen exacto. Si falla al conectar, revisa la URI, las credenciales y los rangos activos en Atlas. |
| La salud funciona en el dominio de la API y devuelve HTML en el dominio web | Revisa el destino y el orden de las dos reescrituras. |
| Un formulario devuelve 403 tras cambiar el dominio web | Actualiza `WEB_ORIGIN` en la API, vuelve a desplegar e inicia sesión en el dominio nuevo. |
| El catálogo está vacío | Comprueba que ejecutaste la carga con la misma base que usa Render. |
| Se agotan los 90 segundos de espera | Consulta el estado en Render. Cuando la API esté lista, usa **Reintentar conexión**. |

## 9. Cerrar la etapa

La web publicada debe permitirte abrir directamente una ruta, iniciar sesión y usar la colección, las imágenes y el dashboard. En esta etapa se comprobó la reactivación real y la revocación de sesión. La persistencia de una sesión autenticada tras un reinicio controlado de Render queda como comprobación independiente.

En la guía 6 usarás la API alojada para integrar el cliente React con Electron y generar un paquete para macOS Apple Silicon.
