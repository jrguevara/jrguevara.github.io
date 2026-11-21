# Etapa 1 — registro técnico

Fecha: 12 de noviembre de 2026. Plataforma: macOS Apple Silicon (arm64).

## Objetivo y estado

Configurar GPB y permitir registro, inicio y cierre de sesión con navegación protegida en modo oscuro. El dashboard es una pantalla inicial: estadísticas en etapa 4. Mi colección muestra únicamente el punto de continuación de etapa 2.

**Guía 1 final y reproducida, técnicamente lista para grabar. Publicación pendiente de indicaciones del docente.**

Este registro conserva el historial de implementación y redacción; los bloqueos iniciales de Atlas y aprobación se resolvieron. El resultado vigente se documenta al final y en VERIFICACION.md. No existe todavía guía redactada por ChatGPT ni reproducción independiente de esa guía. Las pruebas locales con memoria no acreditan persistencia en Atlas. Publicación real y paquete macOS son comprobaciones separadas de las etapas 5 y 6.

## Punto de partida

Sólo AGENTS.md, PLANIFICACION.md, skills y documentación preparatoria; sin aplicación ni repositorio Git. `git status --short` confirmó que no existe repositorio. No se crearon commits, etiquetas ni publicaciones. Se conserva una copia de fuentes de esta entrega y su inventario SHA-256; véase TRASPASO-CHATGPT.md.

## Entorno y versiones efectivas

Desde `/Users/jrguevara/Developer/MERN-electron` (raíz en el resto del documento):

```sh
node --version
pnpm --version
vp --version
uname -m
pnpm --filter @gpb/client exec vp --version
pnpm list -r --depth 0
pnpm --filter @gpb/server why mongodb
pnpm exec playwright --version
pnpm exec electron --version
pnpm dlx shadcn@4.23.0 --version
```

Resultados: Node v26.13.1, pnpm 12.18.0 (el registro anterior decía 11.25.0), CLI global y paquete local Vite+ 1.6.0, arm64, Playwright 1.65.0, Electron v45.3.1, shadcn CLI 4.23.0. No se modificaron instalaciones globales. La primera consulta mediante los shims de Vite+ falló por DNS en el entorno restringido; con acceso a red confirmó las versiones.

| Grupo | Versiones instaladas exactas |
|---|---|
| Cliente | React/React DOM 19.3.1; React Router 8.5.1 |
| Herramientas cliente | Vite+ 1.6.0; @vitejs/plugin-react 6.1.2; Tailwind/@tailwindcss/vite 4.3.5 |
| Componentes | cn 0.5.2; radix-ui 1.8.1; class-variance-authority 0.7.1; componentes shadcn copiados como JSX |
| API | Express 5.3.0; Mongoose 9.12.0; express-session 1.19.0; connect-mongo 6.0.0 |
| Validación/seguridad | argon2 0.45.2; Zod 4.6.7; Helmet 8.3.0; express-rate-limit 8.7.4 |
| Pruebas | @playwright/test 1.65.0; Electron 45.3.1; node:test integrado |

Mongoose requiere Node >=20.19 y usa driver ~7.8; connect-mongo admite Node >=20.8 y driver >=5. Se resolvió una sola versión mongodb 7.8.0 compartida por ambos. Compatibilidad de dependencias comprobada en instalación/importación; conectividad y versión del servidor Atlas todavía pendientes.

Vite+ local informó Vite 8.3.7, Rolldown 1.2.18, Vitest 5.1.0, Oxfmt 0.78.0, Oxlint 1.93.0, oxlint-tsgolint 7.0.2006 y tsdown 0.23.4. No se enseñan ni instalan individualmente: son herramientas del conjunto Vite+.

Fuentes oficiales, requisitos, descripción, motivo de uso, instalación y comprobaciones por herramienta: [FUENTES.md](FUENTES.md), consultadas el 12 de noviembre de 2026. Esta ficha debe acompañar el traspaso a ChatGPT.

## Incrementos y comandos realmente ejecutados

Todos los comandos siguientes se ejecutaron desde la raíz. Los archivos se escribieron directamente; los comandos de instalación no crean por sí solos el código de autenticación. El inventario adjunto identifica qué debe agregarse en cada incremento.

### 1. Generación y fijación por proyecto

