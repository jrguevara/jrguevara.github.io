---
title: GPB — Gunpla Personal Builds | Guía 1 - Configuración y autenticación
date: 2026-11-11
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, nodeJS, mongodb, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

# GPB — Gunpla Personal Builds

## Descripción del proyecto

**GPB — Gunpla Personal Builds** es una aplicación para organizar y llevar un registro personal de una colección de modelos a escala de Gunpla. Permite documentar cada modelo, guardar fotografías y dar seguimiento a su estado: **Sin armar, En progreso o Armado**.

Cada usuario cuenta con una colección privada donde puede registrar el nombre, grado, escala, descripción, notas y etiquetas de sus modelos. También puede agregar una portada, una galería de imágenes y un video de YouTube para complementar la información de cada construcción.

Al iniciar sesión, un **dashboard con estadísticas y gráficos** presenta un resumen de la colección. La búsqueda por nombre y los filtros por grado, escala y estado facilitan encontrar los modelos registrados.

El proyecto se desarrollará como parte de la materia **Desarrollo de Aplicaciones Multiplataforma**, utilizando el stack **MERN: MongoDB, Express, React y Node.js**. La interfaz tendrá un diseño oscuro construido con **shadcn/ui**, y posteriormente se integrará con **Electron** para crear una versión de escritorio para macOS con Apple Silicon.

A lo largo de **seis guías progresivas**, construiremos la aplicación desde su configuración inicial y autenticación de usuarios hasta la publicación de la versión web y el empaquetado de escritorio. El objetivo es aprender a integrar una interfaz, una API, una base de datos y servicios de almacenamiento de imágenes en un mismo proyecto.

### Recorrido de la guía

