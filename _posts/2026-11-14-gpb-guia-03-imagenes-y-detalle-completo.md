---
title: GPB — Gunpla Personal Builds | Guía 3 - Imágenes y detalle completo
date: 2026-11-14
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, nodeJS, mongodb, cloudinary, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

# GPB — Guía 3: imágenes y detalle completo

En la guía 2 construimos una colección privada. Ahora cada Gunpla tendrá una portada, hasta ocho fotografías adicionales, etiquetas y un video opcional de YouTube. Mantendremos la propiedad, las sesiones, CSRF y las páginas de doce registros.

## Recorrido

1. Crear una versión independiente desde guía 2.
2. Configurar las herramientas de imágenes.
3. Ampliar el contrato de datos.
4. Gestionar subidas y limpieza sin perder el estado anterior.
5. Completar el detalle en React.
6. Comprobar, reproducir y conservar la entrega.

**Convención:** salvo indicación, los comandos se ejecutan desde la raíz de guia-03. Cada bloque marcado como archivo se copia completo al editor, creando sus carpetas cuando sea necesario. Los bloques de JavaScript no son comandos de terminal.

Material: [fuentes oficiales]({{ '/assets/downloads/gpb/guia-03/etapas/03/FUENTES.md' | relative_url }}), [registro]({{ '/assets/downloads/gpb/guia-03/etapas/03/REGISTRO.md' | relative_url }}), [traspaso]({{ '/assets/downloads/gpb/guia-03/etapas/03/TRASPASO-CHATGPT.md' | relative_url }}), [código]({{ '/assets/downloads/gpb/guia-03/etapas/03/codigo-etapa-3.zip' | relative_url }}).

## 1. Punto de partida y preparación

Necesitas la guía 2 completada y conocimientos de JavaScript, React, HTTP y MongoDB. La referencia anterior es gpb-dev/guia-02 del commit 5e34cf3. Conserva Node 26.13.1, pnpm 12.18.0 y Vite+ 1.6.0. No cambies instalaciones globales. Detén otras versiones que utilicen los puertos 3000 y 5173. No sobrescribas una carpeta guia-03 existente.

**Carpeta: gpb-dev.**

{% raw %}
```sh
mkdir guia-03
rsync -a --exclude=node_modules --exclude=dist --exclude='.env' --exclude='.env.*' --exclude=test-results --exclude=playwright-report --exclude='*.log' guia-02/client guia-02/server guia-02/electron guia-02/tests guia-03/
cp guia-02/package.json guia-02/pnpm-lock.yaml guia-02/pnpm-workspace.yaml guia-02/playwright.config.js guia-02/.gitignore guia-02/.node-version guia-03/
cp guia-02/server/.env.example guia-03/server/.env.example
cd guia-03
node --version
pnpm --version
uname -m
pnpm --filter @gpb/server add --save-exact cloudinary@2.11.0 multer@2.5.0 sharp@0.35.5
pnpm install --frozen-lockfile
pnpm --filter @gpb/server list --depth 0
pnpm --filter @gpb/client exec vp --version
```
{% endraw %}

Resultados de referencia: Node 26.13.1, pnpm 12.18.0, macOS arm64, Vite+ 1.6.0. Las versiones exactas nuevas son Cloudinary 2.11.0, Multer 2.5.0 y Sharp 0.35.5. El resto se hereda de la guía 2. Las dependencias sin CLI se comprueban con pnpm list.

## 2. Herramientas y configuración privada