Se consultaron `vp help create` y `vp create --list`. Comando de generación aceptado:

```sh
vp create vite --no-agent --no-editor --no-git --no-hooks --package-manager pnpm --no-interactive -- client --template react
```

Generó React JavaScript mediante create-vite 9.3.4. El instalador automático quedó sin progreso y se interrumpió; la instalación final se hizo desde el workspace raíz. La invocación previa con `--directory client` falló porque ese parámetro sólo sirve con plantillas builtin/bundled: no usarla en la guía.

Se escribieron `package.json`, `.node-version`, `pnpm-workspace.yaml` y los manifiestos de cliente/servidor, fijando versiones exactas. Se eliminó la configuración/lock anidados que produjo el generador: sólo hay un lock en raíz. `catalog:` resuelve versiones exactas de Vite+ y su alias oficial `vite`; no es una versión abierta.

```sh
pnpm install
```

La primera instalación rechazó el script nativo de argon2. pnpm 12 utiliza `allowBuilds` en `pnpm-workspace.yaml`; `onlyBuiltDependencies` y opciones de instalación en `.npmrc` no eran la configuración correcta para esta versión. Se corrigió el workspace (saveExact, engineStrict y allowBuilds) y se repitió `pnpm install`: script de argon2 correcto.

### 2. API independiente

Se crearon `server/src/config.js`, `users.js`, `app.js`, `index.js` y `server/.env.example`. Express, conexión Atlas y sesiones están fuera del cliente y de Electron. Node usa soporte nativo `--env-file` y `--watch`, sin dotenv/nodemon.

Se implementaron esquema de usuario, normalización, índices únicos, Argon2id, respuestas públicas sin hash, regeneración de sesión, cookie persistente, CSRF/origen, rate limiting, límites de cuerpo, errores en español y cierre ordenado. La API espera conexión e índices antes de escuchar. Los errores de arranque no imprimen URI ni secretos.

### 3. Cliente y componentes

Se configuraron React Router, Context de autenticación, fetch nativo, proxy `/api`, alias `@` y Tailwind. Se escribió `components.json` con `tsx:false`, estilo new-york y base zinc; se consultó `pnpm --filter @gpb/client dlx shadcn@4.23.0 init --help`, sin ejecutar init.

```sh
pnpm dlx shadcn@4.23.0 add button input label card --cwd client --yes
pnpm --filter @gpb/client add class-variance-authority@0.7.1
```

Se generaron cuatro componentes JSX. La dependencia CVA se agregó explícitamente porque Button la importaba y no quedó declarada al generar. Se conservaron componentes generados y versiones efectivas: el registro remoto de shadcn puede cambiar aunque se fije la CLI, por lo que la reproducción debe usar el código adjunto como referencia.

Se retiraron assets y contenido de demostración de la plantilla. Se implementaron registro, acceso, dashboard protegido, navegación, cierre de sesión, carga, reintento de conexión y errores. No se instalaron Recharts ni Cloudinary: todavía no hacen falta.

### 4. Pruebas de API y transporte

```sh
pnpm add -Dw @playwright/test@1.65.0 electron@45.3.1
pnpm exec playwright install chromium
pnpm exec install-electron
pnpm --filter @gpb/client exec vp check --fix
pnpm --filter @gpb/client exec vp fmt
pnpm install --frozen-lockfile
pnpm check
pnpm build
pnpm test
GPB_BROWSER_CHANNEL=chrome pnpm exec playwright test tests/web.spec.js
pnpm exec playwright test tests/electron.spec.js --timeout=20000
GPB_CAPTURE_DIR=/Users/jrguevara/Developer/MERN-electron/docs/etapas/01/capturas pnpm test:transport
```

La instalación congelada terminó sin cambios de resolución. `pnpm rebuild electron` no descargó un ejecutable: Electron 45 exige el comando explícito `install-electron`, que sí lo descargó. Chromium 158.0.8127.18, Headless Shell y FFmpeg se descargaron correctamente. Como comprobación inicial se utilizó Chrome ya instalado 144.0.7559.134 con un perfil temporal; no se utilizó el perfil personal del docente.

Correcciones durante las pruebas:

