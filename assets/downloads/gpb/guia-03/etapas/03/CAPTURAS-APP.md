# Capturas de la aplicación — guía 3

19 de noviembre de 2026. Ocho capturas de la interfaz real de `gpb-dev/guia-03`, en modo oscuro, con datos ficticios. Se añadieron a la sección 6.1 de la guía y de la entrada publicada. No se modificó código de aplicación ni pruebas existentes. Los bloques de código de ambos documentos se compararon antes y después y permanecen idénticos. El bloque de estado retirado previamente del blog no se reintrodujo.

## Recorrido y límites

Se iniciaron `node tests/local-api.js` desde guia-03 y el CLI local `vp dev` desde su cliente, con puertos libres 3000/5173. Se automatizó Chromium con viewport 1440×1000 y 390×844. Comando de autoría: `node /private/tmp/gpb-capturas-app-guia3.mjs`.

La API de pruebas utiliza los adaptadores de memoria existentes y la interfaz React real. Las respuestas de imágenes externas se reemplazaron por el recurso gráfico de prueba de tests/images.spec.js. No se accedió a Atlas, Cloudinary real ni cuentas personales; no se capturaron credenciales, cookies o tokens. No se incluyó video de un tercero. Esto documenta las pantallas y el recorrido local; las comprobaciones reales de proveedores permanecen en VERIFICACION.md.

Se crearon tres Gunpla, se consultó su colección y detalle, se subió una portada y una imagen de galería, se editó estado/notas/etiquetas y se eliminó un registro mediante confirmación. Se comprobó el mensaje de éxito, la ausencia de su tarjeta y el 404 de su consulta posterior. Se comprobó ausencia de desbordamiento en cada captura. Al finalizar se cerraron navegador y procesos propios, eliminando los datos de memoria.

## Archivos

- `capturas/app-crud/coleccion-crud.png`: Colección en tarjetas.
- `capturas/app-crud/formulario-crear.png`: Crear un Gunpla.
- `capturas/app-crud/detalle-crud.png`: Consultar el detalle.
- `capturas/app-crud/gestion-imagenes.png`: Administrar portada y galería.
- `capturas/app-crud/formulario-editar.png`: Editar el registro.
- `capturas/app-crud/confirmar-eliminacion.png`: Confirmar la eliminación.
- `capturas/app-crud/coleccion-eliminada.png`: Comprobar el resultado de eliminar.
- `capturas/app-crud/coleccion-crud-movil.png`: Consultar la colección en móvil.

COMPROBACION.json conserva las rutas, viewports, alcance y resultado del recorrido sin datos de sesión. Los recortes de Fotografías y confirmación son capturas de sus elementos DOM, no reconstrucciones gráficas. La vista móvil conserva un ancho máximo de 390 px en el artículo; todas las imágenes mantienen altura automática y permiten abrir el PNG completo en pestaña nueva.

La primera comprobación HTML detectó que el tema del blog añade automáticamente un enlace de ampliación a cada imagen; los enlaces externos envolventes generaban anidación inválida. Se retiraron esos envoltorios y se añadieron enlaces de texto independientes para abrir cada captura completa. Se conserva el visor nativo del tema. Los ocho PNG se inspeccionaron visualmente, con textos y controles legibles y sin recortes de contenido; el detalle y los formularios completos requieren desplazamiento vertical.

La compilación de producción de Jekyll y HTML-Proofer aprobaron 134 archivos. Se revisó la sección renderizada en 1440×1000 y 390×844: ocho imágenes cargadas, con proporciones conservadas y sin desbordamiento. Los enlaces de texto permiten abrir cada PNG completo. El inventario de la guía y MATERIAL-CHATGPT.zip se actualizaron con el texto, capturas y alcance del recorrido. No se crearon commits en MERN-electron ni se incluyeron cambios ajenos de la etapa 3.

## Ampliación de vistas y formularios

Se añadieron ocho capturas a `capturas/app-vistas/` y a la sección 6.2 de la guía: registro, inicio de sesión, inicio protegido, colección vacía, error de validación, confirmación para eliminar una imagen, detalle móvil y edición móvil. Total de la galería docente: 16 capturas. Los controles de acceso se muestran vacíos; el resto usa la cuenta ficticia piloto_vistas. No se accedió a cuentas personales ni a servicios externos reales.

Comando: `node /private/tmp/gpb-vistas-extra03.mjs`. Se ejecutaron API y React de guia-03 con los adaptadores locales existentes; el enlace inválido fue rechazado realmente por la API. Se comprobó que no hay desbordamiento horizontal a 1440 y 390 px. La confirmación de imagen se canceló y la fotografía se mantuvo. Los procesos propios y el navegador se cerraron al finalizar; los datos sólo vivían en memoria. Manifiesto adicional: `capturas/app-vistas/COMPROBACION.json`.

Las ocho capturas se revisaron visualmente en una hoja de contacto, con revisión ampliada del formulario de error y de la edición móvil. Se conserva el modo oscuro y la altura automática, con ancho máximo de 390 px para las vistas móviles. El inicio protegido indica expresamente que las estadísticas se completarán en etapa 4; no se presentó un dashboard nuevo ni se modificó la aplicación.

La ampliación pasó la compilación de producción y HTML-Proofer en 134 archivos. Revisión del artículo a 1440×1000 y 390×844: las 16 capturas cargan, las ocho nuevas conservan proporciones y no hay desbordamiento horizontal. Los 24 bloques de código coinciden con la guía. Se revisaron visualmente las capturas del artículo en ambos tamaños. La fecha editorial permanece 14/11/2026. Evidencia: capturas/app-vistas/COMPROBACION-BLOG.json y blog-escritorio.png / blog-movil.png.
