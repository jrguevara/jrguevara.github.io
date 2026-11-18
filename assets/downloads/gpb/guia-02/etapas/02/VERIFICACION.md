# Verificación — guía 2

Fecha: 18 de noviembre de 2026. **Reproducción completa de los pasos de código y comandos aprobada desde la guía 1.** La publicación del blog se documenta por separado en PUBLICACION.md; no equivale al despliegue de GPB en Render.

## Punto de partida y método

Base: fuentes de `gpb-dev/guia-01` del commit 91c189e, preservadas. Copia temporal: `/private/tmp/gpb-reproduccion-02-hefd2ag5/guia-01`. Se ejecutó la preparación de la guía (mkdir, rsync selectivo y copias explícitas de manifiestos/lock/configuración), creando su hermana guia-02. No se copió la aplicación final como sustituto del recorrido.

Se transcribieron del Markdown los 15 bloques marcados como archivos. Se compararon todos los archivos de aplicación y el lock con `gpb-dev/guia-02`: coinciden byte por byte. README del paquete es documentación adicional y no forma parte de los 15 bloques. La guía fuente se conserva en `docs/guias/02-GESTION-DE-LA-COLECCION.md`; su SHA-256 final está en INVENTARIO-SHA256.txt.

## Entorno

macOS arm64, Node 26.13.1, pnpm 12.18.0, Vite+ 1.6.0; React 19.3.1, Express 5.3.0, Mongoose 9.12.0. Instalación congelada: 303 paquetes reutilizados. Sin cambios globales ni modificación del lock.

## Secuencia comprobada

Carpeta de comandos de aplicación: `/private/tmp/gpb-reproduccion-02-hefd2ag5/guia-02`.

| Comprobación | Resultado |
|---|---|
| Preparación literal, versiones e instalación congelada | Aprobados |
| cp del ejemplo, permisos 0600 y generación independiente de secreto | Aprobados tras corregir un escape en el texto |
| 15 archivos de la guía y resto de fuentes heredadas | Coinciden con la referencia |
| pnpm check | 15 archivos con formato correcto; 10 revisados sin errores/advertencias |
| pnpm build | 206 módulos; aprobado |
| pnpm test | 12 aprobadas, cero fallidas |
| pnpm exec playwright install chromium; pnpm exec install-electron | Binarios disponibles |
| pnpm test:transport | 3 aprobadas, 5,2 s; CRUD React, móvil, errores, sesión web y Electron |
| pnpm --filter @gpb/server seed:catalogs, dos veces | Ambas código 0 |
| pnpm --filter @gpb/server check:atlas | Código 0, MongoDB 8.0.37; índices, hash, persistencia y revocación |
| pnpm --filter @gpb/server check:collection:atlas | Código 0; carga idempotente, CRUD React, propiedad con dos usuarios, reinicios y limpieza |

Para los comandos de Atlas se heredó en memoria la configuración privada local existente mediante Node `--env-file` y spawnSync de los cuatro comandos anteriores; no se copió la URI al proyecto conservado ni se imprimió. La copia temporal recibió su propio .env del ejemplo y un secreto independiente. El verificador de colección sustituye el secreto por otro efímero para su ejecución.

## Diferencias detectadas y corregidas

La primera versión del comando de generación de secreto convirtió un escape de salto de línea en un salto literal dentro de JavaScript y no se ejecutó. Se cambió a `String.fromCharCode(10)`, se repitió el comando completo y se verificaron el archivo y los permisos. La guía final contiene la corrección. Un intento preliminar de comprobaciones ocurrió antes de transcribir los bloques y sólo verificó guía 1; se descartó como evidencia de etapa 2. Después de transcribir se repitieron todas las comprobaciones y se obtuvieron los resultados de esta tabla.

## Alcance y limpieza

Las pruebas locales usan adaptadores de memoria; las reales utilizan los modelos Mongoose y Atlas, incluida la entrada de API de producción en modo desarrollo. Las cuentas, sesiones y Gunpla temporales fueron eliminados; los catálogos compartidos permanecen como datos de la etapa. Se cerraron procesos y perfiles de pruebas. La copia temporal de reproducción se eliminará al cerrar la entrega, sin tocar las versiones conservadas.

No hay pendientes funcionales de etapa 2. Render/HTTPS y el paquete macOS corresponden a etapas 5/6. La prueba Electron no demuestra todavía una interfaz integrada ni un paquete.