- `vp check` detectó formato y una advertencia de estado en un efecto. Se corrigieron el formato y la carga inicial asíncrona; comprobación final sin errores ni advertencias.
- Electron quedó esperando al usar `await app.whenReady()` a nivel superior. Se pasó a `app.whenReady().then(...)`, manteniendo ES Modules.
- `session.fetch`/`net.request` desde un origen opaco fueron bloqueados por CORP; `no-cors` no resolvió el bloqueo. Se descartaron. La propuesta de ampliar CORP de la API fue rechazada por revisión automática y **no se aplicó**. Solución comprobada: fetch nativo de Node en el proceso principal, origen/API fijos, acciones permitidas y almacén persistente de cookies Electron. Se conserva `helmet()` y no se abre CORS.
- Dos intentos de captura fuera de la vida del servidor de pruebas dieron conexión rechazada; se integró la captura opcional dentro del flujo Playwright. No es un defecto del cliente.

## Contrato y decisiones comprobables

| Ruta | Método | Función |
|---|---|---|
| /api/health | GET | Estado del proceso, sin credenciales ni sesión |
| /api/auth/csrf | GET | Token CSRF ligado a una sesión anónima/autenticada |
| /api/auth/register | POST | Valida, guarda hash, regenera y abre sesión |
| /api/auth/login | POST | Correo/contraseña, regenera y abre sesión |
| /api/auth/me | GET | Identidad pública; no renueva actividad |
| /api/auth/activity | POST | Renueva última actividad, sin extender inicio absoluto |
| /api/auth/logout | POST | Destruye sesión y elimina cookie |

Todos los POST exigen Origin exacto y X-CSRF-Token correcto. Códigos: 400 entradas inválidas/JSON, 401 sin identidad o vencimiento, 403 CSRF/origen, 409 duplicados, 413 cuerpo grande y 429 intentos excesivos. No hay endpoints de colección todavía.

Cookie host-only `gpb.sid`, HttpOnly, SameSite=Lax, Path=/api, Secure en producción, persistente hasta 7 días. Sesión regenerada al registrar o entrar, destruida al salir. Inactividad 30 min y máximo absoluto 7 días calculados por separado en servidor; el TTL de MongoDB sólo limpia almacenamiento y no sustituye la autorización.

GET y sondeos no cuentan como actividad. El cliente envía actividad ante pointerdown/keydown reales, visible y como máximo una vez/minuto. La identidad se consulta cada minuto y al recuperar foco. El servidor aplica expiración en cada operación; la interfaz puede tardar hasta un minuto en mostrar una expiración sin interacción. La actividad se registra con granularidad de hasta un minuto.

Web: llamadas relativas `/api`; proxy Vite en desarrollo. Para Render se deberá validar una regla rewrite/proxy pública a la API antes del fallback SPA, con POST/Origin/Set-Cookie preservados. No está publicada ni comprobada remotamente. Si el servicio no preserva ese contrato, debe resolverse antes de publicar; no sustituirlo por cookies de terceros.

Electron: el archivo `electron/session-probe.js` es sólo una prueba preparatoria. No contiene preload ni expone llamadas al renderer. Usa lista cerrada de acciones, sin redirects, timeout, cookie host-only con atributos comprobados y persistencia en la partición; las cookies sólo circulan en el proceso principal. La integración segura con React y el empaquetado siguen en etapa 6.

Rate limiting es por IP y proceso (20/15 min). Se deberá revisar almacén compartido antes de escalar horizontalmente. En producción `trust proxy=1` presupone una entrada por el proxy confiable de Render; comprobar la cadena real al desplegar.

## Resultados y límites

- **Comprobado:** entorno arm64, instalación congelada, importación de módulos nativos, cliente compilado, revisión sin advertencias, pruebas de API y flujo web.
- **Comprobado:** transporte mínimo Electron con reinicios de proceso y partición persistente; cierre de sesión revocado. No acredita paquete ni interfaz React en Electron.
- **Historial de bloqueo externo (resuelto al cierre):** conexión Atlas, versión real del clúster, índices y persistencia con connect-mongo. Se ejecutó `pnpm --filter @gpb/server check:atlas`: no completado. Se corrigió SESSION_SECRET local inválido generando un secreto criptográfico de 48 bytes sin imprimirlo ni modificar MONGODB_URI. Diagnóstico seguro posterior: configuración válida y fallo DNS al resolver el servidor Atlas. No se alcanzó la conexión ni se crearon colecciones de prueba. Pendiente confirmar el hostname copiado desde Atlas y repetir.
- **Pendiente posterior:** despliegue Render (etapa 5), cliente Electron y paquete arm64 (etapa 6), guía ChatGPT y reproducción independiente.