**Cloudinary** guarda y entrega imágenes fuera de MongoDB. En GPB sólo Express conoce las credenciales y envía archivos. Sigue el [Getting Started oficial](https://cloudinary.com/documentation/node_quickstart), crea tu cuenta y consulta cloud name, API key y API secret. El SDK declara Node >=9; utilizaremos la versión del proyecto, 26.13.1. Se instala en el servidor con el comando del apartado anterior y su versión se comprueba con pnpm list. Su funcionamiento real se prueba en el apartado 9.

**Multer** interpreta multipart/form-data en las rutas de carga de Express. Permite limitar los archivos antes de mantenerlos en memoria. Consulta [instalación y primeros pasos](https://expressjs.com/en/resources/middleware/multer/). Requiere Node >=10.16.0; fijamos 2.5.0 en el servidor. Su versión se consulta con pnpm list y sus límites se comprueban con las pruebas HTTP.

**Sharp** decodifica imágenes y produce una salida normalizada. En GPB evita confiar solamente en la extensión y elimina metadatos antes de subir. Consulta la [instalación oficial](https://sharp.pixelplumbing.com/install/) y su [constructor y límites](https://sharp.pixelplumbing.com/api-constructor/). Requiere Node >=20.9.0; fijamos 0.35.5. La instalación nativa se comprobó en macOS arm64. Las pruebas verifican PNG, JPG y WebP válidos, y rechazan archivos discordantes o dañados.

Fuentes consultadas el 19/11/2026. Los límites de 25 megapíxeles, tamaño de salida 2400 × 2400 y WebP calidad 85 son decisiones de GPB. El original puede ocupar hasta **5 MiB (5 × 1024 × 1024 bytes)**. No admitiremos imágenes animadas. Las fotografías se entregan mediante URL pública; evita contenido privado.

Primero completa los archivos de los apartados siguientes, incluido server/.env.example. Luego configura tu entorno propio:

**Carpeta: raíz de guia-03.**

{% raw %}
```sh
cp server/.env.example server/.env
chmod 600 server/.env
node --input-type=module -e 'import { appendFileSync } from "node:fs"; import { randomBytes } from "node:crypto"; appendFileSync("server/.env", String.fromCharCode(10) + "SESSION_SECRET=" + randomBytes(48).toString("hex") + String.fromCharCode(10));'
```
{% endraw %}

En el editor, completa MONGODB_URI con tu conexión de Atlas y descomenta las tres variables CLOUDINARY con tus valores privados. Conserva WEB_ORIGIN=http://localhost:5173, NODE_ENV=development y PORT=3000. El comando genera un secreto independiente sin imprimirlo; la última asignación prevalece sobre la línea vacía. No copies el .env de otra entrega ni lo publiques. Una configuración Cloudinary parcial impide iniciar; si no defines ninguna de sus variables, la colección funciona pero las subidas responden 503.

### Diagramas del proceso

Los diagramas explican el algoritmo; no son trazas de llamadas medidas ni prueba de disponibilidad del proveedor. La correspondencia con las fuentes actuales se documenta en [DIAGRAMAS.md]({{ '/assets/downloads/gpb/guia-03/etapas/03/DIAGRAMAS.md' | relative_url }}).

![Sustitución segura]({{ '/assets/images/gpb/guia-03/gpb-sustitucion-guia-3.png' | relative_url }})

[Explorar sustitución]({{ '/assets/diagrams/gpb/guia-03/gpb-sustitucion-guia-3.html?theme=dark' | relative_url }}) · [SVG oscuro]({{ '/assets/images/gpb/guia-03/gpb-sustitucion-guia-3.svg' | relative_url }})

![Recuperación y limpieza]({{ '/assets/images/gpb/guia-03/gpb-limpieza-guia-3.png' | relative_url }})

[Explorar limpieza]({{ '/assets/diagrams/gpb/guia-03/gpb-limpieza-guia-3.html?theme=dark' | relative_url }}) · [SVG oscuro]({{ '/assets/images/gpb/guia-03/gpb-limpieza-guia-3.svg' | relative_url }})

## 3. Contrato de datos y validación

El cliente envía etiquetas y un enlace, pero nunca puede asignar dueño, URLs de imágenes, identificadores externos ni tareas de limpieza. La API transforma el enlace en un identificador y rechaza HTML. Los registros antiguos reciben valores vacíos al presentarse.

### `server/src/media-input.js`

Sharp verifica la extensión, el MIME y la decodificación. Se reexporta a WebP para retirar metadatos y contenido ajeno. youtubeId acepta las variantes HTTPS watch, youtu.be, shorts y embed de los dominios previstos.

<!-- archivo: server/src/media-input.js -->
{% raw %}
```js
import sharp from 'sharp';
import { extname } from 'node:path';

export const MAX_BYTES = 5 * 1024 * 1024;
export const failure = (status, message) => Object.assign(new Error(message), { status, expose: true });
// No basta la extensión ni el Content-Type enviado por el navegador.
export async function validateImage(file) {
  if (!file) throw failure(400, 'Selecciona una imagen.');
  const expected = { '.jpg': 'jpeg', '.jpeg': 'jpeg', '.png': 'png', '.webp': 'webp' }[extname(file.originalname).toLowerCase()];
  const mime = { jpeg: 'image/jpeg', png: 'image/png', webp: 'image/webp' }[expected];
  if (!expected || file.mimetype !== mime) throw failure(400, 'Usa JPG, PNG o WebP con su extensión y tipo correctos.');
  if (file.buffer.length > MAX_BYTES) throw failure(413, 'Cada imagen admite como máximo 5 MB.');
  try {
    const image = sharp(file.buffer, { failOn: 'warning', limitInputPixels: 25000000 });
    const info = await image.metadata();
    if (info.format !== expected || (info.pages || 1) !== 1) throw new Error('Formato incorrecto o animado');
    // Decodificar y reexportar elimina metadatos y contenido adjunto al archivo.
    return await image.rotate().resize({ width: 2400, height: 2400, fit: 'inside', withoutEnlargement: true }).webp({ quality: 85 }).toBuffer();
  } catch { throw failure(400, 'La imagen está dañada, no coincide con su formato, es animada o supera 25 megapíxeles.'); }
}

export function youtubeId(value) {
  if (!value) return '';
  let url;
  try { url = new URL(value); } catch { return null; }
  if (url.protocol !== 'https:' || url.username || url.password || url.port || url.hash) return null;
  const host = url.hostname.toLowerCase();
  let id;
  if (host === 'youtu.be') id = url.pathname.slice(1);
  else if (['youtube.com', 'www.youtube.com', 'm.youtube.com'].includes(host)) {
    if (url.pathname === '/watch') id = url.searchParams.get('v');
    else id = /^\/(?:shorts|embed)\/([\w-]{11})$/.exec(url.pathname)?.[1];
  }
  return /^[\w-]{11}$/.test(id || '') ? id : null;
}
```
{% endraw %}

### `server/src/gunpla.js`

Se añaden portada, galería, etiquetas e identificador de video. mediaJobs, mediaLock y deleted son privados; publicGunpla no los devuelve. Las lecturas y ediciones normales excluyen eliminados.

<!-- archivo: server/src/gunpla.js -->
{% raw %}
```js
import mongoose from 'mongoose';

export const STATES = ['Sin armar', 'En progreso', 'Armado'];
const image = new mongoose.Schema({ publicId: String, url: String }, { _id: false });
const job = new mongoose.Schema({ publicId: String, createdAt: { type: Date, default: Date.now }, settled: { type: Boolean, default: false } }, { _id: false });
const schema = new mongoose.Schema({
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, immutable: true },
  name: { type: String, required: true, trim: true, maxlength: 120 },
  grade: { type: mongoose.Schema.Types.ObjectId, ref: 'Grade', required: true },
  scale: { type: mongoose.Schema.Types.ObjectId, ref: 'Scale', required: true },
  description: { type: String, trim: true, maxlength: 1000, default: '' },
  notes: { type: String, trim: true, maxlength: 1000, default: '' },
  tags: { type: [String], default: [] },
  youtubeId: { type: String, default: '' },
  cover: { type: image, default: null },
  gallery: { type: [image], default: [] },
  mediaJobs: { type: [job], default: [] },
  mediaLock: { token: String, until: Date },
  deleted: { type: Boolean, default: false },
  state: { type: String, enum: STATES, required: true, default: 'Sin armar' },
}, { timestamps: true });
schema.index({ owner: 1, createdAt: -1, _id: -1 });
export const Gunpla = mongoose.model('Gunpla', schema);
const populate = (query) => query.populate('grade', 'name').populate('scale', 'name').lean();
export function publicGunpla(doc) {
  const option = (value) => value ? { id: String(value._id), name: value.name } : null;
  return { id: String(doc._id), name: doc.name, grade: option(doc.grade), scale: option(doc.scale),
    cover: doc.cover || null, gallery: doc.gallery || [], tags: doc.tags || [], youtubeId: doc.youtubeId || '',
    description: doc.description, notes: doc.notes, state: doc.state, createdAt: doc.createdAt, updatedAt: doc.updatedAt };
}
export const gunpla = {
  async list(owner, page) {
    const filter = { owner, deleted: { $ne: true } };
    const [docs, total] = await Promise.all([
      populate(Gunpla.find(filter).sort({ createdAt: -1, _id: -1 }).skip((page - 1) * 12).limit(12)),
      Gunpla.countDocuments(filter),
    ]);
    return { items: docs.map(publicGunpla), total, page, pageSize: 12, pages: Math.max(1, Math.ceil(total / 12)) };
  },
  async get(owner, id) {
    const doc = await populate(Gunpla.findOne({ _id: id, owner, deleted: { $ne: true } }));
    return doc ? publicGunpla(doc) : null;
  },
  async create(owner, input) {
    const doc = await Gunpla.create({ ...input, owner });
    return this.get(owner, doc._id);
  },
  async update(owner, id, input) {
    const doc = await populate(Gunpla.findOneAndUpdate({ _id: id, owner, deleted: { $ne: true } }, { $set: input }, { returnDocument: 'after', runValidators: true }));
    return doc ? publicGunpla(doc) : null;
  },
  async remove(owner, id) { return Boolean(await Gunpla.findOneAndDelete({ _id: id, owner, deleted: { $ne: true } })); },
};
```
{% endraw %}

### `server/src/collection-routes.js`

El contrato estricto limita etiquetas, elimina duplicados y valida el enlace; la eliminación utiliza el servicio de imágenes cuando está disponible.

<!-- archivo: server/src/collection-routes.js -->
{% raw %}
```js
import { Router } from 'express';
import { z, ZodError } from 'zod';
import { youtubeId } from './media-input.js';
import { STATES } from './gunpla.js';

const id = z.string().regex(/^[a-fA-F0-9]{24}$/, 'Identificador inválido.');
const input = z.strictObject({
  name: z.string().trim().min(1).max(120), grade: id, scale: id,
  description: z.string().trim().max(1000).default(''),
  notes: z.string().trim().max(1000).default(''),
  tags: z.array(z.string().trim().min(1).max(30)).max(20).default([]).transform((tags) => [...new Map(tags.map((tag) => [tag.toLocaleLowerCase('es'), tag])).values()]),
  youtubeUrl: z.string().trim().max(300).default('').refine((value) => youtubeId(value) !== null, 'Usa un enlace HTTPS válido de YouTube.'),
  state: z.enum(STATES).default('Sin armar'),
});
const pageQuery = z.strictObject({ page: z.string().regex(/^[1-9]\d{0,5}$/).transform(Number).optional().default(1) });
const missing = (res) => res.status(404).json({ message: 'Gunpla no encontrado.' });
export function collectionRoutes({ catalogs, gunpla, media }) {
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
    const { youtubeUrl, ...fields } = data;
    return { ...fields, youtubeId: youtubeId(youtubeUrl) };
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
    const removed = await (media ? media.remove.bind(media) : gunpla.remove.bind(gunpla))(String(req.user._id), id.parse(req.params.id));
    return removed ? res.sendStatus(204) : missing(res);
  });
  router.use((error, _req, res, next) => {
    if (error instanceof ZodError) return res.status(400).json({ message: 'Revisa los datos: nombre de 1 a 120 caracteres, grado y escala válidos, estado permitido y textos de hasta 1000 caracteres. Etiquetas: hasta 20 de 1–30 caracteres. Video: enlace HTTPS válido de YouTube. No se admiten campos adicionales ni una página inválida.' });
    next(error);
  });
  return router;
}
```
{% endraw %}

## 4. Cloudinary y consistencia entre servicios

MongoDB y Cloudinary no comparten una transacción. Primero se registra un identificador único, luego se sube y finalmente se cambia la portada. Si algo falla, el diario permite reintentar. No se sobrescribe un recurso anterior. Un bloqueo con token y plazo evita que dos solicitudes compitan por la última posición de galería.

### `server/src/cloudinary.js`

El SDK sólo aparece en el servidor. La subida tiene timeout de 30 s; destroy usa 10 s e invalidación. Una configuración ausente produce un error comprensible.

<!-- archivo: server/src/cloudinary.js -->
{% raw %}
```js
import { v2 as cloudinary } from 'cloudinary';
import { failure } from './media-input.js';

export function cloudinaryProvider(config) {
  // Las credenciales sólo entran al SDK del servidor.
  cloudinary.config({ cloud_name: config.CLOUDINARY_CLOUD_NAME, api_key: config.CLOUDINARY_API_KEY, api_secret: config.CLOUDINARY_API_SECRET, secure: true });
  const ready = () => {
    if (!config.CLOUDINARY_CLOUD_NAME || !config.CLOUDINARY_API_KEY || !config.CLOUDINARY_API_SECRET) throw failure(503, 'Las imágenes todavía no están configuradas en el servidor.');
  };
  return {
    configured: Boolean(config.CLOUDINARY_CLOUD_NAME && config.CLOUDINARY_API_KEY && config.CLOUDINARY_API_SECRET),
    async upload(buffer, publicId) {
      ready();
      return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream({ public_id: publicId, resource_type: 'image', overwrite: false, timeout: 30000 }, (error, result) => {
          if (error) return reject(failure(502, 'No se pudo subir la imagen. Intenta de nuevo.'));
          resolve({ publicId, url: result.secure_url });
        });
        stream.on('error', () => reject(failure(502, 'No se pudo subir la imagen. Intenta de nuevo.')));
        stream.end(buffer);
      });
    },
    async destroy(publicId) {
      ready();
      const result = await cloudinary.uploader.destroy(publicId, { resource_type: 'image', invalidate: true, timeout: 10000 });
      if (!['ok', 'not found'].includes(result.result)) throw failure(502, 'La limpieza de imágenes sigue pendiente.');
    },
  };
}
```
{% endraw %}

### `server/src/media-repository.js`

La adquisición del bloqueo es atómica en MongoDB. Cada cambio comprueba token y vencimiento; la liberación también comprueba el token. No se necesita una transacción de varias colecciones.

<!-- archivo: server/src/media-repository.js -->
{% raw %}
```js
import { Gunpla } from './gunpla.js';

// El bloqueo y el diario viven en el mismo documento: no requieren transacciones.
export const mediaRepository = {
  async acquire(owner, id, token, now, lease) {
    return Gunpla.findOneAndUpdate({ _id: id, ...(owner ? { owner, deleted: { $ne: true } } : {}), $or: [{ 'mediaLock.until': { $exists: false } }, { 'mediaLock.until': { $lte: new Date(now) } }] }, { $set: { mediaLock: { token, until: new Date(now + lease) } } }, { returnDocument: 'after' }).lean();
  },
  async exists(owner, id) { return Boolean(await Gunpla.exists({ _id: id, owner, deleted: { $ne: true } })); },
  async change(id, token, update) {
    const result = await Gunpla.updateOne({ _id: id, 'mediaLock.token': token, 'mediaLock.until': { $gt: new Date() } }, update);
    if (!result.matchedCount) throw Object.assign(new Error('La operación perdió su bloqueo. Recarga el detalle.'), { status: 409, expose: true });
  },
  async release(id, token) { await Gunpla.updateOne({ _id: id, 'mediaLock.token': token }, { $unset: { mediaLock: 1 } }); },
  async purge(id, token) { await Gunpla.deleteOne({ _id: id, 'mediaLock.token': token, deleted: true, mediaJobs: { $size: 0 } }); },
  async candidates(ids) { return Gunpla.find({ ...(ids ? { _id: { $in: ids } } : {}), $expr: { $gt: [{ $size: { $setDifference: [{ $ifNull: ['$mediaJobs.publicId', []] }, { $cond: ['$deleted', [], { $concatArrays: [[{ $ifNull: ['$cover.publicId', ''] }], { $ifNull: ['$gallery.publicId', []] }] }] }] } }, 0] } }).select('_id').limit(100).lean(); },
};
```
{% endraw %}

### `server/src/media-service.js`

El diario se escribe antes de la llamada externa. Una tarea incierta se vuelve a borrar durante al menos 24 h. Las imágenes aún vinculadas jamás se eliminan. Se intenta un borrado por registro y pasada; los demás conservan seguimiento. Un Gunpla eliminado se oculta de inmediato y se purga al terminar la limpieza.

<!-- archivo: server/src/media-service.js -->
{% raw %}
```js
import { randomUUID } from 'node:crypto';
import { failure } from './media-input.js';
const LEASE = 5 * 60 * 1000;
const UNCERTAIN = 24 * 60 * 60 * 1000;
export function mediaService({ repository, gunpla, provider, now = Date.now }) {
  async function locked(owner, id, action) {
    const token = randomUUID();
    const doc = await repository.acquire(owner, id, token, now(), LEASE);
    if (!doc) {
      if (owner && !await repository.exists(owner, id)) throw failure(404, 'Gunpla no encontrado.');
      throw failure(409, 'Hay otra operación de imágenes en curso. Intenta de nuevo.');
    }
    doc.gallery ||= []; doc.mediaJobs ||= [];
    const change = (update) => repository.change(id, token, update);
    try { return await action(doc, change, token); }
    finally { await repository.release(id, token); }
  }
  async function cleanup(doc, change, token) {
    const attached = new Set(doc.deleted ? [] : [doc.cover?.publicId, ...(doc.gallery || []).map((image) => image.publicId)]);
    let pending = false, attempted = false;
    for (const job of doc.mediaJobs || []) {
      if (attached.has(job.publicId)) continue;
      if (attempted) { pending = true; continue; }
      attempted = true;
      try {
        await provider.destroy(job.publicId);
        // Si el proceso cayó o hubo un timeout, repetir durante 24 h por posibles respuestas tardías.
        if (job.settled || now() - new Date(job.createdAt).getTime() >= UNCERTAIN) {
          await change({ $pull: { mediaJobs: { publicId: job.publicId } } });
        } else pending = true;
      } catch { pending = true; }
    }
    if (doc.deleted && !pending) await repository.purge(String(doc._id), token);
    return pending;
  }
  return {
    async owned(owner, id) { return gunpla.get(owner, id); },
    async upload(owner, id, kind, buffer) {
      if (provider.configured === false) throw failure(503, 'Las imágenes todavía no están configuradas en el servidor.');
      return locked(owner, id, async (doc, change, token) => {
        if (kind === 'gallery' && doc.gallery.length >= 8) throw failure(409, 'La galería admite hasta ocho imágenes.');
        if (doc.mediaJobs.length >= 32) throw failure(503, 'Hay limpiezas pendientes. Intenta de nuevo cuando se recupere el servicio.');
        const publicId = `gpb/${id}/${randomUUID()}`;
        const job = { publicId, createdAt: new Date(now()), settled: false };
        // Registrar antes de llamar a Cloudinary: también cubre caídas del proceso.
        await change({ $push: { mediaJobs: job } });
        doc.mediaJobs.push(job);
        let image;
        try { image = await provider.upload(buffer, publicId); }
        catch { throw failure(502, 'No se pudo subir la imagen. La portada anterior se conserva; la limpieza se reintentará.'); }
        const images = kind === 'cover' ? { cover: image } : { gallery: [...doc.gallery, image] };
        job.settled = true;
        await change({ $set: { ...images, mediaJobs: doc.mediaJobs } });
        Object.assign(doc, images);
        const cleanupPending = await cleanup(doc, change, token);
        return { gunpla: await gunpla.get(owner, id), cleanupPending };
      });
    },
    async erase(owner, id, kind, publicId) {
      return locked(owner, id, async (doc, change, token) => {
        const images = kind === 'cover' ? { cover: null } : { gallery: doc.gallery.filter((image) => image.publicId !== publicId) };
        if (kind === 'gallery' && images.gallery.length === doc.gallery.length) throw failure(404, 'Imagen no encontrada.');
        await change({ $set: images }); Object.assign(doc, images);
        const cleanupPending = await cleanup(doc, change, token);
        return { gunpla: await gunpla.get(owner, id), cleanupPending };
      });
    },
    async remove(owner, id) {
      if (!await gunpla.get(owner, id)) return false;
      return locked(owner, id, async (doc, change, token) => {
        await change({ $set: { deleted: true } }); doc.deleted = true;
        await cleanup(doc, change, token);
        return true;
      });
    },
    async reconcile() {
      let pending = 0;
      for (const doc of await repository.candidates()) {
        try { if (await locked(null, String(doc._id), (item, change, token) => cleanup(item, change, token))) pending++; }
        catch { pending++; }
      }
      return { pending };
    },
  };
}
```
{% endraw %}

### `server/src/media-routes.js`

Sesión y CSRF provienen de createApp. La propiedad se revisa antes de Multer y otra vez al adquirir el bloqueo. Un archivo por solicitud, sin campos extra y hasta 5 MiB; dos cargas por proceso hasta terminar, incluso ante desconexión del cliente.

<!-- archivo: server/src/media-routes.js -->
{% raw %}
```js
import { Router } from 'express';
import multer from 'multer';
import { MAX_BYTES, failure, validateImage } from './media-input.js';
const idPattern = /^[a-fA-F0-9]{24}$/;
export function mediaRoutes({ media }) {
  const router = Router();
  const receive = multer({ storage: multer.memoryStorage(), limits: { fileSize: MAX_BYTES, files: 1, fields: 0, parts: 1, fieldNameSize: 20 } }).single('image');
  let active = 0;
  // Rechazar antes de reservar buffers. Máximo dos cargas por proceso, un archivo por solicitud.
  async function upload(req, res, kind) {
    if (active >= 2) throw failure(429, 'Hay demasiadas cargas simultáneas. Intenta de nuevo.');
    active++;
    try {
      await new Promise((resolve, reject) => receive(req, res, (error) => error ? reject(error) : resolve()));
      const buffer = await validateImage(req.file);
      res.status(201).json(await media.upload(String(req.user._id), req.params.id, kind, buffer));
    } finally { active--; }
  }
  async function owned(req, _res, next) {
    if (!idPattern.test(req.params.id)) throw failure(400, 'Identificador inválido.');
    if (!await media.owned(String(req.user._id), req.params.id)) throw failure(404, 'Gunpla no encontrado.');
    next();
  }
  for (const kind of ['cover', 'gallery']) {
    router.post(`/gunpla/:id/${kind}`, owned, (req, res) => upload(req, res, kind));
  }
  router.delete('/gunpla/:id/cover', owned, async (req, res) => res.json(await media.erase(String(req.user._id), req.params.id, 'cover')));
  router.delete('/gunpla/:id/gallery/:publicId', owned, async (req, res) => res.json(await media.erase(String(req.user._id), req.params.id, 'gallery', req.params.publicId)));
  router.use((error, _req, _res, next) => {
    if (error instanceof multer.MulterError) return next(failure(error.code === 'LIMIT_FILE_SIZE' ? 413 : 400, 'Envía una sola imagen JPG, PNG o WebP, sin campos adicionales y de hasta 5 MB.'));
    next(error);
  });
  return router;
}
```
{% endraw %}

## 5. Conectar el servicio y su recuperación

El resto de autenticación y sesiones se conserva. La recuperación se ejecuta al arrancar y cada minuto, sin superponer pasadas. Un timeout del navegador no revierte un cambio ya confirmado: recarga el detalle antes de decidir si repites la acción.

### `server/src/config.js`

Las tres variables de Cloudinary son opcionales como conjunto; una configuración parcial impide iniciar. MongoDB y el secreto de sesión siguen siendo obligatorios.

<!-- archivo: server/src/config.js -->
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
    CLOUDINARY_CLOUD_NAME: z.string().regex(/^[a-zA-Z0-9_-]+$/).optional(),
    CLOUDINARY_API_KEY: z.string().min(1).optional(),
    CLOUDINARY_API_SECRET: z.string().min(1).optional(),
  }).parse(env);
  const cloud = [values.CLOUDINARY_CLOUD_NAME, values.CLOUDINARY_API_KEY, values.CLOUDINARY_API_SECRET];
  if (cloud.some(Boolean) && !cloud.every(Boolean)) throw new Error('Completa las tres variables de Cloudinary.');
  const origin = new URL(values.WEB_ORIGIN);
  if (origin.origin !== values.WEB_ORIGIN || (values.NODE_ENV === 'production' && origin.protocol !== 'https:')) {
    throw new Error('WEB_ORIGIN debe ser un origen exacto; HTTPS en producción.');
  }
  return values;
}
```
{% endraw %}

### `server/src/app.js`

Incorpora las rutas protegidas de imágenes y errores públicos controlados. No devuelve mensajes internos del proveedor ni expone errores de análisis de JSON.

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
import { mediaRoutes } from './media-routes.js';
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
export function createApp({ config, store, users, catalogs, gunpla, media, now = Date.now, idleMs = IDLE_MS, absoluteMs = ABSOLUTE_MS, authLimit = 20 }) {
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
  if (media) app.use('/api', protectedRoute, mediaRoutes({ media }));
  if (catalogs && gunpla) app.use('/api', protectedRoute, collectionRoutes({ catalogs, gunpla, media }));
  app.use('/api', (_req, res) => res.status(404).json({ message: 'Ruta no encontrada.' }));
  app.use((error, _req, res, _next) => {
    if (error.expose && error.status && error.status >= 400 && error.status < 600) return res.status(error.status).json({ message: error.message });
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

Construye el proveedor real, el repositorio y el servicio; programa la recuperación y detiene el temporizador al cerrar.

<!-- archivo: server/src/index.js -->
{% raw %}
```js
import mongoose from 'mongoose';
import MongoStore from 'connect-mongo';
import { readConfig } from './config.js';
import { users, User } from './users.js';
import { catalogs, Grade, Scale } from './catalogs.js';
import { gunpla, Gunpla } from './gunpla.js';
import { mediaRepository } from './media-repository.js';
import { mediaService } from './media-service.js';
import { cloudinaryProvider } from './cloudinary.js';
import { createApp } from './app.js';

