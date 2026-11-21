# Guía 1 — verificación y reproducción

Fecha: 12 de noviembre de 2026.

## Dictamen

**Reproducción funcional completa desde la preparación: aprobada. Guía técnicamente lista para grabar.** No se publicó ni se generó un paquete de distribución. El docente autorizó expresamente la reproducción en copia aislada, incluidas las pruebas con Atlas y la limpieza de sus datos temporales.

Guía revisada: `docs/guias/01-CONFIGURACION-Y-AUTENTICACION.md`, versión final comprobada. SHA-256:

```text
fecd021e4242baaab820da05172b8cbd50769d64cef55d7c96ed4a2461c18d53
```

Código de referencia: commit `9900285`, rama `main`, «Completa la etapa 1: configuración y autenticación». No se modificó código de aplicación para conseguir los resultados. Se corrigieron dos aclaraciones de la guía: dirección del navegador y nombre de rama local.

## Punto de partida y método

Carpeta aislada: `/private/tmp/gpb-guia01-validacion-j2m7nkqi`.

Se partió de una carpeta nueva con documentos de preparación, sin aplicación ni dependencias. **No se copió la aplicación final al directorio de reproducción.** Se transcribieron los 33 bloques de archivo de la guía en grupos, siguiendo la secuencia: manifiestos, instalación, API, configuración privada, cliente, recorrido web y comprobaciones. Se tomó únicamente `pnpm-lock.yaml` del ZIP de referencia, como instruye el apartado 2.2. Cada archivo se comparó al terminar con el bloque correspondiente; los 33 coinciden.

Node, pnpm, el clúster y la cuenta Atlas ya estaban disponibles como prerrequisitos. Se reutilizaron las cachés de paquetes y ejecutables. Esto acredita la reproducción desde la preparación declarada, no la instalación de herramientas en un sistema operativo vacío ni la creación de una nueva cuenta o clúster Atlas.

Las acciones de navegador del apartado 6 se realizaron mediante un operador automatizado temporal, fuera del proyecto reproducido, con la entrada real de API y el cliente iniciados por sus comandos de desarrollo. No se agregaron anticipadamente archivos de producto faltantes para completar ese apartado. Después se transcribieron y ejecutaron, por separado, los archivos de pruebas del apartado 7.

La URI se configuró privadamente a partir de la conexión ya autorizada del docente; no se imprimió. El comando de la guía generó un secreto nuevo para la copia aislada. Al terminar se eliminó su `.env` y se conservó intacta la configuración original.

## Entorno observado

| Elemento | Resultado |
|---|---|
| Plataforma | macOS arm64 |
| Node.js | v26.13.1 |
| pnpm | 12.18.0 |
| Vite+ global/local | 1.6.0 |
| Vite / Rolldown | 8.3.7 / 1.2.18 |
| Vitest / Oxfmt / Oxlint | 5.1.0 / 0.78.0 / 1.93.0 |
| oxlint-tsgolint / tsdown | 7.0.2006 / 0.23.4 |
| React / React DOM | 19.3.1 / 19.3.1 |
| Driver MongoDB compartido | 7.8.0 |
| Playwright / Electron | 1.65.0 / 45.3.1 |
| MongoDB Atlas real | 8.0.37 |
| Git | 2.41.0 |

El resto de versiones directas se confirmó mediante `pnpm list -r --depth 0` y coincide con los manifiestos y FUENTES.md. No se actualizaron dependencias ni herramientas globales.

SHA-256 del lock utilizado y conservado sin cambios:

```text
907d346cd6fe931b3d79733200b5879445c5126a134e5996466d58248fcc3f78
```

## Secuencia ejecutada y resultados

Todos los comandos siguientes se ejecutaron desde la raíz de la copia aislada, salvo la invocación del operador temporal. Los comandos de desarrollo se ejecutaron en procesos separados y se detuvieron antes de las pruebas que requieren puertos libres.