Las pruebas locales usan `session.MemoryStore` **sólo en fixtures** y usuarios aislados de prueba; producción exige store explícito MongoDB. Se comprueba separación de identidades; la propiedad de Gunpla se probará al implementarse en etapa 2. No hay funciones ni límites de imágenes que probar todavía.

## Continuación con Atlas (conexión aún no conseguida)

1. Desde raíz, copiar `server/.env.example` a `server/.env` sin sobrescribir si ya existe. Completar MONGODB_URI, SESSION_SECRET aleatorio de al menos 32 caracteres y conservar WEB_ORIGIN=http://localhost:5173. No poner secretos en React ni en el chat.
2. Atlas: clúster propio, usuario de base de datos e IP permitida; Connect → Drivers → Node.js. URI con base `/gpb`; codificar caracteres reservados del usuario/contraseña.
3. Desde raíz: `pnpm --filter @gpb/server check:atlas`. Crea colecciones únicas temporales `gpb_probe_*` y las limpia. Esperado: conexión, índices únicos, hash Argon2id, sesión tras reiniciar API y revocación; informa sólo versión MongoDB y resultado. Código revisado sintácticamente; ejecución intentada sin conexión por DNS.
4. Desde raíz, dos terminales: `pnpm dev:server` y `pnpm dev:client`. Abrir `http://localhost:5173`, registrar cuenta de prueba propia, salir, entrar y reabrir navegador. Reiniciar API sin cerrar sesión y comprobar persistencia.
5. Actualizar resultados en este registro, FUENTES.md, ESTADO.md y traspaso antes de cerrar etapa. No presentar estos pasos pendientes como ejecutados.

### Resumen numérico de comprobaciones finales

- `pnpm test`: **6/6** pruebas aprobadas, incluidas cookie Secure tras proxy HTTPS y cuerpo excesivo.
- `pnpm test:transport`: **2/2** pruebas aprobadas en 6,6 s, Chromium 158.0.8127.18 y Electron 45.3.1.
- Prueba adicional inicial Chrome 144.0.7559.134: **1/1** aprobada, perfil temporal.
- `pnpm check`: 14 archivos formateados; revisión de 9 archivos sin errores ni advertencias.
- `pnpm build`: correcta, 205 módulos. `pnpm install --frozen-lockfile`: correcta.
- Capturas acceso escritorio 1280×800 y móvil 390×844 inspeccionadas visualmente; sin datos de usuario ni secretos.
- `check:atlas`: **no completado por DNS**, configuración de variables válida después de generar secreto local.

## Archivos y material docente

Inventario por incremento y adjuntos en [TRASPASO-CHATGPT.md](TRASPASO-CHATGPT.md). Fuentes oficiales en [FUENTES.md](FUENTES.md). La copia conservada no incluye `.env`, dependencias, perfiles, cookies, tokens, informes de prueba ni archivos de compilación. El registro no es la guía final.


## Reproducción técnica de la copia conservada

Se extrajo `codigo-etapa-1.zip` en `/private/tmp/gpb-etapa01-ghex2f7z`, sin `.env` ni `node_modules`. Desde esa carpeta se ejecutó:

```sh
pnpm install --offline --frozen-lockfile
pnpm check
pnpm build
pnpm test
pnpm test:transport
```

Resultados: instalación correcta reutilizando los 303 paquetes de la caché local; script nativo argon2 correcto; check sin errores/advertencias; build de 205 módulos; 6/6 pruebas API y 2/2 pruebas de transporte aprobadas (8,7 s). Electron reutilizó su descarga disponible. No es una prueba de instalación en una máquina sin caché ni una reproducción de guía redactada: acredita la copia de fuentes y el lock en una carpeta aislada. Se verificaron los hashes del inventario frente al código actual.


## Nueva comprobación de Atlas — 12 de noviembre de 2026