try {
  const config = readConfig();
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  await Promise.all([User.init(), Grade.init(), Scale.init(), Gunpla.init()]); // Esperar los índices únicos antes de aceptar registros.
  const store = MongoStore.create({ client: mongoose.connection.getClient(), collectionName: 'sessions', ttl: 7 * 24 * 60 * 60, touchAfter: 0 });
  store.on('error', () => console.error('No se pudo acceder al almacén de sesiones.'));
  const media = mediaService({ repository: mediaRepository, gunpla, provider: cloudinaryProvider(config) });
  let cleaning = false;
  async function clean() {
    if (cleaning) return;
    cleaning = true;
    try { const result = await media.reconcile(); if (result.pending) console.warn('Hay limpiezas de imágenes pendientes; se reintentarán.'); }
    catch { console.warn('No se pudo completar la limpieza de imágenes; se reintentará.'); }
    finally { cleaning = false; }
  }
  const timer = setInterval(clean, 60000); timer.unref();
  void clean();
  const server = createApp({ config, store, users, catalogs, gunpla, media }).listen(config.PORT, config.NODE_ENV === 'production' ? '0.0.0.0' : '127.0.0.1', () => console.log(`API GPB disponible en el puerto ${config.PORT}`));
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => {
    clearInterval(timer);
    server.close(async () => { await mongoose.disconnect(); process.exit(0); });
  });
} catch {
  console.error('No se pudo iniciar GPB. Revisa las variables locales y la conexión con Atlas.');
  process.exitCode = 1;
}
```
{% endraw %}

### `server/scripts/reconcile-images.js`

Una pasada manual procesa hasta cien registros. Código 0 indica que esa pasada no dejó tareas pendientes; 2 indica que hay que repetir. No demuestra que una CDN haya retirado todas sus copias.

<!-- archivo: server/scripts/reconcile-images.js -->
{% raw %}
```js
import mongoose from 'mongoose';
import { readConfig } from '../src/config.js';
import { gunpla } from '../src/gunpla.js';
import { mediaRepository } from '../src/media-repository.js';
import { mediaService } from '../src/media-service.js';
import { cloudinaryProvider } from '../src/cloudinary.js';
try {
  const config = readConfig();
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  const media = mediaService({ repository: mediaRepository, gunpla, provider: cloudinaryProvider(config) });
  const { pending } = await media.reconcile();
  console.log(`Pasada de limpieza terminada. Registros con tareas pendientes en esta pasada: ${pending}.`);
  if (pending) process.exitCode = 2;
} catch { console.error('No se pudo completar la limpieza. Revisa la configuración y la conectividad.'); process.exitCode = 1; }
finally { await mongoose.disconnect(); }
```
{% endraw %}

## 6. Completar React

Las imágenes se administran después de guardar un Gunpla, desde su detalle. Así cada operación tiene un propietario y un identificador ya existentes. El formulario compartido conserva la edición de datos, etiquetas y video. Los estados de carga impiden duplicar acciones y cada eliminación pide confirmación.

### 6.1. Pantallas de la app y recorrido CRUD

Este recorrido muestra la interfaz de esta entrega en modo oscuro. Se utiliza una cuenta ficticia en el entorno local de pruebas y un recurso gráfico de demostración para la portada y la galería. Selecciona una captura para verla a tamaño completo.


**Colección en tarjetas**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-crud.png' | relative_url }}" alt="GPB en modo oscuro: colección en tarjetas." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>Los modelos muestran nombre, grado, escala y estado. La portada subida convive con la portada de reemplazo de los registros sin imagen. <a href="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-crud.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Crear un Gunpla**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/formulario-crear.png' | relative_url }}" alt="GPB en modo oscuro: crear un gunpla." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>El formulario reúne datos del modelo, opciones de grado y escala consultadas desde la API, estado, etiquetas y enlace opcional de YouTube. Las fotografías se administran después de guardar. <a href="{{ '/assets/images/gpb/guia-03/app-crud/formulario-crear.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Consultar el detalle**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/detalle-crud.png' | relative_url }}" alt="GPB en modo oscuro: consultar el detalle." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>Después de crear el registro, el detalle permite consultar sus datos, etiquetas, portada y galería, y acceder a la edición o eliminación. <a href="{{ '/assets/images/gpb/guia-03/app-crud/detalle-crud.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Administrar portada y galería**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/gestion-imagenes.png' | relative_url }}" alt="GPB en modo oscuro: administrar portada y galería." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>Desde Fotografías se puede subir o sustituir la portada, agregar imágenes a la galería y solicitar su eliminación con confirmación. <a href="{{ '/assets/images/gpb/guia-03/app-crud/gestion-imagenes.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Editar el registro**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/formulario-editar.png' | relative_url }}" alt="GPB en modo oscuro: editar el registro." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>El mismo formulario recupera los valores existentes. En este ejemplo se cambia el estado a Armado y se actualizan las notas y etiquetas. <a href="{{ '/assets/images/gpb/guia-03/app-crud/formulario-editar.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Confirmar la eliminación**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/confirmar-eliminacion.png' | relative_url }}" alt="GPB en modo oscuro: confirmar la eliminación." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>La aplicación identifica el Gunpla y permite confirmar o cancelar antes de eliminarlo. <a href="{{ '/assets/images/gpb/guia-03/app-crud/confirmar-eliminacion.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Comprobar el resultado de eliminar**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-eliminada.png' | relative_url }}" alt="GPB en modo oscuro: comprobar el resultado de eliminar." loading="lazy" style="display: block; width: 100%; max-width: 100%; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>Tras confirmar, se vuelve a la colección, se muestra el mensaje de éxito y el registro deja de aparecer. <a href="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-eliminada.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>


**Consultar la colección en móvil**

<figure style="margin: 1.5rem 0;">
  <img src="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-crud-movil.png' | relative_url }}" alt="GPB en modo oscuro: consultar la colección en móvil." loading="lazy" style="display: block; width: 100%; max-width: 390px; height: auto; margin: 0 auto; border-radius: 12px;" />
  <figcaption>Las tarjetas se adaptan a una sola columna y mantienen las acciones de navegación disponibles. <a href="{{ '/assets/images/gpb/guia-03/app-crud/coleccion-crud-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir captura completa</a></figcaption>
</figure>

### `client/src/lib/api.js`

FormData no debe recibir Content-Type manual: fetch aporta el boundary. Se conserva el token CSRF y se amplía a 60 s la espera de subida.

<!-- archivo: client/src/lib/api.js -->
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
      signal: AbortSignal.timeout(body instanceof FormData ? 60000 : 20000),
      headers: {
        ...(body && !(body instanceof FormData) ? { "Content-Type": "application/json" } : {}),
        ...(method !== "GET" ? { "X-CSRF-Token": csrfToken } : {}),
      },
      body: body instanceof FormData ? body : body ? JSON.stringify(body) : undefined,
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

### `client/src/collection/MediaPanel.jsx`

Formularios separados para portada y galería, mensajes de resultado, limpieza pendiente y confirmación. TagsInput recorta espacios y evita valores vacíos y duplicados. El botón Agregar etiqueta incorpora el texto antes de guardar.

<!-- archivo: client/src/collection/MediaPanel.jsx -->
{% raw %}
```jsx
import { useState } from "react";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";

