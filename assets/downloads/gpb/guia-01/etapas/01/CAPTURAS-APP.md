# Capturas de la aplicación — guía 1

19/11/2026. Diez capturas de React y la API de `gpb-dev/guia-01`, con cuenta ficticia y sesiones en memoria. Se incorporan a la sección 6.5 de la guía y de su artículo. Se conserva la fecha editorial existente; no se modificaron la aplicación, sus pruebas ni los bloques de código de los documentos. No se añadieron pantallas de CRUD ni estadísticas de etapas posteriores.

## Recorrido

Comando de autoría: `node /private/tmp/gpb-auth-capturas01.mjs`. Se iniciaron la API local de pruebas y Vite+ de guía 1 con puertos 3000/5173 libres. Se abrió el acceso sin sesión, se registró una cuenta ficticia, se consultaron inicio y colección prevista, se cerró sesión y se comprobó GET /api/auth/me = 401. Después se verificaron los errores de contraseña incorrecta y de registro duplicado. Se retiró la contraseña del campo antes de capturar cada error.

No se accedió a MongoDB Atlas, Cloudinary ni cuentas personales. El ejercicio documenta la interfaz y las operaciones locales; no sustituye los informes de reproducción y Atlas existentes. El navegador y los procesos propios se cerraron al finalizar; los datos sólo existían en memoria.

## Imágenes

En `capturas/app-autenticacion/`: inicio-sesion.png, registro.png, inicio-protegido.png, coleccion-prevista.png, acceso-rechazado.png, registro-duplicado.png, cierre-sesion.png, inicio-sesion-movil.png, registro-movil.png e inicio-protegido-movil.png.

Viewport de escritorio: 1440×1000. Móvil: 390×844. En todas las capturas se comprobó ausencia de desbordamiento horizontal. Los diez PNG se inspeccionaron en una hoja de contacto oscura; se revisaron a tamaño completo el error de acceso y el formulario de registro móvil. Se conservaron proporciones, texto legible y enlaces de ampliación; las vistas móviles se presentan con ancho máximo de 390 px.

COMPROBACION.json registra las rutas, viewports y límites sin guardar sesiones ni secretos. El inventario complementario identifica las nuevas imágenes y el documento actualizado; el inventario histórico y codigo-etapa-1.zip no se reescriben porque no hay cambios de código. MATERIAL-CHATGPT.zip recibe únicamente el suplemento documental y visual, conservando los demás archivos previos.

La compilación de producción de Jekyll y HTML-Proofer aprobaron 134 archivos. Las diez imágenes nuevas cargaron en el artículo a 1440×1000 y 390×844, sin desbordamiento horizontal. Se revisaron visualmente ambas vistas del artículo. La revisión se acotó a los PNG nuevos para no depender de la carga de recursos históricos del documento. Evidencia: capturas/app-autenticacion/COMPROBACION-BLOG.json y blog-escritorio.png / blog-movil.png.
