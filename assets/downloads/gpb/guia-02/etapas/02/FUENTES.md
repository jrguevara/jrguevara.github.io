# Herramientas y fuentes — etapa 2

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

Los diagramas son HTML autónomos elaborados con [Archify](https://github.com/tt-a1i/archify). Abrirlos no requiere instalar herramientas adicionales ni iniciar GPB. Sus fuentes y comprobaciones están en [Diagramas de guía 2](../etapas/02/DIAGRAMAS.md).



## Herramienta de autoría de diagramas

Archify 3.2.0 convierte candidatos JSON respaldados por código en HTML autónomo y exportaciones. Se usa para explicar los modelos y el flujo de creación de GPB. Inicio e instalación oficiales: https://github.com/tt-a1i/archify#readme. Requisitos: Node y Chrome local para las validaciones de navegador; paquete ya disponible en `.agents/skills/archify`, sin instalación nueva. No se actualizó. Los recibos finalize verifican installedVersion 3.2.0. Comprobación funcional: `node .agents/skills/archify/bin/archify.mjs finalize <tipo> <candidato> <salida> --repo-root . --quality showcase --json`, desde raíz de MERN-electron; los comandos exactos por artefacto constan en DIAGRAMAS.md. El estudiante sólo abre los HTML, sin necesitar esta herramienta.

Las fichas completas del entorno inicial se conservan en docs/etapas/01/FUENTES.md. La documentación web de Mongoose consultada muestra 9.12.2; GPB mantiene 9.12.0 y su lock, comprobados contra Atlas 8.0.37. Los documentos oficiales describen APIs generales; límites de texto, orden de opciones, propiedad y paginación son decisiones de GPB.
