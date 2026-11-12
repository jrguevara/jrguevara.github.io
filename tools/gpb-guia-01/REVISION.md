# Adaptación de GPB — Guía 1 para jrCoding Docs

Revisión: 12 de noviembre de 2026. Fecha de publicación indicada por el docente: 11 de noviembre de 2026.

## Procedencia

Se comprobaron las herramientas disponibles antes de acceder a GPB. No hay un conector GitHub conectado. La lectura web falló y Git no pudo resolver github.com en este entorno. Se utilizó la copia local accesible del repositorio MERN-electron, cuyo remoto configurado es https://github.com/jrguevara/MERN-electron.git, rama main, HEAD 525ad08cd0656874f6bde4c30809e5e5f00f5980. No se afirma haber comprobado el estado actual del remoto.

Se leyeron sus instrucciones AGENTS.md y el informe VERIFICACION.md. No se encontraron instrucciones AGENTS.md en este sitio ni en sus directorios superiores consultados. Las instrucciones de implementación/reproducción de GPB no se invocaron: este trabajo adapta una publicación, sin implementar ni repetir la aplicación.

La guía original coincide con el SHA-256 del informe: fecd021e4242baaab820da05172b8cbd50769d64cef55d7c96ed4a2461c18d53. La guía y los adjuntos originales no se modificaron.

## Convenciones observadas y adaptación

- Jekyll 4.3.2, Chirpy 5.6.1, Kramdown, Liquid y Rouge; Ruby 3.2.2 y Bundler 2.4.17 disponibles y dependencias satisfechas.
- Publicaciones en `_posts/AAAA-MM-DD-nombre.md`, encabezado YAML con title, date, categories, tags, published y hidden; plantilla post e índice disponibles por configuración.
- Referencias de estilo: guía Electron Recordatorios, parte 1; tutorial AWS Serverless/Lambda/DynamoDB; etiquetas existentes reactjs y nodeJS.
- Nuevo artículo: `_posts/2026-11-11-gpb-guia-01-configuracion-y-autenticacion.md`. Categorías Electron y GPB; etiquetas javascript, electron, reactjs, nodeJS, mongodb y tutorial. El título se presenta mediante Chirpy, evitando duplicar los dos encabezados iniciales del original.
- Se conservaron las diez secciones, el recorrido enlazado, carpetas de ejecución, explicación, versiones, comandos, código y resultados atribuidos a la referencia. Se distinguen pruebas locales, Atlas, transporte mínimo de Electron y despliegues/paquete pendientes de otras entregas.
- Los bloques llevan protección raw de Liquid para conservar JSX como `value={{ ... }}`. Sólo se cambió la etiqueta de lenguaje dotenv a text en dos bloques: Rouge no reconocía dotenv. Sus contenidos permanecen idénticos.
- Los enlaces relativos de GPB ahora usan relative_url hacia copias descargables dentro de assets/downloads/gpb/guia-01. No hay enlaces a archivos del equipo. Los enlaces oficiales externos del original se conservaron; no se comprobó su disponibilidad remota.
- La guía original no incluye imágenes. No se añadieron imágenes ni portada.
- No se modificaron configuraciones, estilos ni dependencias del sitio.

## Archivos creados

1. La publicación indicada arriba.
2. `assets/downloads/gpb/guia-01/guias/01-CONFIGURACION-Y-AUTENTICACION.md`: copia original descargable.
3. En `assets/downloads/gpb/guia-01/etapas/01/`: VERIFICACION.md, TRASPASO-CHATGPT.md, REGISTRO.md, FUENTES.md, INVENTARIO-SHA256.txt y codigo-etapa-1.zip, todos sin cambios respecto a GPB. Se preservó la estructura relativa de los documentos.
4. `tools/gpb-guia-01/verificar.rb`: comprobación reproducible de integridad, enlaces locales, anclas y adjuntos.
5. Este informe, excluido del sitio por la exclusión existente de tools.

## Comprobaciones realizadas

Desde la raíz del sitio:

```sh
JEKYLL_ENV=production bundle exec jekyll build --destination /private/tmp/jrcoding-gpb-preview
bundle exec ruby tools/gpb-guia-01/verificar.rb /private/tmp/jrcoding-gpb-preview
bundle exec htmlproofer /private/tmp/jrcoding-gpb-preview --disable-external --check-html --allow_hash_href
git diff --check
```

- Compilación de producción correcta y sin advertencias en la versión final.
- 57 bloques Markdown y 57 bloques HTML con contenido idéntico al original, incluidos los 33 bloques de archivos.
- 154 enlaces del contenido comprobados cuando son anclas o rutas del sitio; ninguna ancla duplicada dentro del artículo ni destino local ausente. Los enlaces de permalink de encabezados también se comprobaron.
- 7 tablas de contenido renderizadas.
- HTML-Proofer: 124 páginas HTML, sin errores, con la configuración de comprobaciones del despliegue del sitio; se deshabilitan enlaces externos igual que en tools/deploy.sh.
- Los siete adjuntos coinciden byte a byte con sus copias en el sitio generado.
- El ZIP contiene 36 entradas, incluye pnpm-lock.yaml y no contiene un archivo privado .env. SHA-256 del lock: 907d346cd6fe931b3d79733200b5879445c5126a134e5996466d58248fcc3f78, idéntico al registrado por GPB.
- Revisión con navegador a 1280 × 720 y 390 × 844: título, índice, anclas con acentos, tablas, JSX y bloques extensos. En móvil el ancho del documento coincide con 390 px; tablas y código largo mantienen desplazamiento horizontal dentro de sus contenedores. Se restauró el tamaño de escritorio al terminar.
- Las comprobaciones de aplicación/API/Atlas/Electron son las evidencias del informe original; no se ejecutaron nuevamente en esta adaptación.

## Pendientes y límites

Revisión del docente antes de cualquier commit, envío al remoto o publicación. La página usa published: true para que la compilación normal de Jekyll la incluya; esto no ejecuta una publicación. No se ejecutó tools/deploy.sh ni se creó commit, etiqueta, push o despliegue. La compilación de revisión se guardó fuera del proyecto y no reemplazó su _site local.

No pudo contrastarse el último estado remoto de GitHub ni verificarse por red cada enlace externo. La integridad del original y el lock se contrastó contra las huellas del informe accesible localmente.