export function MediaPanel({ item, onChange }) {
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [confirmation, setConfirmation] = useState(null);
  async function perform(path, body, method = "POST") {
    setBusy(true);
    setError("");
    setMessage("");
    try {
      const result = await api(`/gunpla/${item.id}${path}`, { method, body });
      onChange(result.gunpla);
      setConfirmation(null);
      setMessage(
        result.cleanupPending
          ? "Cambio guardado. La limpieza anterior sigue pendiente y se reintentará."
          : "Imágenes actualizadas.",
      );
    } catch (failure) {
      setError(failure.message);
    } finally {
      setBusy(false);
    }
  }
  function upload(event, kind) {
    event.preventDefault();
    const form = event.currentTarget;
    const body = new FormData(form);
    const file = body.get("image");
    if (!file?.size || file.size > 5 * 1024 * 1024) {
      setError("Selecciona una imagen de hasta 5 MB.");
      return;
    }
    void perform(`/${kind}`, body).then(() => form.reset());
  }
  return (
    <section className="media-panel" aria-labelledby="images-title">
      <h2 id="images-title">Fotografías</h2>
      <p className="muted">
        Una portada y hasta ocho imágenes de galería. JPG, PNG o WebP; máximo 5 MB por archivo. Las
        imágenes subidas tienen una URL pública: evita fotografías privadas.
      </p>
      <div className="media-forms">
        {[
          ["cover", item.cover ? "Sustituir portada" : "Subir portada"],
          ["gallery", "Agregar a galería"],
        ].map(([kind, label]) => (
          <form key={kind} onSubmit={(event) => upload(event, kind)}>
            <fieldset disabled={busy || (kind === "gallery" && item.gallery.length >= 8)}>
              <label htmlFor={`upload-${kind}`}>Archivo para {label.toLowerCase()}</label>
              <input
                id={`upload-${kind}`}
                name="image"
                type="file"
                required
                accept="image/jpeg,image/png,image/webp"
              />
              <Button type="submit">{label}</Button>
            </fieldset>
          </form>
        ))}
      </div>
      {item.cover && (
        <Button
          variant="outline"
          disabled={busy}
          onClick={() => setConfirmation({ path: "/cover", label: "la portada" })}
        >
          Quitar portada
        </Button>
      )}
      <h3>Galería ({item.gallery.length}/8)</h3>
      {!item.gallery.length && <p className="muted">Todavía no hay fotografías adicionales.</p>}
      <div className="gallery-grid">
        {item.gallery.map((image, index) => (
          <figure key={image.publicId}>
            <a href={image.url} target="_blank" rel="noreferrer">
              <img src={image.url} alt={`Fotografía ${index + 1} de ${item.name}`} loading="lazy" />
            </a>
            <figcaption>
              <Button
                variant="outline"
                disabled={busy}
                onClick={() =>
                  setConfirmation({
                    path: `/gallery/${encodeURIComponent(image.publicId)}`,
                    label: `la fotografía ${index + 1}`,
                  })
                }
              >
                Eliminar fotografía {index + 1}
              </Button>
            </figcaption>
          </figure>
        ))}
      </div>
      {confirmation && (
        <section className="delete-confirmation" aria-label="Confirmar eliminación de imagen">
          <p>¿Eliminar {confirmation.label}?</p>
          <div className="actions">
            <Button
              variant="destructive"
              disabled={busy}
              onClick={() => perform(confirmation.path, undefined, "DELETE")}
            >
              Confirmar imagen
            </Button>
            <Button variant="outline" disabled={busy} onClick={() => setConfirmation(null)}>
              Cancelar imagen
            </Button>
          </div>
        </section>
      )}
      {busy && <p role="status">Procesando imagen… Espera la confirmación antes de salir.</p>}
      {message && (
        <p className="success" role="status">
          {message}
        </p>
      )}
      {error && (
        <p className="error" role="alert">
          {error}
        </p>
      )}
    </section>
  );
}

