---
title: GPB — Gunpla Personal Builds | Guía 4 - Dashboard y exploración
date: 2026-11-17
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, nodeJS, mongodb, recharts, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

# GPB — Guía 4: dashboard y exploración

En la [guía 3](https://jrguevara.github.io/posts/gpb-guia-03-imagenes-y-detalle-completo/) completaste el detalle de un Gunpla con portada, galería, etiquetas y video. En esta entrega usarás la colección privada para construir un dashboard y permitir que el usuario encuentre un modelo por nombre, grado, escala y estado.

Al finalizar, podrás abrir desde el dashboard uno de los cinco registros agregados más recientemente y localizar un Gunpla aunque no esté en la primera página. Crear, editar o eliminar un modelo cambiará las cifras del dashboard cuando vuelvas a él.

[Descargar el código y las capturas de la etapa 4]({{ '/assets/downloads/gpb/guia-04/MATERIAL-CHATGPT.zip' | relative_url }})

## 1. Preparar la etapa

Necesitas la guía 3 completada, Node.js 26.13.1, pnpm 12.18.0 y los puertos locales 3000 y 5173 libres. La referencia se comprobó con Vite+ 1.6.0 en macOS Apple Silicon. Conserva la carpeta de la guía anterior.

Desde `gpb-dev`:

{% raw %}
```sh
mkdir guia-04 &&
rsync -a --exclude=node_modules --exclude=dist --exclude='.env*' --exclude=test-results --exclude=playwright-report --exclude='*.log' --exclude=.DS_Store guia-03/client guia-03/server guia-03/electron guia-03/tests guia-04/ &&
cp guia-03/package.json guia-03/pnpm-lock.yaml guia-03/pnpm-workspace.yaml guia-03/playwright.config.js guia-03/.gitignore guia-03/.node-version guia-04/ &&
cp guia-03/server/.env.example guia-04/server/.env.example &&
cd guia-04
```
{% endraw %}

El resto de la guía usa la raíz de `guia-04` como carpeta de trabajo. Para cada ruta con un bloque de archivo, crea sus directorios si hace falta y guarda el bloque completo en esa ruta.

### Herramientas para gráficos

**Recharts** es una biblioteca de gráficos para React. GPB la usa para representar cantidades por estado y grado y ofrecer información al recorrer el gráfico. Recharts 3.10.1 admite React 19. Fijamos `react-is` a 19.3.1, la versión de React del proyecto. [Primeros pasos e instalación](https://github.com/recharts/recharts#installation).

En `guia-04`:

{% raw %}
```sh
node --version
pnpm --version
pnpm view recharts@3.10.1 version peerDependencies --json
pnpm view react-is@19.3.1 version
pnpm --filter @gpb/client add --save-exact recharts@3.10.1 react-is@19.3.1
pnpm install --frozen-lockfile
pnpm --filter @gpb/client list recharts react-is --depth 0
pnpm --filter @gpb/client exec vp --version
```
{% endraw %}

La consulta del registro confirma las versiones y la última lista muestra los paquetes instalados. La compilación y el recorrido de navegador comprobarán los dos gráficos.

**Chart de shadcn/ui** proporciona el contenedor y el contenido del tooltip sobre Recharts. Para GPB se adapta a JavaScript y a los colores del tema oscuro. Se incorpora manualmente en `client/src/components/ui/chart.jsx` con el bloque del apartado 3. Requiere React 19, Recharts 3.10.1, Tailwind 4.3.5 y el paquete `cn` 0.5.2 ya instalado. Su comprobación se hace con `pnpm check`, `pnpm build` y el recorrido en el navegador. [Documentación oficial para Radix](https://ui.shadcn.com/docs/components/radix/chart) · [Componente New York v4](https://ui.shadcn.com/r/styles/new-york-v4/chart.json).

Fuentes consultadas el 19/11/2026. [Ficha de herramientas]({{ '/assets/downloads/gpb/guia-04/FUENTES.md' | relative_url }}).

## 2. Consultar la colección privada en Express

Los dos endpoints reciben el propietario de la sesión y excluyen los documentos marcados como eliminados. Esto conserva visibles los registros de versiones previas que todavía carecen del campo `deleted`.

| Ruta | Entrada | Salida |
|---|---|---|
| `GET /api/dashboard` | Sesión activa | Total, cantidades por estado y grado, y cinco registros recientes |
| `GET /api/gunpla` | Sesión activa y parámetros opcionales `q`, `grade`, `scale`, `state`, `page` | Registros y total de coincidencias, con hasta 12 tarjetas por página |

La búsqueda trata caracteres como `[` y `.` como texto y admite diferencias de mayúsculas. El servidor combina los filtros en una sola consulta, cuenta las coincidencias y después devuelve la página solicitada. El dashboard agrupa la colección visible completa con `$facet`. El orden descendente por fecha de creación e identificador mantiene estable la secuencia cuando dos registros comparten fecha.

![Flujo oscuro de las consultas de GPB]({{ '/assets/images/gpb/guia-04/gpb-dashboard-exploracion.png' | relative_url }})

[Visor interactivo oscuro]({{ '/assets/images/gpb/guia-04/gpb-dashboard-exploracion.html' | relative_url }}?theme=dark) · [SVG oscuro]({{ '/assets/images/gpb/guia-04/gpb-dashboard-exploracion.svg' | relative_url }})

Crea primero el archivo de constantes y salida compartida. Después reemplaza el repositorio y registra la ruta del dashboard junto al listado protegido.

### `server/src/exploration.js`

{% raw %}
```javascript
export const PAGE_SIZE = 12;
export const RECENT_LIMIT = 5;

export function namePattern(query) {
  return query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function pageResult(items, total, page) {
  return { items, total, page, pageSize: PAGE_SIZE, pages: Math.max(1, Math.ceil(total / PAGE_SIZE)) };
}

export function summarize(states, grades, recent) {
  const byState = { 'Sin armar': 0, 'En progreso': 0, Armado: 0 };
  for (const { _id, count } of states) byState[_id] = count;
  return {
    total: states.reduce((total, row) => total + row.count, 0),
    byState,
    byGrade: grades,
    recent: recent.map(({ _id, name, state, createdAt }) => ({ id: String(_id), name, state, createdAt })),
  };
}
```
{% endraw %}

### `server/src/gunpla.js`

{% raw %}
```javascript
import mongoose from 'mongoose';
import { namePattern, pageResult, PAGE_SIZE, RECENT_LIMIT, summarize } from './exploration.js';

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
  async list(owner, { page, q, grade, scale, state }) {
    const filter = { owner, deleted: { $ne: true } };
    if (q) filter.name = { $regex: namePattern(q), $options: 'i' };
    if (grade) filter.grade = grade;
    if (scale) filter.scale = scale;
    if (state) filter.state = state;
    const [docs, total] = await Promise.all([
      populate(Gunpla.find(filter).sort({ createdAt: -1, _id: -1 }).skip((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)),
      Gunpla.countDocuments(filter),
    ]);
    return pageResult(docs.map(publicGunpla), total, page);
  },
  async stats(owner) {
    const [result] = await Gunpla.aggregate([
      { $match: { owner: new mongoose.Types.ObjectId(owner), deleted: { $ne: true } } },
      { $sort: { createdAt: -1, _id: -1 } },
      { $facet: {
        states: [{ $group: { _id: '$state', count: { $sum: 1 } } }],
        grades: [
          { $group: { _id: '$grade', count: { $sum: 1 } } },
          { $lookup: { from: 'grades', localField: '_id', foreignField: '_id', as: 'grade' } },
          { $project: { _id: 0, name: { $ifNull: [{ $first: '$grade.name' }, 'Grado no disponible'] }, count: 1 } },
          { $group: { _id: '$name', count: { $sum: '$count' } } },
          { $sort: { _id: 1 } },
          { $project: { _id: 0, name: '$_id', count: 1 } },
        ],
        recent: [{ $limit: RECENT_LIMIT }, { $project: { name: 1, state: 1, createdAt: 1 } }],
      } },
    ]);
    return summarize(result.states, result.grades, result.recent);
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

{% raw %}
```javascript
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
const collectionQuery = z.strictObject({
  page: z.string().regex(/^[1-9]\d{0,5}$/).transform(Number).optional().default(1),
  q: z.string().trim().max(120).optional(),
  grade: id.transform((value) => value.toLowerCase()).optional(),
  scale: id.transform((value) => value.toLowerCase()).optional(),
  state: z.enum(STATES).optional(),
});
const missing = (res) => res.status(404).json({ message: 'Gunpla no encontrado.' });
export function collectionRoutes({ catalogs, gunpla, media }) {
  const router = Router();
  router.get('/catalogs', async (_req, res) => res.json(await catalogs.list()));
  router.get('/gunpla', async (req, res) => {
    const query = collectionQuery.safeParse(req.query);
    if (!query.success) return res.status(400).json({ message: 'Revisa la búsqueda, los filtros y el número de página.' });
    res.json(await gunpla.list(String(req.user._id), query.data));
  });
  router.get('/dashboard', async (req, res) => res.json(await gunpla.stats(String(req.user._id))));
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

## 3. Completar el dashboard y Mi colección en React

Extrae la carga, el aviso de error y el reintento de recursos a un módulo que puedan compartir dashboard, lista y formularios. El dashboard carga sus gráficos al entrar a la ruta. Si la colección está vacía, ofrece un enlace al formulario de creación.

En **Mi colección**, al aplicar los filtros se actualiza la URL y se vuelve a la primera página. Al avanzar de página se conservan los filtros aplicados. Una colección vacía ofrece crear el primer modelo. Una búsqueda sin coincidencias permite quitar sus filtros.

Crea los tres primeros archivos y reemplaza los tres últimos.

### `client/src/lib/resource.jsx`

{% raw %}
```jsx
import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";

export function useResource(path) {
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
export function ResourceState({ resource }) {
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
```
{% endraw %}

### `client/src/components/ui/chart.jsx`

{% raw %}
```jsx
// Adaptado de shadcn/ui New York v4 para JavaScript y el tema oscuro de GPB.
import { createContext, useContext } from "react";
import { cn } from "cn";
import { ResponsiveContainer, Tooltip } from "recharts";

const ChartContext = createContext(null);

function ChartContainer({ className, children, config, style, ...props }) {
  const colors = Object.fromEntries(
    Object.entries(config).map(([key, { color }]) => [`--color-${key}`, color]),
  );
  return (
    <ChartContext.Provider value={config}>
      <div
        data-slot="chart"
        className={cn(
          "text-xs [&_.recharts-cartesian-axis-tick_text]:fill-muted-foreground [&_.recharts-cartesian-grid_line]:stroke-border/50",
          className,
        )}
        style={{ ...colors, ...style }}
        {...props}
      >
        <ResponsiveContainer initialDimension={{ width: 240, height: 210 }}>
          {children}
        </ResponsiveContainer>
      </div>
    </ChartContext.Provider>
  );
}

function ChartTooltipContent({ active, payload, label, nameKey, hideLabel }) {
  const config = useContext(ChartContext);
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-md border bg-card px-3 py-2 text-card-foreground shadow-md">
      {!hideLabel && <p>{label}</p>}
      {payload.map((item) => {
        const key = item.payload?.[nameKey] ?? item.dataKey;
        return (
          <p key={key}>
            {config[key]?.label ?? item.name} <strong>{item.value}</strong>
          </p>
        );
      })}
    </div>
  );
}

export { ChartContainer, Tooltip as ChartTooltip, ChartTooltipContent };
```
{% endraw %}

### `client/src/dashboard/Dashboard.jsx`

{% raw %}
```jsx
import { Link } from "react-router";
import { Bar, BarChart, CartesianGrid, Pie, PieChart, XAxis, YAxis } from "recharts";
import { useAuth } from "@/auth/AuthContext";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { ResourceState, useResource } from "@/lib/resource";

const status = {
  armado: { label: "Armado", summary: "Armados", color: "#51d9aa" },
  progreso: { label: "En progreso", summary: "En progreso", color: "#f9bd6b" },
  pendiente: { label: "Sin armar", summary: "Sin armar", color: "#82adff" },
};
const gradeConfig = { count: { label: "Gunpla", color: "#82adff" } };

function DashboardCharts({ byState, byGrade }) {
  const distribution = Object.entries(status).map(([key, { label, color }]) => ({
    key,
    name: label,
    fill: color,
    count: byState[label],
  }));
  return (
    <div className="dashboard-charts">
      <Card>
        <CardHeader>
          <h2>Distribución por estado</h2>
        </CardHeader>
        <CardContent>
          <ChartContainer config={status} className="dashboard-donut">
            <PieChart accessibilityLayer>
              <ChartTooltip content={<ChartTooltipContent nameKey="key" hideLabel />} />
              <Pie
                data={distribution}
                dataKey="count"
                nameKey="name"
                innerRadius="58%"
                outerRadius="88%"
                stroke="none"
                isAnimationActive={false}
              />
            </PieChart>
          </ChartContainer>
          <ul className="dashboard-legend">
            {distribution.map(({ key, name, count, fill }) => (
              <li key={key}>
                <span style={{ backgroundColor: fill }} aria-hidden="true" />
                {name} <strong>{count}</strong>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <h2>Gunpla por grado</h2>
        </CardHeader>
        <CardContent>
          <ChartContainer
            config={gradeConfig}
            className="dashboard-bars"
            style={{ height: Math.max(210, byGrade.length * 34 + 44) }}
          >
            <BarChart accessibilityLayer layout="vertical" data={byGrade} margin={{ right: 12 }}>
              <CartesianGrid horizontal={false} />
              <XAxis type="number" allowDecimals={false} tick={{ fill: "#a5a7ae" }} />
              <YAxis
                tick={{ fill: "#a5a7ae" }}
                type="category"
                dataKey="name"
                width={78}
                interval={0}
                tickFormatter={(name) => name.match(/\(([^)]+)\)$/)?.[1] || name}
              />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Bar
                dataKey="count"
                fill="var(--color-count)"
                radius={[0, 4, 4, 0]}
                isAnimationActive={false}
              />
            </BarChart>
          </ChartContainer>
          <ul className="sr-only" aria-label="Recuentos por grado">
            {byGrade.map(({ name, count }) => (
              <li key={name}>
                {name} · {count}
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}

export default function Dashboard() {
  const { user } = useAuth();
  const resource = useResource("/dashboard");
  const { data } = resource;
  return (
    <>
      <p className="eyebrow">DASHBOARD</p>
      <div className="page-heading">
        <h1>Hola, {user.username}.</h1>
        <Button asChild>
          <Link to="/coleccion">Ver mi colección</Link>
        </Button>
      </div>
      {!data ? (
        <ResourceState resource={resource} />
      ) : data.total === 0 ? (
        <Card className="empty-card">
          <CardContent>
            <h2>Tu colección está vacía</h2>
            <p className="muted">
              Agrega tu primer Gunpla para ver aquí el resumen de tu colección.
            </p>
            <Button asChild>
              <Link to="/coleccion/nuevo">Agregar mi primer Gunpla</Link>
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="dashboard">
          <section className="dashboard-totals" aria-label="Resumen de la colección">
            <Card>
              <CardContent>
                <p>Total de Gunpla</p>
                <strong>{data.total}</strong>
              </CardContent>
            </Card>
            {Object.entries(status).map(([key, { label, summary, color }]) => (
              <Card key={key}>
                <CardContent>
                  <p>{summary}</p>
                  <strong style={{ color }}>{data.byState[label]}</strong>
                </CardContent>
              </Card>
            ))}
          </section>
          <DashboardCharts byState={data.byState} byGrade={data.byGrade} />
          <Card>
            <CardHeader>
              <h2>Registros recientes</h2>
            </CardHeader>
            <CardContent>
              <ul className="recent-gunpla">
                {data.recent.map(({ id, name, state }) => (
                  <li key={id}>
                    <Link to={`/coleccion/${id}`}>{name}</Link>
                    <span className="state-badge">{state}</span>
                  </li>
                ))}
              </ul>
            </CardContent>
          </Card>
        </div>
      )}
    </>
  );
}
```
{% endraw %}

### `client/src/App.jsx`

{% raw %}
```jsx
import { Collection, GunplaDetail, GunplaFormPage } from "@/collection/Collection";
import { lazy, Suspense, useState } from "react";
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

const Dashboard = lazy(() => import("@/dashboard/Dashboard"));

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
        <Route
          index
          element={
            <Suspense fallback={<p role="status">Cargando…</p>}>
              <Dashboard />
            </Suspense>
          }
        />
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

### `client/src/collection/Collection.jsx`

{% raw %}
```jsx
import { useState } from "react";
import { Link, useLocation, useNavigate, useParams, useSearchParams } from "react-router";
import { ResourceState, useResource } from "@/lib/resource";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

import { MediaPanel, TagsInput } from "./MediaPanel";

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
const filters = ["q", "grade", "scale", "state"];
const states = ["Sin armar", "En progreso", "Armado"];

function CollectionFilters({ params, apply, clear }) {
  const catalogs = useResource("/catalogs");
  if (!catalogs.data) return <ResourceState resource={catalogs} />;
  const fields = [
    ["grade", "Grado", catalogs.data.grades],
    ["scale", "Escala", catalogs.data.scales],
    ["state", "Estado", states.map((name) => ({ id: name, name }))],
  ];
  return (
    <form
      className="collection-filters"
      aria-label="Explorar colección"
      onSubmit={(event) => {
        event.preventDefault();
        apply(new FormData(event.currentTarget));
      }}
    >
      <label>
        Buscar por nombre
        <Input
          type="search"
          name="q"
          placeholder="Buscar Gunpla"
          maxLength={120}
          defaultValue={params.get("q") || ""}
        />
      </label>
      {fields.map(([key, label, options]) => (
        <label key={key}>
          {label}
          <select name={key} defaultValue={params.get(key) || ""}>
            <option value="">Cualquiera</option>
            {options.map(({ id, name }) => (
              <option key={id} value={id}>
                {name}
              </option>
            ))}
          </select>
        </label>
      ))}
      <div className="filter-actions">
        <Button type="submit">Aplicar filtros</Button>
        <Button
          variant="outline"
          type="button"
          onClick={(event) => {
            event.currentTarget.form.reset();
            clear();
          }}
        >
          Limpiar
        </Button>
      </div>
    </form>
  );
}

export function Collection() {
  const [params, setParams] = useSearchParams();
  const selected = new URLSearchParams();
  for (const key of filters) {
    if (params.get(key)) selected.set(key, params.get(key));
  }
  const query = new URLSearchParams(selected);
  query.set("page", params.get("page") || "1");
  const resource = useResource(`/gunpla?${query}`);
  const filtered = selected.size > 0;
  function apply(formData) {
    const next = new URLSearchParams();
    for (const key of filters) {
      const value = formData.get(key).trim();
      if (value) next.set(key, value);
    }
    setParams(next);
  }
  function goToPage(page) {
    const next = new URLSearchParams(selected);
    next.set("page", String(page));
    setParams(next);
  }
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
      <CollectionFilters
        key={selected.toString()}
        params={selected}
        apply={apply}
        clear={() => setParams({})}
      />
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
            {resource.data.total} {resource.data.total === 1 ? "modelo" : "modelos"}{" "}
            {filtered
              ? resource.data.total === 1
                ? "encontrado"
                : "encontrados"
              : "en tu colección"}
          </p>
          {resource.data.items.length === 0 ? (
            <Card className="empty-card">
              <CardContent>
                <h2>
                  {resource.data.total
                    ? "No hay registros en esta página"
                    : filtered
                      ? "Sin coincidencias"
                      : "El primer build está por llegar"}
                </h2>
                <p className="muted">
                  {resource.data.total
                    ? "Vuelve a la primera página para consultar tu colección."
                    : filtered
                      ? "Prueba con otro nombre o cambia los filtros."
                      : "Agrega tu primer Gunpla y acompaña su construcción."}
                </p>
                {resource.data.total ? (
                  <Button onClick={() => goToPage(1)}>Primera página</Button>
                ) : filtered ? (
                  <Button onClick={() => setParams({})}>Quitar filtros</Button>
                ) : (
                  <Button asChild>
                    <Link to="/coleccion/nuevo">Agregar mi primer Gunpla</Link>
                  </Button>
                )}
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
                onClick={() => goToPage(resource.data.page - 1)}
              >
                Anterior
              </Button>
              <span>
                Página {resource.data.page} de {resource.data.pages}
              </span>
              <Button
                variant="outline"
                disabled={resource.data.page >= resource.data.pages}
                onClick={() => goToPage(resource.data.page + 1)}
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

.collection-filters {
  display: grid;
  grid-template-columns: minmax(0, 2fr) repeat(3, minmax(0, 1fr));
  gap: 12px;
  padding: 16px;
  margin-bottom: 20px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--card);
}
.collection-filters label {
  display: grid;
  gap: 6px;
  min-width: 0;
}
.collection-filters input,
.collection-filters select {
  height: 40px;
  padding-block: 0;
}
.filter-actions {
  grid-column: 1 / -1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.dashboard {
  display: grid;
  gap: 20px;
  min-width: 0;
}
.dashboard-totals,
.dashboard-charts {
  display: grid;
  gap: 14px;
}
.dashboard-totals {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}
.dashboard-charts {
  grid-template-columns: minmax(0, 1fr) minmax(0, 1.4fr);
}
.dashboard-totals strong {
  font-size: clamp(1.65rem, 5vw, 2.75rem);
  line-height: 1.2;
  font-variant-numeric: tabular-nums;
}
.dashboard [data-slot="card"] {
  border-color: var(--color-border);
}
.dashboard h2,
.dashboard-totals p {
  margin: 0;
}
.dashboard-donut {
  width: 100%;
  height: 210px;
}
.dashboard-bars {
  width: 100%;
}
.dashboard-legend {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 6px 14px;
  margin: 10px 0 0;
  font-size: 0.875rem;
}
.dashboard-legend li {
  display: flex;
  align-items: center;
  gap: 5px;
}
.dashboard-legend span {
  width: 9px;
  height: 9px;
  border-radius: 50%;
}
.recent-gunpla li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-top: 1px solid var(--color-border);
}
.recent-gunpla a {
  text-decoration: underline;
  text-underline-offset: 3px;
  overflow-wrap: anywhere;
}
.recent-gunpla .state-badge {
  flex-shrink: 0;
}
@media (max-width: 760px) {
  .collection-filters,
  .dashboard-totals {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
  .dashboard-charts {
    grid-template-columns: minmax(0, 1fr);
  }
  .collection-filters label:nth-child(-n + 2) {
    grid-column: 1 / -1;
  }
}
```
{% endraw %}

## 4. Recorrer las pantallas de la aplicación

Las capturas se tomaron en la app de `guia-04`. Los nombres, grados y escalas identifican kits Gunpla reales. La cuenta, la colección de ejemplo y los estados usados para enseñar el recorrido son ficticios. El ejemplo central es el **RG MS-06F Zaku II, escala 1/144**. [Manual oficial de Bandai](https://manual.bandai-hobby.net/menus/detail/659).

Para ejecutar GPB con tu configuración desde `guia-04`, crea el archivo local y completa sus valores con tu propia configuración de Atlas y Cloudinary según la guía 3. Usa un secreto de sesión propio.

{% raw %}
```sh
cp -n server/.env.example server/.env
chmod 600 server/.env
```
{% endraw %}

Carga los catálogos y abre dos terminales en `guia-04`:

{% raw %}
```sh
pnpm --filter @gpb/server seed:catalogs
pnpm dev:server
```
{% endraw %}

{% raw %}
```sh
pnpm dev:client
```
{% endraw %}

Abre [la aplicación local](http://localhost:5173) y registra una cuenta de práctica. Agrega el Zaku II con grado **Real Grade (RG)**, escala **1/144** y estado **Sin armar**. En el detalle puedes subir la portada y una fotografía de galería. Para ver la segunda página, agrega un total de al menos 13 kits con distintos estados. En **Mi colección**, busca `Zaku` y combina los tres filtros. Repite con un nombre inexistente y usa **Quitar filtros** para recuperar el listado.

El dashboard de referencia parte de 14 Gunpla: seis armados, cuatro en progreso y cuatro sin armar. Al cambiar el Zaku II a **Armado** verás siete armados al volver al dashboard. Después de confirmar su eliminación, el total baja a 13. Si empiezas con una cantidad distinta de modelos, comprueba la diferencia al hacer cada operación.

### Dashboard de la colección

Comprueba las cuatro tarjetas, los gráficos y el acceso al detalle desde Registros recientes.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/dashboard-escritorio.png' | relative_url }}" alt="Dashboard de la colección de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/dashboard-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/dashboard-movil.png' | relative_url }}" alt="Dashboard de la colección de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/dashboard-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Dashboard vacío

Desde una cuenta nueva, el enlace abre el formulario para agregar el primer Gunpla.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/dashboard-vacio-escritorio.png' | relative_url }}" alt="Dashboard vacío de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/dashboard-vacio-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/dashboard-vacio-movil.png' | relative_url }}" alt="Dashboard vacío de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/dashboard-vacio-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Colección vacía

La colección ofrece una acción para crear el primer registro.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/coleccion-vacia-escritorio.png' | relative_url }}" alt="Colección vacía de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/coleccion-vacia-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/coleccion-vacia-movil.png' | relative_url }}" alt="Colección vacía de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/coleccion-vacia-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Formulario de creación

Completa nombre, grado, escala y estado del RG MS-06F Zaku II.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/formulario-crear-escritorio.png' | relative_url }}" alt="Formulario de creación de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/formulario-crear-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/formulario-crear-movil.png' | relative_url }}" alt="Formulario de creación de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/formulario-crear-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Colección paginada

La primera página muestra 12 tarjetas. Siguiente conserva los filtros aplicados.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/coleccion-escritorio.png' | relative_url }}" alt="Colección paginada de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/coleccion-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/coleccion-movil.png' | relative_url }}" alt="Colección paginada de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/coleccion-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Búsqueda y filtros con resultados

Zaku, RG, 1/144 y Sin armar dejan una coincidencia.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/filtros-con-resultados-escritorio.png' | relative_url }}" alt="Búsqueda y filtros con resultados de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/filtros-con-resultados-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/filtros-con-resultados-movil.png' | relative_url }}" alt="Búsqueda y filtros con resultados de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/filtros-con-resultados-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Búsqueda sin coincidencias

Quitar filtros recupera la colección y vuelve a la primera página.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/sin-coincidencias-escritorio.png' | relative_url }}" alt="Búsqueda sin coincidencias de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/sin-coincidencias-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/sin-coincidencias-movil.png' | relative_url }}" alt="Búsqueda sin coincidencias de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/sin-coincidencias-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Detalle del RG MS-06F Zaku II

La portada muestra el kit en su caja y la galería muestra una pieza ensamblada.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/detalle-escritorio.png' | relative_url }}" alt="Detalle del RG MS-06F Zaku II de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/detalle-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/detalle-movil.png' | relative_url }}" alt="Detalle del RG MS-06F Zaku II de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/detalle-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Formulario de edición

Cambia el estado a Armado y verifica el recuento en el dashboard.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/formulario-editar-escritorio.png' | relative_url }}" alt="Formulario de edición de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/formulario-editar-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/formulario-editar-movil.png' | relative_url }}" alt="Formulario de edición de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/formulario-editar-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Confirmación de eliminación

La confirmación identifica por nombre el registro que se eliminará.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/confirmar-eliminacion-escritorio.png' | relative_url }}" alt="Confirmación de eliminación de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/confirmar-eliminacion-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/confirmar-eliminacion-movil.png' | relative_url }}" alt="Confirmación de eliminación de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/confirmar-eliminacion-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

### Resultado de la eliminación

La colección confirma la operación y muestra 13 registros.

<figure class="gpb-capture" style="margin: 1rem 0 0.75rem">
  <img src="{{ '/assets/images/gpb/guia-04/resultado-eliminacion-escritorio.png' | relative_url }}" alt="Resultado de la eliminación de GPB en escritorio, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
  <figcaption><a href="{{ '/assets/images/gpb/guia-04/resultado-eliminacion-escritorio.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG de escritorio</a></figcaption>
</figure>
<details class="gpb-mobile" style="margin: 0 0 1.5rem">
  <summary>Ver captura móvil</summary>
  <figure class="gpb-capture" style="max-width: 390px; margin: 0.75rem auto 0">
    <img src="{{ '/assets/images/gpb/guia-04/resultado-eliminacion-movil.png' | relative_url }}" alt="Resultado de la eliminación de GPB en móvil, modo oscuro" loading="lazy" style="display: block; max-width: 100%; width: 100%; height: auto; border-radius: 12px;" />
    <figcaption><a href="{{ '/assets/images/gpb/guia-04/resultado-eliminacion-movil.png' | relative_url }}" target="_blank" rel="noopener">Abrir PNG móvil</a></figcaption>
  </figure>
</details>

Fotografías de Gravis bajo [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Las versiones en portada y galería se redujeron, convirtieron a WebP y se muestran en el encuadre de GPB. Las adaptaciones de las fotos mantienen esa licencia. [Caja del kit](https://commons.wikimedia.org/wiki/File:Gunpla_model_packed.jpg) · [Pieza montada](https://commons.wikimedia.org/wiki/File:Gunpla_foot_assembly.jpg).

## 5. Comprobar la entrega

Actualiza el adaptador de colección y las pruebas de API. Agrega el recorrido del dashboard y el verificador de consultas MongoDB. Las pruebas de navegador usan una cuenta ficticia y levantan la API de prueba con adaptadores de memoria.

### `server/test/collection-helpers.js`

{% raw %}
```javascript
// Adaptadores exclusivos de pruebas: Atlas usa los modelos reales.
import { GRADE_NAMES, SCALE_NAMES } from '../src/catalogs.js';
import { namePattern, pageResult, PAGE_SIZE, RECENT_LIMIT, summarize } from '../src/exploration.js';
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
  const owned = (owner) => [...records.values()].filter((doc) => doc.owner === owner && !doc.deleted).reverse();
  return {
    records,
    catalogs: { async list() { return { grades, scales }; }, async valid(g, s) { return grades.some((x) => x.id === g) && scales.some((x) => x.id === s); } },
    gunpla: {
      async list(owner, { page, q, grade, scale, state }) {
        const pattern = q && new RegExp(namePattern(q), 'i');
        const all = owned(owner).filter((doc) =>
          (!pattern || pattern.test(doc.name)) && (!grade || doc.grade === grade) &&
          (!scale || doc.scale === scale) && (!state || doc.state === state));
        return pageResult(all.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE).map(view), all.length, page);
      },
      async stats(owner) {
        const all = owned(owner);
        const countBy = (key) => Object.entries(Object.groupBy(all, key));
        const states = countBy((doc) => doc.state).map(([_id, docs]) => ({ _id, count: docs.length }));
        const byGrade = countBy((doc) => view(doc).grade?.name || 'Grado no disponible')
          .map(([name, docs]) => ({ name, count: docs.length }))
          .sort((a, b) => a.name.localeCompare(b.name));
        return summarize(states, byGrade, all.slice(0, RECENT_LIMIT));
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

### `server/test/collection.test.js`

{% raw %}
```javascript
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

test('busca literalmente y combina filtros antes de paginar; dashboard privado tras CRUD', async (t) => {
  const { a, b, input, client } = await setup(t);
  const { data: { grades, scales } } = await a.call('/catalogs');
  const stats = async (user) => (await user.call('/dashboard')).data;
  const create = async (user, fields) => {
    const result = await user.call('/gunpla', { method: 'POST', body: { ...input, ...fields } });
    assert.equal(result.status, 201);
    return result.data.gunpla;
  };
  assert.equal((await client().call('/dashboard')).status, 401);
  assert.deepEqual(await stats(a), { total: 0, byState: { 'Sin armar': 0, 'En progreso': 0, Armado: 0 }, byGrade: [], recent: [] });
  const first = await create(a, { name: 'Modelo [RX] 0', state: 'Armado' });
  for (let index = 1; index < 13; index++) await create(a, { name: 'Modelo [RX] ' + index, state: 'Armado' });
  await create(a, { name: 'Modelo [RX] grado', state: 'Armado', grade: grades[2].id });
  await create(a, { name: 'Modelo [RX] escala', state: 'Armado', scale: scales[1].id });
  await create(a, { name: 'Modelo [RX] estado', state: 'En progreso' });
  await create(a, { name: 'Modelo RX sin corchetes', state: 'Armado' });
  const other = await create(b, { name: 'Modelo [RX] ajeno', state: 'Armado' });

  const query = new URLSearchParams({ q: ' [rx] ', grade: input.grade, scale: input.scale, state: 'Armado' });
  const list = async (page) => (await a.call('/gunpla?' + query + '&page=' + page)).data;
  assert.equal((await list(1)).total, 13);
  assert.equal((await list(1)).items.length, 12);
  assert.deepEqual((await list(2)).items.map(({ id }) => id), [first.id]);
  for (const invalid of ['q=a&q=b', 'q=' + 'a'.repeat(121), 'state=Listo', 'grade=invalido', 'scale=1/144']) {
    assert.equal((await a.call('/gunpla?' + invalid)).status, 400);
  }

  const before = await stats(a);
  assert.equal(before.total, 17);
  assert.deepEqual(before.byState, { 'Sin armar': 0, 'En progreso': 1, Armado: 16 });
  assert.deepEqual(before.byGrade.map(({ count }) => count), [16, 1]);
  assert.equal(before.recent.length, 5);
  assert.equal(before.recent[0].name, 'Modelo RX sin corchetes');
  assert.deepEqual((await stats(b)).recent.map(({ id }) => id), [other.id]);

  const stored = await a.call('/gunpla/' + first.id, { method: 'PUT', body: { ...input, state: 'En progreso', grade: grades[2].id } });
  assert.equal(stored.status, 200);
  assert.equal((await list(1)).total, 12);
  assert.deepEqual((await stats(a)).byGrade.map(({ count }) => count), [15, 2]);
  assert.deepEqual((await stats(a)).recent, before.recent);
  assert.equal((await a.call('/gunpla/' + first.id, { method: 'DELETE' })).status, 204);
  const after = await stats(a);
  assert.equal(after.total, 16);
  assert.deepEqual(after.byState, { 'Sin armar': 0, 'En progreso': 1, Armado: 15 });
  assert.equal((await stats(b)).total, 1);
});
```
{% endraw %}

### `tests/dashboard.spec.js`

{% raw %}
```javascript
import { test, expect } from '@playwright/test';
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const captureDir = process.env.GPB_DASHBOARD_CAPTURES;
const viewports = { escritorio: { width: 1440, height: 1000 }, movil: { width: 390, height: 844 } };

test('dashboard y exploración: recorrido con cambios reales en la colección', async ({ page }) => {
  test.setTimeout(75_000);
  const captures = [];
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.setViewportSize(viewports.escritorio);
  async function capture(name) {
    for (const [size, viewport] of Object.entries(viewports)) {
      await page.setViewportSize(viewport);
      await page.locator('main img').evaluateAll((images) => Promise.all(images.map((image) => { image.loading = 'eager'; return image.decode(); })));
      await page.evaluate(() => new Promise((done) => requestAnimationFrame(() => requestAnimationFrame(done))));
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), name + ' ' + size).toBe(true);
      if (captureDir) {
        const file = name + '-' + size + '.png';
        await page.screenshot({ path: join(captureDir, file), fullPage: true, animations: 'disabled' });
        captures.push({ file, path: new URL(page.url()).pathname, viewport, horizontalOverflow: false });
      }
    }
    await page.setViewportSize(viewports.escritorio);
  }

  await page.goto('/registro');
  await page.getByLabel('Nombre de usuario').fill('piloto_demo');
  await page.getByLabel('Correo electrónico').fill('piloto_demo@example.com');
  await page.getByLabel('Contraseña', { exact: true }).fill('Clave de prueba 123!');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Tu colección está vacía' })).toBeVisible();
  await capture('dashboard-vacio');
  await page.getByRole('link', { name: 'Mi colección', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'El primer build está por llegar' })).toBeVisible();
  await capture('coleccion-vacia');
  await page.getByRole('link', { name: 'Agregar mi primer Gunpla' }).click();
  // Los modelos auxiliares se crean por la API local con la sesión de la cuenta ficticia.
  const fixtures = [
    ['Gundam Calibarn', 1, 0, 'Armado'], ['Gundam Lfrith', 1, 0, 'Sin armar'],
    ['Wing Gundam Zero', 3, 1, 'En progreso'], ['Gundam Exia', 2, 0, 'Armado'],
    ['Gundam Barbatos', 3, 1, 'En progreso'], ['MS-06S Char’s Zaku II', 1, 0, 'Armado'],
    ['Gundam Unicorn', 2, 0, 'En progreso'], ['Sazabi', 2, 0, 'Armado'],
    ['Gundam Mk-II', 1, 0, 'Sin armar'], ['Gundam Dynames', 3, 1, 'Armado'],
    ['Strike Freedom Gundam', 4, 2, 'Sin armar'], ['Gundam Schwarzette', 1, 0, 'Armado'],
    ['Gundam Pharact', 1, 0, 'En progreso'],
  ];
  await page.evaluate(async (rows) => {
    const { csrfToken } = await fetch('/api/auth/csrf').then((response) => response.json());
    const { grades, scales } = await fetch('/api/catalogs').then((response) => response.json());
    for (const [name, grade, scale, state] of rows) {
      const response = await fetch('/api/gunpla', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken },
        body: JSON.stringify({ name, grade: grades[grade].id, scale: scales[scale].id, state }),
      });
      if (response.status !== 201) throw new Error('No se pudo crear el modelo ficticio.');
    }
  }, fixtures);
  await page.getByLabel('Grado', { exact: true }).selectOption({ label: 'Real Grade (RG)' });
  await page.getByLabel('Escala', { exact: true }).selectOption({ label: '1/144' });
  await page.getByLabel('Descripción (opcional)').fill('Kit Real Grade a escala 1/144. La caja contiene las piezas sujetas a sus marcos.');
  const name = page.getByLabel('Nombre', { exact: true });
  await name.fill('MS-06F Zaku II');
  await expect(name).toHaveValue('MS-06F Zaku II');
  await capture('formulario-crear');
  await expect(name).toHaveValue('MS-06F Zaku II');
  await page.getByRole('button', { name: 'Guardar Gunpla' }).click();
  await expect(page.getByRole('heading', { name: 'MS-06F Zaku II', exact: true })).toBeVisible();

  if (process.env.GPB_GUNPLA_PHOTOS) {
    const photos = process.env.GPB_GUNPLA_PHOTOS;
    let coverUrl;
    await page.route('https://res.cloudinary.com/demo/image/upload/**', (route) =>
      route.fulfill({
        path: join(photos, !coverUrl || route.request().url() === coverUrl ? 'caja.webp' : 'pie.webp'),
        contentType: 'image/webp',
      }),
    );
    await page.getByLabel('Archivo para subir portada', { exact: true }).setInputFiles(join(photos, 'caja.webp'));
    await page.getByRole('button', { name: 'Subir portada', exact: true }).click();
    const cover = page.getByRole('img', { name: 'Portada de MS-06F Zaku II' });
    await expect(cover).toBeVisible();
    coverUrl = await cover.getAttribute('src');
    await page.getByLabel('Archivo para agregar a galería', { exact: true }).setInputFiles(join(photos, 'pie.webp'));
    await page.getByRole('button', { name: 'Agregar a galería', exact: true }).click();
    await expect(page.getByText('Galería (1/8)')).toBeVisible();
  }

  const dashboard = page.getByRole('link', { name: 'Dashboard', exact: true });
  const totals = page.getByRole('region', { name: 'Resumen de la colección' });
  await dashboard.click();
  await expect(totals.getByText('14', { exact: true })).toBeVisible();
  await expect(page.locator('[data-slot="chart"] svg.recharts-surface')).toHaveCount(2);
  await expect(page.locator('.recharts-pie-sector')).toHaveCount(3);
  await expect(page.locator('.recharts-bar-rectangle')).toHaveCount(4);
  await capture('dashboard');
  await page.getByRole('link', { name: 'MS-06F Zaku II', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'MS-06F Zaku II', exact: true })).toBeVisible();
  await dashboard.click();
  await page.getByRole('link', { name: 'Ver mi colección' }).click();
  await expect(page.getByText('Página 1 de 2')).toBeVisible();
  await expect(page.locator('.gunpla-card')).toHaveCount(12);
  await capture('coleccion');
  await page.getByRole('button', { name: 'Siguiente' }).click();
  await expect(page.locator('.gunpla-card')).toHaveCount(2);

  const filters = page.getByRole('form', { name: 'Explorar colección' });
  await filters.getByLabel('Buscar por nombre').fill('Zaku');
  await filters.getByLabel('Grado').selectOption({ label: 'Real Grade (RG)' });
  await filters.getByLabel('Escala').selectOption({ label: '1/144' });
  await filters.getByLabel('Estado').selectOption('Sin armar');
  await filters.getByRole('button', { name: 'Aplicar filtros' }).click();
  await expect(page.locator('.gunpla-card')).toHaveCount(1);
  await expect(page.getByText('1 modelo encontrado')).toBeVisible();
  await capture('filtros-con-resultados');
  await filters.getByLabel('Buscar por nombre').fill('Sin ningún resultado');
  await filters.getByRole('button', { name: 'Aplicar filtros' }).click();
  await expect(page.getByRole('heading', { name: 'Sin coincidencias' })).toBeVisible();
  await capture('sin-coincidencias');
  await page.getByRole('button', { name: 'Quitar filtros' }).click();
  await expect(page.getByText('14 modelos en tu colección')).toBeVisible();
  await page.getByRole('link', { name: /MS-06F Zaku II/ }).click();
  await expect(page.getByRole('heading', { name: 'MS-06F Zaku II', exact: true })).toBeVisible();
  await capture('detalle');
  await page.getByRole('link', { name: 'Editar Gunpla' }).click();
  await page.getByLabel('Estado', { exact: true }).selectOption('Armado');
  await capture('formulario-editar');
  await page.getByRole('button', { name: 'Guardar Gunpla' }).click();
  await expect(page.getByText('Gunpla actualizado.')).toBeVisible();
  const detail = page.url();
  await dashboard.click();
  await expect(totals.getByText('7', { exact: true })).toBeVisible();
  await page.goto(detail);
  await page.getByRole('button', { name: 'Eliminar Gunpla', exact: true }).click();
  await expect(page.getByRole('heading', { name: '¿Eliminar este Gunpla?' })).toBeVisible();
  await capture('confirmar-eliminacion');
  await page.getByRole('button', { name: 'Confirmar eliminación' }).click();
  await expect(page.getByText('Gunpla eliminado.')).toBeVisible();
  await expect(page.getByText('13 modelos en tu colección')).toBeVisible();
  await capture('resultado-eliminacion');
  await dashboard.click();
  await expect(totals.getByText('13', { exact: true })).toBeVisible();

  await page.route('**/api/dashboard', (route) => route.fulfill({
    status: 503, json: { message: 'Servicio temporalmente no disponible.' },
  }));
  await page.reload();
  await expect(page.getByRole('alert')).toHaveText('Servicio temporalmente no disponible.');
  await page.unroute('**/api/dashboard');
  await page.getByRole('button', { name: 'Reintentar' }).click();
  await expect(totals.getByText('13', { exact: true })).toBeVisible();
  expect(errors).toEqual([]);

  if (captureDir) {
    await mkdir(captureDir, { recursive: true });
    await writeFile(join(captureDir, 'COMPROBACION.json'), JSON.stringify({
      application: 'gpb-dev/guia-04',
      theme: 'dark',
      data: 'Ficticios. Interfaz React y API Express de la etapa con adaptadores de memoria.',
      photos: process.env.GPB_GUNPLA_PHOTOS ? 'Caja y pieza del kit RG MS-06F Zaku II, fotos de Gravis, CC BY-SA 4.0.' : undefined,
      captures,
    }, null, 2) + '\n');
  }
});
```
{% endraw %}

### `server/scripts/check-exploration-mongo.js`

{% raw %}
```javascript
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import mongoose from 'mongoose';
import { catalogs, seedCatalogs } from '../src/catalogs.js';
import { Gunpla, gunpla } from '../src/gunpla.js';

const port = Number(process.argv[2]);
assert.ok(Number.isInteger(port) && port > 0 && port <= 65535, 'Indica el puerto de un MongoDB local de prueba.');
const dbName = 'gpb_exploration_' + randomUUID().replaceAll('-', '');
await mongoose.connect(`mongodb://127.0.0.1:${port}`, { dbName, serverSelectionTimeoutMS: 5000 });

try {
  const { version } = await mongoose.connection.db.admin().serverInfo();
  await seedCatalogs();
  const { grades, scales } = await catalogs.list();
  const owner = new mongoose.Types.ObjectId();
  const other = new mongoose.Types.ObjectId();
  const input = { owner, grade: grades[1].id, scale: scales[0].id, state: 'Armado' };
  assert.equal((await gunpla.stats(String(owner))).total, 0);
  const [first] = await Gunpla.insertMany(Array.from({ length: 13 }, (_, index) => ({
    ...input, name: 'Gundam [RX] ' + index, createdAt: new Date(1700000000000 + index),
  })));
  await Gunpla.create([
    { ...input, name: 'Gundam [RX] otro usuario', owner: other },
    { ...input, name: 'Gundam [RX] eliminado', deleted: true },
    { ...input, name: 'Gundam [RX] grado\u2028especial', grade: grades[2].id },
    { ...input, name: 'Gundam [RX] otra escala', scale: scales[1].id },
    { ...input, name: 'Gundam [RX] otro estado', state: 'En progreso' },
  ]);
  // Simula un registro creado antes de existir la marca de eliminación lógica.
  await Gunpla.collection.updateOne({ _id: first._id }, { $unset: { deleted: 1 } });
  const id = String(owner);
  const query = { q: '[rx]', grade: input.grade, scale: input.scale, state: input.state };
  const firstPage = await gunpla.list(id, { ...query, page: 1 });
  const secondPage = await gunpla.list(id, { ...query, page: 2 });
  assert.equal(firstPage.total, 13);
  assert.equal(firstPage.items.length, 12);
  assert.deepEqual(secondPage.items.map(({ id }) => id), [String(first._id)]);

  assert.equal((await gunpla.list(id, { q: 'grado\u2028especial', page: 1 })).total, 1);

  const before = await gunpla.stats(id);
  assert.equal(before.total, 16);
  assert.deepEqual(before.byState, { 'Sin armar': 0, 'En progreso': 1, Armado: 15 });
  assert.deepEqual(before.byGrade, [
    { name: 'High Grade (HG)', count: 15 },
    { name: 'Real Grade (RG)', count: 1 },
  ]);
  assert.equal(before.recent.length, 5);
  assert.ok(before.recent.every(({ name }) => !name.includes('eliminado') && !name.includes('usuario')));
  assert.equal((await gunpla.stats(String(other))).total, 1);
  await gunpla.update(id, first._id, { state: 'Sin armar', grade: grades[2].id });
  assert.equal((await gunpla.list(id, { ...query, page: 1 })).total, 12);
  const updated = await gunpla.stats(id);
  assert.equal(updated.byState['Sin armar'], 1);
  assert.equal(updated.byGrade[1].count, 2);
  assert.deepEqual(updated.recent, before.recent);
  assert.equal(await gunpla.remove(id, first._id), true);
  assert.equal((await gunpla.stats(id)).total, 15);
  console.log(`MongoDB ${version}: filtros, páginas, propiedad, recuentos, recientes y cambios comprobados.`);
} finally {
  try {
    await mongoose.connection.dropDatabase();
  } finally {
    await mongoose.disconnect();
  }
}
```
{% endraw %}

Desde `guia-04`:

{% raw %}
```sh
pnpm check
pnpm build
pnpm test
pnpm test:transport
```
{% endraw %}

La referencia pasó 22 pruebas de API y cinco recorridos de transporte. El recorrido antiguo de Electron comprueba persistencia y revocación al reiniciar el proceso. El recorrido nuevo comprueba gráficos, filtros, paginación, navegación, cambios tras guardar y eliminar, y reintento de un error temporal. Para la captura editorial se proporcionaron dos archivos WebP locales a la API de prueba mediante `GPB_GUNPLA_PHOTOS`. Las fotos se muestran desde el adaptador de pruebas y la app ejecuta sus formularios de carga.

Para probar las consultas sin usar la cuenta de Atlas, puedes ejecutar `node server/scripts/check-exploration-mongo.js 37104` con una instancia desechable de MongoDB Community en `127.0.0.1:37104`. El verificador crea y elimina su propia base aleatoria. La referencia aprobó con MongoDB 8.0.38. [Registro técnico]({{ '/assets/downloads/gpb/guia-04/REGISTRO.md' | relative_url }}).

| Si ocurre esto | Comprueba esto |
|---|---|
| El cliente muestra un error de conexión | Confirma que Express escucha en el puerto 3000 y abre React en localhost:5173. Después pulsa Reintentar. |
| Los selectores de creación no tienen opciones | Revisa la conexión de MongoDB y vuelve a ejecutar la carga de catálogos. |
| Una búsqueda deja la colección vacía | Verifica que el nombre y los tres filtros correspondan al mismo registro. Usa Quitar filtros para recuperar el listado. |
| Playwright no puede abrir Chromium | Instálalo con `pnpm exec playwright install chromium` desde `guia-04`. Deja libres los puertos 3000 y 5173 para que la suite inicie sus procesos. |

## 6. Cierre

Al completar la guía, puedes distinguir entre el total de la colección y el total que devuelve una búsqueda filtrada. El siguiente paso del curso será configurar el cliente y la API en Render y repetir los recorridos con los servicios remotos.
