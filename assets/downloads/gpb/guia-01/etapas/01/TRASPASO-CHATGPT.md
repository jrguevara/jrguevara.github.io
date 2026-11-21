> **Resultado vigente, 12 de noviembre de 2026:** guía final y reproducida en `docs/guias/01-CONFIGURACION-Y-AUTENTICACION.md`. Informe completo: `docs/etapas/01/VERIFICACION.md`. La reproducción fue autorizada expresamente y todas las comprobaciones de etapa 1 pasaron. La publicación espera indicaciones del docente.

# Material técnico para ChatGPT — etapa 1 de GPB

Fecha: 12 de noviembre de 2026. **Guía final y reproducción completadas; material técnico de respaldo.** Este archivo y REGISTRO.md no son la guía final.

## Criterios para mantener la guía

La guía 1 ya está redactada, revisada y reproducida. Para futuras correcciones, conservar español y Markdown y el nivel de estudiantes con conocimientos previos de JavaScript, React y Electron. Aplicar el formato de PLANIFICACION.md: objetivos, requisitos, comandos con carpeta, rutas, código progresivo, explicación, comprobaciones esperadas, errores frecuentes y conexión con la etapa siguiente. Introducir cada herramienta con los seis puntos documentados en FUENTES.md. No inventar comandos, código, versiones ni resultados. No asumir acceso a rutas locales o a este chat: el docente debe adjuntar los archivos indicados.

**Objetivo:** base React/Express y autenticación con registro, correo/contraseña, acceso protegido y cierre de sesión. **Siguiente entrega:** modelos y gestión de Gunpla, grados y escalas; no adelantar CRUD, imágenes, gráficos, alojamiento ni paquete.

## Estado que debe conservarse en la guía

- Comprobados localmente: versiones, instalación congelada, cliente compilado/revisado, pruebas HTTP de autenticación, navegador y transporte mínimo Electron con reapertura.
- Atlas MongoDB 8.0.37: conexión, índices únicos, Argon2id, persistencia connect-mongo y revocación comprobados. React y la entrada real de la API también pasaron el flujo completo con Atlas, incluida reapertura de navegador y reinicio de API. Las pruebas con memoria se registran por separado.
- Los números de pruebas y resultados efectivos se consultan en REGISTRO.md; resultados nuevos deben actualizarse antes de redactar la versión definitiva.
- La guía final existe y se reprodujo desde la preparación con gpb-verificar-guia. El informe VERIFICACION.md separa resultados locales, Atlas y alcance de Electron. No se ha publicado.
- Publicación real y paquete macOS arm64 se verificarán por separado en etapas 5 y 6. La prueba de etapa 1 no integra React en Electron ni genera instalador.

## Punto de partida y referencia conservada

La preparación anterior contiene planificación, AGENTS.md, skills y documentación; no había aplicación ni Git. Después del cierre técnico, el docente inicializó Git en la raíz y autorizó el primer commit de la etapa 1; consultar su identificador con `git log -1 --oneline`. Sin etiquetas ni publicación. La copia `codigo-etapa-1.zip` conserva las fuentes de esta implementación y `INVENTARIO-SHA256.txt` sus hashes. No contiene secretos, dependencias, perfiles, cookies, tokens ni compilados. Es la referencia conservada al cierre de la implementación; al corregir código se debe regenerar copia e inventario.

No ejecutar generadores sobre el código final. La CLI shadcn fija su versión, pero consulta un registro remoto de componentes que puede cambiar; el código adjunto es la referencia comprobada.

## Incrementos de la explicación y archivos nuevos

Todos los archivos de aplicación siguientes son nuevos respecto a la preparación. Ninguno sustituye código de una etapa funcional anterior.