| Apartado | Comandos o acción | Resultado |
|---|---|---|
| 1 y 2 | `node --version`, `pnpm --version`, `uname -m` | Versiones y arm64 correctos |
| 2 | Escritura de seis archivos de configuración y copia exclusiva del lock adjunto | Correcto, sin aplicación final preinstalada |
| 2 | `pnpm install --frozen-lockfile` | Correcto: 303 paquetes reutilizados, script nativo argon2 correcto |
| 2 | `pnpm --filter @gpb/client exec vp --version` | CLI y paquete local 1.6.0 |
| 2 | `pnpm list -r --depth 0` y `pnpm --filter @gpb/server why mongodb` | Versiones exactas; driver único 7.8.0 |
| 3 y 4 | Transcripción de API y `.env.example`; `cp -n server/.env.example server/.env`; configuración privada de URI y comando de secreto de la guía | Configuración correcta; valor secreto oculto |
| 4 | `pnpm dev:server` | API inició después de conexión e índices Atlas |
| 4 | `curl http://127.0.0.1:3000/api/health` | `{"status":"ok"}` |
| 5 y 6 | Transcripción de cliente y `pnpm dev:client` | Vite+ inició correctamente |
| 6 | Formularios y navegación sobre API real/Atlas | Registro, hash persistido, sesión y navegación correctos |
| 6 | Cierre de navegador, Ctrl+C de API, `pnpm dev:server`, reapertura del mismo perfil | La identidad persistió |
| 6 | Contraseña incorrecta, nuevo acceso y logout | Rechazo y acceso correctos; cierre confirmado |
| 6 | `pnpm check` | 14 archivos bien formateados; revisión de 9 archivos sin errores ni advertencias |
| 6 | `pnpm build` | Correcto: 205 módulos |
| 7 | Transcripción de fixtures, pruebas y verificadores desde sus bloques | Correcto, sin ajustes silenciosos |
| 7.1 | `pnpm test` | 6 aprobadas, 0 fallidas |
| 7.3 | `pnpm exec playwright install chromium`, `pnpm exec install-electron` | Correcto; ejecutables disponibles mediante caché |
| 7.3 | `pnpm exec playwright --version`, `pnpm exec electron --version` | 1.65.0 y v45.3.1 |
| 7.3 | `pnpm test:transport` | 2 aprobadas, 0 fallidas, 4,0 s |
| 7.4 | `pnpm --filter @gpb/server check:atlas` | Código 0, MongoDB 8.0.37 |
| 7.4 | `pnpm --filter @gpb/server check:web:atlas` | Código 0, flujo completo y limpieza correctos |
| 9 | `git --version`, `git init`, `git branch -m main`, `git status --short`, `git check-ignore -v server/.env node_modules client/dist` | Rama main y exclusiones correctas, sólo en copia aislada |

La ejecución opcional del generador shadcn se omitió tal como indica la guía: el recorrido requerido escribe los cuatro componentes comprobados. No se generaron versiones nuevas desde un registro mutable. Los comandos de commit de la guía son una recomendación condicionada a la decisión de conservar el trabajo; no se crearon commits adicionales por reproducirlos. El punto de control de la aplicación ya existe en el repositorio del docente.

## Comprobaciones funcionales

### API local con reloj y almacén de prueba

Se verificaron hash Argon2id, regeneración del identificador al autenticar, respuesta sin hash, revocación de la cookie anterior, login incorrecto/correcto, entradas inválidas, duplicados, CSRF y origen, identidades separadas, inactividad sin renovación por GET, actividad explícita, límite absoluto, rate limiting, JSON inválido, cuerpo excesivo y cookie Secure tras un proxy HTTPS simulado.

El aislamiento entre identidades de esta etapa está comprobado; la propiedad de registros Gunpla aún no existe y corresponde a etapa 2. No hay imágenes ni límites de imágenes implementados todavía.

### Navegador y Electron locales

Chromium comprobó registro, ruta protegida, reapertura de perfil persistente, navegación, logout, credenciales incorrectas/correctas y ancho móvil. Electron comprobó transporte del proceso principal con partición persistente y revocación tras reiniciar. Es una prueba preparatoria, sin React integrado en Electron ni paquete macOS.

### Atlas real

El verificador de API probó índices únicos, hash, persistencia mediante connect-mongo al reiniciar API y revocación. El verificador web usó React, proxy Vite+ y la entrada real de Express con Mongoose. Ambos terminaron con código 0. Las colecciones temporales del primero, la cuenta/sesiones del segundo y las del operador de navegador se limpiaron correctamente.

## Diferencias detectadas y resolución

1. **Dirección que imprime Vite+.** Puede anunciar `http://127.0.0.1:5173/` aunque el origen de GPB sea `http://localhost:5173`. La guía ya indicaba localhost; se hizo explícito que hay que escribir esa dirección y no seguir el enlace con otro hostname. El flujo se ejecutó con localhost y fue correcto. No cambió la configuración.
2. **Nombre inicial de rama Git.** Git 2.41.0 creó `master` con su configuración por defecto. Se añadió `git branch -m main` después de `git init`, sin cambiar la configuración global. Se ejecutó en la copia y confirmó main.
3. **Canal del operador de comprobación.** Al pausar el operador temporal para reiniciar la API, su entrada estándar ya estaba cerrada por la herramienta. Se reanudó únicamente ese proceso mediante su depurador local, sin leer datos privados. El navegador completó el recorrido y su limpieza; el depurador terminó con el proceso. Fue una incidencia del operador, no un paso faltante ni un error de la guía. La ejecución posterior de `check:web:atlas` —sin esa pausa— también pasó de forma independiente.

No se detectaron imports, archivos, dependencias o pasos de aplicación faltantes. No se hicieron correcciones de código para ocultar diferencias. Las dos aclaraciones de documentación se incorporaron a la versión final y se comprobaron sus acciones afectadas.

## Limpieza y alcance del cierre

Se detuvieron API, Vite+ y los procesos de navegador/Electron. Se comprobó que 3000, 5173 y el puerto del operador local quedaran libres. Se retiraron el `.env` de la copia, el script de secreto temporal y el operador temporal. Se conservan las fuentes reproducidas para consulta; ninguna copia publicada incluye credenciales. No se escribieron cookies ni tokens en este informe ni en los documentos versionados.

**No quedan pendientes funcionales requeridos de la guía 1.** La publicación espera indicaciones del docente. El despliegue real HTTPS en Render y el paquete macOS arm64 no se presentaron como comprobados: corresponden a las guías 5 y 6.