A solicitud del docente se repitió desde raíz `pnpm --filter @gpb/server check:atlas`. SESSION_SECRET estaba nuevamente incompleto; se generó localmente un valor criptográfico sin imprimirlo ni modificar la URI. Las variables son válidas y el fallo actual ya no es DNS: Atlas **rechaza la autenticación**. Se comprobó mediante una conexión Mongoose aislada con diagnóstico por categoría, sin mostrar URI, host, usuario ni contraseña. No se alcanzaron las verificaciones de índices y persistencia. Pendiente revisar usuario de base de datos, contraseña y codificación URL en server/.env.


## Última comprobación de Atlas — correcta, 12 de noviembre de 2026

Desde la raíz se ejecutó nuevamente `pnpm --filter @gpb/server check:atlas`, después de que el docente corrigiera su configuración local. Terminó con código 0:

```text
Atlas comprobado: MongoDB 8.0.37; índices únicos, hash, sesión tras reiniciar la API y revocación correctos.
```

El verificador probó registro, unicidad, hash Argon2id, persistencia mediante connect-mongo al reiniciar la API y revocación al cerrar sesión. Sus colecciones temporales se limpiaron al terminar sin errores. No se imprimieron credenciales ni datos privados. Este resultado resuelve los bloqueos anteriores de DNS y autenticación; se conservan arriba como historial. La versión real del servidor es MongoDB 8.0.37. Queda pendiente ejecutar el cliente web contra la API real con Atlas y documentar ese flujo antes del cierre docente. No se modificó código de aplicación.


## Cierre de implementación — flujo web real con Atlas

Se agregó `server/scripts/check-web-atlas.js` y el script `check:web:atlas` en server/package.json. Es una comprobación adicional; no cambia código de aplicación ni dependencias. Desde raíz se ejecutó:

```sh
pnpm --filter @gpb/server check:web:atlas
```

Resultado: **código 0**, con salida:

```text
Web + Atlas comprobados: registro React, hash persistido, navegador y API reiniciados, navegación, credenciales incorrectas, nuevo acceso y cierre de sesión.
Cuenta y sesiones exclusivas de prueba eliminadas; procesos locales detenidos.
```

El verificador inicia la entrada real `server/src/index.js` con el archivo local privado y el cliente mediante la CLI local `vp dev`; usa Chromium con perfil temporal. Comprueba el hash en el documento realmente creado, reinicia API y navegador, y verifica la sesión persistida en MongoDB. Después elimina únicamente la cuenta aleatoria creada por la prueba y los identificadores de sesión observados en su perfil; elimina el perfil y detiene los procesos. No usa MemoryStore ni reemplaza los modelos productivos. No captura credenciales ni muestra errores con valores privados. Requiere configuración de desarrollo estándar y ambos puertos libres.

Resultado vigente: **etapa 1 implementada y comprobada**. Los diagnósticos pendientes mencionados en secciones históricas se resolvieron. Quedan la redacción de la guía en ChatGPT y su reproducción independiente; despliegue y paquete corresponden a etapas posteriores. Se actualizó el traspaso para que no arrastre pendientes resueltos. Se regeneraron copia de fuentes, inventario SHA-256 y paquete de material docente sin secretos. La reproducción aislada anterior cubrió la aplicación sin cambios; el nuevo verificador web se probó con Atlas real.


Comprobación final de instalación: una ejecución sin acceso al almacén externo intentó usar una caché nueva y falló por DNS del registro npm; se interrumpió y se repitió `pnpm install --offline --frozen-lockfile` con acceso a la caché comprobada: 303 paquetes reutilizados, instalación correcta y argon2 nativo correcto. No cambió el lock ni ninguna versión; este diagnóstico de herramientas no corresponde a Atlas. La copia final conserva 35 archivos de fuentes; `MATERIAL-CHATGPT.zip` añade planificación, reglas, estado, registro, fuentes oficiales, traspaso e imágenes de referencia.


## Primer punto de control Git

El docente inicializó Git en la raíz del proyecto, rama main, y autorizó el primer commit después de verificar que aún no existían commits ni archivos preparados. Se preparó el punto de control de la etapa 1 con el mensaje `Completa la etapa 1: configuración y autenticación`. Se revisó la exclusión de server/.env, dependencias y compilaciones, así como el contenido de los archivos ZIP. El identificador final se consulta con `git log -1 --oneline`; no se incluye aquí para evitar una referencia circular dentro del propio commit. No se crean etiquetas ni se publica el repositorio.