export function TagsInput({ initial = [] }) {
  const [tags, setTags] = useState(initial);
  const [draft, setDraft] = useState("");
  function add() {
    const value = draft.trim();
    if (!value || tags.length >= 20) return;
    if (!tags.some((tag) => tag.toLocaleLowerCase("es") === value.toLocaleLowerCase("es")))
      setTags([...tags, value]);
    setDraft("");
  }
  return (
    <div className="field">
      <label htmlFor="tag-draft">Etiquetas (opcional)</label>
      <div className="actions">
        <input
          id="tag-draft"
          value={draft}
          maxLength={30}
          onChange={(event) => setDraft(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === "Enter") {
              event.preventDefault();
              add();
            }
          }}
        />
        <Button
          type="button"
          variant="outline"
          disabled={!draft.trim() || tags.length >= 20}
          onClick={add}
        >
          Agregar etiqueta
        </Button>
      </div>
      <small className="muted">
        Hasta 20 etiquetas de 30 caracteres. Pulsa Agregar etiqueta antes de guardar.
      </small>
      <div className="tags">
        {tags.map((tag) => (
          <span key={tag}>
            <input type="hidden" name="tags" value={tag} />
            {tag}{" "}
            <button
              type="button"
              aria-label={`Quitar etiqueta ${tag}`}
              onClick={() => setTags(tags.filter((value) => value !== tag))}
            >
              ×
            </button>
          </span>
        ))}
      </div>
    </div>
  );
}
```
{% endraw %}

### `client/src/collection/Collection.jsx`

Las tarjetas usan la portada; el detalle muestra galería, etiquetas y un iframe construido desde el identificador. La portada de reemplazo también cubre errores de descarga.

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

import { MediaPanel, TagsInput } from "./MediaPanel";

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
    setData: (data) => setResult({ path, data }),
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
export function Cover({ image, name }) {
  const [failedUrl, setFailedUrl] = useState("");
  if (image?.url && failedUrl !== image.url)
    return (
      <img
        className="gunpla-cover actual-cover"
        src={image.url}
        alt={`Portada de ${name}`}
        onError={() => setFailedUrl(image.url)}
      />
    );
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
                  <Cover image={item.cover} name={item.name} />
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
        <Cover image={item.cover} name={item.name} />
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
      <div className="tags">
        {item.tags?.map((tag) => (
          <span key={tag}>{tag}</span>
        ))}
      </div>
      <MediaPanel
        item={{ ...item, gallery: item.gallery || [] }}
        onChange={(gunpla) => resource.setData({ gunpla })}
      />
      {item.youtubeId && (
        <section>
          <h2>Video del modelo</h2>
          <iframe
            className="youtube-player"
            title={`Video de ${item.name}`}
            src={`https://www.youtube-nocookie.com/embed/${item.youtubeId}`}
            loading="lazy"
            referrerPolicy="strict-origin-when-cross-origin"
            allow="encrypted-media; picture-in-picture"
            allowFullScreen
          />
        </section>
      )}
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
    const form = new FormData(event.currentTarget);
    const body = { ...Object.fromEntries(form), tags: form.getAll("tags") };
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
          <TagsInput initial={initial?.tags || []} />
          <div className="field">
            <Label htmlFor="youtubeUrl">Enlace de YouTube (opcional)</Label>
            <Input
              id="youtubeUrl"
              name="youtubeUrl"
              type="url"
              maxLength={300}
              placeholder="https://www.youtube.com/watch?v=…"
              defaultValue={
                initial?.youtubeId ? `https://www.youtube.com/watch?v=${initial.youtubeId}` : ""
              }
            />
            <small className="muted">
              Enlace HTTPS de youtube.com o youtu.be; no pegues código HTML.
            </small>
          </div>
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

### `client/src/index.css`

Conserva el CSS anterior y añade estilos oscuros y adaptables para imágenes, etiquetas y video. El iframe conserva al menos 200 px de alto.

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

/* Guía 3: imágenes y detalle completo, siempre en modo oscuro. */
.actual-cover {
  width: 100%;
  object-fit: cover;
}
.media-panel {
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #334155;
}
.media-forms {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}
.media-forms fieldset {
  display: grid;
  gap: 0.8rem;
  min-width: 0;
  padding: 1rem;
  border: 1px solid #334155;
  border-radius: 0.75rem;
}
.media-forms input {
  width: 100%;
  min-width: 0;
}
.gallery-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
}
.gallery-grid figure {
  margin: 0;
  min-width: 0;
}
.gallery-grid img {
  width: 100%;
  aspect-ratio: 4/3;
  object-fit: cover;
  border-radius: 0.75rem;
  background: #172033;
}
.gallery-grid figcaption {
  padding-top: 0.5rem;
}
.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin: 1rem 0;
}
.tags span {
  padding: 0.35rem 0.75rem;
  border: 1px solid #475569;
  border-radius: 999px;
  overflow-wrap: anywhere;
}
.tags button {
  cursor: pointer;
  margin-left: 0.4rem;
}
.youtube-player {
  width: 100%;
  aspect-ratio: 16/9;
  border: 0;
  border-radius: 0.75rem;
  margin-bottom: 2rem;
}
@media (max-width: 640px) {
  .media-forms,
  .gallery-grid {
    grid-template-columns: 1fr;
  }
}
.media-panel h2,
.media-panel + section h2 {
  font-size: 1.4rem;
  font-weight: 650;
  margin: 1rem 0 0.65rem;
}
.media-panel h3 {
  font-size: 1.1rem;
  margin: 1.5rem 0 0.75rem;
}
.media-panel {
  margin-bottom: 2rem;
}
.youtube-player {
  min-height: 200px;
  background: #0b1220;
}
```
{% endraw %}

## 7. Pruebas y adaptadores locales

El proveedor simulado permite forzar fallos sin credenciales ni datos externos. No sustituye las verificaciones reales. Las pruebas heredadas de autenticación y colección deben seguir pasando.

### `server/test/helpers.js`

El cliente de pruebas acepta FormData sin convertirlo a JSON.

<!-- archivo: server/test/helpers.js -->
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
        const response = await fetch(base + '/api' + path, { method, headers: { cookie, origin: config.WEB_ORIGIN, ...(body && !(body instanceof FormData) ? { 'content-type': 'application/json' } : {}), 'x-csrf-token': csrf, ...headers }, body: body instanceof FormData ? body : body ? JSON.stringify(body) : undefined });
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

### `server/test/collection-helpers.js`

El adaptador hereda los campos nuevos y respeta la eliminación lógica. Sólo se usa en pruebas.

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
    records,
    catalogs: { async list() { return { grades, scales }; }, async valid(g, s) { return grades.some((x) => x.id === g) && scales.some((x) => x.id === s); } },
    gunpla: {
      async list(owner, page) {
        const all = [...records.values()].filter((doc) => doc.owner === owner && !doc.deleted).reverse();
        return { items: all.slice((page - 1) * 12, page * 12).map(view), total: all.length, page, pageSize: 12, pages: Math.max(1, Math.ceil(all.length / 12)) };
      },
      async get(owner, id) { const doc = records.get(id); return doc?.owner === owner && !doc.deleted ? view(doc) : null; },
      async create(owner, data) { const id = hex(sequence++); const doc = { cover: null, gallery: [], mediaJobs: [], ...data, owner, id, _id: id, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }; records.set(id, doc); return view(doc); },
      async update(owner, id, data) { const doc = records.get(id); if (doc?.owner !== owner || doc.deleted) return null; Object.assign(doc, data, { updatedAt: new Date().toISOString() }); return view(doc); },
      async remove(owner, id) { return records.get(id)?.owner === owner && records.delete(id); },
    },
  };
}
```
{% endraw %}

### `server/test/media-helpers.js`

Repositorio y proveedor de memoria con fallos inyectables para probar consistencia y concurrencia.

