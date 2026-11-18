---
title: GPB — Gunpla Personal Builds | Guía 2 - Gestión de la colección
date: 2026-11-12
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, nodeJS, mongodb, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

# GPB — Guía 2: gestión de la colección

En la guía 1 dejamos una cuenta con sesión protegida. Ahora cada usuario tendrá una colección privada: podrá agregar un Gunpla, consultar su detalle, editarlo y eliminarlo. Grados y escalas provendrán de MongoDB, no de listas escritas en React.

## Recorrido de la guía

1. Preparar una versión independiente sin sobrescribir la guía 1.
2. Modelar la colección y cargar los catálogos.
3. Proteger las operaciones de la API.
4. Construir tarjetas, detalle y formulario compartido.
5. Comprobar el aislamiento, la persistencia y el recorrido web.
6. Conservar la entrega y preparar la guía 3.

**Convención:** después de la preparación, todos los comandos parten de la raíz de `guia-02`, donde están `package.json` y `pnpm-workspace.yaml`, salvo indicación expresa. Los bloques bajo rutas de archivo son contenido para el editor, no comandos de terminal. Reemplaza los archivos completos: así evitas conservar imports o rutas de la versión anterior por accidente.

Material complementario: [código completo]({{ '/assets/downloads/gpb/guia-02/etapas/02/codigo-etapa-2.zip' | relative_url }}), [registro técnico]({{ '/assets/downloads/gpb/guia-02/etapas/02/REGISTRO.md' | relative_url }}), [fuentes]({{ '/assets/downloads/gpb/guia-02/etapas/02/FUENTES.md' | relative_url }}), [traspaso]({{ '/assets/downloads/gpb/guia-02/etapas/02/TRASPASO-CHATGPT.md' | relative_url }}) e [informe de reproducción]({{ '/assets/downloads/gpb/guia-02/etapas/02/VERIFICACION.md' | relative_url }}).

## 1. Objetivos y punto de partida

Necesitas la guía 1 terminada, conocimientos de JavaScript, hooks de React y HTTP, y tu propia cuenta de Atlas. La base conservada es `gpb-dev/guia-01`, commit `91c189e`. El código de aplicación de esta entrega se conserva en `gpb-dev/guia-02`.

Al finalizar tendrás modelos Gunpla, Grade y Scale; catálogos compartidos; CRUD privado por usuario; validación del servidor; tarjetas con portada de reemplazo; detalle básico y un único formulario de creación/edición. La colección se muestra en páginas de 12 registros, ordenadas por creación descendente. No añadiremos aún fotografías, galería, etiquetas o video (guía 3), ni dashboard, búsqueda o filtros (guía 4).

No instalaremos paquetes nuevos. Conserva Node 26.13.1, pnpm 12.18.0 y el lock anterior: React 19.3.1, Vite+ 1.6.0, Tailwind 4.3.5, Router 8.5.1, Express 5.3.0, Mongoose 9.12.0 y Zod 4.6.7. Las fichas de instalación inicial están en la guía 1; al final se incluyen los enlaces oficiales y comprobaciones de las herramientas que utilizaremos aquí.

### 1.1. Crear la versión independiente

Detén los servidores de guía 1 antes de iniciar los de guía 2; ambas usan 3000 y 5173. No sobrescribas una carpeta `guia-02` existente. Si organizas tus ejercicios con otro nombre, adapta únicamente la ruta del contenedor.

**Carpeta: `gpb-dev`, que contiene `guia-01`.**

{% raw %}
```sh
mkdir guia-02
rsync -a --exclude=node_modules --exclude=dist --exclude='.env' --exclude='.env.*' --exclude=test-results --exclude=playwright-report --exclude='*.log' guia-01/client guia-01/server guia-01/electron guia-01/tests guia-02/
cp guia-01/package.json guia-01/pnpm-lock.yaml guia-01/pnpm-workspace.yaml guia-01/playwright.config.js guia-01/.gitignore guia-01/.node-version guia-02/
cp guia-01/server/.env.example guia-02/server/.env.example
cd guia-02
node --version
pnpm --version
uname -m
pnpm install --frozen-lockfile
pnpm list -r --depth 0
pnpm --filter @gpb/client exec vp --version
```
{% endraw %}

Resultados de referencia: Node v26.13.1, pnpm 12.18.0, arm64 y Vite+ 1.6.0. Se instalaron 303 paquetes desde caché, sin cambiar versiones. No copies `node_modules`, compilaciones, evidencias ni credenciales; cada versión mantiene sus propias dependencias.

### 1.2. Configuración privada propia

**Carpeta: raíz de `guia-02`.**

{% raw %}
```sh
cp server/.env.example server/.env
chmod 600 server/.env
node --input-type=module -e 'import { appendFileSync } from "node:fs"; import { randomBytes } from "node:crypto"; appendFileSync("server/.env", String.fromCharCode(10) + "SESSION_SECRET=" + randomBytes(48).toString("hex") + String.fromCharCode(10));'
```
{% endraw %}

En el editor, completa `MONGODB_URI` con tu conexión privada de Atlas y una base de datos propia; conserva `NODE_ENV=development`, `PORT=3000` y `WEB_ORIGIN=http://localhost:5173`. El comando agrega un secreto independiente sin imprimirlo. La última asignación de SESSION_SECRET prevalece sobre la línea vacía del ejemplo. Verifica que `.env` quede ignorado: `git check-ignore server/.env` cuando tu carpeta esté dentro de un repositorio. No compartas este archivo.

## 2. Modelos y catálogos

Separaremos las opciones de referencia de los registros personales. Un Gunpla guarda ObjectId para grado y escala; la API transforma esas referencias en objetos con `id` y `name` para mostrarlos. Los nombres de campos internos siguen el código JavaScript; las etiquetas de la interfaz están en español.

![Modelos de la colección]({{ '/assets/images/gpb/guia-02/gpb-datos-guia-2.png' | relative_url }})

[Explorar el modelo interactivo]({{ '/assets/diagrams/gpb/guia-02/gpb-datos-guia-2.html?theme=dark' | relative_url }}) · [Versión SVG]({{ '/assets/images/gpb/guia-02/gpb-datos-guia-2.svg' | relative_url }})

Las líneas son referencias de MongoDB, no restricciones de claves foráneas SQL. La existencia de las opciones se comprueba en la API. `owner` es obligatorio e inmutable; lo asigna el servidor. `createdAt` y `updatedAt` se generan mediante timestamps.

### `server/src/catalogs.js`

Cada catálogo tiene nombre único y orden explícito. `seedCatalogs` usa upsert por nombre: una segunda ejecución conserva los ids y actualiza el orden sin duplicar las opciones. No elimina opciones adicionales que alguien hubiera cargado externamente. Los desplegables son independientes, incluso para Sin Grado y Sin Escala.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/src/catalogs.js -->
{% raw %}
```js
import mongoose from 'mongoose';

export const GRADE_NAMES = ['Entry Grade (EG)', 'High Grade (HG)', 'Real Grade (RG)', 'Master Grade (MG)', 'Perfect Grade (PG)', 'Super Deformed (SD)', 'Full Mechanics (FM)', 'Reborn-One Hundred (RE/100)', 'Master Grade Extreme (MGEX)', 'Master Grade Super Deformed (MGSD)', 'Mega Size', 'Sin Grado'];
export const SCALE_NAMES = ['1/144', '1/100', '1/60', '1/48', 'Sin Escala'];
const catalogSchema = () => new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  order: { type: Number, required: true },
}, { versionKey: false });
export const Grade = mongoose.model('Grade', catalogSchema());
export const Scale = mongoose.model('Scale', catalogSchema());
export async function seedCatalogs() {
  await Promise.all([Grade.init(), Scale.init()]);
  for (const [Model, names] of [[Grade, GRADE_NAMES], [Scale, SCALE_NAMES]]) {
    await Model.bulkWrite(names.map((name, order) => ({ updateOne: {
      filter: { name }, update: { $set: { order }, $setOnInsert: { name } }, upsert: true,
    } })));
  }
}
const option = (doc) => ({ id: String(doc._id), name: doc.name });
export const catalogs = {
  async list() {
    const [grades, scales] = await Promise.all([
      Grade.find().sort({ order: 1, _id: 1 }).lean(),
      Scale.find().sort({ order: 1, _id: 1 }).lean(),
    ]);
    return { grades: grades.map(option), scales: scales.map(option) };
  },
  async valid(grade, scale) {
    const found = await Promise.all([Grade.exists({ _id: grade }), Scale.exists({ _id: scale })]);
    return found.every(Boolean);
  },
};
```
{% endraw %}