## Redacción del borrador para revisión docente

El 12 de noviembre de 2026 el docente solicitó que Codex redactara la guía 1 y la dejara para su revisión antes de reproducirla. Se creó `docs/guias/01-CONFIGURACION-Y-AUTENTICACION.md` a partir de las fuentes del commit `9900285`, con archivos completos, explicaciones progresivas, comandos por carpeta, resultados esperados/comprobados, errores frecuentes y fichas de herramientas. Se reflejó esta excepción de autoría y orden de revisión en PLANIFICACION.md y ESTADO.md.

Sólo se realizó una comprobación estática de la documentación y correspondencia de bloques de archivos con las fuentes. **No se ejecutó la guía, no se crearon proyectos de reproducción, no se volvieron a ejecutar sus pruebas ni se creó VERIFICACION.md.** La reproducción queda pendiente de la revisión e indicación posterior del docente. El código de aplicación y el punto de control 9900285 no cambian. No se crean commits por el hecho de redactar la guía. Las copias ZIP de implementación se conservan como estaban en ese commit y no contienen el borrador posterior.

La referencia editorial externa de la planificación no pudo abrirse mediante la herramienta web durante la redacción; no se atribuye a esa página contenido no consultado. Se mantuvo el formato docente definido en PLANIFICACION.md. Se consultó la fuente oficial de instalación Git para su explicación; las demás fuentes son las registradas para esta entrega.


## Versión final editorial de la guía 1

El docente autorizó finalizar la guía el 12 de noviembre de 2026, reservando para después sus indicaciones de publicación. Se cerró la redacción, se agregó un índice con enlaces y se revisaron claridad de carpetas, secuencia requerida y distinción de evidencias. Los 33 bloques de archivos mantienen el contenido de la implementación comprobada. No cambió código de aplicación.

Se leyó gpb-verificar-guia para preparar la comprobación de cierre y se creó `/private/tmp/gpb-guia01-final-6ip844om` a partir de preparación, con seis archivos de configuración transcritos de la guía y el lock del adjunto. El intento de ejecutar la secuencia inicial (`node --version`, `pnpm --version`, `uname -m`, instalación congelada y consultas de versiones) fue **rechazado antes de ejecutar el proceso** por revisión automática: la condición anterior del docente de revisar antes de reproducir exige autorización posterior explícita. No se intentó eludir el rechazo; no se instalaron dependencias ni ejecutaron pruebas en esa carpeta. La escritura posterior de fuentes API prevista en esa misma llamada tampoco se ejecutó.

La guía queda como **versión final editorial con reproducción técnica pendiente**, sin afirmación de lista para grabar. Se solicita autorización expresa para continuar esa reproducción; no se publica y no se crean nuevos commits o etiquetas. Los archivos ZIP conservan el material de implementación del commit inicial y no se sobrescriben con un cierre técnico no comprobado.


## Reproducción autorizada y cierre final de la guía 1

El docente respondió expresamente «sí» a reproducir la guía en copia aislada con Atlas y limpieza. Se realizó en `/private/tmp/gpb-guia01-validacion-j2m7nkqi`, comenzando con preparación y transcribiendo 33 bloques del documento; sólo el lock se extrajo del adjunto, como prescribe la guía. Las versiones, instalación congelada, API conectada, secreto privado, cliente, recorrido de navegador/reinicio API, check y build coincidieron. Después se ejecutaron las 6 pruebas API, 2 de transporte y ambos verificadores reales Atlas: todos aprobados. Se probaron las exclusiones de Git y el cambio de rama local a main.

Se incorporaron dos aclaraciones documentales (localhost frente al enlace de Vite+ y rama main), sin modificar aplicación. Se creó VERIFICACION.md con la secuencia, resultados y límites. Se limpiaron cuenta/sesiones/colecciones de prueba, perfiles, configuración privada aislada y procesos; los puertos quedaron libres. Se utilizó la caché existente para paquetes y ejecutables; no es una instalación de herramientas sobre un sistema operativo vacío.

**Resultado vigente: guía 1 final, reproducida y técnicamente lista para grabar.** El rechazo de aprobación anterior quedó resuelto por la autorización explícita; no se mantiene como pendiente. No se publicaron archivos ni servicios y no se crearon nuevos commits o etiquetas. El docente indicará posteriormente la publicación.