<!-- archivo: server/test/media-helpers.js -->
{% raw %}
```js
import { mediaService } from '../src/media-service.js';
import { memoryCollection } from './collection-helpers.js';
import { failure } from '../src/media-input.js';
export function memoryMedia() {
  const collection = memoryCollection();
  const { records } = collection;
  const files = new Map();
  const provider = {
    failUpload: false, failDestroy: false, wait: null,
    async upload(buffer, publicId) {
      if (this.wait) await this.wait;
      files.set(publicId, buffer);
      if (this.failUpload) throw new Error('timeout después de aceptar');
      return { publicId, url: `https://res.cloudinary.com/demo/image/upload/${publicId}.webp` };
    },
    async destroy(id) { if (this.failDestroy) throw new Error('Proveedor no disponible'); files.delete(id); },
  };
  const repository = {
    failCommit: false,
    async acquire(owner, id, token, now, lease) {
      const doc = records.get(id);
      if (!doc || (owner && (doc.owner !== owner || doc.deleted)) || doc.mediaLock?.until > now) return null;
      doc.mediaLock = { token, until: now + lease };
      return structuredClone(doc);
    },
    async exists(owner, id) { const doc = records.get(id); return doc?.owner === owner && !doc.deleted; },
    async change(id, token, update) {
      const doc = records.get(id);
      if (doc?.mediaLock?.token !== token || doc.mediaLock.until <= Date.now()) throw failure(409, 'Bloqueo perdido');
      if (this.failCommit && update.$set?.mediaJobs) throw new Error('MongoDB no disponible');
      if (update.$set) Object.assign(doc, structuredClone(update.$set));
      if (update.$push) doc.mediaJobs.push(structuredClone(update.$push.mediaJobs));
      if (update.$pull) doc.mediaJobs = doc.mediaJobs.filter((job) => job.publicId !== update.$pull.mediaJobs.publicId);
    },
    async release(id, token) { const doc = records.get(id); if (doc?.mediaLock?.token === token) delete doc.mediaLock; },
    async purge(id, token) { const doc = records.get(id); if (doc?.mediaLock?.token === token && doc.deleted && !doc.mediaJobs.length) records.delete(id); },
    async candidates() { return [...records.values()].filter((doc) => doc.mediaJobs.some((job) => doc.deleted || ![doc.cover?.publicId, ...doc.gallery.map((image) => image.publicId)].includes(job.publicId))); },
  };
  return { ...collection, provider, files, repository, media: mediaService({ repository, gunpla: collection.gunpla, provider }) };
}
```
{% endraw %}

### `server/test/media.test.js`

Cubre propiedad, sesión, CSRF, archivos falsos o dañados, límites, sustitución, galería, eliminación, fallos de proveedor y base de datos, cargas concurrentes, etiquetas y YouTube.

<!-- archivo: server/test/media.test.js -->
{% raw %}
```js
import test from 'node:test';
import assert from 'node:assert/strict';
import sharp from 'sharp';
import { fixture } from './helpers.js';
import { memoryMedia } from './media-helpers.js';
import { youtubeId } from '../src/media-input.js';
const png = await sharp({ create: { width: 64, height: 64, channels: 3, background: '#123456' } }).png().toBuffer();
function form(buffer = png, name = 'modelo.png', type = 'image/png') { const body = new FormData(); body.append('image', new Blob([buffer], { type }), name); return body; }
async function setup(t) {
  const adapters = memoryMedia(), f = await fixture(adapters); t.after(f.close);
  async function account(suffix) { const c = f.client(); await c.call('/auth/csrf'); await c.call('/auth/register', { method: 'POST', body: { username: `imagenes_${suffix}`, email: `${suffix}@example.com`, password: 'Clave de prueba 123!' } }); return c; }
  const a = await account('a'), b = await account('b');
  const { data } = await a.call('/catalogs');
  const input = { name: 'Modelo de imágenes', grade: data.grades[0].id, scale: data.scales[0].id };
  const created = await a.call('/gunpla', { method: 'POST', body: input });
  return { ...f, ...adapters, a, b, input, id: created.data.gunpla.id };
}
test('portada: subida real decodificada, sustitución y eliminación limpian el proveedor', async (t) => {
  const f = await setup(t); const path = `/gunpla/${f.id}/cover`;
  const first = await f.a.call(path, { method: 'POST', body: form() });
  assert.equal(first.status, 201); const old = first.data.gunpla.cover.publicId;
  assert.equal((await sharp(f.files.get(old)).metadata()).format, 'webp');
  const second = await f.a.call(path, { method: 'POST', body: form() });
  assert.equal(second.status, 201); assert.equal(f.files.has(old), false); assert.equal(f.files.size, 1);
  assert.equal((await f.a.call(path, { method: 'DELETE' })).data.gunpla.cover, null); assert.equal(f.files.size, 0);
});
test('sesión, CSRF y propiedad se comprueban antes de procesar archivos o eliminaciones', async (t) => {
  const f = await setup(t);
  for (const kind of ['cover', 'gallery']) {
    const path = `/gunpla/${f.id}/${kind}`;
    assert.equal((await f.b.call(path, { method: 'POST', body: form() })).status, 404);
    assert.equal((await f.a.call(path, { method: 'POST', body: form(), headers: { 'x-csrf-token': '' } })).status, 403);
    assert.equal((await f.a.call(path, { method: 'POST', body: form(), headers: { origin: 'https://ajeno.example' } })).status, 403);
    const guest = f.client(); await guest.call('/auth/csrf');
    assert.equal((await guest.call(path, { method: 'POST', body: form() })).status, 401);
  }
  const uploaded = await f.a.call(`/gunpla/${f.id}/gallery`, { method: 'POST', body: form() });
  const image = uploaded.data.gunpla.gallery[0];
  for (const path of [`/gunpla/${f.id}/cover`, `/gunpla/${f.id}/gallery/${encodeURIComponent(image.publicId)}`]) {
    assert.equal((await f.b.call(path, { method: 'DELETE' })).status, 404);
    assert.equal((await f.a.call(path, { method: 'DELETE', headers: { 'x-csrf-token': '' } })).status, 403);
  }
  assert.equal(f.files.size, 1);
});
test('rechaza formatos falsos, dañados, excesos y campos multipart adicionales', async (t) => {
  const f = await setup(t), path = `/gunpla/${f.id}/cover`;
  for (const body of [form(png,'falso.jpg','image/jpeg'), form(Buffer.from('<svg/>')), form(png.subarray(0,20)), form(png,'falso.gif','image/gif'), form(png,'modelo.png','text/plain')]) assert.equal((await f.a.call(path,{method:'POST',body})).status,400);
  assert.equal((await f.a.call(path,{method:'POST',body:form(Buffer.alloc(5*1024*1024+1))})).status,413);
  const extra=form();extra.append('owner','otro');assert.equal((await f.a.call(path,{method:'POST',body:extra})).status,400);
  const multiple=form();multiple.append('image',new Blob([png],{type:'image/png'}),'otro.png');assert.equal((await f.a.call(path,{method:'POST',body:multiple})).status,400);
  for (const [format,type] of [['jpeg','image/jpeg'],['webp','image/webp']]) {
    const buffer=await sharp(png)[format]().toBuffer();assert.equal((await f.a.call(path,{method:'POST',body:form(buffer,`modelo.${format==='jpeg'?'jpg':format}`,type)})).status,201);
  }
});
test('galería: ocho imágenes, rechazo de novena, eliminación individual y del Gunpla', async (t) => {
  const f=await setup(t),path=`/gunpla/${f.id}/gallery`;
  let result;for(let i=0;i<8;i++){result=await f.a.call(path,{method:'POST',body:form()});assert.equal(result.status,201);}
  assert.equal((await f.a.call(path,{method:'POST',body:form()})).status,409);
  const image=result.data.gunpla.gallery[0];
  assert.equal((await f.a.call(`${path}/${encodeURIComponent(image.publicId)}`,{method:'DELETE'})).status,200);
  await f.a.call(`/gunpla/${f.id}/cover`,{method:'POST',body:form()});
  assert.equal((await f.a.call(`/gunpla/${f.id}`,{method:'DELETE'})).status,204);
  for(let i=0;i<12;i++)await f.media.reconcile();assert.equal(f.files.size,0);assert.equal(f.records.has(f.id),false);
});
test('fallos parciales: conserva portada, registra incertidumbre y reintenta borrados', async(t)=>{
  const f=await setup(t),path=`/gunpla/${f.id}/cover`;
  const first=await f.a.call(path,{method:'POST',body:form()}),original=first.data.gunpla.cover.publicId;
  f.provider.failUpload=true;assert.equal((await f.a.call(path,{method:'POST',body:form()})).status,502);
  assert.equal((await f.a.call(`/gunpla/${f.id}`)).data.gunpla.cover.publicId,original);
  assert.equal(f.records.get(f.id).mediaJobs.length,2);
  f.provider.failUpload=false;f.provider.failDestroy=true;
  const second=await f.a.call(path,{method:'POST',body:form()});assert.equal(second.data.cleanupPending,true);
  f.provider.failDestroy=false;await f.media.reconcile();assert.equal(f.files.has(original),false);
  for(const job of f.records.get(f.id).mediaJobs)job.createdAt=new Date(Date.now()-25*60*60*1000);
  await f.media.reconcile();await f.media.reconcile();assert.equal(f.records.get(f.id).mediaJobs.length,1);assert.equal(f.files.size,1);
  f.provider.failDestroy=true;assert.equal((await f.a.call(`/gunpla/${f.id}`,{method:'DELETE'})).status,204);
  assert.equal((await f.a.call(`/gunpla/${f.id}`)).status,404);assert.equal(f.records.get(f.id).deleted,true);
  f.provider.failDestroy=false;for(let i=0;i<12;i++)await f.media.reconcile();assert.equal(f.records.has(f.id),false);assert.equal(f.files.size,0);
});
test('fallo MongoDB tras subir: el diario previo permite recuperar el archivo',async(t)=>{
  const f=await setup(t);f.repository.failCommit=true;
  assert.equal((await f.a.call(`/gunpla/${f.id}/cover`,{method:'POST',body:form()})).status,500);
  assert.equal(f.records.get(f.id).cover,null);assert.equal(f.files.size,1);
  f.repository.failCommit=false;await f.media.reconcile();assert.equal(f.files.size,0);
  assert.equal(f.records.get(f.id).mediaJobs.length,1);
});
test('cargas simultáneas: bloqueo por registro y límite de dos buffers por proceso',async(t)=>{
  const f=await setup(t);let release;f.provider.wait=new Promise(resolve=>{release=resolve;});
  const p1=f.a.call(`/gunpla/${f.id}/cover`,{method:'POST',body:form()});
  while(!f.records.get(f.id).mediaLock) await new Promise(resolve=>setTimeout(resolve,5));
  assert.equal((await f.a.call(`/gunpla/${f.id}/cover`,{method:'POST',body:form()})).status,409);
  const other=(await f.a.call('/gunpla',{method:'POST',body:f.input})).data.gunpla.id;
  const p2=f.a.call(`/gunpla/${other}/cover`,{method:'POST',body:form()});
  while(!f.records.get(other).mediaLock) await new Promise(resolve=>setTimeout(resolve,5));
  assert.equal((await f.a.call(`/gunpla/${other}/gallery`,{method:'POST',body:form()})).status,429);
  release();assert.equal((await p1).status,201);assert.equal((await p2).status,201);
});
test('etiquetas normalizadas y YouTube validado sin HTML ni dominios ajenos',async(t)=>{
  const f=await setup(t);
  const result=await f.a.call(`/gunpla/${f.id}`,{method:'PUT',body:{...f.input,tags:[' Pintado ','pintado','Barnizado'],youtubeUrl:'https://youtu.be/dQw4w9WgXcQ'}});
  assert.deepEqual(result.data.gunpla.tags,['pintado','Barnizado']);assert.equal(result.data.gunpla.youtubeId,'dQw4w9WgXcQ');
  for(const fields of [{tags:[' ']},{tags:['x'.repeat(31)]},{tags:Array(21).fill('x')},{youtubeUrl:'<iframe/>'},{youtubeUrl:'https://youtube.com.evil.test/watch?v=dQw4w9WgXcQ'},{youtubeUrl:'http://youtu.be/dQw4w9WgXcQ'},{youtubeUrl:'https://youtu.be/malo'}]) assert.equal((await f.a.call('/gunpla',{method:'POST',body:{...f.input,...fields}})).status,400);
  assert.equal(youtubeId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),'dQw4w9WgXcQ');
});
test('bloqueo vencido: una subida tardía no reemplaza la portada nueva ni pierde su diario', async (t) => {
  const f = await setup(t); let release;
  f.provider.wait = new Promise(resolve => { release = resolve; });
  const path = `/gunpla/${f.id}/cover`;
  const stale = f.a.call(path, { method: 'POST', body: form() });
  while (!f.records.get(f.id).mediaJobs.length) await new Promise(resolve => setTimeout(resolve, 5));
  f.records.get(f.id).mediaLock.until = Date.now() - 1;
  f.provider.wait = null;
  const current = await f.a.call(path, { method: 'POST', body: form() });
  assert.equal(current.status, 201);
  const currentId = current.data.gunpla.cover.publicId;
  release();
  assert.equal((await stale).status, 409);
  assert.equal((await f.a.call(`/gunpla/${f.id}`)).data.gunpla.cover.publicId, currentId);
  assert.equal(f.files.size, 2);
  await f.media.reconcile();
  assert.equal(f.files.size, 1);
  assert.equal(f.files.has(currentId), true);
  assert.equal(f.records.get(f.id).mediaJobs.length, 2);
});
```
{% endraw %}

### `tests/local-api.js`

La API de transporte utiliza el adaptador de imágenes sólo para pruebas.

<!-- archivo: tests/local-api.js -->
{% raw %}
```js
// Sólo pruebas de transporte; nunca es un sustituto de Atlas en producción.
import session from '../server/node_modules/express-session/index.js';
import { createApp } from '../server/src/app.js';
import { memoryMedia } from '../server/test/media-helpers.js';
import { memoryUsers } from '../server/test/helpers.js';
const config = { NODE_ENV: 'test', WEB_ORIGIN: 'http://localhost:5173', SESSION_SECRET: 'pruebas-locales-sin-secretos-reales-123456789' };
const server = createApp({ config, store: new session.MemoryStore(), users: memoryUsers(), ...memoryMedia(), authLimit: 200 }).listen(3000, '127.0.0.1', () => console.log('API aislada de prueba disponible'));
process.on('SIGTERM', () => server.close());
```
{% endraw %}

### `tests/images.spec.js`

Recorrido de React real: crear, etiquetas, video, portada, sustitución, galería, recarga, móvil y eliminación. Las respuestas externas se sustituyen explícitamente.

<!-- archivo: tests/images.spec.js -->
{% raw %}
```js
import { test, expect } from '@playwright/test';
import { join } from 'node:path';
import { createRequire } from 'node:module';
const sharp = createRequire(new URL('../server/package.json', import.meta.url))('sharp');
const image = await sharp({ create: { width: 800, height: 600, channels: 3, background: '#17263c' } }).composite([{ input: Buffer.from('<svg width="800" height="600"><path d="M400 100L480 200L460 300L540 450L400 400L260 450L340 300L320 200Z" fill="#203b52" stroke="#53e2ba" stroke-width="6"/><path d="M350 230L450 230M400 100L400 70" stroke="#53e2ba" stroke-width="8"/><text x="400" y="540" fill="#c5d6eb" font-family="Arial" font-size="28" text-anchor="middle">GPB · MODELO DE PRUEBA</text></svg>') }]).png().toBuffer();
test('imágenes y detalle completo: carga, sustitución, galería, etiquetas, video y móvil', async ({ page }) => {
  await page.route('https://res.cloudinary.com/**', route => route.fulfill({ contentType: 'image/png', body: image }));
  await page.route('https://www.youtube-nocookie.com/**', route => route.fulfill({ contentType: 'text/html; charset=utf-8', body: '<html style="background:#0b1220;color:#d5e3f5"><body>Reproductor externo · no se carga video en esta prueba local.</body></html>' }));
  await page.goto('/registro');
  await page.getByLabel('Nombre de usuario').fill('imagenes_web');
  await page.getByLabel('Correo electrónico').fill('imagenes_web@example.com');
  await page.getByLabel('Contraseña', { exact: true }).fill('Clave de prueba 123!');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
  await page.getByRole('link', { name: 'Agregar mi primer Gunpla' }).click();
  await page.getByLabel('Nombre', { exact: true }).fill('RX-78-2 · Proyecto personal');
  await page.getByLabel('Grado', { exact: true }).selectOption({ label: 'High Grade (HG)' });
  await page.getByLabel('Escala', { exact: true }).selectOption({ label: '1/144' });
  await page.getByLabel('Etiquetas (opcional)', { exact: true }).fill(' Pintado ');
  await page.getByRole('button', { name: 'Agregar etiqueta', exact: true }).click();
  await page.getByLabel('Etiquetas (opcional)', { exact: true }).fill('pintado');
  await page.getByRole('button', { name: 'Agregar etiqueta', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Quitar etiqueta Pintado', exact: true })).toHaveCount(1);
  await page.getByLabel('Enlace de YouTube (opcional)').fill('https://youtu.be/dQw4w9WgXcQ');
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'RX-78-2 · Proyecto personal', exact: true })).toBeVisible();
  await expect(page.locator('iframe')).toHaveAttribute('src', 'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ');
  await page.getByLabel('Archivo para subir portada', { exact: true }).setInputFiles({ name: 'portada.png', mimeType: 'image/png', buffer: image });
  await page.getByRole('button', { name: 'Subir portada', exact: true }).click();
  await expect(page.getByAltText('Portada de RX-78-2 · Proyecto personal')).toBeVisible();
  await page.getByLabel('Archivo para sustituir portada', { exact: true }).setInputFiles({ name: 'nueva.png', mimeType: 'image/png', buffer: image });
  await page.getByRole('button', { name: 'Sustituir portada', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Imágenes actualizadas.' })).toBeVisible();
  await page.getByLabel('Archivo para agregar a galería', { exact: true }).setInputFiles({ name: 'galeria.png', mimeType: 'image/png', buffer: image });
  await page.getByRole('button', { name: 'Agregar a galería', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Galería (1/8)', exact: true })).toBeVisible();
  await page.reload();
  await expect(page.getByAltText('Fotografía 1 de RX-78-2 · Proyecto personal')).toBeVisible();
  await page.locator('iframe').scrollIntoViewIfNeeded();
  await expect(page.frameLocator('iframe').getByText('Reproductor externo', { exact: false })).toBeVisible();
  if (process.env.GPB_CAPTURE_DIR) await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'detalle-imagenes.png'), fullPage: true });
  await page.setViewportSize({ width: 390, height: 844 });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (process.env.GPB_CAPTURE_DIR) await page.screenshot({ path: join(process.env.GPB_CAPTURE_DIR, 'detalle-imagenes-movil.png'), fullPage: true });
  await page.getByRole('button', { name: 'Eliminar fotografía 1', exact: true }).click();
  await page.getByRole('button', { name: 'Confirmar imagen', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Galería (0/8)', exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Quitar portada', exact: true }).click();
  await page.getByRole('button', { name: 'Confirmar imagen', exact: true }).click();
  await expect(page.getByRole('img', { name: 'Portada de reemplazo' })).toBeVisible();
  await page.getByRole('link', { name: 'Editar Gunpla', exact: true }).click();
  await expect(page.getByLabel('Enlace de YouTube (opcional)')).toHaveValue('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
  await page.getByRole('button', { name: 'Quitar etiqueta Pintado', exact: true }).click();
  await page.getByLabel('Enlace de YouTube (opcional)').fill('');
  await page.getByRole('button', { name: 'Guardar Gunpla', exact: true }).click();
  await expect(page.locator('iframe')).toHaveCount(0);
});
```
{% endraw %}

### `server/scripts/check-images-atlas.js`

Comprobación con modelos reales y cuentas temporales propias. Sin flags usa Cloudinary real; --provider-memory usa Atlas real y proveedor simulado. Limpia sólo recursos y usuarios del recorrido.

<!-- archivo: server/scripts/check-images-atlas.js -->
{% raw %}
```js
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import mongoose from 'mongoose';
import MongoStore from 'connect-mongo';
import sharp from 'sharp';
import { readConfig } from '../src/config.js';
import { users, User } from '../src/users.js';
import { catalogs, Grade, Scale, seedCatalogs } from '../src/catalogs.js';
import { gunpla, Gunpla } from '../src/gunpla.js';
import { mediaRepository } from '../src/media-repository.js';
import { mediaService } from '../src/media-service.js';
import { cloudinaryProvider } from '../src/cloudinary.js';
import { createApp } from '../src/app.js';
const suffix = randomBytes(6).toString('hex');
const emails = [`gpb_img_a_${suffix}@example.com`, `gpb_img_b_${suffix}@example.com`];
let server, store, media, provider;
const ids = [];
let clean = true;
try {
  const config = { ...readConfig(), NODE_ENV: 'test', SESSION_SECRET: randomBytes(48).toString('base64url') };
  const simulated = process.argv.includes('--provider-memory');
  if (!simulated && ![config.CLOUDINARY_CLOUD_NAME, config.CLOUDINARY_API_KEY, config.CLOUDINARY_API_SECRET].every(Boolean)) throw new Error('Configuración de imágenes incompleta');
  await mongoose.connect(config.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
  await Promise.all([User.init(), Grade.init(), Scale.init(), Gunpla.init()]);
  await seedCatalogs();
  provider = simulated ? { async upload(_buffer, publicId) { return { publicId, url: 'https://example.com/prueba.webp' }; }, async destroy() {} } : cloudinaryProvider(config);
  const repository = { ...mediaRepository, async candidates() { return mediaRepository.candidates(ids); } };
  media = mediaService({ repository, gunpla, provider });
  store = MongoStore.create({ client: mongoose.connection.getClient(), collectionName: 'sessions' });
  server = createApp({ config, store, users, catalogs, gunpla, media }).listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}/api`;
  function client() {
    let cookie = '', csrf = '';
    return async (path, { method = 'GET', body, headers = {} } = {}) => {
      const multipart = body instanceof FormData;
      const res = await fetch(base + path, { method, headers: { cookie, origin: config.WEB_ORIGIN, 'x-csrf-token': csrf, ...(body && !multipart ? { 'content-type': 'application/json' } : {}), ...headers }, body: multipart ? body : body ? JSON.stringify(body) : undefined, signal: AbortSignal.timeout(60000) });
      if (res.headers.get('set-cookie')) cookie = res.headers.get('set-cookie').split(';')[0];
      const data = res.status === 204 ? null : await res.json(); if (data?.csrfToken) csrf = data.csrfToken;
      return { status: res.status, data };
    };
  }
  const a = client(), b = client();
  for (const [index, call] of [a,b].entries()) {
    await call('/auth/csrf');
    assert.equal((await call('/auth/register', { method: 'POST', body: { username: `img_${index}_${suffix}`, email: emails[index], password: randomBytes(24).toString('base64url') } })).status, 201);
  }
  const options = (await a('/catalogs')).data;
  const created = await a('/gunpla', { method: 'POST', body: { name: 'Prueba temporal de imágenes', grade: options.grades[0].id, scale: options.scales[0].id, tags: [' Prueba ', 'prueba'], youtubeUrl: 'https://youtu.be/M7lc1UVf-VE' } });
  assert.equal(created.status,201); const id = created.data.gunpla.id; ids.push(id);
  const image = await sharp({ create: { width: 64, height: 64, channels: 3, background: '#132035' } }).png().toBuffer();
  const form = () => { const body = new FormData(); body.append('image',new Blob([image],{type:'image/png'}),'prueba.png'); return body; };
  for (const kind of ['cover','gallery']) assert.equal((await b(`/gunpla/${id}/${kind}`,{method:'POST',body:form()})).status,404);
  assert.equal((await a(`/gunpla/${id}/cover`,{method:'POST',body:form(),headers:{'x-csrf-token':''}})).status,403);
  const first = await a(`/gunpla/${id}/cover`,{method:'POST',body:form()});assert.equal(first.status,201);
  const old = first.data.gunpla.cover.publicId;
  const second = await a(`/gunpla/${id}/cover`,{method:'POST',body:form()});assert.equal(second.status,201);
  assert.notEqual(second.data.gunpla.cover.publicId,old);
  assert.equal((await Gunpla.findById(id)).mediaJobs.some(job=>job.publicId===old),false);
  const gallery = await a(`/gunpla/${id}/gallery`,{method:'POST',body:form()});assert.equal(gallery.status,201);
  const publicId = gallery.data.gunpla.gallery[0].publicId;
  assert.equal((await b(`/gunpla/${id}/gallery/${encodeURIComponent(publicId)}`,{method:'DELETE'})).status,404);
  assert.equal((await a(`/gunpla/${id}/gallery/${encodeURIComponent(publicId)}`,{method:'DELETE'})).status,200);
  const persistent = await gunpla.get(String((await User.findOne({ email: emails[0] }))._id),id);
  assert.equal(persistent.gallery.length,0);assert.deepEqual(persistent.tags,['prueba']);assert.equal(persistent.youtubeId,'M7lc1UVf-VE');
  assert.equal((await a(`/gunpla/${id}/gallery`,{method:'POST',body:form()})).status,201);
  assert.equal((await a(`/gunpla/${id}`,{method:'DELETE'})).status,204);
  for(let i=0;i<12 && await Gunpla.exists({_id:id});i++) await media.reconcile();
  assert.equal(await Gunpla.exists({_id:id}),null);
  console.log(simulated ? 'Atlas real y proveedor simulado: operaciones, propiedad, CSRF, persistencia y diario aprobados. Cloudinary real no comprobado.' : 'Atlas y Cloudinary: subida, sustitución, galería, etiquetas, video, propiedad, CSRF y limpieza aprobados.');
} catch { console.error('No se completó la comprobación real de imágenes. Revisa configuración, conectividad y permisos.'); process.exitCode = 1; }
finally {
  if (mongoose.connection.readyState === 1) {
    const owners = (await User.find({ email: { $in: emails } }).select('_id')).map(user=>String(user._id));
    for (const doc of await Gunpla.find({ owner: { $in: owners } }).lean()) {
      await Gunpla.updateOne({ _id: doc._id }, { $set: { deleted: true } });
      for (const job of doc.mediaJobs || []) {
        if (!job.settled) clean = false; // Conservar el diario ante posibles respuestas tardías.
        try { await provider.destroy(job.publicId); } catch { clean = false; }
      }
      if (clean) await Gunpla.deleteOne({ _id: doc._id });
    }
    if (clean) {
      await mongoose.connection.collection('sessions').deleteMany({ session: { $regex: suffix } });
      for (const owner of owners) await mongoose.connection.collection('sessions').deleteMany({ session: { $regex: `"userId":"${owner}"` } });
      await User.deleteMany({ email: { $in: emails } });
    } else { console.error('Quedan recursos temporales con seguimiento en MongoDB; reintenta su limpieza.'); process.exitCode = 1; }
  }
  if (server) await new Promise(resolve => server.close(resolve));
  await mongoose.disconnect();
}
```
{% endraw %}

## 8. Manifiesto, entorno de ejemplo e instrucciones locales

Conserva las versiones anteriores y el lock generado al instalar las tres dependencias. No edites manualmente pnpm-lock.yaml. Estos son los únicos archivos de configuración adicionales; las demás fuentes heredadas se mantienen.

### `server/package.json`

Incorpora las dependencias exactas y los comandos check:images:atlas e images:cleanup.

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
    "check:collection:atlas": "node --env-file=.env scripts/check-collection-atlas.js",
    "check:images:atlas": "node --env-file=.env scripts/check-images-atlas.js",
    "images:cleanup": "node --env-file=.env scripts/reconcile-images.js"
  },
  "dependencies": {
    "argon2": "0.45.2",
    "cloudinary": "2.11.0",
    "connect-mongo": "6.0.0",
    "express": "5.3.0",
    "express-rate-limit": "8.7.4",
    "express-session": "1.19.0",
    "helmet": "8.3.0",
    "mongoose": "9.12.0",
    "multer": "2.5.0",
    "sharp": "0.35.5",
    "zod": "4.6.7"
  }
}
```
{% endraw %}

### `server/.env.example`

Este archivo es público y contiene únicamente marcadores. Nunca reemplaces estos ejemplos por secretos en la guía ni en Git.

<!-- archivo: server/.env.example -->
{% raw %}
```dotenv
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb+srv://USUARIO:CLAVE@CLUSTER/gpb
SESSION_SECRET=
WEB_ORIGIN=http://localhost:5173
# En producción: origen público HTTPS del proxy web; nunca una URL de terceros.

