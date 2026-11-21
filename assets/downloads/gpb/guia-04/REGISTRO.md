# GPB · Etapa 4: registro técnico

Inicio autorizado el 19/11/2026. Base conservada en `gpb-dev/guia-03`. Implementación y comprobaciones en `gpb-dev/guia-04`. El repositorio raíz estaba en `main`, HEAD `5e34cf3`, con la etapa 3 y otros archivos docentes locales. La referencia exacta de etapa 4 se identifica por su [inventario](INVENTARIO-SHA256.txt).

## Incrementos y decisiones

1. Copiar selectivamente fuentes, pruebas, manifiestos y lock de la etapa 3.
2. Ampliar el listado sin cambiar sus campos de respuesta. Validar `q`, `grade`, `scale`, `state` y `page`. La búsqueda es por fragmento literal de hasta 120 caracteres tras recortar espacios y sin distinguir mayúsculas. Los filtros se combinan con AND. El orden usa fecha de creación e identificador descendentes. Se conservan 12 elementos por página.
3. Agregar `GET /api/dashboard`. Ambas consultas toman el propietario de la sesión y excluyen registros eliminados lógicamente. La agregación obtiene recuentos por estado y grado y los cinco últimos registros agregados, con el mismo criterio de orden. Los estados ausentes cuentan como cero. Los grados sin registros se omiten y una referencia desaparecida se agrupa como «Grado no disponible».
4. Sustituir el inicio protegido por el dashboard. Cargar sus gráficos al visitar la ruta. El formulario de exploración aplica los filtros al enviarse y guarda sus valores en la URL. Aplicar o quitar filtros vuelve a la primera página. Mostrar mensaje y acción para la colección vacía, resultados sin coincidencias y páginas fuera de rango.
5. Verificar la API, el cliente, el repositorio y el recorrido de interfaz. Preparar [capturas reales](CAPTURAS-APP.md), [diagrama](DIAGRAMAS.md) y [traspaso editorial](TRASPASO-CHATGPT.md).

## Comandos ejecutados

Carpeta `gpb-dev/guia-04`, salvo indicación. Entorno: macOS 27.0.1 arm64, Node.js 26.13.1, pnpm 12.18.0, Vite+ 1.6.0 y Vite 8.3.7.

| Comando | Resultado |
|---|---|
| Desde `gpb-dev`, `mkdir guia-04` y `rsync -a --exclude=node_modules --exclude=dist --exclude='.env' --exclude='test-results' --exclude='.vite*' --exclude=README.md --exclude=.DS_Store guia-03/ guia-04/` | Fuentes copiadas. El único archivo de entorno de la nueva versión es `server/.env.example`. |
| `pnpm install --frozen-lockfile` | Instalación desde el lock heredado. La primera ejecución restringida no resolvió el registro. La repetición con acceso autorizado reutilizó 317 paquetes del almacén local. |
| `pnpm view recharts@3.10.1 version peerDependencies --json`, `pnpm view react-is@19.3.1 version`, `pnpm view shadcn@4.23.0 version` | Versiones disponibles y compatibilidad declarada con React 19. |
| `pnpm --filter @gpb/client add --save-exact recharts@3.10.1 react-is@19.3.1` | Dependencias instaladas, con lock de etapa actualizado. |
| `pnpm --filter @gpb/client list recharts react-is --depth 0` y `pnpm install --frozen-lockfile` | Versiones exactas confirmadas. Reinstalación congelada aprobada. |
| `pnpm --filter @gpb/client exec vp --version` | Vite+ 1.6.0 y Vite 8.3.7. |
| `pnpm test` | 22/22 aprobadas. La ejecución requiere que Node pueda abrir puertos locales. |
| `pnpm --filter @gpb/client exec vp check --fix`, `pnpm check` y `pnpm build` | Revisión aprobada sin advertencias. Compilación de 583 módulos con la entrada principal y el dashboard en archivos independientes. |
| `GPB_DASHBOARD_CAPTURES="$PWD/../../docs/etapas/04/capturas" pnpm test:transport` | 5/5 aprobados. Generó 22 capturas y el manifiesto. |
| Desde la raíz del repositorio, `node .agents/skills/archify/bin/archify.mjs finalize dataflow .archify/dataflow-gpb-dashboard-exploracion-20261119-160000/candidate.json .archify/dataflow-gpb-dashboard-exploracion-20261119-160000/gpb-dashboard-exploracion.html --quality showcase --json` | Validación, entrega, integridad y navegador aprobados. PNG y SVG oscuro se descargaron desde el menú del visor con Chromium. |