### `server/src/gunpla.js`

El índice comienza por owner y sigue el orden de las tarjetas. Tanto el listado como el conteo filtran por propietario. Detalle, edición y eliminación usan `_id` y `owner` en una misma consulta: conocer un id ajeno no concede acceso. `populate` obtiene los nombres de los catálogos. La respuesta pública excluye owner y __v.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/src/gunpla.js -->
{% raw %}
```js
import mongoose from 'mongoose';

export const STATES = ['Sin armar', 'En progreso', 'Armado'];
const schema = new mongoose.Schema({
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, immutable: true },
  name: { type: String, required: true, trim: true, maxlength: 120 },
  grade: { type: mongoose.Schema.Types.ObjectId, ref: 'Grade', required: true },
  scale: { type: mongoose.Schema.Types.ObjectId, ref: 'Scale', required: true },
  description: { type: String, trim: true, maxlength: 1000, default: '' },
  notes: { type: String, trim: true, maxlength: 1000, default: '' },
  state: { type: String, enum: STATES, required: true, default: 'Sin armar' },
}, { timestamps: true });
schema.index({ owner: 1, createdAt: -1, _id: -1 });
export const Gunpla = mongoose.model('Gunpla', schema);
const populate = (query) => query.populate('grade', 'name').populate('scale', 'name').lean();
export function publicGunpla(doc) {
  const option = (value) => value ? { id: String(value._id), name: value.name } : null;
  return { id: String(doc._id), name: doc.name, grade: option(doc.grade), scale: option(doc.scale),
    description: doc.description, notes: doc.notes, state: doc.state, createdAt: doc.createdAt, updatedAt: doc.updatedAt };
}
export const gunpla = {
  async list(owner, page) {
    const filter = { owner };
    const [docs, total] = await Promise.all([
      populate(Gunpla.find(filter).sort({ createdAt: -1, _id: -1 }).skip((page - 1) * 12).limit(12)),
      Gunpla.countDocuments(filter),
    ]);
    return { items: docs.map(publicGunpla), total, page, pageSize: 12, pages: Math.max(1, Math.ceil(total / 12)) };
  },
  async get(owner, id) {
    const doc = await populate(Gunpla.findOne({ _id: id, owner }));
    return doc ? publicGunpla(doc) : null;
  },
  async create(owner, input) {
    const doc = await Gunpla.create({ ...input, owner });
    return this.get(owner, doc._id);
  },
  async update(owner, id, input) {
    const doc = await populate(Gunpla.findOneAndUpdate({ _id: id, owner }, { $set: input }, { new: true, runValidators: true }));
    return doc ? publicGunpla(doc) : null;
  },
  async remove(owner, id) { return Boolean(await Gunpla.findOneAndDelete({ _id: id, owner })); },
};
```
{% endraw %}

### `server/scripts/seed-catalogs.js`

Este comando conecta con Atlas, carga los catálogos y cierra la conexión incluso si falla. No se ejecuta en cada petición ni depende de React.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/scripts/seed-catalogs.js -->
{% raw %}
```js
import mongoose from 'mongoose';
import { readConfig } from '../src/config.js';
import { seedCatalogs } from '../src/catalogs.js';
try {
  await mongoose.connect(readConfig().MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  await seedCatalogs();
  console.log('Catálogos cargados: 12 grados y 5 escalas; repetir no duplica las opciones iniciales.');
} catch {
  console.error('No se pudieron cargar los catálogos. Revisa la configuración y el acceso a Atlas.');
  process.exitCode = 1;
} finally { await mongoose.disconnect(); }
```
{% endraw %}

### `server/package.json`

Conservamos todas las versiones y agregamos los comandos seed:catalogs y check:collection:atlas. El segundo archivo se incorporará en la sección de comprobaciones; no lo ejecutes antes de crearlo.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/package.json -->
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
    "check:web:atlas": "node --env-file=.env scripts/check-web-atlas.js",
    "seed:catalogs": "node --env-file=.env scripts/seed-catalogs.js",
    "check:collection:atlas": "node --env-file=.env scripts/check-collection-atlas.js"
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

## 3. API protegida de colección

| Método y ruta | Propósito | Resultado correcto |
|---|---|---|
| GET `/api/catalogs` | Opciones compartidas ordenadas | 200, grades y scales |
| GET `/api/gunpla?page=1` | Colección del usuario, 12 por página | 200, items y metadatos |
| GET `/api/gunpla/:id` | Detalle propio | 200, gunpla |
| POST `/api/gunpla` | Crear con propietario de la sesión | 201, gunpla |
| PUT `/api/gunpla/:id` | Reemplazar campos editables de un registro propio | 200, gunpla |
| DELETE `/api/gunpla/:id` | Eliminar un registro propio | 204 |

Todas requieren sesión. Las escrituras conservan comprobación de Origin y X-CSRF-Token. Un registro ajeno y uno inexistente producen el mismo 404. Un id malformado, un estado desconocido, una opción inexistente o un campo adicional producen 400. No se admite enviar owner, fechas ni operadores MongoDB.

Nombre: 1–120 caracteres tras recortar espacios. Descripción y notas: opcionales, hasta 1000 cada una. Estado: Sin armar, En progreso o Armado; el servidor aplica Sin armar cuando no se envía. PUT recibe todos los campos editables; los opcionales omitidos se vacían y estado omitido vuelve al valor inicial. La interfaz siempre envía el formulario completo. Se mantiene el límite total de 8 KB por solicitud; un cuerpo mayor devuelve 413 incluso si cada campo cumple su límite individual.

![Creación y propiedad de un Gunpla]({{ '/assets/images/gpb/guia-02/gpb-coleccion-guia-2.png' | relative_url }})

[Explorar la secuencia interactiva]({{ '/assets/diagrams/gpb/guia-02/gpb-coleccion-guia-2.html?theme=dark' | relative_url }}) · [Versión SVG]({{ '/assets/images/gpb/guia-02/gpb-coleccion-guia-2.svg' | relative_url }})

### `server/src/collection-routes.js`

El router valida la forma de los datos con Zod y después verifica la existencia del grado y la escala. Los errores de colección tienen su propio mensaje, antes del manejador general de autenticación. La página es un entero positivo; se rechazan parámetros adicionales, incluida cualquier propuesta de owner del cliente.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/src/collection-routes.js -->
{% raw %}
```js
import { Router } from 'express';
import { z, ZodError } from 'zod';
import { STATES } from './gunpla.js';

const id = z.string().regex(/^[a-fA-F0-9]{24}$/, 'Identificador inválido.');
const input = z.strictObject({
  name: z.string().trim().min(1).max(120), grade: id, scale: id,
  description: z.string().trim().max(1000).default(''),
  notes: z.string().trim().max(1000).default(''),
  state: z.enum(STATES).default('Sin armar'),
});
const pageQuery = z.strictObject({ page: z.string().regex(/^[1-9]\d{0,5}$/).transform(Number).optional().default(1) });
const missing = (res) => res.status(404).json({ message: 'Gunpla no encontrado.' });
export function collectionRoutes({ catalogs, gunpla }) {
  const router = Router();
  router.get('/catalogs', async (_req, res) => res.json(await catalogs.list()));
  router.get('/gunpla', async (req, res) => {
    const { page } = pageQuery.parse(req.query);
    res.json(await gunpla.list(String(req.user._id), page));
  });
  router.get('/gunpla/:id', async (req, res) => {
    const record = await gunpla.get(String(req.user._id), id.parse(req.params.id));
    return record ? res.json({ gunpla: record }) : missing(res);
  });
  async function readInput(body) {
    const data = input.parse(body);
    if (!await catalogs.valid(data.grade, data.scale)) throw new ZodError([{ code: 'custom', path: ['grade'], message: 'Selecciona un grado y una escala existentes.' }]);
    return data;
  }
  router.post('/gunpla', async (req, res) => {
    const record = await gunpla.create(String(req.user._id), await readInput(req.body));
    res.status(201).json({ gunpla: record });
  });
  router.put('/gunpla/:id', async (req, res) => {
    const recordId = id.parse(req.params.id);
    const owner = String(req.user._id);
    if (!await gunpla.get(owner, recordId)) return missing(res);
    const record = await gunpla.update(owner, recordId, await readInput(req.body));
    return record ? res.json({ gunpla: record }) : missing(res);
  });
  router.delete('/gunpla/:id', async (req, res) => {
    const removed = await gunpla.remove(String(req.user._id), id.parse(req.params.id));
    return removed ? res.sendStatus(204) : missing(res);
  });
  router.use((error, _req, res, next) => {
    if (error instanceof ZodError) return res.status(400).json({ message: 'Revisa los datos: nombre de 1 a 120 caracteres, grado y escala válidos, estado permitido y textos de hasta 1000 caracteres. No se admiten campos adicionales ni una página inválida.' });
    next(error);
  });
  return router;
}
```
{% endraw %}

