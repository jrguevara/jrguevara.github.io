# Etapa 1 — herramientas y fuentes oficiales

Consulta: 12 de noviembre de 2026. Este material es técnico, no la guía docente. Las descripciones se adaptan a GPB; las URL son fuentes oficiales. Las versiones sin CLI se consultan mediante pnpm, nunca con opciones inventadas. Todos los comandos de esta ficha se ejecutan desde la raíz del proyecto. La instalación final reproducible usa los manifiestos adjuntos y `pnpm install --frozen-lockfile`.

## Node.js — 26.13.1

1. **Qué es:** Runtime JavaScript para API y herramientas.
2. **Uso en GPB:** Unifica la versión local y la prevista para Render.
3. **Getting Started:** [Node.js](https://nodejs.org/en/download).
4. **Requisitos y versión:** macOS arm64; ya instalado por el docente. Se fija en .node-version y engines; no se instaló globalmente. Versión elegida: 26.13.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `node --version`. Resultado efectivo: v26.13.1; pruebas con node:test ejecutadas.

## pnpm — 12.18.0

1. **Qué es:** Gestor de paquetes y workspaces.
2. **Uso en GPB:** Conserva una resolución exacta para cliente y API.
3. **Getting Started:** [pnpm](https://pnpm.io/installation).
4. **Requisitos y versión:** Disponible mediante el entorno existente Vite+; packageManager fija la versión, sin actualización global. Versión elegida: 12.18.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --version`. Resultado efectivo: 12.18.0; pnpm install --frozen-lockfile terminó correctamente.

## Vite+ — 1.6.0

1. **Qué es:** Conjunto de herramientas detrás de vp.
2. **Uso en GPB:** Desarrolla, compila, da formato y revisa React con una CLI local.
3. **Getting Started:** [Vite+](https://viteplus.dev/guide/).
4. **Requisitos y versión:** Node ^22.18, ^24.11 o >=26. Global opcional ya existente; paquete local exacto vía manifiesto y pnpm install. Versión elegida: 1.6.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client exec vp --version`. Resultado efectivo: CLI/local 1.6.0; Vite 8.3.7, Rolldown 1.2.18, Vitest 5.1.0, Oxfmt 0.78.0, Oxlint 1.93.0, oxlint-tsgolint 7.0.2006, tsdown 0.23.4. Build y check correctos.

## React y React DOM — 19.3.1

1. **Qué es:** Biblioteca de componentes y renderizador web.
2. **Uso en GPB:** Construyen formularios y estado de autenticación.
3. **Getting Started:** [React y React DOM](https://react.dev/learn/installation).
4. **Requisitos y versión:** Node y Vite+ configurados. Dependencias exactas declaradas en client/package.json; pnpm install desde raíz. Versión elegida: 19.3.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list react react-dom --depth 0`. Resultado efectivo: 19.3.1 ambos; flujo web comprobado con Chrome.

## Plugin React de Vite — 6.1.2

1. **Qué es:** Integración de React con la herramienta de desarrollo.
2. **Uso en GPB:** Transforma JSX y mantiene el ciclo de desarrollo.
3. **Getting Started:** [Plugin React de Vite](https://github.com/vitejs/vite-plugin-react/tree/main/packages/plugin-react).
4. **Requisitos y versión:** Node ^20.19 o >=22.12. Manifiesto del cliente y pnpm install en raíz. Versión elegida: 6.1.2.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list @vitejs/plugin-react --depth 0`. Resultado efectivo: 6.1.2; compilación correcta con el alias Vite+ del workspace.

## React Router — 8.5.1

1. **Qué es:** Navegación declarativa para React.
2. **Uso en GPB:** Separa acceso, registro y rutas protegidas.
3. **Getting Started:** [React Router](https://reactrouter.com/start/declarative/installation).
4. **Requisitos y versión:** Node >=22.22. Se declara exacto en client/package.json y se instala desde raíz. Versión elegida: 8.5.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list react-router --depth 0`. Resultado efectivo: 8.5.1; redirección al login y navegación comprobadas.

## Tailwind CSS y plugin Vite — 4.3.5

1. **Qué es:** Estilos utilitarios y su integración de compilación.
2. **Uso en GPB:** Estilizan shadcn/ui y el modo oscuro de GPB.
3. **Getting Started:** [Tailwind CSS y plugin Vite](https://tailwindcss.com/docs/installation/using-vite).
4. **Requisitos y versión:** Cliente React/Vite+ configurado. Ambos paquetes exactos en manifiesto; pnpm install raíz; plugin en vite.config.js e import CSS. Versión elegida: 4.3.5.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list tailwindcss @tailwindcss/vite --depth 0`. Resultado efectivo: 4.3.5 ambos; CSS compilado y formulario renderizado.

## shadcn/ui CLI — 4.23.0

1. **Qué es:** Generador que copia componentes editables al proyecto.
2. **Uso en GPB:** Aporta Button, Input, Label y Card sin añadir pantallas ajenas a la etapa.
3. **Getting Started:** [shadcn/ui CLI](https://ui.shadcn.com/docs/installation/vite).
4. **Requisitos y versión:** React, Tailwind, alias @ y components.json con tsx:false. Desde raíz: pnpm dlx shadcn@4.23.0 add button input label card --cwd client --yes. Versión elegida: 4.23.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm dlx shadcn@4.23.0 --version`. Resultado efectivo: Versión fijada y comprobada: 4.23.0. Se ejecutaron init --help, add y --version (4.23.0). Cuatro componentes JSX generados y compilados; no hay paquete runtime shadcn.

## Radix UI — 1.8.1

1. **Qué es:** Primitivas accesibles utilizadas por los componentes.
2. **Uso en GPB:** Implementa Label y composición Slot de Button.
3. **Getting Started:** [Radix UI](https://www.radix-ui.com/primitives/docs/overview/getting-started).
4. **Requisitos y versión:** React. Instalado por shadcn y fijado en el manifiesto del cliente. Versión elegida: 1.8.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list radix-ui --depth 0`. Resultado efectivo: 1.8.1; renderizado y formularios comprobados.

## cn — 0.5.2

1. **Qué es:** Combinador de clases y resolución de conflictos de Tailwind.
2. **Uso en GPB:** Los componentes actuales de shadcn lo importan directamente.
3. **Getting Started:** [cn](https://github.com/shadcn-ui/cn#readme).
4. **Requisitos y versión:** Cliente React/Tailwind. Instalado por shadcn, versión exacta en manifiesto. Versión elegida: 0.5.2.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list cn --depth 0`. Resultado efectivo: 0.5.2; compilación y estilos correctos.

## Class Variance Authority — 0.7.1

1. **Qué es:** Composición de variantes de clases.
2. **Uso en GPB:** Button lo utiliza para variantes y tamaños.
3. **Getting Started:** [Class Variance Authority](https://cva.style/getting-started/installation/).
4. **Requisitos y versión:** Cliente preparado. Desde raíz: pnpm --filter @gpb/client add class-variance-authority@0.7.1. Versión elegida: 0.7.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/client list class-variance-authority --depth 0`. Resultado efectivo: 0.7.1; Button compila y funciona.

## Express — 5.3.0

1. **Qué es:** Framework HTTP para Node.
2. **Uso en GPB:** API independiente del cliente y de Electron.
3. **Getting Started:** [Express](https://expressjs.com/en/starter/installing/).
4. **Requisitos y versión:** Node >=18. Dependencia exacta de server/package.json; pnpm install raíz. Versión elegida: 5.3.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list express --depth 0`. Resultado efectivo: 5.3.0; pruebas HTTP de API correctas.

## Mongoose — 9.12.0

1. **Qué es:** Modelos, esquemas e índices para MongoDB.
2. **Uso en GPB:** Valida persistencia del usuario e índices únicos.
3. **Getting Started:** [Mongoose](https://mongoosejs.com/docs/index.html).
4. **Requisitos y versión:** Node >=20.19 y MongoDB compatible. Dependencia exacta de servidor; pnpm install raíz. Versión elegida: 9.12.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list mongoose --depth 0`. Resultado efectivo: 9.12.0; importación correcta. Conexión Atlas e índices únicos comprobados con MongoDB 8.0.37.

## express-session — 1.19.0

1. **Qué es:** Middleware de sesiones del servidor.
2. **Uso en GPB:** Usa cookie con identificador revocable en lugar de guardar identidad en React.
3. **Getting Started:** [express-session](https://expressjs.com/en/resources/middleware/session/).
4. **Requisitos y versión:** Express y secreto privado de 32 caracteres mínimo. Dependencia exacta del servidor; pnpm install raíz. Versión elegida: 1.19.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list express-session --depth 0`. Resultado efectivo: 1.19.0; regeneración, cookie, expiración y revocación HTTP comprobadas con MemoryStore de prueba.

## connect-mongo — 6.0.0

1. **Qué es:** Almacén persistente de sesiones MongoDB.
2. **Uso en GPB:** Conserva sesiones al reiniciar API y evita depender de memoria en Render.
3. **Getting Started:** [connect-mongo](https://github.com/jdesboeufs/connect-mongo#readme).
4. **Requisitos y versión:** Node >=20.8, express-session ^1.17.1 y driver mongodb >=5. Comparte cliente Mongoose; instalado desde manifiesto servidor. Versión elegida: 6.0.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server why mongodb`. Resultado efectivo: Driver único 7.8.0 compatible con ambos paquetes. Persistencia real Atlas comprobada con reinicio de API; prueba separada de las fixtures de memoria.

## Argon2 — 0.45.2

1. **Qué es:** Implementación nativa de hash de contraseñas.
2. **Uso en GPB:** Almacena hash Argon2id, nunca contraseñas en texto.
3. **Getting Started:** [Argon2](https://github.com/ranisalt/node-argon2#readme).
4. **Requisitos y versión:** Node >=16.17 y binario compatible. Dependencia servidor; allowBuilds autoriza sólo argon2; pnpm install raíz. Versión elegida: 0.45.2.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list argon2 --depth 0`. Resultado efectivo: 0.45.2; binario arm64 instalado, hash y verificación reales correctos.

## Zod — 4.6.7

1. **Qué es:** Validación declarativa de entradas JavaScript.
2. **Uso en GPB:** Rechaza cuerpos inválidos y configuración incompleta.
3. **Getting Started:** [Zod](https://zod.dev/).
4. **Requisitos y versión:** JavaScript ES Modules. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 4.6.7.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list zod --depth 0`. Resultado efectivo: 4.6.7; entradas inválidas rechazadas en pruebas.

## Helmet — 8.3.0

1. **Qué es:** Middleware de encabezados de seguridad.
2. **Uso en GPB:** Configura respuestas de la API.
3. **Getting Started:** [Helmet](https://helmetjs.github.io/).
4. **Requisitos y versión:** Express configurado. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 8.3.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list helmet --depth 0`. Resultado efectivo: 8.3.0; cargado en todas las pruebas HTTP.

## express-rate-limit — 8.7.4

1. **Qué es:** Límite de solicitudes por IP.
2. **Uso en GPB:** Limita registro y acceso a 20 intentos por 15 minutos en una instancia.
3. **Getting Started:** [express-rate-limit](https://express-rate-limit.mintlify.app/quickstart/installation).
4. **Requisitos y versión:** Express. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 8.7.4.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server list express-rate-limit --depth 0`. Resultado efectivo: 8.7.4; respuesta 429 comprobada. Contador local por proceso; antes de escalar instancias se requerirá almacenamiento compartido.

## MongoDB Atlas — MongoDB 8.0.37

1. **Qué es:** Servicio de base de datos MongoDB.
2. **Uso en GPB:** Guarda usuarios y sesiones sin servidor local del estudiante.
3. **Getting Started:** [MongoDB Atlas](https://www.mongodb.com/docs/atlas/getting-started/).
4. **Requisitos y versión:** Cuenta propia, clúster Free, usuario de base de datos e IP permitida. Connect → Drivers → Node.js; URI privada en server/.env. No requiere instalar una CLI. Versión real del clúster comprobada: MongoDB 8.0.37.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm --filter @gpb/server check:atlas`. Resultado efectivo: conexión y comprobaciones correctas, código 0. El comando de proyecto verifica conexión, índices, hash, persistencia tras reiniciar API y revocación; crea y elimina colecciones temporales gpb_probe_*.

## Playwright — 1.65.0

1. **Qué es:** Automatización de navegador y Electron.
2. **Uso en GPB:** Comprueba flujos reales y reapertura con perfiles temporales.
3. **Getting Started:** [Playwright](https://playwright.dev/docs/intro).
4. **Requisitos y versión:** macOS arm64 con Chrome o Chromium y Electron. Desde raíz: pnpm add -Dw @playwright/test@1.65.0 electron@45.3.1; pnpm exec playwright install chromium. Versión elegida: 1.65.0.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm exec playwright --version`. Resultado efectivo: 1.65.0 fijado; prueba web aprobada con Chrome instalado 144.0.7559.134. Chromium 158.0.8127.18 descargado; resultado adicional en REGISTRO.md.

## Electron — 45.3.1

1. **Qué es:** Contenedor de escritorio basado en Chromium y Node.
2. **Uso en GPB:** Prueba mínima de transporte persistente, preparatoria para la etapa 6.
3. **Getting Started:** [Electron](https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app).
4. **Requisitos y versión:** Node >=22.12 para instalación. Dependencia de desarrollo raíz; pnpm exec install-electron descarga el binario explícitamente en esta versión. Versión elegida: 45.3.1.
5. **Instalación/configuración:** véase el paso 4 y la secuencia de REGISTRO.md; las adaptaciones por proyecto no requieren instalación global.
6. **Comprobación:** `pnpm exec electron --version`. Resultado efectivo: Paquete y binario 45.3.1 comprobados con --version. Resultado de transporte se registra en REGISTRO.md; no equivale a un paquete distribuible.

## Referencias complementarias

- [Creación de proyecto Vite+](https://viteplus.dev/guide/create): sintaxis de plantillas.
- [Configuración pnpm 12](https://pnpm.io/settings): configuración por workspace y allowBuilds.
- [Pruebas nativas de Node](https://nodejs.org/api/test.html): ejecutor usado para API.
- [Sesiones Electron](https://www.electronjs.org/docs/latest/api/session) y [red Electron](https://www.electronjs.org/docs/latest/api/net): partición persistente; GPB adapta el transporte con fetch de Node para conservar CORP/CORS de la API.
- [Rewrites Render](https://render.com/docs/redirects-rewrites): admite destinos públicos; adaptación de proxy bajo el origen web por validar en publicación real, incluidos POST, Origin y Set-Cookie.


## Resultados reales de Atlas al cierre — 12 de noviembre de 2026

MongoDB 8.0.37. `pnpm --filter @gpb/server check:atlas` completado con código 0: conexión, índices únicos, hash, persistencia tras reiniciar API y revocación. `pnpm --filter @gpb/server check:web:atlas` completado con código 0: flujo de React contra la entrada real de API/Atlas, incluidos reinicios de navegador/API y cierre de sesión. Ambos limpiaron sus datos exclusivos de prueba. Estos comandos son adaptaciones de GPB, no CLI oficiales de Atlas. No hubo cambios de dependencias para agregar el segundo verificador.


## Reproducción final de la guía

El conjunto de versiones se volvió a comprobar al transcribir y ejecutar la guía desde preparación en una copia aislada. Instalación congelada, check, build, 6 pruebas API, 2 de transporte y verificadores Atlas aprobados. Git 2.41.0 observado; se fijó main sólo en el repositorio de prueba. Fuente oficial complementaria consultada para Git: [Getting Started — Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), 12 de noviembre de 2026. Secuencia y límites en [VERIFICACION.md](VERIFICACION.md).