1. [Objetivos, requisitos y arquitectura](#1-objetivos-y-punto-de-partida).
2. [Preparar la raíz y las dependencias](#2-preparar-la-raíz-del-proyecto).
3. [Crear la API de autenticación](#3-crear-la-api-de-configuración-y-autenticación).
4. [Configurar MongoDB Atlas](#4-configurar-mongodb-atlas-y-las-variables-privadas).
5. [Crear la interfaz React](#5-preparar-el-cliente-react-y-el-proxy).
6. [Comprobar el flujo en el navegador](#6-ejecutar-y-comprobar-la-aplicación).
7. [Incorporar las pruebas de API y transporte](#7-incorporar-las-comprobaciones-de-la-entrega).
8. [Resolver errores frecuentes](#8-errores-frecuentes).
9. [Conservar el punto de control y cerrar](#9-guardar-el-punto-de-control-y-cerrar-la-entrega).
10. [Consultar herramientas y fuentes oficiales](#10-catálogo-de-herramientas-y-fuentes-oficiales).

**Convención de comandos:** salvo que se indique otra carpeta, todos los comandos se ejecutan desde la raíz de GPB, donde están `package.json` y `pnpm-workspace.yaml`. Los bloques con rutas como encabezado contienen archivos, no comandos que debas pegar en la terminal. Los comentarios dentro de los bloques `sh` indican la carpeta o el propósito de la instrucción.

**Material de referencia:** conserva disponible el [archivo de código de la entrega]({{ '/assets/downloads/gpb/guia-01/etapas/01/codigo-etapa-1.zip' | relative_url }}), llamado `codigo-etapa-1.zip`. Contiene el código y el `pnpm-lock.yaml` comprobados, sin credenciales ni dependencias. Puedes consultar [el traspaso]({{ '/assets/downloads/gpb/guia-01/etapas/01/TRASPASO-CHATGPT.md' | relative_url }}), [el registro]({{ '/assets/downloads/gpb/guia-01/etapas/01/REGISTRO.md' | relative_url }}) y [las fuentes]({{ '/assets/downloads/gpb/guia-01/etapas/01/FUENTES.md' | relative_url }}) para ampliar los antecedentes técnicos. Esta guía desarrolla los pasos de aprendizaje; no sustituye esos documentos por una lista de comandos.

Si ya tienes el proyecto implementado del docente, úsalo como referencia de lectura. No sobrescribas su configuración privada para seguir un ejercicio: trabaja en una carpeta de práctica separada cuando corresponda reproducir la guía.

## 1. Objetivos y punto de partida

Necesitas conocimientos de JavaScript, componentes y hooks de React, promesas, módulos y solicitudes HTTP. La integración completa de Electron se estudiará en la guía 6; aquí sólo se incluye una prueba mínima de sesiones para comprobar temprano la arquitectura.

Al finalizar esta entrega tendrás:

- Un cliente React con Vite+, Tailwind CSS y componentes de shadcn/ui.
- Una API Express independiente, conectada con MongoDB Atlas mediante Mongoose.
- Registro con nombre de usuario y correo únicos, y contraseñas guardadas como hash Argon2id.
- Inicio de sesión por correo y contraseña, cookie persistente y cierre de sesión con revocación en el servidor.
- Navegación protegida, mensajes de carga/error y un dashboard inicial.
- Pruebas reproducibles de validación, sesiones y transporte en navegador/Electron.

### 1.1. Entorno requerido

Utiliza una terminal, un editor y una cuenta propia de MongoDB Atlas. Las cuentas de Cloudinary y Render no hacen falta para esta entrega.

| Herramienta | Versión de referencia comprobada |
|---|---|
| Node.js | 26.13.1 |
| pnpm | 12.18.0 |
| Vite+ local | 1.6.0 |
| React y React DOM | 19.3.1 |
| React Router | 8.5.1 |
| Tailwind CSS / plugin Vite | 4.3.5 |
| shadcn CLI | 4.23.0 |
| Express / Mongoose | 5.3.0 / 9.12.0 |
| express-session / connect-mongo | 1.19.0 / 6.0.0 |

La lista completa de herramientas, requisitos e instalación está en el catálogo al final. Cada ficha incluye su fuente oficial y cómo comprobarla; consúltala antes de introducir una herramienta. Las versiones exactas de dependencias de apoyo se encuentran en los manifiestos que escribiremos.

**Carpeta: raíz del proyecto o carpeta de preparación.**

{% raw %}
```sh
node --version
pnpm --version
uname -m
```

{% endraw %}
Resultados comprobados en el entorno de referencia:

{% raw %}
```text
v26.13.1
12.18.0
arm64
```

{% endraw %}
Si tu versión es distinta, no actualices globalmente el equipo para intentar corregirla. Usa un runtime separado y una configuración por proyecto, siguiendo las fichas de Node/pnpm. Tener instalada una herramienta no demuestra que el conjunto sea compatible: también comprobaremos instalación, compilación y funcionamiento.

### 1.2. Cómo se comunican las partes

{% raw %}
```text
Navegador: http://localhost:5173
   React → solicitudes relativas /api/...
                      │
                      ▼
              Proxy de Vite+
                      │
                      ▼
           Express: 127.0.0.1:3000
                      │
                      ▼
                MongoDB Atlas
              usuarios y sesiones
```

{% endraw %}
React solicita `/api/auth/me` bajo el mismo origen de la página. Vite+ reenvía esa solicitud a Express. El navegador no necesita comunicarse directamente con un dominio externo de API ni depender de cookies de terceros.

El servidor guarda la identidad y los tiempos de la sesión en MongoDB. El navegador conserva una cookie con un identificador firmado; no contiene la contraseña ni el documento completo del usuario. `HttpOnly` impide que React lea esa cookie. El navegador la envía en las solicitudes correspondientes.

La futura publicación en Render deberá conservar el proxy bajo el origen web y comprobar sus encabezados y métodos. La distribución de Electron utilizará comunicación controlada desde el proceso principal. Estas decisiones se preparan aquí; el despliegue HTTPS real y el paquete no se realizan en esta guía.

## 2. Preparar la raíz del proyecto

Puedes partir de la carpeta que ya contiene la planificación. Si comienzas en una carpeta nueva, crea una llamada `GPB` y ábrela en el editor. Usa esa carpeta como raíz en todos los pasos.

Crearemos explícitamente los archivos de configuración para mostrar cómo queda el proyecto. No necesitas una instalación global de Vite+. Los comandos ejecutables de esta guía utilizan pnpm para invocar la herramienta local; la mención del generador en el apartado 5 es informativa y no forma parte de la secuencia requerida. El generador `vp create` fue útil durante la implementación de referencia, pero la plantilla remota puede variar: los archivos completos de esta guía son la referencia para esta entrega.

**Carpeta: raíz.**

{% raw %}
```sh
mkdir -p client/src server/src
```

{% endraw %}
Al agregar un archivo en una ruta anidada, crea también sus carpetas si todavía no existen. Usa el editor o `mkdir -p` desde la raíz, con la ruta indicada. Las carpetas de pruebas y Electron se crearán cuando incorporemos sus archivos.

### 2.1. Un repositorio y dos paquetes

Un workspace permite administrar cliente y servidor con un único archivo de bloqueo. Cada paquete conserva sus propias dependencias; Electron no debe incluir la API ni sus credenciales.

La raíz tendrá comandos que delegan en cada paquete. `private: true` evita publicar accidentalmente el paquete en un registro. `packageManager` fija pnpm y `engines` declara el runtime del curso.

### Archivo `package.json`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Este manifiesto incluye también las herramientas de comprobación de la entrega. Sus archivos se agregarán en el apartado de pruebas; no ejecutes esos comandos antes de crearlos.

{% raw %}
```json
{
  "name": "gpb",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "packageManager": "pnpm@12.18.0",
  "engines": {
    "node": "26.13.1"
  },
  "scripts": {
    "dev:client": "pnpm --filter @gpb/client dev",
    "dev:server": "pnpm --filter @gpb/server dev",
    "build": "pnpm --filter @gpb/client build",
    "check": "pnpm --filter @gpb/client check",
    "test": "pnpm --filter @gpb/server test",
    "test:transport": "playwright test"
  },
  "devDependencies": {
    "@playwright/test": "1.65.0",
    "electron": "45.3.1"
  }
}
```

{% endraw %}
### Archivo `.node-version`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Este archivo declara la versión del runtime para herramientas que reconocen esta convención. Es una declaración de proyecto: por sí solo no instala Node ni cambia el entorno del equipo.

{% raw %}
```text
26.13.1
```

{% endraw %}
### Archivo `pnpm-workspace.yaml`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

`packages` registra las dos carpetas. El catálogo fija Vite+ 1.6.0 y su alias oficial de Vite. El override evita mezclar otro Vite con las herramientas del conjunto. `saveExact` y `engineStrict` pertenecen al workspace en pnpm 12. `allowBuilds` autoriza específicamente los paquetes listados; no habilita scripts de cualquier dependencia. La excepción de antigüedad de Electron está limitada a la versión elegida en esta referencia.

{% raw %}
```yaml
packages:
  - client
  - server
catalog:
  vite: npm:@voidzero-dev/vite-plus-core@1.6.0
  vite-plus: 1.6.0
overrides:
  vite: npm:@voidzero-dev/vite-plus-core@1.6.0
peerDependencyRules:
  allowedVersions:
    vite: "*"
saveExact: true
engineStrict: true
allowBuilds:
  argon2: true
  electron: true
minimumReleaseAgeExclude:
  - electron@45.3.1
```

{% endraw %}
### Archivo `.gitignore`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Las credenciales sólo existirán en `server/.env`. Se ignoran los archivos `.env` privados y se permite conservar sus ejemplos sin secretos. También se excluyen dependencias, compilaciones e informes de prueba.

{% raw %}
```text
node_modules/
dist/
dist-electron/
release/
coverage/
.env
.env.*
!.env.example
!.env.*.example
*.log
.DS_Store
test-results/
playwright-report/
```

{% endraw %}
### Archivo `client/package.json`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

React, el router y los auxiliares de shadcn son dependencias del cliente. Vite+, el plugin de React y Tailwind son herramientas de desarrollo. `catalog:` apunta a las versiones exactas declaradas en el workspace; no deja abierta la versión de Vite+.

{% raw %}
```json
{
  "name": "@gpb/client",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vp dev",
    "build": "vp build",
    "lint": "vp lint",
    "preview": "vp preview",
    "check": "vp check"
  },
  "dependencies": {
    "class-variance-authority": "0.7.1",
    "cn": "0.5.2",
    "radix-ui": "1.8.1",
    "react": "19.3.1",
    "react-dom": "19.3.1",
    "react-router": "8.5.1"
  },
  "devDependencies": {
    "@tailwindcss/vite": "4.3.5",
    "@vitejs/plugin-react": "6.1.2",
    "tailwindcss": "4.3.5",
    "vite": "catalog:",
    "vite-plus": "catalog:"
  }
}
```

{% endraw %}
### Archivo `server/package.json`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Express, Mongoose, sesiones, validación y hash se instalan únicamente para la API. Los comandos nativos `--env-file` y `--watch` de Node sustituyen aquí a dotenv y nodemon. Los scripts de comprobación se implementan más adelante.

{% raw %}
```json
{
  "name": "@gpb/server",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "node --env-file=.env --watch src/index.js",
    "start": "node --env-file=.env src/index.js",
    "test": "node --test test/*.test.js",
    "check:atlas": "node --env-file=.env scripts/check-atlas.js",
    "check:web:atlas": "node --env-file=.env scripts/check-web-atlas.js"
  },
  "dependencies": {
    "express": "5.3.0",
    "mongoose": "9.12.0",
    "connect-mongo": "6.0.0",
    "express-session": "1.19.0",
    "argon2": "0.45.2",
    "helmet": "8.3.0",
    "express-rate-limit": "8.7.4",
    "zod": "4.6.7"
  }
}
```

{% endraw %}
### 2.2. Instalar la resolución comprobada

Copia **sólo el archivo `pnpm-lock.yaml`** desde la raíz de `codigo-etapa-1.zip` hasta la raíz de tu proyecto, junto a los manifiestos anteriores. No copies `.env` de otra persona. El lock es extenso y no se reproduce como un bloque de texto: contiene la resolución exacta de las dependencias directas y transitivas comprobadas.

**Carpeta: raíz.**

{% raw %}
```sh
pnpm install --frozen-lockfile
pnpm --filter @gpb/client exec vp --version
pnpm list -r --depth 0
pnpm --filter @gpb/server why mongodb
```

{% endraw %}
`--frozen-lockfile` exige que los manifiestos y el lock correspondan. Si aparece una diferencia, revisa primero lo copiado; no regeneres el lock para ocultarla.

En la referencia, la instalación terminó correctamente y Argon2 pudo cargar su componente nativo arm64. Vite+ informó CLI y paquete local 1.6.0; su conjunto incluyó Vite 8.3.7. Mongoose y connect-mongo compartieron **MongoDB Driver 7.8.0**. No necesitas instalar otro driver para copiar una cadena desde Atlas.

Si has decidido explorar la resolución desde cero, `pnpm install` genera un lock, pero fijar sólo dependencias directas no garantiza obtener las mismas transitivas en otra fecha. Ese sería un conjunto por comprobar; para esta entrega utilizamos el lock adjunto.

**Punto de control:** todavía no hay una interfaz lista para arrancar; acabamos de comprobar dependencias. Continúa creando los archivos que consumen esas dependencias.

## 3. Crear la API de configuración y autenticación

[Express](https://expressjs.com/en/starter/installing/) recibe las solicitudes y organiza el middleware. [Mongoose](https://mongoosejs.com/docs/index.html) define los usuarios e índices. Ambos se ejecutan exclusivamente en el servidor.

Separaremos la creación de la aplicación de su arranque. Esto permitirá probar las mismas rutas con un reloj y un almacén de sesiones controlados, mientras la entrada real siempre utiliza Atlas.

### 3.1. Validar la configuración antes de conectar

Un error de configuración debe detener el arranque, no dejar el servidor funcionando parcialmente. Zod comprueba la forma de las variables; la conectividad real de MongoDB se comprobará después.

### Archivo `server/src/config.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

`SESSION_SECRET` requiere al menos 32 caracteres. `WEB_ORIGIN` debe ser un origen exacto, sin rutas ni barra final; en producción debe ser HTTPS. PORT se convierte de texto a número y se valida. Las variables privadas no se envían a React.

{% raw %}
```js
import { z } from 'zod';

export function readConfig(env = process.env) {
  const values = z.object({
    NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
    PORT: z.coerce.number().int().min(1).max(65535).default(3000),
    MONGODB_URI: z.string().startsWith('mongodb'),
    SESSION_SECRET: z.string().min(32),
    WEB_ORIGIN: z.url(),
  }).parse(env);
  const origin = new URL(values.WEB_ORIGIN);
  if (origin.origin !== values.WEB_ORIGIN || (values.NODE_ENV === 'production' && origin.protocol !== 'https:')) {
    throw new Error('WEB_ORIGIN debe ser un origen exacto; HTTPS en producción.');
  }
  return values;
}
```

{% endraw %}
### 3.2. Definir el usuario y su representación pública

El registro utiliza nombre de usuario, correo y contraseña. Nombre y correo se normalizan a minúsculas antes de guardarse. El nombre admite de 3 a 30 letras ASCII, números, guion y guion bajo; no acepta espacios ni tildes. La contraseña de registro exige de 12 a 128 caracteres y se conserva sin recortarla para calcular su hash.

`unique: true` crea índices en MongoDB: la base de datos respalda la unicidad aun si llegan dos solicitudes simultáneas. No es suficiente confiar únicamente en una validación del formulario.

### Archivo `server/src/users.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

`passwordHash` tiene `select: false` para no seleccionarlo por defecto. Sólo la búsqueda para autenticar lo solicita. `publicUser` construye explícitamente la respuesta permitida; el hash no forma parte de la identidad pública.

{% raw %}
```js
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true, select: false },
}, { timestamps: true });
export const User = mongoose.model('User', schema);
export const users = {
  create: (data) => User.create(data),
  byEmail: (email) => User.findOne({ email }).select('+passwordHash'),
  byId: (id) => User.findById(id),
};
export const publicUser = (user) => ({ id: String(user._id), username: user.username, email: user.email });
```

{% endraw %}
### 3.3. Comprender la sesión antes de escribir las rutas

[express-session](https://expressjs.com/en/resources/middleware/session/) administra el identificador y los datos de sesión. [connect-mongo](https://github.com/jdesboeufs/connect-mongo#readme) guarda esos datos en MongoDB para conservarlos al reiniciar la API. [Argon2](https://github.com/ranisalt/node-argon2#readme) calcula y verifica hashes de contraseñas con Argon2id.

GPB establece dos límites independientes:

| Límite | Regla |
|---|---|
| Inactividad | Reautenticar después de 30 minutos sin actividad registrada |
| Absoluto | Reautenticar al cumplir 7 días desde el registro/inicio de sesión, aunque haya actividad |

Son decisiones del producto, no duraciones impuestas por un estándar. La sesión conserva `startedAt` y `lastActivity`. La API verifica ambos valores antes de aceptar una sesión autenticada. El TTL de MongoDB ayuda a limpiar documentos; no decide si una solicitud está autorizada.

Al registrar o autenticar regeneraremos la sesión para cambiar su identificador. Al salir destruiremos el registro del servidor y eliminaremos la cookie. No guardaremos un JWT ni credenciales en localStorage.

La cookie será persistente, host-only, `HttpOnly`, `SameSite=Lax` y limitada a `/api`. En producción tendrá además `Secure`. En desarrollo local usamos HTTP y `NODE_ENV=development`.

### 3.4. Proteger las operaciones de escritura

Cuando un navegador envía cookies automáticamente, una página externa podría intentar provocar una operación. Para reducir ese riesgo usamos dos comprobaciones en los POST:

1. El encabezado `Origin` debe coincidir exactamente con `WEB_ORIGIN`.
2. `X-CSRF-Token` debe contener el token aleatorio ligado a esa sesión.

El cliente obtiene el token mediante `GET /api/auth/csrf`; al autenticar recibe otro, porque la sesión también se regenera. El token se mantiene en memoria de React. No sustituye a la autenticación.

Helmet configura encabezados de respuesta; express-rate-limit limita conjuntamente registro y acceso a 20 solicitudes por IP en 15 minutos. El límite es por proceso: antes de escalar a varias instancias habrá que revisar un almacén compartido. Las solicitudes JSON se limitan a 8 KB.

### 3.5. Crear la aplicación y sus rutas

El archivo siguiente contiene la secuencia completa. Léelo en este orden: constantes y validadores; middleware de sesión/expiración; CSRF; registro/login; identidad/actividad/logout; respuestas de error. Los callbacks asíncronos aprovechan el manejo de errores de Express 5.

### Archivo `server/src/app.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Las dependencias `store`, `users` y `now` se reciben como parámetros para las pruebas. La aplicación exige un store explícito, de modo que la entrada real no caiga accidentalmente en almacenamiento en memoria.

{% raw %}
```js
import express from 'express';
import session from 'express-session';
import helmet from 'helmet';
import { rateLimit } from 'express-rate-limit';
import argon2 from 'argon2';
import { randomBytes, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { z, ZodError } from 'zod';
import { publicUser } from './users.js';

export const IDLE_MS = 30 * 60 * 1000;
export const ABSOLUTE_MS = 7 * 24 * 60 * 60 * 1000;
const email = z.string().trim().toLowerCase().pipe(z.email().max(254));
const password = z.string().min(12).max(128);
const registration = z.strictObject({ username: z.string().trim().toLowerCase().min(3).max(30).regex(/^[a-z0-9_-]+$/), email, password });
const login = z.strictObject({ email, password: z.string().min(1).max(128) });
const token = () => randomBytes(32).toString('hex');
const equal = (a, b) => typeof a === 'string' && typeof b === 'string' && Buffer.byteLength(a) === Buffer.byteLength(b) && timingSafeEqual(Buffer.from(a), Buffer.from(b));
const save = (req) => promisify(req.session.save).call(req.session);
const regenerate = (req) => promisify(req.session.regenerate).call(req.session);
const destroy = (req) => promisify(req.session.destroy).call(req.session);

// Store y reloj inyectables: producción usa MongoDB; las pruebas no necesitan credenciales.
export function createApp({ config, store, users, now = Date.now, idleMs = IDLE_MS, absoluteMs = ABSOLUTE_MS, authLimit = 20 }) {
  if (!store) throw new Error('Es obligatorio proporcionar un almacén de sesiones.');
  const app = express();
  const secure = config.NODE_ENV === 'production';
  const cookieOptions = { httpOnly: true, secure, sameSite: 'lax', path: '/api' };
  if (secure) app.set('trust proxy', 1);
  app.disable('x-powered-by');
  app.use(helmet());
  app.use('/api', (_req, res, next) => { res.set('Cache-Control', 'no-store'); next(); });
  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));
  app.use('/api', express.json({ limit: '8kb' }));
  app.use('/api', session({
    name: 'gpb.sid', secret: config.SESSION_SECRET, store,
    resave: false, saveUninitialized: false, rolling: false,
    cookie: { ...cookieOptions, maxAge: absoluteMs },
  }));
  app.use('/api', async (req, res, next) => {
    if (req.session.userId) {
      const expired = now() - req.session.startedAt >= absoluteMs || now() - req.session.lastActivity >= idleMs;
      if (expired) {
        await destroy(req);
        res.clearCookie('gpb.sid', cookieOptions);
        return res.status(401).json({ message: 'Tu sesión venció. Inicia sesión nuevamente.' });
      }
      req.session.cookie.maxAge = Math.max(1, absoluteMs - (now() - req.session.startedAt));
    }
    next();
  });
  app.get('/api/auth/csrf', async (req, res) => {
    req.session.csrf ??= token();
    await save(req);
    res.json({ csrfToken: req.session.csrf });
  });
  app.use('/api', (req, res, next) => {
    if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) return next();
    if (req.get('origin') !== config.WEB_ORIGIN || !equal(req.get('x-csrf-token'), req.session.csrf)) {
      return res.status(403).json({ message: 'Solicitud no autorizada. Recarga la página.' });
    }
    next();
  });
  const attempts = rateLimit({ windowMs: 15 * 60 * 1000, limit: authLimit, standardHeaders: 'draft-8', legacyHeaders: false,
    message: { message: 'Demasiados intentos. Intenta de nuevo en 15 minutos.' } });
  async function startSession(req, user) {
    await regenerate(req);
    req.session.userId = String(user._id);
    req.session.startedAt = now();
    req.session.lastActivity = now();
    req.session.csrf = token();
    req.session.cookie.maxAge = absoluteMs;
    await save(req);
  }
  app.post('/api/auth/register', attempts, async (req, res) => {
    const input = registration.parse(req.body);
    const passwordHash = await argon2.hash(input.password, { type: argon2.argon2id, memoryCost: 65536, timeCost: 3, parallelism: 1 });
    const user = await users.create({ username: input.username, email: input.email, passwordHash });
    await startSession(req, user);
    res.status(201).json({ user: publicUser(user), csrfToken: req.session.csrf });
  });
  app.post('/api/auth/login', attempts, async (req, res) => {
    const input = login.parse(req.body);
    const user = await users.byEmail(input.email);
    // También consumir trabajo Argon2 para cuentas inexistentes.
    const valid = user ? await argon2.verify(user.passwordHash, input.password) : (await argon2.hash(input.password), false);
    if (!valid) return res.status(401).json({ message: 'Correo o contraseña incorrectos.' });
    await startSession(req, user);
    res.json({ user: publicUser(user), csrfToken: req.session.csrf });
  });
  const protectedRoute = async (req, res, next) => {
    if (!req.session.userId) return res.status(401).json({ message: 'Inicia sesión para continuar.' });
    const user = await users.byId(req.session.userId);
    if (!user) {
      await destroy(req);
      res.clearCookie('gpb.sid', cookieOptions);
      return res.status(401).json({ message: 'Inicia sesión para continuar.' });
    }
    req.user = user;
    next();
  };
  app.get('/api/auth/me', protectedRoute, (req, res) => res.json({ user: publicUser(req.user) }));
  // Sólo una interacción explícita renueva la actividad; las lecturas de fondo no lo hacen.
  app.post('/api/auth/activity', protectedRoute, async (req, res) => {
    req.session.lastActivity = now();
    await save(req);
    res.sendStatus(204);
  });
  app.post('/api/auth/logout', async (req, res) => {
    await destroy(req);
    res.clearCookie('gpb.sid', cookieOptions);
    res.sendStatus(204);
  });
  app.use('/api', (_req, res) => res.status(404).json({ message: 'Ruta no encontrada.' }));
  app.use((error, _req, res, _next) => {
    if (error instanceof ZodError) return res.status(400).json({ message: 'Revisa los campos: usuario de 3 a 30 caracteres (letras, números, _ o -), correo válido y contraseña de 12 a 128 caracteres.' });
    if (error.code === 11000) return res.status(409).json({ message: 'El usuario o correo ya está registrado.' });
    if (error.type === 'entity.parse.failed') return res.status(400).json({ message: 'JSON inválido.' });
    if (error.type === 'entity.too.large') return res.status(413).json({ message: 'Solicitud demasiado grande.' });
    res.status(500).json({ message: 'No se pudo completar la solicitud.' });
  });
  return app;
}
```

{% endraw %}
#### Qué hace cada ruta

| Método y ruta | Resultado |
|---|---|
| GET `/api/health` | Indica que el proceso está atendiendo; no crea sesión |
| GET `/api/auth/csrf` | Entrega un token ligado a la sesión |
| POST `/api/auth/register` | Valida, crea el usuario y abre sesión; 201 |
| POST `/api/auth/login` | Comprueba correo/contraseña y abre sesión; 200 |
| GET `/api/auth/me` | Devuelve la identidad pública de una sesión válida |
| POST `/api/auth/activity` | Registra actividad sin reiniciar el límite absoluto; 204 |
| POST `/api/auth/logout` | Destruye sesión y elimina cookie; 204 |

`register` transforma la contraseña mediante Argon2id antes de guardar. `login` verifica el hash; también consume trabajo Argon2 para un correo inexistente. La respuesta de credenciales incorrectas es la misma para ambos casos.

Las lecturas de identidad no actualizan `lastActivity`. Un sondeo de fondo no debe mantener una sesión activa indefinidamente. La ruta `activity` requiere sesión y CSRF válidos; sólo se invocará desde interacciones reales del cliente.

`resave: false` evita reescribir una sesión sin cambios; `saveUninitialized: false` evita guardarla hasta que tenga contenido. CSRF crea contenido en la sesión anónima deliberadamente. `rolling: false` evita que cada lectura vuelva a emitir una cookie con siete días completos.

El middleware reduce el tiempo de cookie restante con respecto a `startedAt`. Actualizar actividad no desplaza el inicio absoluto. Las contraseñas no aparecen en las respuestas ni en los mensajes de error.

### 3.6. Conectar y arrancar el servidor

La entrada real conecta con Atlas, espera la creación de índices y sólo entonces escucha. Así, un registro no se acepta antes de que la base de datos esté preparada.

### Archivo `server/src/index.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

connect-mongo reutiliza el cliente del driver de Mongoose en la colección `sessions`. El listener local se limita a 127.0.0.1; el modo producción utiliza 0.0.0.0 para el alojamiento. El arranque imprime un mensaje genérico ante un fallo para no mostrar la URI. Las señales de parada cierran el servidor y la conexión.

{% raw %}
```js
import mongoose from 'mongoose';
import MongoStore from 'connect-mongo';
import { readConfig } from './config.js';
import { users, User } from './users.js';
import { createApp } from './app.js';

try {
  const config = readConfig();
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  await User.init(); // Esperar los índices únicos antes de aceptar registros.
  const store = MongoStore.create({ client: mongoose.connection.getClient(), collectionName: 'sessions', ttl: 7 * 24 * 60 * 60, touchAfter: 0 });
  store.on('error', () => console.error('No se pudo acceder al almacén de sesiones.'));
  const server = createApp({ config, store, users }).listen(config.PORT, config.NODE_ENV === 'production' ? '0.0.0.0' : '127.0.0.1', () => console.log(`API GPB disponible en el puerto ${config.PORT}`));
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => {
    server.close(async () => { await mongoose.disconnect(); process.exit(0); });
  });
} catch {
  console.error('No se pudo iniciar GPB. Revisa las variables locales y la conexión con Atlas.');
  process.exitCode = 1;
}
```

{% endraw %}
**Punto de control:** los archivos del servidor ya existen, pero no lo arranques hasta configurar `server/.env` en el siguiente apartado. No agregues dotenv ni nodemon: los scripts ya utilizan funciones nativas de Node.

## 4. Configurar MongoDB Atlas y las variables privadas

[MongoDB Atlas](https://www.mongodb.com/docs/atlas/getting-started/) administra la base de datos remota. Lo utilizamos para usuarios y sesiones sin exigir un servidor MongoDB local. La versión real comprobada en la referencia fue **MongoDB 8.0.37**; un clúster administrado puede ofrecer otra versión compatible y deberá registrarse al comprobarlo.

### 4.1. Preparar el clúster

En tu cuenta de Atlas:

1. Crea un proyecto y un clúster Free disponible para tu cuenta. Las imágenes se integrarán en otra entrega; aquí sólo guardaremos documentos y sesiones.
2. En **Database Access**, crea un usuario de base de datos con permisos de lectura y escritura sobre la base `gpb` que utilizará el curso. Este usuario no es tu cuenta de acceso al sitio web de Atlas.
3. En **Network Access**, permite la IP pública desde la que se conectará tu equipo. Si cambia, actualiza la regla. No abras el acceso a todas las IP como solución automática.
4. Abre **Connect → Drivers** y selecciona **Node.js**. Elige la opción de compatibilidad que incluya el driver instalado; GPB utiliza MongoDB Driver 7.8.0. Copiar la URI no requiere instalar un driver adicional.
5. Copia la cadena que Atlas proporciona. Conserva exactamente su servidor y sustituye las credenciales localmente. Añade `/gpb` antes de `?` si la URI no incluye el nombre de la base.

Ejemplo ilustrativo, que no se puede usar para conectar:

{% raw %}
```text
mongodb+srv://USUARIO:CONTRASENA@cluster0.ejemplo.mongodb.net/gpb?retryWrites=true&w=majority
```

{% endraw %}
`cluster0.ejemplo.mongodb.net` debe reemplazarse por el servidor real que copiaste de Atlas. No escribas los signos `< >` que a veces rodean los marcadores del proveedor. Codifica los caracteres reservados de usuario/contraseña para una URL: `@` pasa a `%40`, `#` a `%23` y `%` a `%25`. No codifiques toda la URI ni vuelvas a codificar una contraseña que ya codificaste.

### 4.2. Mantener un ejemplo sin secretos

### Archivo `server/.env.example`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Este archivo se versiona y documenta los nombres de las variables. Los valores de acceso reales pertenecen únicamente a su copia local `.env`.

{% raw %}
```text
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb+srv://USUARIO:CLAVE@CLUSTER/gpb
SESSION_SECRET=
WEB_ORIGIN=http://localhost:5173
# En producción: origen público HTTPS del proxy web; nunca una URL de terceros.
```

{% endraw %}
**Carpeta: raíz.** Si `server/.env` aún no existe, crea una copia de `server/.env.example` con ese nombre. En macOS puedes ejecutar:

{% raw %}
```sh
cp -n server/.env.example server/.env
```

{% endraw %}
`-n` evita sobrescribir una configuración que ya tengas. Edita `MONGODB_URI` en el archivo privado con la cadena real. Conserva por ahora:

{% raw %}
```text
NODE_ENV=development
PORT=3000
WEB_ORIGIN=http://localhost:5173
```

{% endraw %}
No uses `http://127.0.0.1:5173` para abrir la página si declaraste `http://localhost:5173`: son orígenes diferentes. No añadas una barra al final del origen.

### 4.3. Generar el secreto de sesión sin mostrarlo

El secreto firma el identificador de sesión. No es la contraseña de MongoDB y no debe ser una frase de ejemplo. Este comando conserva un secreto existente de longitud válida y genera uno criptográfico si falta o tiene menos de 32 caracteres. No modifica `MONGODB_URI`.

**Carpeta: raíz.**

{% raw %}
```sh
node --input-type=module <<'JS'
import { readFile, writeFile, chmod } from 'node:fs/promises';
import { parseEnv } from 'node:util';
import { randomBytes } from 'node:crypto';

const file = 'server/.env';
let content = await readFile(file, 'utf8');
if ((parseEnv(content).SESSION_SECRET ?? '').length < 32) {
  const line = `SESSION_SECRET=${randomBytes(48).toString('hex')}`;
  content = /^SESSION_SECRET\s*=/m.test(content)
    ? content.replace(/^SESSION_SECRET\s*=.*$/m, line)
    : `${content}\n${line}\n`;
  await writeFile(file, content, { mode: 0o600 });
  await chmod(file, 0o600);
  console.log('Secreto local generado; valor oculto.');
} else {
  console.log('Secreto existente conservado.');
}
JS
```

{% endraw %}
No cambies el secreto en cada arranque: si cambia, las cookies firmadas con el anterior dejarán de ser válidas. No imprimas ni pegues `.env` en el chat, capturas o documentación. React no necesita variables `VITE_MONGODB_URI` ni `VITE_SESSION_SECRET`.

### 4.4. Comprobar el arranque de la API

**Carpeta: raíz, terminal 1.**

{% raw %}
```sh
pnpm dev:server
```

{% endraw %}
Resultado esperado con Atlas accesible:

{% raw %}
```text
API GPB disponible en el puerto 3000
```

{% endraw %}
**Carpeta: raíz, otra terminal.**

{% raw %}
```sh
curl http://127.0.0.1:3000/api/health
```

{% endraw %}
La respuesta esperada es `{"status":"ok"}`. Esta comprobación sólo acredita el proceso: el flujo de registro y sesiones se probará desde la interfaz y con los verificadores de los apartados siguientes. Puedes detener la API con Ctrl+C antes de continuar o mantenerla abierta para probar el cliente más adelante.

En la implementación de referencia se verificó la conexión real, los índices y la persistencia con las herramientas de este proyecto; no se dedujo funcionamiento sólo de una URI con formato válido.

## 5. Preparar el cliente React y el proxy

[React](https://react.dev/learn/installation) organiza los componentes y el estado de autenticación. [React Router](https://reactrouter.com/start/declarative/installation) manejará las pantallas; [Tailwind](https://tailwindcss.com/docs/installation/using-vite) y [shadcn/ui](https://ui.shadcn.com/docs/installation/vite) aportan la base visual.

Vite+ se ejecuta mediante los scripts del paquete cliente. El proxy de desarrollo preserva el origen enviado por el navegador. No añadiremos CORS abierto a Express para ocultar un error de configuración.

### 5.1. Configurar compilación, alias y entrada

### Archivo `client/vite.config.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Los plugins habilitan JSX y Tailwind. El alias `@` apunta a `client/src`. El proxy reenvía `/api` a la API local; `strictPort` evita que Vite+ cambie silenciosamente al puerto 5174 y rompa WEB_ORIGIN. La configuración de preview también utiliza el puerto local acordado.

{% raw %}
```js
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite-plus";
import { fileURLToPath } from "node:url";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: { alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) } },
  server: {
    host: "127.0.0.1",
    port: 5173,
    strictPort: true,
    proxy: { "/api": { target: "http://127.0.0.1:3000", changeOrigin: false } },
  },
  preview: {
    host: "127.0.0.1",
    port: 5173,
    strictPort: true,
    proxy: { "/api": "http://127.0.0.1:3000" },
  },
  fmt: {},
  lint: { plugins: ["react"], rules: { "react/rules-of-hooks": "error" } },
});
```

{% endraw %}
### Archivo `client/jsconfig.json`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Este archivo ayuda al editor a resolver el alias `@`. Es configuración JavaScript; no convierte el proyecto a TypeScript.

{% raw %}
```json
{ "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["./src/*"] } }, "include": ["src"] }
```

{% endraw %}
### Archivo `client/index.html`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

`lang="es"` identifica el idioma; la clase `dark` fija el modo oscuro. El navegador cargará el módulo `src/main.jsx` que agregaremos después.

{% raw %}
```html
<!doctype html>
<html lang="es" class="dark">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#101113" />
    <title>GPB — Gunpla Personal Builds</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

{% endraw %}
### Archivo `client/components.json`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

shadcn copiará componentes como JSX porque `tsx` es false. Los estilos y alias coinciden con el proyecto. No hay React Server Components.

{% raw %}
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": false,
  "tailwind": { "config": "", "css": "src/index.css", "baseColor": "zinc", "cssVariables": true },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "iconLibrary": "lucide"
}
```

{% endraw %}
### 5.2. Incorporar los componentes de shadcn/ui

La CLI copia componentes editables; no instalamos un paquete de ejecución llamado shadcn. Los componentes actuales usan Radix UI, `cn` y Class Variance Authority para composición y variantes.

**Referencia del generador; no es un paso obligatorio de este recorrido.** El camino de esta guía consiste en crear los cuatro archivos JSX completos que aparecen abajo. Si deseas explorar el generador, hazlo en una copia de práctica, con su CSS de Tailwind inicializado; no lo ejecutes sobre la referencia conservada.

El comando ejecutado durante la implementación fue:

**Carpeta: raíz de la copia de exploración; comando informativo.**

{% raw %}
```sh
pnpm dlx shadcn@4.23.0 add button input label card --cwd client --yes
```

{% endraw %}
La versión fijada corresponde a la CLI. El registro remoto de componentes puede cambiar después de esta publicación. Para conservar la referencia del curso, crea los cuatro archivos siguientes con el contenido completo comprobado. Si probaste el generador, reemplaza los resultados que difieran y conserva los manifiestos/lock de la entrega.

Las dependencias necesarias ya están declaradas exactamente en `client/package.json`. En particular, Button importa `class-variance-authority`; no basta con que el generador haya terminado para asumir que esa dependencia quedó agregada.

### Archivo `client/src/components/ui/button.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Button centraliza variantes, tamaños y estados deshabilitado/foco. `asChild` permite componerlo con otro elemento mediante Radix Slot.

{% raw %}
```jsx
import * as React from "react";
import { cva } from "class-variance-authority";
import { cn } from "cn";
import { Slot } from "radix-ui";

const buttonVariants = cva(
  "inline-flex shrink-0 items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40",
        outline:
          "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2 has-[>svg]:px-3",
        xs: "h-6 gap-1 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
        sm: "h-8 gap-1.5 rounded-md px-3 has-[>svg]:px-2.5",
        lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
        icon: "size-9",
        "icon-xs": "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3",
        "icon-sm": "size-8",
        "icon-lg": "size-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
);

function Button({ className, variant = "default", size = "default", asChild = false, ...props }) {
  const Comp = asChild ? Slot.Root : "button";

  return (
    <Comp
      data-slot="button"
      data-variant={variant}
      data-size={size}
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

export { Button, buttonVariants };
```

{% endraw %}
### Archivo `client/src/components/ui/input.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Input conserva atributos HTML y estilos comunes. Cada formulario seguirá indicando tipo, nombre y autocompletado.

{% raw %}
```jsx
import * as React from "react";
import { cn } from "cn";

function Input({ className, type, ...props }) {
  return (
    <input
      type={type}
      data-slot="input"
      className={cn(
        "h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none selection:bg-primary selection:text-primary-foreground file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground placeholder:text-muted-foreground disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm dark:bg-input/30",
        "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50",
        "aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40",
        className,
      )}
      {...props}
    />
  );
}

export { Input };
```

{% endraw %}
### Archivo `client/src/components/ui/label.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Label utiliza la primitiva de Radix y permite asociar el texto al id del campo.

{% raw %}
```jsx
import * as React from "react";
import { cn } from "cn";
import { Label as LabelPrimitive } from "radix-ui";

function Label({ className, ...props }) {
  return (
    <LabelPrimitive.Root
      data-slot="label"
      className={cn(
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        className,
      )}
      {...props}
    />
  );
}

export { Label };
```

{% endraw %}
### Archivo `client/src/components/ui/card.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Card y sus partes organizan el encabezado, descripción y contenido. Son componentes visuales, sin lógica de autenticación.

{% raw %}
```jsx
import * as React from "react";
import { cn } from "cn";

function Card({ className, ...props }) {
  return (
    <div
      data-slot="card"
      className={cn(
        "flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm",
        className,
      )}
      {...props}
    />
  );
}

function CardHeader({ className, ...props }) {
  return (
    <div
      data-slot="card-header"
      className={cn(
        "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
        className,
      )}
      {...props}
    />
  );
}

function CardTitle({ className, ...props }) {
  return (
    <div
      data-slot="card-title"
      className={cn("leading-none font-semibold", className)}
      {...props}
    />
  );
}

function CardDescription({ className, ...props }) {
  return (
    <div
      data-slot="card-description"
      className={cn("text-sm text-muted-foreground", className)}
      {...props}
    />
  );
}

function CardAction({ className, ...props }) {
  return (
    <div
      data-slot="card-action"
      className={cn("col-start-2 row-span-2 row-start-1 self-start justify-self-end", className)}
      {...props}
    />
  );
}

function CardContent({ className, ...props }) {
  return <div data-slot="card-content" className={cn("px-6", className)} {...props} />;
}

function CardFooter({ className, ...props }) {
  return (
    <div
      data-slot="card-footer"
      className={cn("flex items-center px-6 [.border-t]:pt-6", className)}
      {...props}
    />
  );
}

export { Card, CardHeader, CardFooter, CardTitle, CardAction, CardDescription, CardContent };
```

{% endraw %}
**Nota sobre carpetas:** al crear estos archivos, crea `client/src/components/ui/` si tu editor no lo hace automáticamente. Haz lo mismo con `client/src/lib/` y `client/src/auth/` en los siguientes pasos.

### 5.3. Centralizar las solicitudes HTTP

El cliente no construye una URL distinta de API para cada pantalla. La función `api` utiliza siempre rutas relativas `/api`, envía la cookie bajo el mismo origen y añade el token CSRF a los métodos de escritura.

Mantiene el token y la solicitud inicial de CSRF en el módulo, sin persistirlos en localStorage. Si una respuesta indica 401/403, los descarta para permitir una nueva inicialización. El timeout evita una espera indefinida y devuelve un mensaje comprensible ante una interrupción de conexión.

### Archivo `client/src/lib/api.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

La respuesta 204 no tiene cuerpo y no debe pasarse a response.json(). Los errores conservan el código HTTP para que el contexto distinga una sesión vencida de un fallo de conexión.

{% raw %}
```js
let csrfToken;
let csrfRequest;
export async function api(path, { method = "GET", body } = {}) {
  try {
    if (method !== "GET" && !csrfToken) await csrf();
    const response = await fetch(`/api${path}`, {
      method,
      credentials: "same-origin",
      signal: AbortSignal.timeout(20000),
      headers: {
        ...(body ? { "Content-Type": "application/json" } : {}),
        ...(method !== "GET" ? { "X-CSRF-Token": csrfToken } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    const data = response.status === 204 ? null : await response.json();
    if (!response.ok) {
      if (response.status === 401 || response.status === 403) {
        csrfToken = undefined;
        csrfRequest = undefined;
      }
      throw Object.assign(new Error(data.message || "No se pudo completar la solicitud."), {
        status: response.status,
      });
    }
    if (data?.csrfToken) csrfToken = data.csrfToken;
    return data;
  } catch (error) {
    if (error.status) throw error;
    throw new Error(
      "No pudimos conectar con GPB. La API puede tardar en activarse; intenta de nuevo.",
    );
  }
}
export function csrf() {
  csrfRequest ??= api("/auth/csrf").catch((error) => {
    csrfRequest = undefined;
    throw error;
  });
  return csrfRequest;
}
export function resetCsrf() {
  csrfToken = undefined;
  csrfRequest = undefined;
}
```

{% endraw %}
### 5.4. Compartir la identidad con Context

El contexto conserva `user`, `loading` y un error de conexión. Al arrancar pregunta al servidor por la identidad; no da por autenticado al usuario sólo porque exista un valor guardado en el cliente.

Después del acceso registra interacciones reales de teclado o puntero cuando la página está visible. Limita el envío de actividad a una vez por minuto. Las consultas automáticas a `/auth/me`, cada minuto y al recuperar foco, comprueban vigencia pero no renuevan actividad. La interfaz puede tardar hasta un minuto en mostrar el vencimiento mientras no se interactúa; la API lo aplica en cada solicitud.

### Archivo `client/src/auth/AuthContext.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Los listeners y el temporizador se retiran cuando se desmonta el efecto o deja de haber usuario. Logout sólo borra la identidad local después de que el servidor confirme la invalidación; si falla la conexión, permite informar el error.

{% raw %}
```jsx
import { createContext, useContext, useEffect, useState } from "react";
import { api, csrf, resetCsrf } from "@/lib/api";

const AuthContext = createContext(null);
export const useAuth = () => useContext(AuthContext);
export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  async function loadSession() {
    try {
      await csrf();
      setUser((await api("/auth/me")).user);
    } catch (failure) {
      if (failure.status !== 401) setError(failure.message);
      setUser(null);
    } finally {
      setLoading(false);
    }
  }
  function refresh() {
    setLoading(true);
    setError("");
    return loadSession();
  }
  useEffect(() => {
    let active = true;
    csrf()
      .then(() => api("/auth/me"))
      .then((data) => {
        if (active) setUser(data.user);
      })
      .catch((failure) => {
        if (active && failure.status !== 401) setError(failure.message);
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);
  useEffect(() => {
    if (!user) return;
    let lastSent = 0;
    const expire = (failure) => {
      if (failure.status === 401) setUser(null);
    };
    const activity = (event) => {
      if (
        !event.isTrusted ||
        document.visibilityState !== "visible" ||
        Date.now() - lastSent < 60000
      )
        return;
      lastSent = Date.now();
      api("/auth/activity", { method: "POST" }).catch(expire);
    };
    const check = () => api("/auth/me").catch(expire);
    const timer = setInterval(check, 60000);
    window.addEventListener("pointerdown", activity);
    window.addEventListener("keydown", activity);
    window.addEventListener("focus", check);
    return () => {
      clearInterval(timer);
      window.removeEventListener("pointerdown", activity);
      window.removeEventListener("keydown", activity);
      window.removeEventListener("focus", check);
    };
  }, [user]);
  async function authenticate(mode, data) {
    const result = await api(`/auth/${mode}`, { method: "POST", body: data });
    setUser(result.user);
  }
  async function logout() {
    await api("/auth/logout", { method: "POST" });
    resetCsrf();
    setUser(null);
  }
  return (
    <AuthContext.Provider value={{ user, loading, error, refresh, authenticate, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
```

{% endraw %}
### 5.5. Crear formularios, navegación y rutas protegidas

El archivo siguiente reúne las pantallas iniciales de esta entrega. Primero crea el contenido completo y después recorre sus funciones:

- `AuthForm` comparte estructura para registro/login, recoge FormData y muestra errores del servidor.
- `ProtectedLayout` dirige a `/login` cuando el contexto no tiene identidad y ofrece navegación y cierre de sesión.
- `Home` muestra la bienvenida o el punto de continuación de colección, sin estadísticas ficticias.
- `AppRoutes` espera la consulta inicial y permite reintentar cuando la API no está accesible.
- `App` instala BrowserRouter y el proveedor de autenticación.

La validación del formulario mejora la experiencia; la API sigue siendo la autoridad. Ocultar una pantalla no protege un endpoint: por eso `/auth/me` comprueba sesión y existencia del usuario en servidor.

### Archivo `client/src/App.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Registro e inicio reciben respuestas públicas. Las redirecciones usan replace para no dejar una entrada intermedia de acceso en el historial. Los mensajes de error y carga se anuncian mediante roles apropiados.

{% raw %}
```jsx
import { useState } from "react";
import {
  BrowserRouter,
  Link,
  Navigate,
  NavLink,
  Outlet,
  Route,
  Routes,
  useNavigate,
} from "react-router";
import { AuthProvider, useAuth } from "@/auth/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

function Brand() {
  return (
    <Link to="/" className="brand">
      <span className="brand-mark">GPB</span>
      <span>
        Gunpla Personal Builds<small>Tu colección. Tu proceso.</small>
      </span>
    </Link>
  );
}
function AuthForm({ register = false }) {
  const { user, authenticate } = useAuth();
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const navigate = useNavigate();
  if (user) return <Navigate to="/" replace />;
  async function submit(event) {
    event.preventDefault();
    setError("");
    setBusy(true);
    const data = Object.fromEntries(new FormData(event.currentTarget));
    try {
      await authenticate(register ? "register" : "login", data);
      navigate("/", { replace: true });
    } catch (failure) {
      setError(failure.message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <main className="auth-page">
      <section className="intro">
        <Brand />
        <p className="eyebrow">GUNPLA PERSONAL BUILDS / 01</p>
        <h1>
          Cada build
          <br />
          tiene una historia.
        </h1>
        <p>
          Un espacio para organizar tu colección y acompañar cada proyecto, desde la primera pieza.
        </p>
        <div className="intro-rule" />
        <span className="muted">Construye a tu ritmo.</span>
      </section>
      <Card className="auth-card">
        <CardHeader>
          <CardTitle className="text-2xl">
            {register ? "Crea tu cuenta" : "Bienvenido de nuevo"}
          </CardTitle>
          <CardDescription>
            {register
              ? "Empieza tu espacio personal de Gunpla."
              : "Inicia sesión para entrar a tu espacio."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={submit} className="grid gap-5">
            {register && (
              <div className="grid gap-2">
                <Label htmlFor="username">Nombre de usuario</Label>
                <Input
                  id="username"
                  name="username"
                  autoComplete="username"
                  required
                  minLength={3}
                  maxLength={30}
                  pattern="[a-zA-Z0-9_\-]+"
                  placeholder="piloto_gunpla"
                />
                <p className="field-help">3 a 30 letras, números, guion o guion bajo.</p>
              </div>
            )}
            <div className="grid gap-2">
              <Label htmlFor="email">Correo electrónico</Label>
              <Input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                maxLength={254}
                placeholder="tu@correo.com"
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="password">Contraseña</Label>
              <Input
                id="password"
                name="password"
                type="password"
                autoComplete={register ? "new-password" : "current-password"}
                required
                minLength={register ? 12 : 1}
                maxLength={128}
              />
              {register && <p className="field-help">Entre 12 y 128 caracteres.</p>}
            </div>
            {error && (
              <p role="alert" className="error">
                {error}
              </p>
            )}
            <Button type="submit" disabled={busy}>
              {busy ? "Un momento…" : register ? "Crear cuenta" : "Iniciar sesión"}
            </Button>
            <p className="text-sm muted">
              {register ? "¿Ya tienes una cuenta?" : "¿Aún no tienes cuenta?"}{" "}
              <Link className="text-link" to={register ? "/login" : "/registro"}>
                {register ? "Inicia sesión" : "Regístrate"}
              </Link>
            </p>
          </form>
        </CardContent>
      </Card>
    </main>
  );
}
function ProtectedLayout() {
  const { user, logout } = useAuth();
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  if (!user) return <Navigate to="/login" replace />;
  async function leave() {
    setBusy(true);
    setError("");
    try {
      await logout();
    } catch (failure) {
      setError(failure.message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <div className="app-shell">
      <header>
        <Brand />
        <nav aria-label="Navegación principal">
          <NavLink to="/" end>
            Dashboard
          </NavLink>
          <NavLink to="/coleccion">Mi colección</NavLink>
        </nav>
        <Button variant="outline" onClick={leave} disabled={busy}>
          {busy ? "Cerrando…" : "Cerrar sesión"}
        </Button>
      </header>
      <main className="content">
        {error && (
          <p role="alert" className="error">
            {error}
          </p>
        )}
        <Outlet />
      </main>
    </div>
  );
}
function Home({ collection = false }) {
  const { user } = useAuth();
  return (
    <>
      <p className="eyebrow">TU ESPACIO PERSONAL</p>
      <h1>{collection ? "Mi colección" : `Hola, ${user.username}.`}</h1>
      <p className="muted">
        {collection
          ? "Aquí comenzará tu colección personal."
          : "Tu próximo build empieza con una idea."}
      </p>
      <Card className="empty-card">
        <CardHeader>
          <span className="empty-symbol" aria-hidden="true">
            ＋
          </span>
          <CardTitle>
            {collection ? "El primer build está por llegar" : "Bienvenido a GPB"}
          </CardTitle>
          <CardDescription>
            {collection
              ? "La gestión de Gunpla se incorporará en la etapa 2."
              : "Tu cuenta está lista. Este dashboard se completará con las estadísticas de tu colección en la etapa 4."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <span className="status-dot" /> Sesión protegida · {user.email}
        </CardContent>
      </Card>
    </>
  );
}
function AppRoutes() {
  const { loading, error, refresh } = useAuth();
  if (loading)
    return (
      <main className="centered" role="status">
        Conectando con GPB…
      </main>
    );
  if (error)
    return (
      <main className="centered">
        <p role="alert">{error}</p>
        <Button onClick={refresh}>Reintentar conexión</Button>
      </main>
    );
  return (
    <Routes>
      <Route path="/login" element={<AuthForm />} />
      <Route path="/registro" element={<AuthForm register />} />
      <Route element={<ProtectedLayout />}>
        <Route index element={<Home />} />
        <Route path="/coleccion" element={<Home collection />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}
```

{% endraw %}
### 5.6. Aplicar la presentación oscura

El CSS importa Tailwind, declara los colores utilizados por los componentes y agrega los estilos de las pantallas de GPB. Las reglas móviles reorganizan las columnas y la navegación. La referencia utiliza tipografías del sistema, sin descargar una fuente externa.

### Archivo `client/src/index.css`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Conserva el import de Tailwind al inicio. Los tokens de color deben coincidir con las clases de los componentes shadcn para que inputs, texto y botones sean legibles.

{% raw %}
```css
@import "tailwindcss";

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: #101113;
  --color-secondary: #26282c;
  --color-secondary-foreground: #f5f5f5;
  --color-muted-foreground: #a5a7ae;
  --color-accent: #303238;
  --color-accent-foreground: #fafafa;
  --color-destructive: #ed7474;
  --color-border: #34363d;
  --color-input: #34363d;
  --color-ring: #c4ea80;
}
:root {
  color-scheme: dark;
  --background: #101113;
  --foreground: #f1f2ee;
  --card: #191b1f;
  --primary: #c4ea80;
  font-family: Inter, ui-sans-serif, system-ui, sans-serif;
  font-synthesis: none;
}
body {
  margin: 0;
  background: var(--background);
  color: var(--foreground);
}
button,
input,
a {
  -webkit-tap-highlight-color: transparent;
}
button,
a {
  cursor: pointer;
}
a {
  text-decoration: none;
}
h1 {
  font-size: clamp(2rem, 4vw, 3.25rem);
  letter-spacing: -0.045em;
  line-height: 1.12;
  font-weight: 650;
  margin: 0 0 1rem;
}
.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--foreground);
  font-weight: 650;
  font-size: 14px;
}
.brand small {
  display: block;
  font-size: 11px;
  font-weight: 400;
  color: #a5a7ae;
  margin-top: 4px;
}
.brand-mark {
  display: grid;
  place-items: center;
  width: 46px;
  height: 46px;
  border: 1px solid #c4ea80;
  color: #c4ea80;
  font-weight: 800;
  letter-spacing: -0.06em;
}
.auth-page {
  min-height: 100svh;
  max-width: 1120px;
  margin: auto;
  padding: 56px 36px;
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 100px;
  align-items: center;
}
.intro .brand {
  margin-bottom: 90px;
}
.eyebrow {
  font-size: 11px;
  letter-spacing: 0.16em;
  font-weight: 650;
  color: #c4ea80;
  margin: 0 0 24px;
}
.intro > p:not(.eyebrow) {
  color: #a5a7ae;
  max-width: 365px;
  line-height: 1.75;
  margin: 24px 0;
}
.intro-rule {
  width: 64px;
  height: 1px;
  background: #45484e;
  margin: 32px 0 20px;
}
.muted {
  color: #a5a7ae;
}
.auth-card {
  width: 100%;
}
.field-help {
  font-size: 12px;
  color: #a5a7ae;
}
.text-link {
  color: #c4ea80;
  text-decoration: underline;
  text-underline-offset: 3px;
}
.error {
  color: #ffabab;
  border-left: 2px solid #ed7474;
  padding: 8px 12px;
  font-size: 14px;
}
.app-shell header {
  min-height: 100px;
  border-bottom: 1px solid #34363d;
  display: flex;
  gap: 40px;
  align-items: center;
  padding: 20px 5vw;
}
nav {
  display: flex;
  gap: 28px;
  margin-left: auto;
}
nav a {
  color: #a5a7ae;
  font-size: 14px;
  padding: 8px 0;
}
nav a.active {
  color: #c4ea80;
  box-shadow: 0 1px #c4ea80;
}
.content {
  max-width: 1120px;
  margin: auto;
  padding: 64px 36px;
}
.empty-card {
  text-align: center;
  margin-top: 40px;
  padding: 60px 0;
}
.empty-card [data-slot="card-description"] {
  max-width: 440px;
  margin: 12px auto 0;
  line-height: 1.8;
}
.empty-card [data-slot="card-content"] {
  font-size: 12px;
  color: #a5a7ae;
}
.empty-symbol {
  font-size: 40px;
  font-weight: 200;
  color: #c4ea80;
  margin-bottom: 20px;
}
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  background: #c4ea80;
  border-radius: 50%;
  margin-right: 6px;
}
.centered {
  min-height: 100svh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 20px;
  padding: 30px;
  text-align: center;
}
@media (max-width: 760px) {
  .auth-page {
    grid-template-columns: 1fr;
    gap: 30px;
    padding: 28px 20px;
    max-width: 480px;
  }
  .intro .brand {
    margin-bottom: 32px;
  }
  .intro .eyebrow,
  .intro-rule,
  .intro > .muted,
  .intro > p:not(.eyebrow) {
    display: none;
  }
  .intro h1 {
    margin: 0;
  }
  .app-shell header {
    flex-wrap: wrap;
    gap: 24px;
    padding: 20px;
  }
  .app-shell header .brand {
    flex: 1;
  }
  nav {
    order: 3;
    margin: 0;
    width: 100%;
  }
  .content {
    padding: 40px 20px;
  }
}
```

{% endraw %}
### Archivo `client/src/main.jsx`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Este archivo une el contenedor HTML, los estilos y la aplicación React. La autenticación se inicializa dentro de AuthProvider.

{% raw %}
```jsx
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App.jsx";

createRoot(document.getElementById("root")).render(<App />);
```

{% endraw %}
## 6. Ejecutar y comprobar la aplicación

### 6.1. Arrancar cada parte en su terminal

**Carpeta: raíz, terminal 1.**

{% raw %}
```sh
pnpm dev:server
```

{% endraw %}
**Carpeta: raíz, terminal 2.**

{% raw %}
```sh
pnpm dev:client
```

{% endraw %}
Abre **http://localhost:5173**. Vite+ puede mostrar `http://127.0.0.1:5173/` en la terminal; escribe la dirección con `localhost` para que coincida con `WEB_ORIGIN`. React se comunica con la API mediante el proxy `/api`; no abras el HTML directamente como un archivo.

### 6.2. Recorrer el acceso

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Abrir `/` sin una sesión válida | Pantalla de inicio de sesión |
| 2 | Seguir «Regístrate» y enviar un usuario válido, correo propio y contraseña de al menos 12 caracteres | Bienvenida personalizada y navegación protegida |
| 3 | Entrar en «Mi colección» | Pantalla inicial de la etapa siguiente, sin CRUD |
| 4 | Cerrar sesión | Regreso al formulario de acceso |
| 5 | Entrar con contraseña incorrecta | Mensaje «Correo o contraseña incorrectos.» |
| 6 | Entrar con las credenciales correctas | Dashboard protegido |
| 7 | Cerrar completamente el navegador y reabrir la misma dirección usando el mismo perfil | Sesión conservada si todavía está vigente |
| 8 | Detener y volver a arrancar la API, sin cerrar sesión | La sesión continúa gracias a MongoDB |
| 9 | Cerrar sesión y volver a cargar `/` | Se solicita autenticación otra vez |

Usa cuentas de práctica y no captures sus credenciales. El verificador automatizado con Atlas, descrito después, crea y elimina su propia cuenta temporal.

### 6.3. Revisar validación y errores

Prueba un correo inválido, una contraseña de registro corta y un nombre con caracteres no permitidos. El navegador puede impedir algunos envíos antes de contactar a la API; las pruebas HTTP del siguiente apartado comprobarán además la validación del servidor.

Intenta registrar dos veces el mismo correo y, por separado, el mismo nombre con otro correo. La API responde 409. No basta con esconder un botón: los índices únicos son la última barrera frente a duplicados.

| Código | Significado en esta entrega |
|---|---|
| 400 | Campos o JSON inválidos |
| 401 | Falta sesión, credenciales incorrectas o sesión vencida |
| 403 | Origin/token CSRF no autorizado |
| 409 | Usuario o correo duplicado |
| 413 | JSON supera el límite de cuerpo |
| 429 | Demasiados intentos de registro/login |
| 500 | Error interno, sin detalles privados para el cliente |

### 6.4. Confirmar compilación y estilo

**Carpeta: raíz.**

{% raw %}
```sh
pnpm check
pnpm build
```

{% endraw %}
En el código de referencia ambas comprobaciones terminaron correctamente: cliente sin advertencias ni errores de revisión, y compilación de 205 módulos. La salida se crea en `client/dist`, que no se versiona. Si tu edición produce diferencias de formato, desde raíz puedes ejecutar `pnpm --filter @gpb/client exec vp check --fix`, revisar lo que cambió y repetir check.

La compilación no comprueba por sí sola registro, conexión Atlas o sesiones. Esas evidencias se obtienen con el recorrido anterior y las pruebas siguientes.

## 7. Incorporar las comprobaciones de la entrega

Este apartado amplía las comprobaciones manuales con archivos de prueba. Usa el mismo código de aplicación; no agregamos funciones de colección ni estadísticas.

Node incluye [un ejecutor de pruebas](https://nodejs.org/api/test.html). Lo utilizaremos para solicitudes HTTP y límites de sesión con reloj controlado, sin esperar físicamente 30 minutos o siete días. [Playwright](https://playwright.dev/docs/intro) comprobará el flujo en procesos reales de navegador y Electron. Consulta sus fichas de requisitos antes de instalar los ejecutables.

### 7.1. Pruebas HTTP sin credenciales de Atlas

Crea `server/test/` y los siguientes archivos. El fixture usa un almacén de usuarios y `session.MemoryStore` exclusivamente para pruebas; `server/src/index.js` sigue utilizando Mongoose y connect-mongo. El diseño permite controlar el reloj y comprobar que los GET no renuevan la inactividad.

### Archivo `server/test/helpers.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Levanta la API en un puerto temporal, conserva cookie/CSRF para el cliente de prueba y permite avanzar el reloj. La memoria de esta utilidad no forma parte del arranque real.

{% raw %}
```js
import session from 'express-session';
import { createApp } from '../src/app.js';

export function memoryUsers() {
  const records = new Map();
  return {
    records,
    async create(data) {
      if ([...records.values()].some((u) => u.email === data.email || u.username === data.username)) throw Object.assign(new Error('duplicate'), { code: 11000 });
      const user = { ...data, _id: String(records.size + 1) };
      records.set(user._id, user);
      return user;
    },
    async byEmail(email) { return [...records.values()].find((u) => u.email === email); },
    async byId(id) { return records.get(id); },
  };
}
export async function fixture(options = {}) {
  let clock = Date.now();
  const users = memoryUsers();
  const store = new session.MemoryStore();
  const config = { NODE_ENV: 'test', SESSION_SECRET: 'solo-pruebas-'.repeat(4), WEB_ORIGIN: 'http://localhost:5173' };
  const app = createApp({ config, store, users, now: () => clock, ...options });
  const server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  function client() {
    let cookie = '', csrf = '';
    return {
      get cookie() { return cookie; },
      async call(path, { method = 'GET', body, headers = {} } = {}) {
        const response = await fetch(base + '/api' + path, { method, headers: { cookie, origin: config.WEB_ORIGIN, ...(body ? { 'content-type': 'application/json' } : {}), 'x-csrf-token': csrf, ...headers }, body: body ? JSON.stringify(body) : undefined });
        const set = response.headers.get('set-cookie');
        if (set) cookie = set.split(';')[0];
        const data = response.status === 204 ? null : await response.json();
        if (data?.csrfToken) csrf = data.csrfToken;
        return { status: response.status, data, headers: response.headers };
      },
    };
  }
  return { base, config, store, users, client, advance: (ms) => { clock += ms; }, close: () => new Promise((resolve) => server.close(resolve)) };
}
```

{% endraw %}
### Archivo `server/test/auth.test.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Las pruebas ejercitan el protocolo HTTP: hash, regeneración, revocación, credenciales, validación, duplicados, CSRF/origen, identidades, inactividad, límite absoluto, rate limiting, cuerpo grande y cookie Secure detrás de un proxy HTTPS simulado.

{% raw %}
```js
import test from 'node:test';
import assert from 'node:assert/strict';
import argon2 from 'argon2';
import { fixture } from './helpers.js';
import { IDLE_MS, ABSOLUTE_MS } from '../src/app.js';

const account = { username: 'piloto', email: 'piloto@example.com', password: 'Clave de prueba 123!' };
async function register(c, data = account) {
  await c.call('/auth/csrf');
  return c.call('/auth/register', { method: 'POST', body: data });
}
test('registro, hash Argon2id, regeneración, identidad y revocación', async (t) => {
  const f = await fixture(); t.after(f.close);
  const a = f.client(); await a.call('/auth/csrf'); const anonymous = a.cookie;
  const result = await a.call('/auth/register', { method: 'POST', body: account });
  assert.equal(result.status, 201); assert.notEqual(a.cookie, anonymous);
  assert.equal(result.data.user.passwordHash, undefined);
  const stored = f.users.records.get('1');
  assert.match(stored.passwordHash, /^\$argon2id\$/); assert.ok(await argon2.verify(stored.passwordHash, account.password));
  assert.equal((await a.call('/auth/me')).data.user.email, account.email);
  assert.match(result.headers.get('set-cookie'), /HttpOnly/); assert.match(result.headers.get('set-cookie'), /SameSite=Lax/);
  const oldCookie = a.cookie;
  assert.equal((await a.call('/auth/logout', { method: 'POST' })).status, 204);
  assert.equal((await a.call('/auth/me', { headers: { cookie: oldCookie } })).status, 401);
  await a.call('/auth/csrf');
  assert.equal((await a.call('/auth/login', { method: 'POST', body: { email: account.email, password: 'incorrecta' } })).status, 401);
  assert.equal((await a.call('/auth/login', { method: 'POST', body: { email: account.email, password: account.password } })).status, 200);
});
test('validación, duplicados, CSRF y dos identidades aisladas', async (t) => {
  const f = await fixture(); t.after(f.close);
  const a = f.client(), b = f.client();
  assert.equal((await a.call('/auth/register', { method: 'POST', body: account })).status, 403);
  await a.call('/auth/csrf');
  assert.equal((await a.call('/auth/register', { method: 'POST', body: { ...account, password: 'corta' } })).status, 400);
  assert.equal((await register(a)).status, 201);
  assert.equal((await register(b)).status, 409);
  assert.equal((await register(b, { ...account, username: 'otro' })).status, 409);
  assert.equal((await register(b, { ...account, email: 'otro@example.com' })).status, 409);
  assert.equal((await register(b, { ...account, username: 'otro', email: 'otro@example.com' })).status, 201);
  assert.notEqual((await a.call('/auth/me')).data.user.id, (await b.call('/auth/me')).data.user.id);
  assert.equal((await a.call('/auth/logout', { method: 'POST', headers: { origin: 'https://externo.example' } })).status, 403);
  assert.equal((await a.call('/auth/logout', { method: 'POST', headers: { 'x-csrf-token': 'x' } })).status, 403);
});
test('lecturas no renuevan inactividad; actividad explícita sí', async (t) => {
  const f = await fixture(); t.after(f.close); const a = f.client(); await register(a);
  f.advance(IDLE_MS - 1000); assert.equal((await a.call('/auth/me')).status, 200);
  f.advance(1000); assert.equal((await a.call('/auth/me')).status, 401);
  await register(a, { ...account, username: 'nuevo', email: 'nuevo@example.com' });
  f.advance(IDLE_MS - 1000); assert.equal((await a.call('/auth/activity', { method: 'POST' })).status, 204);
  f.advance(1000); assert.equal((await a.call('/auth/me')).status, 200);
});
test('el límite absoluto vence aunque exista actividad', async (t) => {
  const f = await fixture({ idleMs: ABSOLUTE_MS * 2 }); t.after(f.close); const a = f.client(); await register(a);
  f.advance(ABSOLUTE_MS - 1); assert.equal((await a.call('/auth/activity', { method: 'POST' })).status, 204);
  f.advance(1); assert.equal((await a.call('/auth/me')).status, 401);
});
test('límites de intentos y cuerpo JSON inválido', async (t) => {
  const f = await fixture({ authLimit: 2 }); t.after(f.close); const a = f.client(); await a.call('/auth/csrf');
  for (let i = 0; i < 2; i++) assert.equal((await a.call('/auth/login', { method: 'POST', body: {} })).status, 400);
  assert.equal((await a.call('/auth/login', { method: 'POST', body: {} })).status, 429);
  const response = await fetch(f.base + '/api/auth/login', { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{' });
  assert.equal(response.status, 400);
});
test('cookie Secure en producción detrás del proxy HTTPS y rechazo de cuerpos grandes', async (t) => {
  const f = await fixture({ config: { NODE_ENV: 'production', SESSION_SECRET: 'prueba-segura-'.repeat(4), WEB_ORIGIN: 'https://gpb.example.com' } });
  t.after(f.close); const a = f.client();
  const result = await a.call('/auth/csrf', { headers: { 'x-forwarded-proto': 'https' } });
  assert.match(result.headers.get('set-cookie'), /; Secure/);
  assert.match(result.headers.get('set-cookie'), /Path=\/api/);
  assert.equal((await a.call('/auth/register', { method: 'POST', body: account, headers: { origin: 'https://gpb.example.com', 'x-forwarded-proto': 'https' } })).status, 201);
  const response = await fetch(f.base + '/api/auth/login', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ large: 'x'.repeat(9000) }) });
  assert.equal(response.status, 413);
});
```

{% endraw %}
**Carpeta: raíz.**

{% raw %}
```sh
pnpm test
```

{% endraw %}
Resultado comprobado en la implementación: **6 pruebas aprobadas, 0 fallidas**. No necesitas `.env` para estas pruebas. El reloj controlado verifica reglas de expiración, no simula que se haya desplegado un servidor HTTPS.

### 7.2. Prueba web con una API aislada

Crea la carpeta `tests/` y agrega su API de prueba. Playwright arrancará tanto la API aislada como Vite+; no mantengas la API real en el puerto 3000 mientras ejecutas estas pruebas.

### Archivo `tests/local-api.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Utiliza las rutas reales con un store de memoria y usuarios de prueba. Su único propósito es la prueba de transporte; nunca debe utilizarse como entrada de producción.

{% raw %}
```js
// Sólo pruebas de transporte; nunca es un sustituto de Atlas en producción.
import session from '../server/node_modules/express-session/index.js';
import { createApp } from '../server/src/app.js';
import { memoryUsers } from '../server/test/helpers.js';
const config = { NODE_ENV: 'test', WEB_ORIGIN: 'http://localhost:5173', SESSION_SECRET: 'pruebas-locales-sin-secretos-reales-123456789' };
const server = createApp({ config, store: new session.MemoryStore(), users: memoryUsers(), authLimit: 200 }).listen(3000, '127.0.0.1', () => console.log('API aislada de prueba disponible'));
process.on('SIGTERM', () => server.close());
```

{% endraw %}
### Archivo `playwright.config.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

La configuración usa un solo worker, puertos fijos y no permite reutilizar un servidor ya existente. Desactiva trazas, video y capturas automáticas para no conservar cookies ni datos de formularios.

{% raw %}
```js
import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './tests', testMatch: '*.spec.js', workers: 1,
  use: { baseURL: 'http://localhost:5173', trace: 'off', screenshot: 'off', video: 'off' },
  webServer: [
    { command: 'node tests/local-api.js', url: 'http://127.0.0.1:3000/api/health', reuseExistingServer: false },
    { command: 'pnpm dev:client', url: 'http://localhost:5173', reuseExistingServer: false },
  ],
});
```

{% endraw %}
### Archivo `tests/web.spec.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Abre un perfil temporal, registra una cuenta ficticia, reinicia el navegador con el mismo perfil, navega, cierra sesión y comprueba nuevo acceso. También comprueba el ancho móvil. El flag solicita la política de bloqueo de cookies de terceros; la garantía arquitectónica es que las solicitudes usan el mismo origen.

{% raw %}
```js
import { test, expect, chromium } from '@playwright/test';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

test('registro, reinicio de navegador, login y cierre con cookies de terceros bloqueadas', async () => {
  const profile = await mkdtemp(join(tmpdir(), 'gpb-web-'));
  const options = { headless: true, ...(process.env.GPB_BROWSER_CHANNEL ? { channel: process.env.GPB_BROWSER_CHANNEL } : {}), args: ['--test-third-party-cookie-phaseout'], viewport: { width: 1280, height: 800 } };
  let context = await chromium.launchPersistentContext(profile, options);
  try {
    let page = await context.newPage();
    await page.goto('http://localhost:5173/');
    await expect(page).toHaveURL(/login/);
    if (process.env.GPB_CAPTURE_DIR) {
      await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).waitFor();
      await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'acceso.png') });
      await page.setViewportSize({ width: 390, height: 844 });
      await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'acceso-movil.png'), fullPage: true });
      await page.setViewportSize({ width: 1280, height: 800 });
    }
    await page.getByRole('link', { name: 'Regístrate' }).click();
    await page.getByLabel('Nombre de usuario').fill('piloto_web');
    await page.getByLabel('Correo electrónico').fill('web@example.com');
    await page.getByLabel('Contraseña', { exact: true }).fill('Clave de prueba 123!');
    await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Hola, piloto_web.' })).toBeVisible();
    const cookie = (await context.cookies()).find((c) => c.name === 'gpb.sid');
    expect(cookie.httpOnly).toBe(true); expect(cookie.expires).toBeGreaterThan(Date.now() / 1000);
    await context.close();
    context = await chromium.launchPersistentContext(profile, options);
    page = await context.newPage(); await page.goto('http://localhost:5173/');
    await expect(page.getByRole('heading', { name: 'Hola, piloto_web.' })).toBeVisible();
    await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Mi colección' })).toBeVisible();
    await page.getByRole('button', { name: 'Cerrar sesión' }).click();
    await expect(page).toHaveURL(/login/);
    await page.reload(); await expect(page.getByRole('button', { name: 'Iniciar sesión', exact: true })).toBeVisible();
    await page.getByLabel('Correo electrónico').fill('web@example.com');
    await page.getByLabel('Contraseña', { exact: true }).fill('incorrecta');
    await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
    await expect(page.getByRole('alert')).toContainText('Correo o contraseña incorrectos.');
    await page.getByLabel('Contraseña', { exact: true }).fill('Clave de prueba 123!');
    await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Hola, piloto_web.' })).toBeVisible();
    await page.setViewportSize({ width: 390, height: 844 });
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  } finally { await context.close(); await rm(profile, { recursive: true, force: true }); }
});
```

{% endraw %}
### 7.3. Preparar la prueba mínima de Electron

Electron será el contenedor del cliente en la guía 6. Por ahora sólo comprobaremos la persistencia y revocación del transporte. Crear esta prueba temprano permite detectar diferencias con el navegador antes de construir toda la aplicación de escritorio.

Crea `electron/` para el archivo siguiente. El proceso principal limita las acciones permitidas y usa fetch nativo de Node con el almacén de cookies persistente de Electron. No entrega cookies al renderer ni cambia las políticas CORS/CORP de la API. La ventana oculta no contiene todavía nuestra interfaz React.

Durante la implementación, las solicitudes desde un contexto opaco de Chromium encontraron restricciones de recursos. La solución de referencia conserva las protecciones de la API y administra el transporte en el proceso principal; no desactives webSecurity para intentar corregirlo.

### Archivo `electron/session-probe.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Las variables GPB_PROBE_* se proporcionan desde la prueba, no desde el cliente. Se aceptan acciones cerradas y una cookie host-only con atributos conocidos; se rechazan redirecciones. La ventana mantiene contextIsolation y sandbox activados, y nodeIntegration desactivado.

{% raw %}
```js
// Preparativo de etapa 1. No empaqueta ni integra React (etapa 6).
import { app, BrowserWindow, session } from 'electron';
app.setPath('userData', process.env.GPB_PROBE_PROFILE);
app.whenReady().then(async () => {
  const transport = session.fromPartition('persist:gpb-session-probe');
  const origin = new URL(process.env.GPB_PROBE_API);
  if (!['http:', 'https:'].includes(origin.protocol) || origin.pathname !== '/') throw new Error('Origen de prueba inválido');
  const allowed = new Map([
    ['csrf', 'GET'], ['me', 'GET'], ['register', 'POST'], ['login', 'POST'], ['logout', 'POST'], ['activity', 'POST'],
  ]);
  let csrfToken;
  // Sólo proceso principal y controlador de pruebas; ninguna cookie se entrega al renderer.
  // Fetch nativo de Node + almacén persistente de Electron: no cambia CORP/CORS de la API.
  globalThis.gpbProbe = async (action, body) => {
    if (!allowed.has(action)) throw new Error('Acción no permitida');
    const method = allowed.get(action);
    const url = new URL(`/api/auth/${action}`, origin).href;
    const cookies = await transport.cookies.get({ url, name: 'gpb.sid' });
    const response = await fetch(url, {
      method, redirect: 'error', signal: AbortSignal.timeout(15000),
      headers: {
        Origin: process.env.GPB_PROBE_WEB_ORIGIN,
        Cookie: cookies.map(({ name, value }) => `${name}=${value}`).join('; '),
        ...(body ? { 'Content-Type': 'application/json' } : {}),
        ...(method === 'POST' ? { 'X-CSRF-Token': csrfToken } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    // El contrato de la API es una única cookie host-only, Path=/api, HttpOnly, SameSite=Lax.
    // No se aceptan cookies de otros nombres, dominios o rutas.
    for (const header of response.headers.getSetCookie()) {
      const [pair, ...attributes] = header.split(';').map((part) => part.trim());
      const separator = pair.indexOf('=');
      if (pair.slice(0, separator) !== 'gpb.sid') continue;
      const fields = new Map(attributes.map((field) => { const i = field.indexOf('='); return i < 0 ? [field.toLowerCase(), true] : [field.slice(0, i).toLowerCase(), field.slice(i + 1)]; }));
      if (fields.has('domain') || fields.get('path') !== '/api' || !fields.has('httponly') || String(fields.get('samesite')).toLowerCase() !== 'lax') throw new Error('Cookie fuera del contrato');
      const expirationDate = Date.parse(fields.get('expires')) / 1000;
      if (!Number.isFinite(expirationDate)) throw new Error('Cookie sin vencimiento');
      if (expirationDate <= Date.now() / 1000) await transport.cookies.remove(url, 'gpb.sid');
      else await transport.cookies.set({ url, name: 'gpb.sid', value: pair.slice(separator + 1), path: '/api', httpOnly: true, secure: fields.has('secure'), sameSite: 'lax', expirationDate });
    }
    await transport.cookies.flushStore();
    const data = response.status === 204 ? null : await response.json();
    if (data?.csrfToken) csrfToken = data.csrfToken;
    return { status: response.status, user: data?.user };
  };
  const window = new BrowserWindow({ show: false, webPreferences: { contextIsolation: true, nodeIntegration: false, sandbox: true } });
  window.webContents.setWindowOpenHandler(() => ({ action: 'deny' }));
  window.webContents.on('will-navigate', (event) => event.preventDefault());
  await window.loadURL('about:blank');
});
```

{% endraw %}
### Archivo `tests/electron.spec.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Inicia y cierra procesos Electron con la misma partición en un perfil temporal. Comprueba acceso después de reiniciar y rechazo después de cerrar sesión y reiniciar de nuevo. Siempre elimina el perfil al terminar.

{% raw %}
```js
import { test, expect, _electron as electron } from '@playwright/test';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

test('transporte controlado Electron conserva y revoca sesión al reiniciar', async () => {
  const profile = await mkdtemp(join(tmpdir(), 'gpb-electron-'));
  const options = { args: ['electron/session-probe.js'], env: { ...process.env, GPB_PROBE_PROFILE: profile, GPB_PROBE_API: 'http://127.0.0.1:3000', GPB_PROBE_WEB_ORIGIN: 'http://localhost:5173' } };
  let desktop = await electron.launch(options);
  const call = (action, body) => desktop.evaluate((_electron, values) => globalThis.gpbProbe(values.action, values.body), { action, body });
  try {
    expect((await call('csrf')).status).toBe(200);
    expect((await call('register', { username: 'piloto_electron', email: 'electron@example.com', password: 'Clave de prueba 123!' })).status).toBe(201);
    await desktop.close(); desktop = await electron.launch(options);
    expect((await call('me')).user.username).toBe('piloto_electron');
    await call('csrf'); expect((await call('logout')).status).toBe(204);
    await desktop.close(); desktop = await electron.launch(options);
    expect((await call('me')).status).toBe(401);
  } finally { await desktop.close(); await rm(profile, { recursive: true, force: true }); }
});
```

{% endraw %}
**Carpeta: raíz.** Detén los servidores de desarrollo y deja libres 3000 y 5173. Instala los ejecutables de comprobación por proyecto/caché y ejecuta:

{% raw %}
```sh
pnpm exec playwright install chromium
pnpm exec install-electron
pnpm exec playwright --version
pnpm exec electron --version
pnpm test:transport
```

{% endraw %}
Versiones de herramientas comprobadas: Playwright 1.65.0 y Electron 45.3.1. En esta versión de Electron se utilizó el comando explícito `install-electron` para disponer del binario. Estas descargas requieren conexión a internet; el lock no incluye sus ejecutables.

Resultado comprobado: **2 pruebas de transporte aprobadas**. Los perfiles son temporales; no se automatiza tu perfil personal. El navegador de prueba de referencia fue Chromium 158.0.8127.18. Esto no constituye un paquete macOS ni la integración de React dentro de Electron.

### 7.4. Verificar persistencia real con Atlas

Las pruebas anteriores no acreditan que tus permisos, credenciales o índices de Atlas estén correctos. Crea `server/scripts/` y agrega estos verificadores para comprobarlos de forma separada.

### Archivo `server/scripts/check-atlas.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Crea colecciones temporales con nombres aleatorios, registra un usuario mediante HTTP, comprueba hash/duplicados, reinicia la API sobre el mismo MongoDB, comprueba sesión y logout, informa la versión del servidor y limpia las colecciones. No modifica cuentas existentes.

{% raw %}
```js
// Verificación real opcional. Usa colecciones temporales con sufijo aleatorio y las elimina al terminar.
import mongoose from 'mongoose';
import MongoStore from 'connect-mongo';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { createApp } from '../src/app.js';
import { readConfig } from '../src/config.js';
import { User } from '../src/users.js';

let connection, server;
const suffix = randomBytes(6).toString('hex');
const collections = [`gpb_probe_users_${suffix}`, `gpb_probe_sessions_${suffix}`];
try {
  const config = readConfig();
  connection = await mongoose.createConnection(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 }).asPromise();
  const ProbeUser = connection.model('ProbeUser', User.schema.clone(), collections[0]);
  await ProbeUser.init();
  const users = { create: (data) => ProbeUser.create(data), byEmail: (email) => ProbeUser.findOne({ email }).select('+passwordHash'), byId: (id) => ProbeUser.findById(id) };
  const start = async () => {
    const store = MongoStore.create({ client: connection.getClient(), collectionName: collections[1] });
    store.on('error', () => {});
    server = createApp({ config: { ...config, NODE_ENV: 'test' }, store, users }).listen(0, '127.0.0.1');
    await new Promise((resolve) => server.once('listening', resolve));
    return `http://127.0.0.1:${server.address().port}/api/auth`;
  };
  let base = await start(), cookie = '', csrf = '';
  const call = async (action, body) => {
    const response = await fetch(`${base}/${action}`, { method: body ? 'POST' : 'GET', headers: { cookie, origin: config.WEB_ORIGIN, 'content-type': 'application/json', 'x-csrf-token': csrf }, body: body ? JSON.stringify(body) : undefined });
    const set = response.headers.get('set-cookie'); if (set) cookie = set.split(';')[0];
    const data = response.status === 204 ? null : await response.json(); if (data?.csrfToken) csrf = data.csrfToken;
    return { status: response.status, data };
  };
  await call('csrf');
  const account = { username: `probe_${suffix}`, email: `${suffix}@example.com`, password: randomBytes(24).toString('hex') };
  assert.equal((await call('register', account)).status, 201);
  const saved = await users.byEmail(account.email); assert.match(saved.passwordHash, /^\$argon2id\$/);
  assert.equal((await call('register', account)).status, 409);
  const persistentCookie = cookie;
  await new Promise((resolve) => server.close(resolve));
  base = await start(); cookie = persistentCookie;
  assert.equal((await call('me')).data.user.username, account.username);
  await call('csrf'); assert.equal((await call('logout', {})).status, 204);
  cookie = persistentCookie; assert.equal((await call('me')).status, 401);
  const info = await connection.db.admin().serverInfo();
  console.log(`Atlas comprobado: MongoDB ${info.version}; índices únicos, hash, sesión tras reiniciar la API y revocación correctos.`);
} catch (error) {
  const category = ['ENOTFOUND', 'EAI_AGAIN', 'ESERVFAIL'].includes(error.code) ? 'DNS del servidor Atlas' : error.code === 18 ? 'autenticación Atlas' : error.issues ? 'variables de entorno' : 'conexión o verificación';
  console.error(`Etapa pendiente: ${category}.`);
  console.error('Comprobación Atlas no completada. Revisa conexión, variables y permisos locales. No se muestran datos privados.');
  process.exitCode = 1;
} finally {
  if (server?.listening) await new Promise((resolve) => server.close(resolve));
  if (connection?.readyState === 1) {
    for (const name of collections) {
      try { await connection.dropCollection(name); } catch (error) { if (error.code !== 26) { console.error('Quedó pendiente limpiar una colección temporal gpb_probe.'); process.exitCode = 1; } }
    }
    await connection.close();
  }
}
```

{% endraw %}
### Archivo `server/scripts/check-web-atlas.js`

**Acción:** crear este archivo con el contenido completo siguiente. Si vienes de una plantilla, reemplaza su contenido.

Arranca la entrada real de la API con tu .env local y Vite+. Usa un perfil Chromium temporal, crea su propia cuenta desde React, verifica el hash en MongoDB, reinicia navegador/API y recorre navegación, acceso incorrecto/correcto y cierre. Elimina sólo la cuenta y sesiones observadas por esta prueba, detiene sus procesos y elimina el perfil. Requiere la configuración de desarrollo y puertos libres.

{% raw %}
```js
// Comprueba la entrada real de la API y React con Atlas; sólo elimina la cuenta y sesiones creadas aquí.
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { createServer } from 'node:net';
import { mkdtemp, rm } from 'node:fs/promises';
import { randomBytes } from 'node:crypto';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import mongoose from 'mongoose';
import { chromium } from '@playwright/test';
import { readConfig } from '../src/config.js';
import { User } from '../src/users.js';

const root = fileURLToPath(new URL('../../', import.meta.url));
const suffix = randomBytes(6).toString('hex');
const account = { username: `web_${suffix}`, email: `${suffix}@example.com`, password: randomBytes(24).toString('hex') };
const sessionIds = new Set();
let apiProcess, clientProcess, browser, profile, createdId;
let stage = 'configuración';
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
async function freePort(port) {
  const server = createServer();
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(port, '127.0.0.1', resolve); });
  await new Promise((resolve) => server.close(resolve));
}
function start(executable, args, cwd, env = process.env) {
  const child = spawn(executable, args, { cwd, env, detached: true, stdio: 'ignore' });
  child.on('error', () => {});
  return child;
}
async function stop(child) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return;
  const done = once(child, 'exit').catch(() => {});
  try { process.kill(-child.pid, 'SIGTERM'); } catch { return; }
  await Promise.race([done, delay(5000)]);
  if (child.exitCode === null && child.signalCode === null) { try { process.kill(-child.pid, 'SIGKILL'); } catch {} await done; }
}
async function ready(url, child) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    if (child.exitCode !== null || child.signalCode !== null) throw new Error('Proceso detenido');
    try { const response = await fetch(url, { signal: AbortSignal.timeout(1000) }); if (response.ok) return; } catch {}
    await delay(100);
  }
  throw new Error('Sin respuesta');
}
async function trackCookies() {
  if (!browser) return;
  for (const cookie of await browser.cookies('http://localhost:5173/api/auth/me')) {
    if (cookie.name !== 'gpb.sid') continue;
    const value = decodeURIComponent(cookie.value);
    if (value.startsWith('s:')) sessionIds.add(value.slice(2).split('.')[0]);
  }
}
async function heading(page) {
  await page.getByRole('heading', { name: `Hola, ${account.username}.`, exact: true }).waitFor();
  await trackCookies();
}
try {
  const config = readConfig();
  if (config.NODE_ENV !== 'development' || config.PORT !== 3000 || config.WEB_ORIGIN !== 'http://localhost:5173') throw new Error('La prueba requiere configuración local estándar');
  await freePort(3000); await freePort(5173);
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  stage = 'arranque de API y cliente';
  const startApi = () => start(process.execPath, ['--env-file=.env', 'src/index.js'], join(root, 'server'));
  apiProcess = startApi();
  await ready('http://127.0.0.1:3000/api/health', apiProcess);
  const clientEnv = { ...process.env }; delete clientEnv.MONGODB_URI; delete clientEnv.SESSION_SECRET;
  clientProcess = start(join(root, 'client/node_modules/vite-plus/bin/vp'), ['dev'], join(root, 'client'), clientEnv);
  await ready('http://localhost:5173', clientProcess);
  profile = await mkdtemp(join(tmpdir(), 'gpb-atlas-web-'));
  const options = { headless: true, args: ['--test-third-party-cookie-phaseout'], viewport: { width: 1280, height: 800 } };
  browser = await chromium.launchPersistentContext(profile, options);
  let page = await browser.newPage();
  page.setDefaultTimeout(15000);
  stage = 'registro desde React';
  await page.goto('http://localhost:5173/'); await page.waitForURL('**/login'); await trackCookies();
  await page.getByRole('link', { name: 'Regístrate', exact: true }).click();
  await page.getByLabel('Nombre de usuario').fill(account.username);
  await page.getByLabel('Correo electrónico').fill(account.email);
  await page.getByLabel('Contraseña', { exact: true }).fill(account.password);
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await heading(page);
  const saved = await User.findOne({ email: account.email, username: account.username }).select('+passwordHash');
  if (!saved || !saved.passwordHash.startsWith('$argon2id$')) throw new Error('Cuenta no persistida');
  createdId = saved._id;
  stage = 'reapertura del navegador y reinicio de API';
  await browser.close(); browser = null;
  await stop(apiProcess); apiProcess = startApi();
  await ready('http://127.0.0.1:3000/api/health', apiProcess);
  browser = await chromium.launchPersistentContext(profile, options);
  page = await browser.newPage(); page.setDefaultTimeout(15000);
  await page.goto('http://localhost:5173/'); await heading(page);
  stage = 'navegación y cierre de sesión';
  await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
  await page.getByRole('heading', { name: 'Mi colección', exact: true }).waitFor();
  await page.getByRole('button', { name: 'Cerrar sesión', exact: true }).click();
  await page.waitForURL('**/login'); await page.reload();
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).waitFor(); await trackCookies();
  stage = 'rechazo de contraseña incorrecta y nuevo acceso';
  await page.getByLabel('Correo electrónico').fill(account.email);
  await page.getByLabel('Contraseña', { exact: true }).fill('incorrecta');
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
  await page.getByRole('alert').filter({ hasText: 'Correo o contraseña incorrectos.' }).waitFor(); await trackCookies();
  await page.getByLabel('Contraseña', { exact: true }).fill(account.password);
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click(); await heading(page);
  await page.getByRole('button', { name: 'Cerrar sesión', exact: true }).click(); await page.waitForURL('**/login');
  console.log('Web + Atlas comprobados: registro React, hash persistido, navegador y API reiniciados, navegación, credenciales incorrectas, nuevo acceso y cierre de sesión.');
} catch {
  console.error(`Comprobación web Atlas no completada. Paso: ${stage}. No se muestran datos privados.`);
  process.exitCode = 1;
} finally {
  if (browser) { await trackCookies().catch(() => {}); await browser.close(); }
  await stop(apiProcess); await stop(clientProcess);
  if (mongoose.connection.readyState === 1) {
    try {
      const user = createdId ? { _id: createdId, email: account.email } : { username: account.username, email: account.email };
      await User.deleteOne(user);
      if (sessionIds.size) await mongoose.connection.collection('sessions').deleteMany({ _id: { $in: [...sessionIds] } });
      console.log('Cuenta y sesiones exclusivas de prueba eliminadas; procesos locales detenidos.');
    } catch { console.error('Pendiente limpiar los registros exclusivos de esta prueba.'); process.exitCode = 1; }
    await mongoose.disconnect();
  }
  if (profile) await rm(profile, { recursive: true, force: true });
}
```

{% endraw %}
**Carpeta: raíz.** Con `server/.env` privado correcto y los servidores de desarrollo detenidos:

{% raw %}
```sh
pnpm --filter @gpb/server check:atlas
pnpm --filter @gpb/server check:web:atlas
```

{% endraw %}
Resultados reales observados en la implementación de referencia:

{% raw %}
```text
Atlas comprobado: MongoDB 8.0.37; índices únicos, hash, sesión tras reiniciar la API y revocación correctos.
```

{% endraw %}
{% raw %}
```text
Web + Atlas comprobados: registro React, hash persistido, navegador y API reiniciados, navegación, credenciales incorrectas, nuevo acceso y cierre de sesión.
Cuenta y sesiones exclusivas de prueba eliminadas; procesos locales detenidos.
```

{% endraw %}
Ambos comandos terminaron con código 0. Debes obtener y registrar tus propios resultados: la conectividad del clúster del docente no demuestra la de tu cuenta. Si la limpieza informa un fallo, revisa los datos exclusivos de prueba antes de repetir; no elimines colecciones de usuarios reales para resolverlo.

**Distinción de evidencias:** se comprobó el código local y su conexión con Atlas. Esta redacción también se reprodujo desde la preparación en una carpeta aislada, con los resultados descritos en el informe de verificación. La publicación de web/API y la aplicación empaquetada se comprobarán en entregas posteriores.

## 8. Errores frecuentes

| Síntoma | Qué revisar |
|---|---|
| Node/pnpm no coinciden con las versiones del curso | Comprueba los ejecutables activos y la configuración por proyecto; no cambies globalmente herramientas sin diagnosticar |
| El lock no coincide con los manifiestos | Usa los archivos de la misma entrega y el lock adjunto; no lo regeneres para ocultar diferencias |
| Argon2 aparece como compilación no autorizada | En pnpm 12 revisa `allowBuilds` del workspace y repite la instalación; no habilites indiscriminadamente todos los scripts |
| Atlas falla por DNS | Conserva el servidor exacto de Connect → Drivers; el hostname del ejemplo no existe para tu clúster |
| Atlas rechaza autenticación | Usa un usuario de Database Access, contraseña real sin `< >` y codificación URL de caracteres reservados |
| Atlas no conecta o agota tiempo | Revisa disponibilidad del clúster y la IP pública permitida en Network Access |
| Variables incompletas | Revisa los nombres y SESSION_SECRET de al menos 32 caracteres; no publiques el archivo para pedir ayuda |
| El navegador devuelve 403 | Usa http://localhost:5173, el mismo WEB_ORIGIN sin barra final y el cliente que solicita CSRF; no abras CORS para resolverlo |
| Vite+ indica puerto ocupado | Detén el proceso que lo utiliza; no cambies silenciosamente el origen de una parte solamente |
| La sesión se pierde al reiniciar API | Comprueba que ejecutas src/index.js con connect-mongo y mantienes el mismo secreto; no uses tests/local-api.js como servidor real |
| La sesión no se conserva al cerrar navegador | Usa el mismo perfil, fuera de incógnito, sin borrar cookies; verifica primero que no haya vencido por inactividad |
| Los GET parecen mantener una sesión viva | Revisa las pruebas de reloj: sólo activity modifica lastActivity. No agregues actividad a un sondeo periódico |
| Electron no tiene ejecutable | Ejecuta pnpm exec install-electron; pnpm rebuild electron no fue el paso que descargó el binario de esta referencia |
| Electron no llega al estado ready | Conserva app.whenReady().then(...); no traslades la espera al nivel superior de la entrada ESM |
| Un POST manual a login/register da 403 | Es esperado sin Origin y token ligados a una cookie. Usa el cliente o los verificadores; no quites CSRF para probar |
| Cambia el código que genera shadcn | La CLI fija su versión, pero consulta un registro remoto; usa los componentes JSX de esta entrega |
| check informa formato o lint | Revisa la ruta y el contenido copiado. vp check --fix puede formatear, pero no sustituye comprender el cambio |

Un mensaje genérico del servidor es deliberado: no imprime la URI ni la contraseña. Diagnostica por categoría y comparte sólo el síntoma, no credenciales, cookies o tokens.

## 9. Guardar el punto de control y cerrar la entrega

Si todavía no inicializaste Git, hazlo **en la raíz**, no dentro de client o server. Git crea la carpeta oculta `.git`; no hay un archivo que debas escribir manualmente. Git se utiliza para conservar un punto consultable de la entrega; no se publica nada automáticamente.

**Carpeta: raíz, sólo si todavía no existe repositorio.**

{% raw %}
```sh
git init
git branch -m main
```

{% endraw %}
El segundo comando fija `main` sólo en este repositorio; evita depender del nombre inicial que tenga configurado el equipo. En la comprobación, `git init` eligió inicialmente `master` y el cambio local a `main` terminó correctamente.

Antes de preparar archivos:

{% raw %}
```sh
git status --short
git check-ignore -v server/.env node_modules client/dist
```

{% endraw %}
Los archivos privados y generados deben aparecer excluidos. Revisa también cualquier archivo ZIP que decidas versionar; `.gitignore` no inspecciona su interior.

Cuando hayas terminado tus comprobaciones y decidido conservarlas:

{% raw %}
```sh
git add .
git diff --cached --check
git diff --cached --stat
git commit -m "Completa la etapa 1: configuración y autenticación"
git status --short
```

{% endraw %}
No repitas un commit por haber leído la recomendación si ya tienes el punto de control. En el repositorio de referencia se creó el commit `9900285`. No se crearon etiquetas ni se publicó un remoto.

### 9.1. Lista de comprobación de la entrega

- [ ] Node, pnpm y Vite+ local coinciden con las versiones declaradas.
- [ ] La instalación congelada, check y build terminan correctamente.
- [ ] `.env` contiene sólo valores privados locales y está excluido de Git.
- [ ] Registro válido abre la pantalla protegida y los duplicados se rechazan.
- [ ] Login incorrecto se rechaza y el correcto abre sesión.
- [ ] El mismo perfil conserva la sesión vigente al reabrir navegador y reiniciar API.
- [ ] Logout invalida el identificador en el servidor.
- [ ] Las pruebas de inactividad, límite absoluto, validación y CSRF están aprobadas.
- [ ] Las pruebas de transporte web/Electron pasan sin reutilizar datos personales.
- [ ] Los verificadores reales de Atlas pasan y sus datos de prueba se limpian.
- [ ] Se distinguen resultados locales de despliegue y paquete, que no se probaron aquí.

### 9.2. Qué continúa

La base de usuarios y sesiones permitirá asociar cada Gunpla con su propietario. La guía 2 implementará los modelos, catálogos de grados/escalas y operaciones de colección. Allí se comprobará que un usuario no pueda consultar ni modificar los registros de otro.

La reproducción de esta guía se completó desde la preparación en una copia aislada. Se registraron los resultados y se incorporaron las aclaraciones documentales sin cambiar el código de aplicación. La guía queda técnicamente lista para grabar. La publicación se realizará únicamente conforme a las indicaciones del docente.

## 10. Catálogo de herramientas y fuentes oficiales

Fuentes consultadas el **12 de noviembre de 2026**. Las instrucciones oficiales explican la instalación general; el uso de workspaces, versiones exactas, proxy, límites de sesión y scripts de comprobación son adaptaciones de GPB.

Las fichas siguientes mantienen el orden: qué es, por qué se utiliza, fuente oficial de inicio, requisitos/versión, instalación/configuración y comprobación. Para paquetes sin CLI se usa `pnpm list`; no se inventa una opción `--version`.

Los comandos se ejecutan desde la raíz, después de escribir los manifiestos. El comando común `pnpm install --frozen-lockfile` instala las dependencias declaradas; no crea por sí solo el código que presentamos.

### Node.js — 26.13.1

1. **Qué es:** Runtime JavaScript para API y herramientas.
2. **Uso en GPB:** Unifica la versión local y la prevista para Render.
3. **Getting Started:** [Node.js](https://nodejs.org/en/download).
4. **Requisitos y versión:** macOS arm64. El entorno de referencia ya tenía esta versión; .node-version y engines la declaran por proyecto. Versión elegida: 26.13.1.
5. **Instalación/configuración:** si no tienes ese runtime, descarga su archivo binario portable para macOS arm64 desde la fuente oficial y descomprímelo en una carpeta de herramientas fuera del repositorio. Activa su directorio bin en el PATH sólo de la terminal de trabajo o mediante tu gestor por proyecto. No cambies globalmente el Node del equipo. La instalación del runtime no se volvió a realizar durante esta entrega; se comprobó el ya disponible.
6. **Comprobación:** `node --version`. Resultado efectivo: v26.13.1; pruebas con node:test ejecutadas.

### pnpm — 12.18.0

1. **Qué es:** Gestor de paquetes y workspaces.
2. **Uso en GPB:** Conserva una resolución exacta para cliente y API.
3. **Getting Started:** [pnpm](https://pnpm.io/installation).
4. **Requisitos y versión:** Disponible mediante el entorno existente Vite+; packageManager fija la versión, sin actualización global. Versión elegida: 12.18.0.
5. **Instalación/configuración:** el entorno de referencia ya disponía de pnpm a través de Vite+. El packageManager raíz selecciona 12.18.0. Si tu entorno no lo proporciona, sigue la instalación oficial en un directorio de herramientas de tu usuario y actívalo sólo para la terminal del proyecto; no ejecutes una actualización global como parte del ejercicio. Una vez disponible, ejecuta `pnpm install --frozen-lockfile` en raíz.
6. **Comprobación:** `pnpm --version`. Resultado efectivo: 12.18.0; pnpm install --frozen-lockfile terminó correctamente.

### Vite+ — 1.6.0

1. **Qué es:** Conjunto de herramientas detrás de vp.
2. **Uso en GPB:** Desarrolla, compila, da formato y revisa React con una CLI local.
3. **Getting Started:** [Vite+](https://viteplus.dev/guide/).
4. **Requisitos y versión:** Node ^22.18, ^24.11 o >=26. Global opcional ya existente; paquete local exacto vía manifiesto y pnpm install. Versión elegida: 1.6.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client exec vp --version`. Resultado efectivo: CLI/local 1.6.0; Vite 8.3.7, Rolldown 1.2.18, Vitest 5.1.0, Oxfmt 0.78.0, Oxlint 1.93.0, oxlint-tsgolint 7.0.2006, tsdown 0.23.4. Build y check correctos.

### React y React DOM — 19.3.1

1. **Qué es:** Biblioteca de componentes y renderizador web.
2. **Uso en GPB:** Construyen formularios y estado de autenticación.
3. **Getting Started:** [React y React DOM](https://react.dev/learn/installation).
4. **Requisitos y versión:** Node y Vite+ configurados. Dependencias exactas declaradas en client/package.json; pnpm install desde raíz. Versión elegida: 19.3.1.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list react react-dom --depth 0`. Resultado efectivo: 19.3.1 ambos; flujo web comprobado con Chrome.

### Plugin React de Vite — 6.1.2

1. **Qué es:** Integración de React con la herramienta de desarrollo.
2. **Uso en GPB:** Transforma JSX y mantiene el ciclo de desarrollo.
3. **Getting Started:** [Plugin React de Vite](https://github.com/vitejs/vite-plugin-react/tree/main/packages/plugin-react).
4. **Requisitos y versión:** Node ^20.19 o >=22.12. Manifiesto del cliente y pnpm install en raíz. Versión elegida: 6.1.2.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list @vitejs/plugin-react --depth 0`. Resultado efectivo: 6.1.2; compilación correcta con el alias Vite+ del workspace.

### React Router — 8.5.1

1. **Qué es:** Navegación declarativa para React.
2. **Uso en GPB:** Separa acceso, registro y rutas protegidas.
3. **Getting Started:** [React Router](https://reactrouter.com/start/declarative/installation).
4. **Requisitos y versión:** Node >=22.22. Se declara exacto en client/package.json y se instala desde raíz. Versión elegida: 8.5.1.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list react-router --depth 0`. Resultado efectivo: 8.5.1; redirección al login y navegación comprobadas.

### Tailwind CSS y plugin Vite — 4.3.5

1. **Qué es:** Estilos utilitarios y su integración de compilación.
2. **Uso en GPB:** Estilizan shadcn/ui y el modo oscuro de GPB.
3. **Getting Started:** [Tailwind CSS y plugin Vite](https://tailwindcss.com/docs/installation/using-vite).
4. **Requisitos y versión:** Cliente React/Vite+ configurado. Ambos paquetes exactos en manifiesto; pnpm install raíz; plugin en vite.config.js e import CSS. Versión elegida: 4.3.5.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list tailwindcss @tailwindcss/vite --depth 0`. Resultado efectivo: 4.3.5 ambos; CSS compilado y formulario renderizado.

### shadcn/ui CLI — 4.23.0

1. **Qué es:** Generador que copia componentes editables al proyecto.
2. **Uso en GPB:** Aporta Button, Input, Label y Card sin añadir pantallas ajenas a la etapa.
3. **Getting Started:** [shadcn/ui CLI](https://ui.shadcn.com/docs/installation/vite).
4. **Requisitos y versión:** React, Tailwind, alias @ y components.json con tsx:false. Desde raíz: pnpm dlx shadcn@4.23.0 add button input label card --cwd client --yes. Versión elegida: 4.23.0.
5. **Instalación/configuración:** CLI puntual mediante `pnpm dlx shadcn@4.23.0 add button input label card --cwd client --yes`; sin instalación global. Los componentes de referencia y sus dependencias exactas se incluyen en el apartado 5.
6. **Comprobación:** `pnpm dlx shadcn@4.23.0 --version`. Resultado efectivo: Versión fijada y comprobada: 4.23.0. Se ejecutaron init --help, add y --version (4.23.0). Cuatro componentes JSX generados y compilados; no hay paquete runtime shadcn.

### Radix UI — 1.8.1

1. **Qué es:** Primitivas accesibles utilizadas por los componentes.
2. **Uso en GPB:** Implementa Label y composición Slot de Button.
3. **Getting Started:** [Radix UI](https://www.radix-ui.com/primitives/docs/overview/getting-started).
4. **Requisitos y versión:** React. Instalado por shadcn y fijado en el manifiesto del cliente. Versión elegida: 1.8.1.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list radix-ui --depth 0`. Resultado efectivo: 1.8.1; renderizado y formularios comprobados.

### cn — 0.5.2

1. **Qué es:** Combinador de clases y resolución de conflictos de Tailwind.
2. **Uso en GPB:** Los componentes actuales de shadcn lo importan directamente.
3. **Getting Started:** [cn](https://github.com/shadcn-ui/cn#readme).
4. **Requisitos y versión:** Cliente React/Tailwind. Instalado por shadcn, versión exacta en manifiesto. Versión elegida: 0.5.2.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list cn --depth 0`. Resultado efectivo: 0.5.2; compilación y estilos correctos.

### Class Variance Authority — 0.7.1

1. **Qué es:** Composición de variantes de clases.
2. **Uso en GPB:** Button lo utiliza para variantes y tamaños.
3. **Getting Started:** [Class Variance Authority](https://cva.style/getting-started/installation/).
4. **Requisitos y versión:** Cliente preparado. Desde raíz: pnpm --filter @gpb/client add class-variance-authority@0.7.1. Versión elegida: 0.7.1.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/client list class-variance-authority --depth 0`. Resultado efectivo: 0.7.1; Button compila y funciona.

### Express — 5.3.0

1. **Qué es:** Framework HTTP para Node.
2. **Uso en GPB:** API independiente del cliente y de Electron.
3. **Getting Started:** [Express](https://expressjs.com/en/starter/installing/).
4. **Requisitos y versión:** Node >=18. Dependencia exacta de server/package.json; pnpm install raíz. Versión elegida: 5.3.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list express --depth 0`. Resultado efectivo: 5.3.0; pruebas HTTP de API correctas.

### Mongoose — 9.12.0

1. **Qué es:** Modelos, esquemas e índices para MongoDB.
2. **Uso en GPB:** Valida persistencia del usuario e índices únicos.
3. **Getting Started:** [Mongoose](https://mongoosejs.com/docs/index.html).
4. **Requisitos y versión:** Node >=20.19 y MongoDB compatible. Dependencia exacta de servidor; pnpm install raíz. Versión elegida: 9.12.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list mongoose --depth 0`. Resultado efectivo: 9.12.0; importación correcta. Conexión Atlas e índices únicos comprobados con MongoDB 8.0.37.

### express-session — 1.19.0

1. **Qué es:** Middleware de sesiones del servidor.
2. **Uso en GPB:** Usa cookie con identificador revocable en lugar de guardar identidad en React.
3. **Getting Started:** [express-session](https://expressjs.com/en/resources/middleware/session/).
4. **Requisitos y versión:** Express y secreto privado de 32 caracteres mínimo. Dependencia exacta del servidor; pnpm install raíz. Versión elegida: 1.19.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list express-session --depth 0`. Resultado efectivo: 1.19.0; regeneración, cookie, expiración y revocación HTTP comprobadas con MemoryStore de prueba.

### connect-mongo — 6.0.0

1. **Qué es:** Almacén persistente de sesiones MongoDB.
2. **Uso en GPB:** Conserva sesiones al reiniciar API y evita depender de memoria en Render.
3. **Getting Started:** [connect-mongo](https://github.com/jdesboeufs/connect-mongo#readme).
4. **Requisitos y versión:** Node >=20.8, express-session ^1.17.1 y driver mongodb >=5. Comparte cliente Mongoose; instalado desde manifiesto servidor. Versión elegida: 6.0.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server why mongodb`. Resultado efectivo: Driver único 7.8.0 compatible con ambos paquetes. Persistencia real Atlas comprobada con reinicio de API; prueba separada de las fixtures de memoria.

### Argon2 — 0.45.2

1. **Qué es:** Implementación nativa de hash de contraseñas.
2. **Uso en GPB:** Almacena hash Argon2id, nunca contraseñas en texto.
3. **Getting Started:** [Argon2](https://github.com/ranisalt/node-argon2#readme).
4. **Requisitos y versión:** Node >=16.17 y binario compatible. Dependencia servidor; allowBuilds autoriza sólo argon2; pnpm install raíz. Versión elegida: 0.45.2.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list argon2 --depth 0`. Resultado efectivo: 0.45.2; binario arm64 instalado, hash y verificación reales correctos.

### Zod — 4.6.7

1. **Qué es:** Validación declarativa de entradas JavaScript.
2. **Uso en GPB:** Rechaza cuerpos inválidos y configuración incompleta.
3. **Getting Started:** [Zod](https://zod.dev/).
4. **Requisitos y versión:** JavaScript ES Modules. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 4.6.7.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list zod --depth 0`. Resultado efectivo: 4.6.7; entradas inválidas rechazadas en pruebas.

### Helmet — 8.3.0

1. **Qué es:** Middleware de encabezados de seguridad.
2. **Uso en GPB:** Configura respuestas de la API.
3. **Getting Started:** [Helmet](https://helmetjs.github.io/).
4. **Requisitos y versión:** Express configurado. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 8.3.0.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list helmet --depth 0`. Resultado efectivo: 8.3.0; cargado en todas las pruebas HTTP.

### express-rate-limit — 8.7.4

1. **Qué es:** Límite de solicitudes por IP.
2. **Uso en GPB:** Limita registro y acceso a 20 intentos por 15 minutos en una instancia.
3. **Getting Started:** [express-rate-limit](https://express-rate-limit.mintlify.app/quickstart/installation).
4. **Requisitos y versión:** Express. Dependencia exacta servidor; pnpm install raíz. Versión elegida: 8.7.4.
5. **Instalación/configuración:** `pnpm install --frozen-lockfile` desde raíz, con los manifiestos y lock de esta guía; configuración específica indicada en el apartado correspondiente.
6. **Comprobación:** `pnpm --filter @gpb/server list express-rate-limit --depth 0`. Resultado efectivo: 8.7.4; respuesta 429 comprobada. Contador local por proceso; antes de escalar instancias se requerirá almacenamiento compartido.

### MongoDB Atlas — MongoDB 8.0.37

1. **Qué es:** Servicio de base de datos MongoDB.
2. **Uso en GPB:** Guarda usuarios y sesiones sin servidor local del estudiante.
3. **Getting Started:** [MongoDB Atlas](https://www.mongodb.com/docs/atlas/getting-started/).
4. **Requisitos y versión:** Cuenta propia, clúster Free, usuario de base de datos e IP permitida. Connect → Drivers → Node.js; URI privada en server/.env. No requiere instalar una CLI. Versión real del clúster comprobada: MongoDB 8.0.37.
5. **Instalación/configuración:** prepara clúster, usuario e IP como indica el apartado 4 y configura server/.env local. No requiere una instalación local de MongoDB ni comando de versión de Atlas.
6. **Comprobación:** `pnpm --filter @gpb/server check:atlas`. Resultado efectivo: conexión y comprobaciones correctas, código 0. El comando de proyecto verifica conexión, índices, hash, persistencia tras reiniciar API y revocación; crea y elimina colecciones temporales gpb_probe_*.

### Playwright — 1.65.0

1. **Qué es:** Automatización de navegador y Electron.
2. **Uso en GPB:** Comprueba flujos reales y reapertura con perfiles temporales.
3. **Getting Started:** [Playwright](https://playwright.dev/docs/intro).
4. **Requisitos y versión:** macOS arm64 con Chrome o Chromium y Electron. Desde raíz: pnpm add -Dw @playwright/test@1.65.0 electron@45.3.1; pnpm exec playwright install chromium. Versión elegida: 1.65.0.
5. **Instalación/configuración:** paquete exacto en el manifiesto raíz y `pnpm install --frozen-lockfile`; después `pnpm exec playwright install chromium`. La configuración y los tests están en el apartado 7.
6. **Comprobación:** `pnpm exec playwright --version`. Resultado efectivo: 1.65.0 fijado; prueba web aprobada con Chrome instalado 144.0.7559.134. Chromium 158.0.8127.18 descargado; flujo Chromium también comprobado con dos pruebas de transporte aprobadas.

### Electron — 45.3.1

1. **Qué es:** Contenedor de escritorio basado en Chromium y Node.
2. **Uso en GPB:** Prueba mínima de transporte persistente, preparatoria para la etapa 6.
3. **Getting Started:** [Electron](https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app).
4. **Requisitos y versión:** Node >=22.12 para instalación. Dependencia de desarrollo raíz; pnpm exec install-electron descarga el binario explícitamente en esta versión. Versión elegida: 45.3.1.
5. **Instalación/configuración:** paquete exacto en el manifiesto raíz y `pnpm install --frozen-lockfile`; después `pnpm exec install-electron` para descargar el ejecutable del entorno.
6. **Comprobación:** `pnpm exec electron --version`. Resultado efectivo: Paquete y binario 45.3.1 comprobados con --version. Transporte mínimo con reinicio y revocación comprobados; no equivale a un paquete distribuible.

### Git y las fuentes complementarias

Git conserva el historial del código y permite consultar la entrega usada en un video. En GPB se utiliza un repositorio en la raíz para cliente, API, documentación y preparativos de escritorio. Su [documentación oficial de inicio](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) explica instalación por plataforma. No se instaló ni cambió Git durante esta entrega; se utilizó el ya disponible para `git init`, revisión y commit. La versión de Git no se fijó como dependencia del runtime: compruébala en tu terminal con `git --version` antes de usarlo. En la reproducción se utilizó Git 2.41.0. El resultado de control de esta entrega es el commit indicado al principio de la guía, no un despliegue.

- [Vite+ — creación de proyectos](https://viteplus.dev/guide/create): generadores y opciones. La guía utiliza los archivos explícitos conservados para no depender de futuras variaciones de plantilla.
- [pnpm — configuración del workspace](https://pnpm.io/settings): configuración por proyecto y autorización de builds en pnpm 12.
- [Node — ejecutor de pruebas](https://nodejs.org/api/test.html): base de las comprobaciones HTTP.
- [Electron — sesiones](https://www.electronjs.org/docs/latest/api/session): almacén persistente de cookies. La administración del contrato de cookie en el proceso principal es una adaptación de GPB.
- [Render — redirecciones y rewrites](https://render.com/docs/redirects-rewrites): referencia para la futura topología bajo el origen web; se validará en la entrega de publicación.

### Estado de las comprobaciones al redactar

| Evidencia | Resultado del código de referencia |
|---|---|
| Instalación congelada | Correcta; dependencias exactas y componente nativo Argon2 comprobados |
| Revisión de cliente | Sin errores ni advertencias |
| Compilación | Correcta, 205 módulos |
| API con reloj/store de prueba | 6 pruebas aprobadas |
| Transporte Chromium/Electron | 2 pruebas aprobadas |
| Atlas real | MongoDB 8.0.37, conexión, índices, hash, persistencia y revocación correctos |
| React + API real + Atlas | Flujo completo correcto, incluidos reinicios y limpieza |
| Reproducción de este documento | **Completada desde la preparación; seis pruebas API, dos de transporte y verificadores Atlas aprobados** |
| Despliegue real y paquete macOS | No realizados; corresponden a guías 5 y 6 |

Esta versión reúne la implementación comprobada y la reproducción de las instrucciones. Se conservaron separados los resultados locales, Atlas y el transporte mínimo de Electron. La publicación requiere las indicaciones del docente; el despliegue real y el paquete se comprobarán en las guías correspondientes.