| Incremento | Archivos que deben adjuntarse | Qué explicar |
|---|---|---|
| Entorno/workspace | package.json, pnpm-workspace.yaml, pnpm-lock.yaml, .node-version, .gitignore | Versiones exactas, Node por proyecto, un lock raíz, paquetes separados, autorización específica de argon2 |
| Base cliente | client/package.json, client/index.html, client/vite.config.js, client/jsconfig.json, client/src/main.jsx | React JavaScript, Vite+, proxy /api y alias @ |
| UI | client/components.json, client/src/index.css, client/src/components/ui/button.jsx, input.jsx, label.jsx, card.jsx | Tailwind, shadcn con tsx:false, estilos oscuros; JSX copiado, Radix/cn/CVA |
| API/configuración | server/package.json, server/.env.example, server/src/config.js, server/src/index.js | Variables privadas, conexión antes de escuchar, errores sin secretos, inicio/parada |
| Usuario | server/src/users.js | Esquema e índices únicos, hash fuera de respuestas públicas, normalización |
| Autenticación API | server/src/app.js | Validación, Argon2id, sesiones MongoDB, regeneración, CSRF/origen, límites, rutas y errores |
| Cliente autenticado | client/src/lib/api.js, client/src/auth/AuthContext.jsx, client/src/App.jsx | Token sólo en memoria, cookie HttpOnly, carga/reintento, formularios, rutas y navegación, actividad real |
| Pruebas API/Atlas | server/test/helpers.js, server/test/auth.test.js, server/scripts/check-atlas.js, server/scripts/check-web-atlas.js | Inyección de store/reloj, límites, identidades, revocación; Atlas separado de memoria |
| Transporte local | playwright.config.js, tests/local-api.js, tests/web.spec.js, tests/electron.spec.js, electron/session-probe.js | Prueba de web con mismo origen, reapertura y prueba mínima de proceso Electron |

Cambios respecto a la preparación: PLANIFICACION.md incorpora decisiones de transporte y validación; docs/ESTADO.md registra el avance; docs/etapas/01/REGISTRO.md sustituye el registro preparatorio por comandos y resultados reales; se agregan FUENTES.md, este traspaso, capturas e inventario/copia conservada. AGENTS.md y skills no se modificaron.

Además del ZIP, adjuntar **PLANIFICACION.md, AGENTS.md, docs/ESTADO.md, REGISTRO.md, FUENTES.md y este traspaso**. Las capturas de acceso pueden adjuntarse como referencia visual. Si ChatGPT no admite el ZIP, extraerlo y adjuntar todos los archivos del inventario por bloques; no asumir que basta con compartir nombres de archivos.

## Secuencia técnica comprobada y reproducción del código adjunto

Carpeta de todos los comandos: raíz de GPB, `/Users/jrguevara/Developer/MERN-electron` en el equipo del docente. En un equipo distinto, usar la raíz equivalente.

La secuencia histórica de generación y sus diagnósticos está en REGISTRO.md. Para reproducir **la referencia adjunta**, extraer fuentes en una carpeta vacía y ejecutar:

```sh
node --version
pnpm --version
pnpm install --frozen-lockfile
pnpm --filter @gpb/client exec vp --version
pnpm list -r --depth 0
pnpm check
pnpm build
pnpm test
pnpm exec playwright install chromium
pnpm exec install-electron
pnpm test:transport
```

Versiones esperadas: Node 26.13.1 y pnpm 12.18.0. Estos comandos se ejecutaron sobre la implementación; la copia ZIP también se extrajo en carpeta aislada y pasó instalación congelada (offline, con caché local), check, build, 6 pruebas API y 2 de transporte. No equivale a reproducir una guía ChatGPT ni a una máquina sin caché. El entorno debe permitir descargas e iniciar procesos locales. Los tests de transporte necesitan libres los puertos 3000 y 5173 y levantan su propia API aislada. No activar a la vez la API real de Atlas en ese puerto.

Para reconstrucción pedagógica desde preparación, ordenar escritura de archivos según la tabla y explicar el comando de generación real de REGISTRO.md. No presentar `pnpm install` como generador de los archivos escritos manualmente. No utilizar el generador actual como sustituto del código de referencia.

## Configuración y comprobaciones reales de Atlas

Crear localmente `server/.env` a partir de `.env.example`, sin sobrescribir una configuración existente. Completar el secreto y la URI propia. No incluir ese archivo en adjuntos, ejemplos, capturas o código público. Configurar usuario de base de datos, permisos e IP en Atlas.

Comandos desde raíz. Ambos verificadores se ejecutaron correctamente con la configuración local; los comandos de desarrollo se proporcionan para uso interactivo:

```sh
pnpm --filter @gpb/server check:atlas
pnpm --filter @gpb/server check:web:atlas
pnpm dev:server
# En otra terminal desde la raíz:
pnpm dev:client
```