# Opcionales hasta configurar imágenes; completar las tres, sin comillas vacías.
# CLOUDINARY_CLOUD_NAME=
# CLOUDINARY_API_KEY=
# CLOUDINARY_API_SECRET=
```
{% endraw %}

## 9. Comprobar la entrega

**Carpeta: raíz de guia-03.** Después de guardar todos los archivos:

{% raw %}
```sh
pnpm install --frozen-lockfile
pnpm check
pnpm build
pnpm test
pnpm exec playwright install chromium
pnpm exec install-electron
pnpm test:transport
```
{% endraw %}

Referencia local inicial: 21 pruebas API y cuatro recorridos de navegador/Electron aprobados. Las pruebas nuevas usan un proveedor de memoria; la prueba de React reemplaza las respuestas externas de imágenes y video, sin afirmar que se haya reproducido un video remoto. El transporte Electron sigue siendo preparatorio, sin empaquetado ni interfaz completa.

Para comprobar con servicios reales, configura tu archivo privado y ejecuta:

{% raw %}
```sh
pnpm --filter @gpb/server seed:catalogs
pnpm --filter @gpb/server check:atlas
pnpm --filter @gpb/server check:collection:atlas
pnpm --filter @gpb/server check:images:atlas
```
{% endraw %}

El último comando utiliza MongoDB y Cloudinary reales, crea sus propias cuentas e imágenes y las limpia. No es suficiente que pase la prueba de memoria. Si únicamente tienes Atlas configurado, puedes comprobar la persistencia del diario con el proveedor simulado:

**Carpeta: server.**

{% raw %}
```sh
node --env-file=.env scripts/check-images-atlas.js --provider-memory
```
{% endraw %}

Ese modo debe informar explícitamente que Cloudinary real no fue comprobado. Conserva la distinción al presentar resultados. Consulta el informe de reproducción para conocer cuáles se ejecutaron efectivamente.

### Recorrido manual

Desde guia-03 ejecuta pnpm dev:server y, en otra terminal de la misma carpeta, pnpm dev:client. Abre http://localhost:5173.

1. Inicia sesión y crea un Gunpla. Agrega etiquetas y guarda un enlace HTTPS de YouTube.
2. Desde el detalle, sube una portada JPG, PNG o WebP y recarga. Debe persistir.
3. Sustituye la portada. La anterior se mantiene hasta que la nueva queda confirmada.
4. Agrega ocho imágenes; no debe permitirse una novena. Elimina una con confirmación y comprueba que puedes agregar otra.
5. Comprueba la presentación móvil, la portada de reemplazo y el iframe. La disponibilidad del video depende de YouTube y de sus permisos de inserción.
6. Con otra cuenta, intenta consultar y modificar el mismo identificador. Debes recibir 404 sin información del propietario.
7. Elimina el Gunpla. Debe desaparecer de la colección; si el proveedor falla, la limpieza permanece en el diario y se reintenta.

### Errores frecuentes y recuperación

- **503 al subir:** configura las tres variables Cloudinary en el servidor y reinicia. No las pongas en React ni en variables VITE_.
- **400 o 413:** comprueba formato real, extensión, MIME, archivo íntegro, menos de 25 megapíxeles, sin animación y hasta 5 MiB. Renombrar una extensión no convierte la imagen.
- **403:** recarga y vuelve a iniciar sesión si es necesario. No retires CSRF ni la comprobación de origen.
- **409:** existe otra operación del mismo registro o ya hay ocho imágenes. Espera, recarga y revisa el estado.
- **429:** ya hay dos cargas en este proceso. Espera a que terminen.
- **Error de subida o tiempo de espera:** la tarea queda registrada. La portada anterior no se reemplaza si no se confirma MongoDB; si el cliente pierde la respuesta después de confirmar, recarga para conocer el resultado.
- **Limpieza pendiente:** mantiene acceso al proveedor y a Atlas. El servidor procesa una eliminación por registro y pasada; repite el comando siguiente cuando sea necesario. No borres el diario ni elimines documentos manualmente para ocultar el aviso.

**Carpeta: raíz de guia-03.**

{% raw %}
```sh
pnpm --filter @gpb/server images:cleanup
```
{% endraw %}

Código 2 significa que la pasada dejó trabajo pendiente. Una subida incierta conserva seguimiento durante al menos 24 horas para cubrir respuestas tardías. Mientras siga fallando el proveedor, no se descarta la tarea. Los recursos aún vinculados se conservan. Después de eliminar un Gunpla, el documento oculto se purga únicamente cuando termina la limpieza. En casos de fallos persistentes, consulta los registros sin imprimir credenciales ni tokens.

## 10. Cierre y siguiente guía

Conserva fuentes y pnpm-lock.yaml, sin secretos, node_modules, compilaciones ni perfiles. Un punto de control Git puede crearse cuando el docente lo indique; esta guía no autoriza publicar ni hacer commits automáticamente. La guía 4 incorporará dashboard, estadísticas, búsqueda y filtros. Render y el paquete macOS siguen reservados a las guías 5 y 6.

Fecha editorial de esta guía: **14 de noviembre de 2026**, autorizada por el docente. Los datos de la sesión de Canvas se confirman por separado; no se deducen de esta fecha editorial ni de las guías anteriores.
