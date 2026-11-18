# Etapa 2 — registro técnico

Fecha: 18 de noviembre de 2026. Base: commit `91c189e`, `gpb-dev/guia-01` conservado sin modificaciones. Implementación independiente: `gpb-dev/guia-02`. No se alteró la aplicación de referencia raíz.

## Incrementos y decisiones

1. Copia selectiva de client, server, electron, tests, manifiestos, lock, configuración de Vite+/Playwright y ejemplo de entorno. Excluidos secretos, dependencias, compilaciones, perfiles y evidencias anteriores.
2. Modelos Grade, Scale y Gunpla, carga idempotente por nombre con índices únicos, consulta ordenada por order/_id. Referencias independientes.
3. Router protegido detrás de autenticación y CSRF existentes; consultas por owner e identificador, proyección pública sin propietario. PUT reemplaza todos los campos editables.
4. Tarjetas, detalle, formulario compartido, confirmación de eliminación, portada de reemplazo en CSS, estados de carga/error y paginación de 12 registros.
5. Pruebas locales y comprobación real con Atlas; documentación y diagramas vinculados al código.

Nombre: 1–120 caracteres tras recortar espacios; descripción y notas: hasta 1000 cada una. Estado: Sin armar, En progreso o Armado; predeterminado Sin armar. Se rechazan propiedades adicionales, operadores MongoDB, ids malformados y opciones inexistentes. Propietario y fechas son del servidor. Se conservan cuerpo máximo de 8 KB, CSRF, cookie y límites de sesión. Un registro ajeno y uno inexistente devuelven el mismo 404. Catálogos de sólo lectura para usuarios autenticados; no hay administración de catálogos.

## Entorno y comandos reales

Salvo indicación, carpeta: `/Users/jrguevara/Developer/MERN-electron/gpb-dev/guia-02`.

| Comando | Resultado |
|---|---|
| `node --version`, `pnpm --version`, `uname -m` | 26.13.1, 12.18.0, arm64 |
| `pnpm install --frozen-lockfile` | 303 paquetes reutilizados, sin cambiar lock ni herramientas globales; Argon2 operativo |
| `pnpm list -r --depth 0` | Dependencias exactas de guía 1 conservadas |
| `pnpm --filter @gpb/client exec vp --version` | Vite+ 1.6.0, Vite 8.3.7, Rolldown 1.2.18 |
| `pnpm --filter @gpb/client exec vp check --fix` | Formato corregido; 10 archivos revisados sin advertencias |
| `pnpm build` | Aprobado, 206 módulos |
| `pnpm test` | 12/12 aprobadas: seis de autenticación y seis de colección |
| `GPB_CAPTURE_DIR=/Users/jrguevara/Developer/MERN-electron/docs/etapas/02/capturas pnpm test:transport` | 3/3: colección, navegador y Electron; 10 s |

No se instalaron dependencias nuevas: Express 5.3.0, Mongoose 9.12.0, Zod 4.6.7, React 19.3.1, Router 8.5.1, Tailwind 4.3.5. El lock no cambió. Las fuentes y fichas están en FUENTES.md.

## Diagnósticos separados de la secuencia docente

- El primer intento de instalación restringido no pudo resolver el registro y eligió un almacén local. La repetición con acceso autorizado reutilizó el almacén existente; `.pnpm-store/` queda ignorado.
- Un primer `pnpm test` se ejecutó por error desde la raíz y no pudo abrir un puerto por restricciones. No fue una comprobación de etapa 2. Se repitió desde guia-02 con acceso local autorizado: 12 aprobadas.
- La primera revisión detectó formato en Collection.jsx e index.css; se corrigió con Vite+ antes de compilar. Dos intentos de escritura con rutas relativas a una carpeta incorrecta no cambiaron los archivos previstos; se corrigió la carpeta y se ejecutaron los comandos finales.
- Atlas y reproducción de la guía: resultados finales se incorporarán tras completar esas comprobaciones. No se consideran aprobados por las pruebas de memoria.

No se registran variables privadas, cookies ni tokens. Para las comprobaciones de esta sesión puede cargarse el archivo privado ya existente mediante Node sin copiarlo a guia-02; el verificador genera un secreto de sesión efímero propio. El estudiante configura su propio `.env`.

## Comprobación real de colección con Atlas

Carpeta: `gpb-dev/guia-02/server`. Comando real de esta sesión: `node --env-file=../../guia-01/server/.env scripts/check-collection-atlas.js`. Lee la configuración privada existente sin copiarla; el propio verificador sustituye el secreto por uno aleatorio efímero.

Resultado: código 0. Catálogos cargados dos veces con iguales ids y orden, 12 grados y 5 escalas. Registro desde React, persistencia del hash, creación de Gunpla con referencias reales, estado inicial, aislamiento de dos usuarios en listado/consulta/PUT/DELETE, reapertura de navegador y reinicio de API, persistencia del registro y sesión, edición a Armado, eliminación, rechazo de contraseña incorrecta, nuevo acceso y cierre de sesión aprobados. Sólo se limpiaron cuentas/sesiones/registros exclusivos de la prueba; los catálogos compartidos permanecen como datos iniciales de la etapa.

El comando docente equivalente, una vez configurado su propio server/.env, es `pnpm --filter @gpb/server check:collection:atlas` desde guia-02. No sustituye las comprobaciones de Render ni del paquete macOS.