check:atlas usa colecciones temporales exclusivas y las elimina. check:web:atlas levanta la entrada real de la API y Vite+, registra una cuenta aleatoria desde React en la colección users y la elimina al terminar junto con sus sesiones; no elimina cuentas preexistentes. Requiere NODE_ENV=development, PORT=3000 y WEB_ORIGIN=http://localhost:5173, con ambos puertos libres. No ejecutarlo sobre un servidor de producción. Registra únicamente versión del servidor y éxito/fallo. La interacción manual usa `http://localhost:5173`; mantener WEB_ORIGIN igual a ese origen, sin barra final. Un inicio de API correcto debe esperar conexión e índices.

## Comprobaciones que la guía debe enseñar

| Acción | Resultado esperado / estado |
|---|---|
| Entrar sin sesión al dashboard | Redirección a /login; comprobado en web |
| Registro válido | Usuario normalizado, contraseña hash, identidad sin hash, sesión nueva; comprobado local |
| Datos inválidos/duplicados | 400/409, sin cuenta duplicada; duplicados reales Atlas comprobados |
| Login incorrecto/correcto | 401 genérico / identidad y sesión regenerada; comprobado local |
| Reabrir navegador | Sesión conservada si vigente; comprobado local |
| Cerrar sesión y reutilizar cookie anterior | 401; comprobado local |
| Sin actividad 30 minutos | Sesión rechazada; comprobado mediante reloj controlado |
| Actividad hasta cumplir 7 días | Rechazo por límite absoluto; comprobado mediante reloj controlado |
| Sondeos GET | No renuevan inactividad; comprobado |
| Token/origen incorrectos en POST | 403; comprobado |
| Dos cuentas | Identidades separadas; propiedad de Gunpla corresponde a etapa 2 |
| Reiniciar proceso Electron | Cookie persistente; revocación tras logout; comprobado en prueba mínima |
| Reiniciar API con connect-mongo | Sesión persistente; comprobado con MongoDB 8.0.37, también desde React |
| Cookie Secure detrás de proxy HTTPS | Prueba local de configuración; no equivale a despliegue HTTPS real |

## Decisiones que no debe alterar la redacción

- Sesión de servidor, no JWT ni almacenamiento de tokens en localStorage.
- Inactividad 30 min y límite absoluto 7 días son decisiones de GPB. El servidor mantiene ambos tiempos y no usa el TTL como autorización.
- Usuario 3–30 caracteres ASCII, minúsculas, números, guion o guion bajo; correo normalizado; contraseña 12–128 sin recortar.
- Origen web único para `/api`. No depender de cookies de terceros. Render requiere comprobar el proxy/rewrite real en etapa 5.
- En Electron se conserva el almacén nativo de cookies y fetch Node desde el proceso principal; no se amplía CORP/CORS de la API. El renderer no tiene acceso a cookies. La interfaz preload limitada con validación de remitente corresponde a etapa 6.
- Mantener seis entregas y evaluación independiente. No exigir Windows/Linux.
- No incluir Atlas URI real, cookies, hashes de usuarios reales ni SESSION_SECRET.

## Errores observados que conviene explicar

Sintaxis --directory incompatible con plantilla externa; pnpm 12 configura instalación en workspace; dependencia CVA requerida por Button; descarga explícita de Electron 45; top-level await del arranque Electron; CORP bloquea recursos de origen opaco; recursos y pruebas deben ejecutarse mientras sus servidores están vivos. Consultar soluciones concretas en REGISTRO.md, sin enseñar diagnósticos descartados como pasos finales.


## Resultado de cierre de implementación

- API local: 6/6 pruebas. Transporte local Chromium/Electron: 2/2. Cliente: check sin advertencias y build correcto.
- check:atlas: código 0, MongoDB 8.0.37; limpieza temporal correcta.
- check:web:atlas: código 0; registro real desde React, hash persistido, reinicio de navegador y API, navegación, contraseña incorrecta, nuevo acceso y cierre; cuenta y sesiones exclusivas eliminadas y procesos detenidos. Sin capturas ni registros de credenciales.
- La reproducción técnica aislada anterior acreditó las fuentes de aplicación, instalación congelada y pruebas sin Atlas. La copia final agrega únicamente el verificador web Atlas y su script de paquete, además de actualizar README; no cambia código de aplicación. Este verificador adicional se ejecutó contra la aplicación real y Atlas.
- La guía final y su reproducción independiente están completadas. El despliegue y paquete siguen en etapas 5 y 6.
- `MATERIAL-CHATGPT.zip` reúne fuentes y documentos necesarios para el traspaso, sin .env ni dependencias. `codigo-etapa-1.zip` conserva sólo las fuentes e inventario de hashes.