[Fuentes oficiales y formato de herramientas](FUENTES.md).

## Nuevos o modificados

| Área | Nuevos o modificados |
|---|---|
| API | `server/src/collection-routes.js`, `server/src/gunpla.js`, `server/src/exploration.js` |
| Inicio y lista | `client/src/App.jsx`, `client/src/dashboard/Dashboard.jsx`, `client/src/collection/Collection.jsx`, `client/src/lib/resource.jsx`, `client/src/components/ui/chart.jsx`, `client/src/index.css` |
| Dependencias | `client/package.json`, `pnpm-lock.yaml` |
| Pruebas | `server/test/collection-helpers.js`, `server/test/collection.test.js`, `server/scripts/check-exploration-mongo.js`, `tests/dashboard.spec.js` |
| Uso de la versión | `README.md` |

La primera compilación indicó un archivo superior a 500 kB. La carga diferida del dashboard redujo el archivo de entrada a 315.58 kB. El primer recorrido de navegador encontró dos controles llamados «Nombre» durante el cambio de ruta. La etiqueta «Buscar por nombre» distingue la exploración del formulario de alta y la suite completa aprobó tras el ajuste.

## Alcance comprobado

Las pruebas de API con dos usuarios verifican la privacidad, búsquedas literales, filtros simultáneos, 13 coincidencias en dos páginas, parámetros inválidos y cambios de estadísticas después de crear, editar y eliminar. Los recorridos de transporte prueban la interfaz en Chromium con adaptadores de memoria, además del transporte preparatorio de sesión de Electron. La redacción y reproducción formal de la guía 4 y su publicación son pasos editoriales posteriores.

### MongoDB Community local

La URL de 8.0.39 devolvió HTTP 403. El catálogo oficial ofrecía 8.0.38 para macOS arm64. Se descargó `https://fastdl.mongodb.org/osx/mongodb-macos-arm64-8.0.38.tgz` con `curl -fsSL` a una carpeta temporal y se extrajo `mongodb-macos-aarch64--8.0.38/bin/mongod` con `tar -xzf`. Se inició con `--bind_ip 127.0.0.1 --port 37104 --dbpath <directorio-temporal>/db --logpath <directorio-temporal>/mongo.log --pidfilepath <directorio-temporal>/mongo.pid --fork`.

Desde `gpb-dev/guia-04`, `node server/scripts/check-exploration-mongo.js 37104` aprobó contra MongoDB 8.0.38. Se verificaron el aislamiento de dos propietarios, el registro previo a la marca de borrado lógico, la exclusión de registros ocultos, la búsqueda literal de corchetes y un separador Unicode, los filtros antes de paginar, recuentos, recientes ordenados por creación y cambios por edición y eliminación. El verificador elimina su base aleatoria y el proceso se detiene al salir. Esta prueba usa el repositorio Mongoose real con MongoDB local. Atlas y Cloudinary no se volvieron a probar para esta etapa.

### Cierre editorial

El docente autorizó redactar y publicar con fecha editorial 17/11/2026. Se refinó el singular «1 modelo encontrado». El recorrido editorial crea el kit RG MS-06F Zaku II con sus datos de catálogo y carga sus dos fotografías con licencia abierta. La cuenta, los estados y las notas son de demostración. Se renovaron las 22 capturas y se repitieron los cinco recorridos. El [informe de reproducción](VERIFICACION.md) documenta la reconstrucción desde guia-03 con 13 bloques de archivo.
