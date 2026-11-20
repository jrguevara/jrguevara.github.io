# Fuentes de la etapa 4

Consulta: 19/11/2026.

## Recharts 3.10.1

1. Biblioteca de gráficos componibles para React.
2. GPB la usa para la dona de estados y las barras por grado, con tamaño adaptable, información contextual y navegación por teclado.
3. [Inicio oficial](https://recharts.github.io/en-US/guide/) e [instalación oficial](https://github.com/recharts/recharts#installation).
4. Node.js 26.13.1, pnpm 12.18.0 y React/React DOM 19.3.1 en macOS arm64. El registro declaró compatibilidad con React 19 y requiere `react-is`, fijado a 19.3.1 para coincidir con React.
5. Desde `gpb-dev/guia-04`, `pnpm --filter @gpb/client add --save-exact recharts@3.10.1 react-is@19.3.1`.
6. `pnpm view recharts@3.10.1 version peerDependencies --json` y `pnpm view react-is@19.3.1 version` confirmaron las referencias antes de instalar. `pnpm --filter @gpb/client list recharts react-is --depth 0` comprueba las versiones instaladas. `pnpm build` y el recorrido `tests/dashboard.spec.js` comprueban la compilación y el renderizado de ambos gráficos.

## Chart de shadcn/ui

1. Código fuente reutilizable para componer y dar estilo a gráficos de Recharts.
2. GPB aprovecha el contenedor adaptable, la configuración por serie y el tooltip con su tema oscuro.
3. [Documentación oficial de Chart para Radix y Recharts 3](https://ui.shadcn.com/docs/components/radix/chart) y [registro oficial New York v4](https://ui.shadcn.com/r/styles/new-york-v4/chart.json).
4. Cliente React, Tailwind 4.3.5, `cn` 0.5.2 y Recharts 3.10.1. El CLI de referencia 4.23.0 se consultó con `pnpm view shadcn@4.23.0 version`. El componente se incorpora manualmente.
5. Se consultó primero el registro New York anterior, que apuntaba a Recharts 2. Se descargó después el registro New York v4 con `curl -fsSL https://ui.shadcn.com/r/styles/new-york-v4/chart.json -o /private/tmp/gpb04-chart-v4.json`. La adaptación docente en `client/src/components/ui/chart.jsx` conserva contenedor, contexto y tooltip, con JavaScript, variables de estilo locales y la dependencia fijada del curso.
6. Desde `gpb-dev/guia-04`, `pnpm check`, `pnpm build` y `pnpm test:transport tests/dashboard.spec.js` comprueban que el componente funciona en el cliente. El código incorporado se identifica por la ruta y el inventario de fuentes de la etapa.

## MongoDB

GPB conserva la configuración de MongoDB Atlas de etapas previas. La comprobación del repositorio puede ejecutarse contra una instancia local y desechable según la [documentación oficial de MongoDB Community para macOS](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-os-x-tarball/) y su [catálogo de descargas](https://www.mongodb.com/try/download/community-edition/releases). El comando del verificador y su resultado se registran por separado en REGISTRO.md.
