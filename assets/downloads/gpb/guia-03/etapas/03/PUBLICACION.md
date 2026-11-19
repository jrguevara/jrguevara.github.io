# Publicación — guía 3

19/11/2026: el docente autoriza publicar en GitHub.io con fecha editorial **14/11/2026**. Se prepara la entrada definitiva y se comprobará el resultado remoto antes de darla por publicada.

Destino local previsto: `/Users/jrguevara/Developer/jrguevara.github.io`. Se respetará el formato de guías previas: front matter, categorías, tabla de contenido, bloques raw para código, filtros relative_url, imágenes HTTPS y enlaces a los visores con ?theme=dark. La comprobación real de Cloudinary ya está aprobada. Fecha y publicación autorizadas; se creará únicamente el commit necesario del sitio. No se incluyen cambios de la aplicación GPB ni archivos de Canvas.

Canvas se prepara sólo para copiar una vez confirmados sus datos y la URL publicada. Se solicitó semana, sesión, fecha, modalidad, video si existe y foro. La plantilla indicada es SESION-GUIA-02.html; se conservará su paleta institucional y los diagramas GPB serán oscuros. Los archivos de guías previas no se modificarán ni se enviarán a Git sin indicación expresa.

El foro anterior https://univo.instructure.com/courses/1800/discussion_topics/7186 no se considera validado por recibir una redirección al inicio de sesión. Hace falta comprobar contenido y permisos o confirmación del docente antes de reutilizarlo.


## Borrador local preparado

Archivo: `_drafts/gpb-guia-03-imagenes-y-detalle-completo.md` en el sitio. Sin fecha editorial, published:false y hidden:true. Se prepararon sólo los archivos nuevos de guía 3: entrada, seis PNG/SVG/capturas, dos HTML interactivos y documentación/descargas. No se modificaron guías anteriores ni la configuración del sitio.

Compilación local de revisión, desde el sitio: `PATH=/Users/jrguevara/.rubies/ruby-3.2.2/bin:$PATH JEKYLL_ENV=production bundle exec jekyll build --drafts --unpublished --disable-disk-cache --destination /private/tmp/gpb-guia03-site-build`. Aprobada. Las opciones draft/unpublished se usaron únicamente para visualizar el borrador en la salida temporal; no habilitan su publicación normal.

`PATH=/Users/jrguevara/.rubies/ruby-3.2.2/bin:$PATH bundle exec htmlproofer --disable-external --check-html --allow_hash_href /private/tmp/gpb-guia03-site-build`: aprobado en 134 archivos. El navegador comparó los 24 bloques completos con el Markdown, comprobó 12 destinos locales y las dos imágenes cargadas, sin desbordamiento horizontal a 1440 y 390 px. Capturas oscuras de ambos tamaños revisadas visualmente. Las fechas que Jekyll pueda asignar automáticamente a un borrador en la previsualización no constituyen una fecha editorial autorizada. No se ha comprobado una URL pública de guía 3 porque no se ha publicado.
