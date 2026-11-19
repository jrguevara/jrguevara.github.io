# Traspaso — guía 3 de GPB

Objetivo: completar el detalle de cada Gunpla mediante portada, galería, etiquetas y video opcional. Base: guía 2 conservada en `gpb-dev/guia-02`, commit raíz 5e34cf3. Versión de trabajo: `gpb-dev/guia-03`, sin commit todavía. El docente autorizó también la redacción y reproducción de la guía 3 por Codex; no autorizó publicaciones ni commits por iniciar esta entrega.

## Alcance y conocimientos previos

JavaScript ES Modules, React, HTTP, MongoDB y las guías 1/2. Se conservan autenticación, sesiones con límites previos, CSRF, propiedad, catálogos, CRUD y paginación. No se adelantan dashboard, estadísticas, búsqueda/filtros, Render ni empaquetado.

Incrementos: validación real y normalización de imagen; proveedor sólo del servidor; diario y bloqueo persistente; portada/galería y recuperación; etiquetas/YouTube; interfaz oscura; pruebas locales y externas separadas. Comandos reales en REGISTRO.md y fichas oficiales en FUENTES.md. Resultado de reproducción en VERIFICACION.md.

## Material que adjuntar

- `docs/guias/03-IMAGENES-Y-DETALLE-COMPLETO.md`: guía redactada con 24 bloques de archivo completos.
- `docs/etapas/03/REGISTRO.md`, `FUENTES.md`, `VERIFICACION.md` y `DIAGRAMAS.md`.
- `docs/etapas/03/codigo-etapa-3.zip`: fuentes selectivas del proyecto, con lock, sin secretos ni dependencias.
- `docs/etapas/03/INVENTARIO-SHA256.txt`: versión exacta del material.
- `docs/etapas/03/ARCHIVOS.md`: archivos nuevos/modificados respecto a guía 2.
- PNG/SVG oscuros e HTML interactivos indicados en DIAGRAMAS.md.

ChatGPT no tiene acceso implícito a estas rutas ni al proyecto. Adjuntar los archivos o el paquete completo, no sólo enviar los nombres.

## Secuencia para el lector

Desde gpb-dev crear guia-03 mediante la copia selectiva de la guía, comprobar Node/pnpm, instalar las tres versiones exactas, completar los 24 bloques, configurar un .env privado propio, comprobar instalación congelada, check/build/tests/transporte, ejecutar catálogos y verificadores reales con las cuentas del lector. La guía contiene el contenido literal y las carpetas. Reproducirla se documenta por separado; pasar pruebas con el código final no equivale a ejecutar sus instrucciones.

## Criterios editoriales

Español, Markdown, propósito y conexión entre cambios; código completo y explicación antes de cada archivo. Mantener el formato de fuentes de PLANIFICACION: descripción, motivo, Getting Started oficial, requisitos/versiones, instalación y comprobación. No inventar CLI de versiones para SDKs, disponibilidad de servicios, URL de publicación ni reproducción remota de YouTube.

Distinguir comprobado local, Atlas real con proveedor simulado y Atlas/Cloudinary reales. No declarar lista para grabar mientras falte una comprobación requerida. Mantener las correcciones sincronizadas con código, guía e inventario. Diagramas y capturas oscuros; SVG de tema oscuro fijo. Los diagramas son conceptuales mientras no exista un commit autorizado de esta entrega.

La guía 4 introducirá resumen y exploración. La publicación editorial exige fecha y autorización propias. Canvas necesita semana, sesión, fecha, modalidad, video si existe, confirmación de foro y URL pública real. No reutilizar automáticamente los datos de la guía 2.