### `server/src/app.js`

La autenticación permanece como en guía 1. Agregamos la dependencia de catálogos y colección y montamos el router después de protectedRoute y de CSRF. La inyección permite probar la API sin credenciales; en producción se proporcionan los modelos reales.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/src/app.js -->
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
import { collectionRoutes } from './collection-routes.js';

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
export function createApp({ config, store, users, catalogs, gunpla, now = Date.now, idleMs = IDLE_MS, absoluteMs = ABSOLUTE_MS, authLimit = 20 }) {
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
  if (catalogs && gunpla) app.use('/api', protectedRoute, collectionRoutes({ catalogs, gunpla }));
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

### `server/src/index.js`

El arranque real proporciona los adaptadores de MongoDB y espera los índices antes de escuchar. MongoDB sigue almacenando tanto datos como sesiones, sin incluir esas credenciales en React o Electron.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/src/index.js -->
{% raw %}
```js
import mongoose from 'mongoose';
import MongoStore from 'connect-mongo';
import { readConfig } from './config.js';
import { users, User } from './users.js';
import { catalogs, Grade, Scale } from './catalogs.js';
import { gunpla, Gunpla } from './gunpla.js';
import { createApp } from './app.js';

try {
  const config = readConfig();
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  await Promise.all([User.init(), Grade.init(), Scale.init(), Gunpla.init()]); // Esperar los índices únicos antes de aceptar registros.
  const store = MongoStore.create({ client: mongoose.connection.getClient(), collectionName: 'sessions', ttl: 7 * 24 * 60 * 60, touchAfter: 0 });
  store.on('error', () => console.error('No se pudo acceder al almacén de sesiones.'));
  const server = createApp({ config, store, users, catalogs, gunpla }).listen(config.PORT, config.NODE_ENV === 'production' ? '0.0.0.0' : '127.0.0.1', () => console.log(`API GPB disponible en el puerto ${config.PORT}`));
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => {
    server.close(async () => { await mongoose.disconnect(); process.exit(0); });
  });
} catch {
  console.error('No se pudo iniciar GPB. Revisa las variables locales y la conexión con Atlas.');
  process.exitCode = 1;
}
```
{% endraw %}

### 3.1. Cargar y comprobar los catálogos

**Carpeta: raíz de `guia-02`, con `server/.env` privado configurado.**

{% raw %}
```sh
pnpm --filter @gpb/server seed:catalogs
pnpm --filter @gpb/server seed:catalogs
```
{% endraw %}

Ambas ejecuciones deben indicar 12 grados y 5 escalas sin duplicar las opciones iniciales. La comprobación automática con Atlas verificará después tanto el conteo como la estabilidad de ids. En Atlas puedes consultar las colecciones grades y scales y su campo order; no cambies manualmente sus documentos durante el ejercicio.

## 4. Interfaz: colección, detalle y formulario

Reutilizamos Button, Input, Label y Card de la guía 1. Para selecciones y textos largos usamos controles HTML accesibles con etiquetas asociadas; no necesitamos instalar otros componentes. `Cover` es un reemplazo visual en CSS, sin carga de archivos ni solicitudes a Cloudinary.

El formulario consulta `/api/catalogs`; las opciones no están duplicadas en React. Los tres estados son parte del dominio y se muestran en español. Un mismo componente recibe datos iniciales al editar y decide entre POST y PUT. Las respuestas de carga se descartan al abandonar la ruta para evitar que una petición anterior sustituya la pantalla actual. Ante un error de consulta se ofrece Reintentar; si faltan catálogos, se desactiva el formulario y se explica cómo cargarlos.

### `client/src/collection/Collection.jsx`

Este módulo reúne las pantallas de la entrega. El listado conserva la página en la URL, cada tarjeta abre el detalle y la eliminación requiere una confirmación explícita con opción de cancelar. Crear o actualizar abre el detalle con un mensaje de éxito; eliminar vuelve a la colección. Los errores de escritura conservan los valores del formulario.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: client/src/collection/Collection.jsx -->
{% raw %}
```jsx
import { useEffect, useState } from "react";
import { Link, useLocation, useNavigate, useParams, useSearchParams } from "react-router";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

function useResource(path) {
  const [result, setResult] = useState({ path, loading: true });
  const [attempt, setAttempt] = useState(0);
  useEffect(() => {
    let active = true;
    if (!path)
      return () => {
        active = false;
      };
    api(path).then(
      (data) => {
        if (active) setResult({ path, data });
      },
      (error) => {
        if (active) setResult({ path, error: error.message });
      },
    );
    return () => {
      active = false;
    };
  }, [path, attempt]);
  return {
    ...(result.path === path ? result : { loading: true }),
    retry: () => {
      setResult({ path, loading: true });
      setAttempt((value) => value + 1);
    },
  };
}
function ResourceState({ resource }) {
  if (resource.loading) return <p role="status">Cargando…</p>;
  return (
    <div>
      <p role="alert" className="error">
        {resource.error}
      </p>
      <Button onClick={resource.retry}>Reintentar</Button>
    </div>
  );
}
export function Cover() {
  return (
    <div className="gunpla-cover" role="img" aria-label="Portada de reemplazo">
      <span aria-hidden="true">◇</span>
      <small>GPB / SIN PORTADA</small>
    </div>
  );
}
export function Collection() {
  const [params, setParams] = useSearchParams();
  const page = params.get("page") || "1";
  const resource = useResource(`/gunpla?page=${encodeURIComponent(page)}`);
  const location = useLocation();
  return (
    <>
      <p className="eyebrow">TUS MODELOS / TU PROCESO</p>
      <div className="page-heading">
        <h1>Mi colección</h1>
        <Button asChild>
          <Link to="/coleccion/nuevo">Agregar Gunpla</Link>
        </Button>
      </div>
      {location.state?.message && (
        <p role="status" className="success">
          {location.state.message}
        </p>
      )}
      {!resource.data ? (
        <ResourceState resource={resource} />
      ) : (
        <>
          <p className="muted">
            {resource.data.total} {resource.data.total === 1 ? "modelo" : "modelos"} en tu colección
          </p>
          {resource.data.items.length === 0 ? (
            <Card className="empty-card">
              <CardContent>
                <h2>
                  {resource.data.total
                    ? "No hay registros en esta página"
                    : "El primer build está por llegar"}
                </h2>
                <p className="muted">
                  {resource.data.total
                    ? "Vuelve a la primera página para consultar tu colección."
                    : "Agrega tu primer Gunpla y acompaña su construcción."}
                </p>
                <Button asChild>
                  <Link to={resource.data.total ? "/coleccion" : "/coleccion/nuevo"}>
                    {resource.data.total ? "Primera página" : "Agregar mi primer Gunpla"}
                  </Link>
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="collection-grid">
              {resource.data.items.map((item) => (
                <Link className="gunpla-card" to={`/coleccion/${item.id}`} key={item.id}>
                  <Cover />
                  <div className="gunpla-card-body">
                    <span className="state-badge">{item.state}</span>
                    <h2>{item.name}</h2>
                    <p className="muted">
                      {item.grade?.name} · {item.scale?.name}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          )}
          {resource.data.pages > 1 && (
            <div className="pagination" aria-label="Páginas de la colección">
              <Button
                variant="outline"
                disabled={resource.data.page <= 1}
                onClick={() => setParams({ page: String(resource.data.page - 1) })}
              >
                Anterior
              </Button>
              <span>
                Página {resource.data.page} de {resource.data.pages}
              </span>
              <Button
                variant="outline"
                disabled={resource.data.page >= resource.data.pages}
                onClick={() => setParams({ page: String(resource.data.page + 1) })}
              >
                Siguiente
              </Button>
            </div>
          )}
        </>
      )}
    </>
  );
}
export function GunplaDetail() {
  const location = useLocation();
  const { id } = useParams();
  const resource = useResource(`/gunpla/${id}`);
  const [confirming, setConfirming] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  async function remove() {
    setBusy(true);
    setError("");
    try {
      await api(`/gunpla/${id}`, { method: "DELETE" });
      navigate("/coleccion", { replace: true, state: { message: "Gunpla eliminado." } });
    } catch (failure) {
      setError(failure.message);
      setBusy(false);
    }
  }
  if (!resource.data) return <ResourceState resource={resource} />;
  const item = resource.data.gunpla;
  return (
    <>
      <Link className="text-link" to="/coleccion">
        Volver a mi colección
      </Link>
      {location.state?.message && (
        <p role="status" className="success">
          {location.state.message}
        </p>
      )}
      <div className="detail-grid">
        <Cover />
        <section>
          <p className="eyebrow">DETALLE DEL GUNPLA</p>
          <h1>{item.name}</h1>
          <span className="state-badge">{item.state}</span>
          <dl>
            <dt>Grado</dt>
            <dd>{item.grade?.name}</dd>
            <dt>Escala</dt>
            <dd>{item.scale?.name}</dd>
            <dt>Descripción</dt>
            <dd>{item.description || "Sin descripción."}</dd>
            <dt>Notas</dt>
            <dd>{item.notes || "Sin notas."}</dd>
          </dl>
          <div className="actions">
            <Button asChild>
              <Link to={`/coleccion/${id}/editar`}>Editar Gunpla</Link>
            </Button>
            <Button variant="outline" onClick={() => setConfirming(true)}>
              Eliminar Gunpla
            </Button>
          </div>
          {confirming && (
            <section className="delete-confirmation" aria-label="Confirmar eliminación">
              <h2>¿Eliminar este Gunpla?</h2>
              <p>Se eliminará «{item.name}». Esta acción no se puede deshacer.</p>
              <div className="actions">
                <Button variant="destructive" disabled={busy} onClick={remove}>
                  {busy ? "Eliminando…" : "Confirmar eliminación"}
                </Button>
                <Button
                  variant="outline"
                  disabled={busy}
                  onClick={() => {
                    setConfirming(false);
                    setError("");
                  }}
                >
                  Cancelar
                </Button>
              </div>
            </section>
          )}
          {error && (
            <p className="error" role="alert">
              {error}
            </p>
          )}
        </section>
      </div>
    </>
  );
}
export function GunplaFormPage() {
  const { id } = useParams();
  const options = useResource("/catalogs");
  const record = useResource(id ? `/gunpla/${id}` : null);
  if (!options.data) return <ResourceState resource={options} />;
  if (id && !record.data) return <ResourceState resource={record} />;
  return (
    <GunplaForm
      key={id || "new"}
      id={id}
      catalogs={options.data}
      initial={id ? record.data.gunpla : null}
    />
  );
}
function GunplaForm({ id, catalogs, initial }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const unavailable = !catalogs.grades.length || !catalogs.scales.length;
  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    const body = Object.fromEntries(new FormData(event.currentTarget));
    try {
      const result = await api(id ? `/gunpla/${id}` : "/gunpla", {
        method: id ? "PUT" : "POST",
        body,
      });
      navigate(`/coleccion/${result.gunpla.id}`, {
        replace: true,
        state: { message: id ? "Gunpla actualizado." : "Gunpla creado." },
      });
    } catch (failure) {
      setError(failure.message);
      setBusy(false);
    }
  }
  return (
    <>
      <p className="eyebrow">TU SIGUIENTE BUILD</p>
      <h1>{id ? "Editar Gunpla" : "Agregar Gunpla"}</h1>
      <p className="muted">Nombre, grado, escala y estado son obligatorios.</p>
      {unavailable && (
        <p role="alert" className="error">
          Los catálogos todavía no están disponibles. Ejecuta la carga inicial del servidor y
          recarga esta página.
        </p>
      )}
      <form className="gunpla-form" onSubmit={submit}>
        <fieldset disabled={busy || unavailable}>
          <div className="field">
            <Label htmlFor="name">Nombre</Label>
            <Input
              id="name"
              name="name"
              required
              maxLength={120}
              defaultValue={initial?.name || ""}
            />
          </div>
          <div className="form-row">
            {[
              ["grade", "Grado", catalogs.grades],
              ["scale", "Escala", catalogs.scales],
            ].map(([name, label, items]) => (
              <div className="field" key={name}>
                <Label htmlFor={name}>{label}</Label>
                <select id={name} name={name} required defaultValue={initial?.[name]?.id || ""}>
                  <option value="" disabled>
                    Selecciona una opción
                  </option>
                  {items.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.name}
                    </option>
                  ))}
                </select>
              </div>
            ))}
          </div>
          <div className="field">
            <Label htmlFor="state">Estado</Label>
            <select id="state" name="state" defaultValue={initial?.state || "Sin armar"} required>
              {["Sin armar", "En progreso", "Armado"].map((state) => (
                <option key={state}>{state}</option>
              ))}
            </select>
          </div>
          {[
            ["description", "Descripción"],
            ["notes", "Notas"],
          ].map(([name, label]) => (
            <div className="field" key={name}>
              <Label htmlFor={name}>{label} (opcional)</Label>
              <textarea
                id={name}
                name={name}
                maxLength={1000}
                rows={4}
                defaultValue={initial?.[name] || ""}
              />
              <small className="muted">Hasta 1000 caracteres.</small>
            </div>
          ))}
        </fieldset>
        {error && (
          <p role="alert" className="error">
            {error}
          </p>
        )}
        <div className="actions">
          <Button type="submit" disabled={busy || unavailable}>
            {busy ? "Guardando…" : "Guardar Gunpla"}
          </Button>
          <Button variant="outline" asChild>
            <Link to={id ? `/coleccion/${id}` : "/coleccion"}>Cancelar</Link>
          </Button>
        </div>
      </form>
    </>
  );
}
```
{% endraw %}

### `client/src/App.jsx`

Registramos las rutas /coleccion, /coleccion/nuevo, /coleccion/:id y /coleccion/:id/editar dentro de ProtectedLayout. El dashboard conserva el inicio de guía 1; sus estadísticas pertenecen a guía 4.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: client/src/App.jsx -->
{% raw %}
```jsx
import { Collection, GunplaDetail, GunplaFormPage } from "@/collection/Collection";
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
        <Route path="/coleccion" element={<Collection />} />
        <Route path="/coleccion/nuevo" element={<GunplaFormPage />} />
        <Route path="/coleccion/:id" element={<GunplaDetail />} />
        <Route path="/coleccion/:id/editar" element={<GunplaFormPage />} />
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

### `client/src/index.css`

Los estilos conservan el modo oscuro y añaden tarjetas adaptables, controles de formulario, portada de reemplazo y detalle. En móvil las columnas pasan a una sola; nombres y notas largos pueden ajustar línea.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: client/src/index.css -->
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

.page-heading,
.actions,
.pagination {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}
.page-heading {
  justify-content: space-between;
  margin-bottom: 24px;
}
.page-heading h1 {
  margin: 0;
}
.collection-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 24px;
  margin-top: 32px;
}
.gunpla-card {
  border: 1px solid #34363d;
  border-radius: 12px;
  overflow: hidden;
  background: var(--card);
}
.gunpla-card:hover,
.gunpla-card:focus-visible {
  border-color: var(--primary);
}
.gunpla-cover {
  min-height: 210px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: radial-gradient(ellipse at center, #30362b, #181c1b);
  color: #b5c5a1;
  gap: 12px;
}
.gunpla-cover span {
  font-size: 80px;
  line-height: 1;
}
.gunpla-cover small {
  font-size: 10px;
  letter-spacing: 0.18em;
}
.gunpla-card-body {
  padding: 24px;
}
.gunpla-card h2 {
  font-size: 20px;
  margin: 16px 0 8px;
  color: var(--foreground);
  overflow-wrap: anywhere;
}
.state-badge {
  display: inline-block;
  font-size: 12px;
  color: var(--primary);
  border: 1px solid #424b36;
  border-radius: 20px;
  padding: 4px 10px;
}
.pagination {
  justify-content: center;
  margin-top: 32px;
}
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 48px;
  margin-top: 32px;
}
.detail-grid > .gunpla-cover {
  border-radius: 12px;
  min-height: 360px;
  align-self: start;
}
.detail-grid h1,
dd {
  overflow-wrap: anywhere;
}
dt {
  color: #a5a7ae;
  font-size: 12px;
  margin-top: 24px;
}
dd {
  margin: 8px 0 24px;
  white-space: pre-wrap;
}
.gunpla-form {
  max-width: 720px;
  margin-top: 32px;
}
.gunpla-form fieldset {
  border: 0;
  padding: 0;
  min-width: 0;
}
.field {
  display: grid;
  gap: 10px;
  margin-bottom: 24px;
}
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}
select,
textarea {
  width: 100%;
  background: var(--card);
  color: var(--foreground);
  border: 1px solid #45484e;
  border-radius: 6px;
  padding: 10px 12px;
  font: inherit;
  min-width: 0;
}
select:focus-visible,
textarea:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}
.delete-confirmation {
  border: 1px solid #ed7474;
  border-radius: 8px;
  padding: 24px;
  margin-top: 24px;
}
.delete-confirmation h2,
.empty-card h2 {
  font-size: 22px;
  margin-bottom: 12px;
}
.delete-confirmation p,
.empty-card p {
  margin-bottom: 20px;
}
.success {
  color: var(--primary);
  padding: 12px 0;
}
@media (max-width: 900px) {
  .collection-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
@media (max-width: 600px) {
  .collection-grid,
  .detail-grid,
  .form-row {
    grid-template-columns: 1fr;
  }
  .detail-grid {
    gap: 24px;
  }
  .detail-grid > .gunpla-cover {
    min-height: 240px;
  }
}
```
{% endraw %}

## 5. Ejecutar y comprobar en el navegador

**Terminal 1, raíz de `guia-02`:**

{% raw %}
```sh
pnpm dev:server
```
{% endraw %}

**Terminal 2, misma carpeta:**

{% raw %}
```sh
pnpm dev:client
```
{% endraw %}

Abre http://localhost:5173, no una URL directa de la API. Vite+ mantiene `/api` bajo el mismo origen y conserva las cookies. Los diagramas omiten ese salto para facilitar su lectura; no cambió el transporte de guía 1.

1. Registra una cuenta de práctica o inicia sesión. En Mi colección debe aparecer el estado vacío con acción para agregar tu primer registro.
2. Crea RX-78-2 Gundam, selecciona High Grade (HG), escala 1/144 y deja Sin armar. Guarda: debe abrir el detalle con portada de reemplazo.
3. Recarga la página. El nombre y los catálogos deben conservarse porque están en MongoDB.
4. Edita el mismo registro, cambia a En progreso y escribe una nota. Guarda y vuelve a la colección: la tarjeta debe mostrar el estado nuevo.
5. Inicia la eliminación y cancélala: el registro debe seguir visible. Confirma una segunda vez: debe desaparecer y mostrarse el mensaje de éxito.
6. Prueba una ventana de 390 px de ancho: tarjetas y controles deben poder usarse sin desplazamiento horizontal.
7. Con dos cuentas distintas, el registro de una no debe aparecer en la otra. Las pruebas de API comprueban también el intento de acceso directo por id: ocultarlo en la interfaz por sí solo no sería suficiente.
8. Para comprobar la paginación, agrega 13 registros de práctica: habrá 12 en la primera página y uno en la segunda. El conteo no debe incluir registros de otro usuario.

![Colección en escritorio]({{ '/assets/images/gpb/guia-02/coleccion.png' | relative_url }})

Detén ambas terminales con Control+C antes de ejecutar las pruebas de transporte o el verificador web de Atlas: estos levantan sus propios procesos y exigen los puertos libres.

## 6. Pruebas reproducibles

Las seis pruebas de autenticación de guía 1 se conservan. Agregaremos seis de colección: catálogos y acceso anónimo; CRUD; aislamiento entre usuarios; entradas inválidas; paginación; y protección CSRF/caducidad/revocación. Los adaptadores de memoria son exclusivos de pruebas. Su aprobación no demuestra por sí sola que MongoDB funcione: el verificador real de la siguiente sección cubre esa parte.

### `server/test/collection-helpers.js`

Estos adaptadores implementan el contrato de los repositorios para las pruebas HTTP. No los importa el arranque de producción. Cada prueba empieza con sus propios registros y catálogos.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/test/collection-helpers.js -->
{% raw %}
```js
// Adaptadores exclusivos de pruebas: Atlas usa los modelos reales.
import { GRADE_NAMES, SCALE_NAMES } from '../src/catalogs.js';
const hex = (value) => value.toString(16).padStart(24, '0');
export function memoryCollection() {
  const grades = GRADE_NAMES.map((name, i) => ({ id: hex(i + 1), name }));
  const scales = SCALE_NAMES.map((name, i) => ({ id: hex(i + 101), name }));
  const records = new Map();
  let sequence = 1000;
  const view = (doc) => {
    const { owner: _owner, ...data } = doc;
    return { ...data, grade: grades.find((g) => g.id === doc.grade), scale: scales.find((s) => s.id === doc.scale) };
  };
  return {
    catalogs: { async list() { return { grades, scales }; }, async valid(g, s) { return grades.some((x) => x.id === g) && scales.some((x) => x.id === s); } },
    gunpla: {
      async list(owner, page) {
        const all = [...records.values()].filter((doc) => doc.owner === owner).reverse();
        return { items: all.slice((page - 1) * 12, page * 12).map(view), total: all.length, page, pageSize: 12, pages: Math.max(1, Math.ceil(all.length / 12)) };
      },
      async get(owner, id) { const doc = records.get(id); return doc?.owner === owner ? view(doc) : null; },
      async create(owner, data) { const id = hex(sequence++); const doc = { ...data, owner, id, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }; records.set(id, doc); return view(doc); },
      async update(owner, id, data) { const doc = records.get(id); if (doc?.owner !== owner) return null; Object.assign(doc, data, { updatedAt: new Date().toISOString() }); return view(doc); },
      async remove(owner, id) { return records.get(id)?.owner === owner && records.delete(id); },
    },
  };
}
```
{% endraw %}

### `server/test/collection.test.js`

Se intenta consultar, modificar y eliminar un registro ajeno y se comprueba después que el original siga intacto. También se prueba la página con 13 registros, los campos inyectados y que las lecturas no renueven la sesión.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/test/collection.test.js -->
{% raw %}
```js
import test from 'node:test';
import assert from 'node:assert/strict';
import { fixture } from './helpers.js';
import { memoryCollection } from './collection-helpers.js';
import { IDLE_MS } from '../src/app.js';
async function setup(t) {
  const f = await fixture(memoryCollection()); t.after(f.close);
  async function account(suffix) {
    const c = f.client(); await c.call('/auth/csrf');
    assert.equal((await c.call('/auth/register', { method: 'POST', body: { username: 'piloto_' + suffix, email: suffix + '@example.com', password: 'Clave de prueba 123!' } })).status, 201);
    return c;
  }
  const a = await account('a'), b = await account('b');
  const { data } = await a.call('/catalogs');
  const input = { name: 'RX-78-2', grade: data.grades[1].id, scale: data.scales[0].id };
  return { ...f, a, b, input };
}
test('catálogos protegidos, completos y ordenados; colección vacía', async (t) => {
  const f = await setup(t);
  assert.equal((await f.client().call('/catalogs')).status, 401);
  assert.equal((await f.client().call('/gunpla')).status, 401);
  const { data } = await f.a.call('/catalogs');
  assert.equal(data.grades.length, 12); assert.equal(data.scales.length, 5);
  assert.equal(data.grades[0].name, 'Entry Grade (EG)'); assert.equal(data.grades[11].name, 'Sin Grado');
  assert.deepEqual(data.scales.map((s) => s.name), ['1/144', '1/100', '1/60', '1/48', 'Sin Escala']);
  assert.equal((await f.a.call('/gunpla')).data.total, 0);
});
test('crear, consultar, editar y eliminar; estado inicial y textos recortados', async (t) => {
  const { a, input } = await setup(t);
  const created = await a.call('/gunpla', { method: 'POST', body: { ...input, name: ' RX-78-2 ' } });
  assert.equal(created.status, 201); const item = created.data.gunpla;
  assert.equal(item.name, 'RX-78-2'); assert.equal(item.state, 'Sin armar'); assert.equal(item.owner, undefined);
  assert.ok(item.createdAt); assert.ok(item.updatedAt);
  assert.equal((await a.call('/gunpla/' + item.id)).data.gunpla.grade.name, 'High Grade (HG)');
  assert.equal((await a.call('/gunpla/' + item.id, { method: 'PUT', body: { ...input, state: 'Armado', notes: ' Listo ' } })).data.gunpla.notes, 'Listo');
  assert.equal((await a.call('/gunpla/' + item.id, { method: 'DELETE' })).status, 204);
  assert.equal((await a.call('/gunpla/' + item.id)).status, 404);
});
test('un segundo usuario no lista, consulta, edita ni elimina registros ajenos', async (t) => {
  const { a, b, input } = await setup(t);
  const id = (await a.call('/gunpla', { method: 'POST', body: input })).data.gunpla.id;
  assert.equal((await b.call('/gunpla')).data.total, 0);
  for (const method of ['GET', 'PUT', 'DELETE']) assert.equal((await b.call('/gunpla/' + id, { method, ...(method === 'PUT' ? { body: { ...input, name: 'Robado' } } : {}) })).status, 404);
  assert.equal((await a.call('/gunpla/' + id)).data.gunpla.name, input.name);
});
test('rechaza referencias inexistentes, tipos y campos adicionales, textos largos y estados inválidos', async (t) => {
  const { a, input } = await setup(t);
  for (const body of [{}, { ...input, name: ' ' }, { ...input, name: 'x'.repeat(121) }, { ...input, grade: 'bad' }, { ...input, scale: 'f'.repeat(24) }, { ...input, grade: { $ne: null } }, { ...input, state: 'Pintado' }, { ...input, description: 'x'.repeat(1001) }, { ...input, notes: [] }, { ...input, owner: '1' }, { ...input, createdAt: 'ayer' }, { ...input, cover: 'url' }]) {
    assert.equal((await a.call('/gunpla', { method: 'POST', body })).status, 400);
  }
  assert.equal((await a.call('/gunpla/no-es-id')).status, 400);
  for (const query of ['page=0','page=-1','page=1.5','page=abc','page=1&page=2','owner=otro']) assert.equal((await a.call('/gunpla?' + query)).status, 400);
  assert.equal((await a.call('/gunpla')).data.total, 0);
});
test('paginación de 12 sin registros de otro usuario', async (t) => {
  const { a, b, input } = await setup(t);
  for (let i = 0; i < 13; i++) await a.call('/gunpla', { method: 'POST', body: { ...input, name: 'Modelo ' + i } });
  await b.call('/gunpla', { method: 'POST', body: input });
  const first = (await a.call('/gunpla')).data, second = (await a.call('/gunpla?page=2')).data;
  assert.equal(first.total, 13); assert.equal(first.items.length, 12); assert.equal(first.pages, 2); assert.equal(second.items.length, 1);
  assert.equal(first.items[0].name, 'Modelo 12'); assert.equal(second.items[0].name, 'Modelo 0');
});
test('CSRF, origen, caducidad y revocación protegen las operaciones nuevas', async (t) => {
  const f = await setup(t); const { a, input } = f;
  const id = (await a.call('/gunpla', { method: 'POST', body: input })).data.gunpla.id;
  for (const headers of [{ 'x-csrf-token': '' }, { origin: 'https://ajeno.example' }]) {
    for (const [method, path] of [['POST', '/gunpla'], ['PUT', '/gunpla/' + id], ['DELETE', '/gunpla/' + id]]) assert.equal((await a.call(path, { method, body: input, headers })).status, 403);
  }
  f.advance(IDLE_MS - 1); assert.equal((await a.call('/gunpla')).status, 200);
  f.advance(1); assert.equal((await a.call('/gunpla/' + id)).status, 401);
  await f.b.call('/auth/logout', { method: 'POST' });
  assert.equal((await f.b.call('/gunpla')).status, 401);
});
```
{% endraw %}

### `tests/local-api.js`

El servidor aislado usado por Playwright recibe ahora catálogos y colección de memoria. Mantiene la misma autenticación y protección CSRF de la aplicación.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: tests/local-api.js -->
{% raw %}
```js
// Sólo pruebas de transporte; nunca es un sustituto de Atlas en producción.
import session from '../server/node_modules/express-session/index.js';
import { createApp } from '../server/src/app.js';
import { memoryCollection } from '../server/test/collection-helpers.js';
import { memoryUsers } from '../server/test/helpers.js';
const config = { NODE_ENV: 'test', WEB_ORIGIN: 'http://localhost:5173', SESSION_SECRET: 'pruebas-locales-sin-secretos-reales-123456789' };
const server = createApp({ config, store: new session.MemoryStore(), users: memoryUsers(), ...memoryCollection(), authLimit: 200 }).listen(3000, '127.0.0.1', () => console.log('API aislada de prueba disponible'));
process.on('SIGTERM', () => server.close());
```
{% endraw %}

### `tests/collection.spec.js`

El recorrido de navegador comprueba formularios, estado inicial, recarga, edición, cancelación y confirmación de eliminación, móvil y recuperación después de una respuesta 503 simulada.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: tests/collection.spec.js -->
{% raw %}
```js
import { test, expect } from '@playwright/test';
import { join } from 'node:path';

test('colección: CRUD, recarga, confirmación, móvil y recuperación de errores', async ({ page }) => {
  await page.goto('/registro');
  await page.getByLabel('Nombre de usuario').fill('coleccion_web');
  await page.getByLabel('Correo electrónico').fill('coleccion_web@example.com');
  await page.getByLabel('Contraseña', { exact: true }).fill('Clave de prueba 123!');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
  await expect(page.getByText('El primer build está por llegar')).toBeVisible();
  await page.getByRole('link', { name: 'Agregar mi primer Gunpla' }).click();
  await expect(page.getByLabel('Estado', { exact: true })).toHaveValue('Sin armar');
  await expect(page.getByLabel('Grado', { exact: true }).locator('option')).toHaveCount(13);
  await page.getByLabel('Nombre', { exact: true }).fill('RX-78-2 Gundam');
  await page.getByLabel('Grado', { exact: true }).selectOption({ label: 'High Grade (HG)' });
  await page.getByLabel('Escala', { exact: true }).selectOption({ label: '1/144' });
  await page.getByLabel('Descripción (opcional)', { exact: true }).fill('Mi primer modelo.');
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'RX-78-2 Gundam', exact: true })).toBeVisible();
  await page.reload(); await expect(page.getByText('Mi primer modelo.', { exact: true })).toBeVisible();
  await page.getByRole('link', { name: 'Editar Gunpla', exact: true }).click();
  await expect(page.getByLabel('Grado', { exact: true }).locator('option:checked')).toHaveText('High Grade (HG)');
  await page.getByLabel('Estado', { exact: true }).selectOption('En progreso');
  await page.getByLabel('Notas (opcional)', { exact: true }).fill('Panel lining pendiente.');
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await expect(page.getByText('Panel lining pendiente.', { exact: true })).toBeVisible();
  await page.getByRole('link', { name: 'Volver a mi colección', exact: true }).click();
  await expect(page.getByRole('link', { name: /RX-78-2 Gundam/ })).toContainText('En progreso');
  if (process.env.GPB_CAPTURE_DIR) await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'coleccion.png'), fullPage: true });
  await page.setViewportSize({ width: 390, height: 844 });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (process.env.GPB_CAPTURE_DIR) await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'coleccion-movil.png'), fullPage: true });
  await page.getByRole('link', { name: /RX-78-2 Gundam/ }).click();
  await page.getByRole('button', { name: 'Eliminar Gunpla', exact: true }).click();
  await page.getByRole('button', { name: 'Cancelar', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Confirmar eliminación', exact: true })).toHaveCount(0);
  await page.getByRole('button', { name: 'Eliminar Gunpla', exact: true }).click();
  await page.getByRole('button', { name: 'Confirmar eliminación', exact: true }).click();
  await expect(page.getByText('Gunpla eliminado.', { exact: true })).toBeVisible();
  await expect(page.getByText('El primer build está por llegar')).toBeVisible();
  await page.route('**/api/gunpla?*', (route) => route.fulfill({ status: 503, contentType: 'application/json', body: JSON.stringify({ message: 'Servicio temporalmente no disponible.' }) }));
  await page.reload(); await expect(page.getByRole('alert')).toContainText('Servicio temporalmente no disponible.');
  await page.unroute('**/api/gunpla?*');
  await page.getByRole('button', { name: 'Reintentar', exact: true }).click();
  await expect(page.getByText('El primer build está por llegar')).toBeVisible();
});
```
{% endraw %}

### 6.1. Ejecutar las comprobaciones locales

**Carpeta: raíz de `guia-02`.**

{% raw %}
```sh
pnpm check
pnpm build
pnpm test
pnpm exec playwright install chromium
pnpm exec install-electron
pnpm test:transport
```
{% endraw %}

Resultados comprobados: revisión sin errores ni advertencias, build de 206 módulos, 12 pruebas API y 3 recorridos de navegador/Electron aprobados. El transporte Electron continúa siendo una prueba preparatoria; la interfaz integrada y el paquete macOS pertenecen a guía 6. Los binarios de Chromium y Electron deben estar disponibles; sus comandos de preparación proceden de la guía 1.

### 6.2. Comprobar Atlas y persistencia real

El siguiente verificador usa la entrada real de API y React con tu configuración local. Carga los catálogos compartidos, crea dos cuentas aleatorias y un registro exclusivo de prueba, reinicia navegador y API, comprueba propiedad y CRUD, y elimina sus cuentas, sesiones y Gunpla al terminar. No borra las cuentas personales ni los catálogos. Ejecútalo únicamente en la base de práctica del proyecto y con 3000/5173 libres.

### `server/scripts/check-collection-atlas.js`

El verificador genera un secreto de sesión efímero, no imprime URI, contraseñas ni cookies y realiza su limpieza en finally. Un resultado no completado indica el paso que falló; no lo interpretes como aprobado.

Crea este archivo o reemplaza todo su contenido, según corresponda.

<!-- archivo: server/scripts/check-collection-atlas.js -->
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
import assert from 'node:assert/strict';
import { seedCatalogs, catalogs, Grade, Scale } from '../src/catalogs.js';
import { Gunpla } from '../src/gunpla.js';
import { chromium } from '@playwright/test';
import { readConfig } from '../src/config.js';
import { User } from '../src/users.js';

const root = fileURLToPath(new URL('../../', import.meta.url));
const suffix = randomBytes(6).toString('hex');
const account = { username: `web_${suffix}`, email: `${suffix}@example.com`, password: randomBytes(24).toString('hex') };
const sessionIds = new Set();
let apiProcess, clientProcess, browser, profile, createdId, gunplaId;
const other = { username: `other_${suffix}`, email: `other_${suffix}@example.com`, password: randomBytes(24).toString('hex') };
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
  process.env.SESSION_SECRET = randomBytes(48).toString('hex');
  const config = readConfig();
  if (config.NODE_ENV !== 'development' || config.PORT !== 3000 || config.WEB_ORIGIN !== 'http://localhost:5173') throw new Error('La prueba requiere configuración local estándar');
  await freePort(3000); await freePort(5173);
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  stage = 'carga idempotente de catálogos';
  await seedCatalogs();
  const before = await catalogs.list();
  await seedCatalogs();
  assert.deepEqual(await catalogs.list(), before);
  assert.equal(await Grade.countDocuments(), 12); assert.equal(await Scale.countDocuments(), 5);
  stage = 'arranque de API y cliente';
  const startApi = () => start(process.execPath, ['src/index.js'], join(root, 'server'));
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
  stage = 'crear Gunpla desde React con catálogos reales';
  await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
  await page.getByRole('link', { name: 'Agregar mi primer Gunpla', exact: true }).click();
  await page.getByLabel('Nombre', { exact: true }).fill('RX-78-2 Atlas');
  await page.getByLabel('Grado', { exact: true }).selectOption({ label: 'High Grade (HG)' });
  await page.getByLabel('Escala', { exact: true }).selectOption({ label: '1/144' });
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await page.getByRole('heading', { name: 'RX-78-2 Atlas', exact: true }).waitFor();
  const savedGunpla = await Gunpla.findOne({ owner: createdId });
  assert.ok(savedGunpla); gunplaId = String(savedGunpla._id);
  assert.equal(savedGunpla.state, 'Sin armar');
  stage = 'aislamiento real entre dos usuarios';
  let otherCookie = '', otherCsrf = '';
  async function otherCall(path, method = 'GET', body) {
    const response = await fetch('http://127.0.0.1:3000/api' + path, { method, headers: { cookie: otherCookie, origin: config.WEB_ORIGIN, 'content-type': 'application/json', 'x-csrf-token': otherCsrf }, body: body ? JSON.stringify(body) : undefined });
    const set = response.headers.get('set-cookie');
    if (set) {
      otherCookie = set.split(';')[0];
      const value = decodeURIComponent(otherCookie.slice(otherCookie.indexOf('=') + 1));
      if (value.startsWith('s:')) sessionIds.add(value.slice(2).split('.')[0]);
    }
    const data = response.status === 204 ? null : await response.json();
    if (data?.csrfToken) otherCsrf = data.csrfToken;
    return { status: response.status, data };
  }
  await otherCall('/auth/csrf');
  assert.equal((await otherCall('/auth/register', 'POST', other)).status, 201);
  assert.equal((await otherCall('/gunpla')).data.total, 0);
  for (const method of ['GET', 'PUT', 'DELETE']) assert.equal((await otherCall('/gunpla/' + gunplaId, method, method === 'PUT' ? { name: 'Ajeno' } : undefined)).status, 404);
  assert.equal((await otherCall('/auth/logout', 'POST')).status, 204);
  stage = 'reapertura del navegador y reinicio de API';
  await browser.close(); browser = null;
  await stop(apiProcess); apiProcess = startApi();
  await ready('http://127.0.0.1:3000/api/health', apiProcess);
  browser = await chromium.launchPersistentContext(profile, options);
  page = await browser.newPage(); page.setDefaultTimeout(15000);
  await page.goto('http://localhost:5173/'); await heading(page);
  stage = 'persistencia del Gunpla, edición y eliminación';
  await page.goto('http://localhost:5173/coleccion/' + gunplaId);
  await page.getByRole('heading', { name: 'RX-78-2 Atlas', exact: true }).waitFor();
  await page.getByRole('link', { name: 'Editar Gunpla', exact: true }).click();
  await page.getByLabel('Estado', { exact: true }).selectOption('Armado');
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await page.getByText('Armado', { exact: true }).waitFor();
  assert.equal((await Gunpla.findById(gunplaId)).state, 'Armado');
  await page.getByRole('button', { name: 'Eliminar Gunpla', exact: true }).click();
  await page.getByRole('button', { name: 'Confirmar eliminación', exact: true }).click();
  await page.getByText('Gunpla eliminado.', { exact: true }).waitFor();
  assert.equal(await Gunpla.findById(gunplaId), null);
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
  console.log('Colección + Atlas comprobados: catálogos idempotentes, CRUD React, aislamiento entre dos usuarios y persistencia tras reinicios; además: registro React, hash persistido, navegador y API reiniciados, navegación, credenciales incorrectas, nuevo acceso y cierre de sesión.');
} catch {
  console.error(`Comprobación web Atlas no completada. Paso: ${stage}. No se muestran datos privados.`);
  process.exitCode = 1;
} finally {
  if (browser) { await trackCookies().catch(() => {}); await browser.close(); }
  await stop(apiProcess); await stop(clientProcess);
  if (mongoose.connection.readyState === 1) {
    try {
      const user = createdId ? { _id: createdId, email: account.email } : { username: account.username, email: account.email };
      if (createdId) await Gunpla.deleteMany({ owner: createdId });
      else { const own = await User.findOne(user); if (own) await Gunpla.deleteMany({ owner: own._id }); }
      await User.deleteOne(user);
      await User.deleteOne({ username: other.username, email: other.email });
      if (sessionIds.size) await mongoose.connection.collection('sessions').deleteMany({ _id: { $in: [...sessionIds] } });
      console.log('Cuenta y sesiones exclusivas de prueba eliminadas; procesos locales detenidos.');
    } catch { console.error('Pendiente limpiar los registros exclusivos de esta prueba.'); process.exitCode = 1; }
    await mongoose.disconnect();
  }
  if (profile) await rm(profile, { recursive: true, force: true });
}
```
{% endraw %}

**Carpeta: raíz de `guia-02`, con `server/.env` configurado.**

{% raw %}
```sh
pnpm --filter @gpb/server check:atlas
pnpm --filter @gpb/server check:collection:atlas
```
{% endraw %}

El primer comando conserva la comprobación de sesiones reales de guía 1. El segundo debe finalizar con código 0 y comunicar catálogos idempotentes, CRUD React, aislamiento entre dos usuarios, persistencia tras reinicios y limpieza de datos temporales. En esta entrega ambos recorridos de autenticación y colección se comprobaron con Atlas; el detalle de ejecución queda en el informe de reproducción. Las comprobaciones de Render se harán en guía 5.

## 7. Errores frecuentes

| Síntoma | Revisión |
|---|---|
| El formulario no tiene grados o escalas | Ejecuta seed:catalogs contra la misma base que usa la API y recarga. |
| Atlas no responde | Comprueba conexión, disponibilidad del clúster e IP permitida en Network Access. No pegues la URI en capturas. |
| 403 al guardar | Usa localhost:5173, conserva Origin y deja que api.js obtenga CSRF. Recarga si cambió la sesión. |
| 400 en la colección | Comprueba campos, ids de los catálogos, estado y límites; no envíes owner ni fechas. |
| 404 con un id conocido | Puede no existir o pertenecer a otra cuenta; la respuesta deliberadamente no revela cuál. |
| El puerto ya está ocupado | Detén guía 1 u otros procesos propios antes de iniciar guía 2 o los verificadores. |
| Un registro desapareció al reiniciar las pruebas locales | Los fixtures usan memoria; la aplicación real debe iniciarse con dev:server y Atlas. |
| Una página quedó vacía tras cambios en otra ventana | Vuelve a la primera página o recarga; no hay sincronización en tiempo real en esta etapa. |
| 413 al guardar | El cuerpo JSON completo supera 8 KB; reduce los textos. Se conserva el límite de guía 1. |

## 8. Cierre y siguiente entrega

Conserva el lock, el código y tus resultados. Si utilizas Git, revisa que no se incluyan `.env`, node_modules, dist ni perfiles de navegador. Los puntos de control del docente se conservan en el repositorio; no necesitas crear etiquetas para ejecutar la aplicación.

Antes de grabar, reproduce esta guía desde la versión anterior y comprueba los resultados anteriores. El [informe de verificación]({{ '/assets/downloads/gpb/guia-02/etapas/02/VERIFICACION.md' | relative_url }}) distingue los resultados locales, Atlas y la publicación del material docente. Publicar esta entrada de blog no equivale a desplegar la aplicación en Render.

En la guía 3 reemplazaremos la portada de ejemplo, integraremos Cloudinary y completaremos galería, etiquetas y video. Mantendremos la comprobación de propiedad también para las operaciones de imágenes.

## 9. Herramientas y fuentes oficiales

Consulta: 18 de noviembre de 2026. No cambiamos versiones por el hecho de que la documentación publique una versión posterior.

| Herramienta | Qué es y por qué se usa en GPB | Inicio oficial | Requisitos, instalación y comprobación |
|---|---|---|---|
| Mongoose 9.12.0 | Modela documentos, referencias y validaciones de MongoDB. Permite guardar opciones por id y recuperar sus nombres. | [Quick Start](https://mongoosejs.com/docs/index.html) | Node y acceso a Atlas de guía 1. Ya fijado: pnpm install --frozen-lockfile. Consultar pnpm list -r --depth 0; comprobar con seed:catalogs y check:collection:atlas. No tiene CLI de versión. |
| Express 5.3.0 | Atiende las rutas HTTP y encadena sesión, CSRF y autenticación antes del CRUD. | [Instalación](https://expressjs.com/en/starter/installing.html) | Node de guía 1; instalación congelada existente. pnpm list -r --depth 0 y pnpm test comprueban versión/función. No tiene CLI de versión. |
| Zod 4.6.7 | Valida entradas y rechaza campos desconocidos antes de consultar MongoDB. | [Introducción](https://zod.dev/) | Dependencia existente, instalación congelada. Versión por pnpm list -r --depth 0; entradas inválidas verificadas por pnpm test. No tiene CLI de versión. |
| React 19.3.1 y Router 8.5.1 | Construyen pantallas y rutas protegidas, compartiendo el formulario entre creación/edición. | [React](https://react.dev/learn), [Router](https://reactrouter.com/start/declarative/installation) | Cliente y navegador de guía 1; versiones en el lock. pnpm list -r --depth 0, build y test:transport. |
| Vite+ 1.6.0 y pnpm 12.18.0 | Ejecutan cliente, proxy, revisión, build y dependencias exactas sin cambiar herramientas globales. | [Vite+](https://viteplus.dev/guide/), [pnpm](https://pnpm.io/installation) | Entorno de guía 1, instalación por proyecto. node --version, pnpm --version, pnpm --filter @gpb/client exec vp --version; check y build. |
| Node 26.13.1, Playwright 1.65.0 y Electron 45.3.1 | Ejecutan pruebas HTTP, navegador y la regresión de transporte del escritorio. | [Node test runner](https://nodejs.org/api/test.html), [Playwright](https://playwright.dev/docs/intro), [Electron](https://www.electronjs.org/docs/latest/tutorial/quick-start) | Herramientas de guía 1; instalación congelada y preparación de binarios en 6.1. pnpm test y test:transport. |
| MongoDB Atlas | Base remota para colección, catálogos y sesiones; se mantiene separada del cliente. | [Primeros pasos](https://www.mongodb.com/docs/atlas/getting-started/) | Cuenta, usuario de base y acceso de red propios. Sin instalación local de MongoDB; verificar con los comandos Atlas. La versión administrada se consulta con serverInfo, no se instala desde pnpm. |

Para ampliar los mecanismos: [esquemas Mongoose](https://mongoosejs.com/docs/guide.html), [validación](https://mongoosejs.com/docs/validation.html), [populate](https://mongoosejs.com/docs/populate.html), [rutas Express](https://expressjs.com/en/guide/routing.html) y [esquemas Zod](https://zod.dev/api). Las adaptaciones del proyecto son la paginación de 12, sus límites de texto, los catálogos y las políticas de sesión acordadas.

Los diagramas son HTML autónomos elaborados con [Archify](https://github.com/tt-a1i/archify). Abrirlos no requiere instalar herramientas adicionales ni iniciar GPB. Sus fuentes y comprobaciones están en [Diagramas de guía 2]({{ '/assets/downloads/gpb/guia-02/etapas/02/DIAGRAMAS.md' | relative_url }}).
