# Publicación — guía 3

19/11/2026: el docente autoriza publicar en GitHub.io con fecha editorial **14/11/2026**. La entrada definitiva está publicada y comprobada en línea.

Destino local previsto: `/Users/jrguevara/Developer/jrguevara.github.io`. Se respetará el formato de guías previas: front matter, categorías, tabla de contenido, bloques raw para código, filtros relative_url, imágenes HTTPS y enlaces a los visores con ?theme=dark. La comprobación real de Cloudinary ya está aprobada. Fecha y publicación autorizadas; se creará únicamente el commit necesario del sitio. No se incluyen cambios de la aplicación GPB ni archivos de Canvas.

Canvas se prepara sólo para copiar una vez confirmados sus datos y la URL publicada. Se solicitó semana, sesión, fecha, modalidad, video si existe y foro. La plantilla indicada es SESION-GUIA-02.html; se conservará su paleta institucional y los diagramas GPB serán oscuros. Los archivos de guías previas no se modificarán ni se enviarán a Git sin indicación expresa.

El foro anterior https://univo.instructure.com/courses/1800/discussion_topics/7186 no se considera validado por recibir una redirección al inicio de sesión. Hace falta comprobar contenido y permisos o confirmación del docente antes de reutilizarlo.


## Borrador previo y revisión local

Archivo: `_drafts/gpb-guia-03-imagenes-y-detalle-completo.md` en el sitio. Sin fecha editorial, published:false y hidden:true. Se prepararon sólo los archivos nuevos de guía 3: entrada, seis PNG/SVG/capturas, dos HTML interactivos y documentación/descargas. No se modificaron guías anteriores ni la configuración del sitio.

Compilación local de revisión, desde el sitio: `PATH=/Users/jrguevara/.rubies/ruby-3.2.2/bin:$PATH JEKYLL_ENV=production bundle exec jekyll build --drafts --unpublished --disable-disk-cache --destination /private/tmp/gpb-guia03-site-build`. Aprobada. Las opciones draft/unpublished se usaron únicamente para visualizar el borrador en la salida temporal; no habilitan su publicación normal.

`PATH=/Users/jrguevara/.rubies/ruby-3.2.2/bin:$PATH bundle exec htmlproofer --disable-external --check-html --allow_hash_href /private/tmp/gpb-guia03-site-build`: aprobado en 134 archivos. El navegador comparó los 24 bloques completos con el Markdown, comprobó 12 destinos locales y las dos imágenes cargadas, sin desbordamiento horizontal a 1440 y 390 px. Capturas oscuras de ambos tamaños revisadas visualmente. Las fechas que Jekyll pueda asignar automáticamente a un borrador en la previsualización no constituyen una fecha editorial autorizada. Esta revisión inicial precedió a la publicación autorizada, cuyo resultado se registra a continuación.

## Publicación autorizada — 19/11/2026

El docente indicó fecha editorial 14/11/2026 y autorizó publicar. El borrador se convirtió en `_posts/2026-11-14-gpb-guia-03-imagenes-y-detalle-completo.md`, con date: 2026-11-14, published:true y hidden:false. Se retiró el borrador para evitar duplicados.

Compilación normal en producción, sin incluir borradores: salida `/private/tmp/gpb-guia03-site-publicacion`, aprobada. HTML-Proofer aprobó 134 archivos. Los 24 bloques completos coinciden con el Markdown verificado y article:published_time es 2026-11-14T00:00:00-06:00. El primer comprobador buscaba etiquetas time que este tema no utiliza; se corrigió a su metadato real, sin cambiar la fecha de la entrada.

Commit del sitio: `ad79b7d396f8aca22dbae8db75ef6a4430d3e8a7`, enviado a origin/main. Sólo entrada de guía 3 y sus 18 recursos: diagramas, imágenes y descargas. No se incluyeron archivos de Canvas ni se creó un commit en el repositorio GPB. Se conservaron los bytes de los HTML/SVG exportados y su procedencia; los avisos de espacios finales de Git en esos archivos generados no se corrigieron reescribiendo artefactos validados. Los documentos editables pasaron git diff --cached --check.

Automatic build iniciado: https://github.com/jrguevara/jrguevara.github.io/actions/runs/44613832685 . Resultado: completed / success. El despliegue de GitHub Pages 44613932023 también terminó completed / success.


## Resultado público comprobado

URL: https://jrguevara.github.io/posts/gpb-guia-03-imagenes-y-detalle-completo/ . HTTP 200, fecha editorial 14/11/2026 (article:published_time 2026-11-14T00:00:00-06:00). Los 24 bloques completos coinciden con la guía reproducida; los 12 destinos únicos del artículo, incluidas imágenes, dos SVG oscuros, dos visores interactivos y descargas, respondieron HTTP 200. Los ZIP públicos coincidieron con los archivos locales. COMPROBACION-PUBLICA.json conserva la evidencia inicial del despliegue del commit ad79b7d; sus hashes corresponden a ese momento, anterior al cierre documental.

Despliegue Pages: https://github.com/jrguevara/jrguevara.github.io/actions/runs/44613932023 . Guías anteriores conservadas. La fecha editorial no determina la fecha de la sesión de Canvas: sus datos y foro siguen pendientes. No se publicó en Canvas ni se comprometieron archivos de Canvas o de la aplicación GPB. Esta publicación corresponde exclusivamente al material docente.
