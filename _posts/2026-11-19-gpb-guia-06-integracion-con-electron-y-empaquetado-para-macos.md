---
title: GPB — Guía 6 de 6 — Integración con Electron y empaquetado para macOS
date: 2026-11-19 00:00:00 -0600
categories: [Electron, GPB]
tags: [javascript, electron, reactjs, macos, tutorial]
published: true
layout: post
toc: true
comments: false
hidden: false
---

> **Nota sobre plataformas.** La integración con Electron de esta guía da como resultado una aplicación de escritorio para **macOS con Apple Silicon (arm64)**. Queda en manos del lector investigar, si le interesa, cómo crear versiones para otros sistemas operativos.

## 1. Objetivo y resultado esperado

En la [guía 5](https://jrguevara.github.io/posts/gpb-guia-05-alojamiento-y-configuracion-de-produccion/) desplegaste GPB en Render. Ahora vas a ejecutar la misma interfaz React en una ventana de Electron. El proceso principal se conectará por HTTPS a la API alojada y se encargará de la sesión. Al terminar tendrás un DMG y un ZIP para abrir GPB en un Mac Apple Silicon y usar la colección, las fotografías y el reproductor de video.

## 2. Requisitos y preparación

Parte de la guía 5 y comprueba que puedes acceder a GPB desde su versión web. Necesitas un Mac Apple Silicon, las herramientas de línea de comandos de Apple, Node.js **26.13.1**, pnpm **12.18.0** e Internet para obtener las dependencias y usar los servicios alojados.

Descarga el [ZIP de fuentes de la guía 6]({{ '/assets/downloads/gpb/guia-06/GPB-GUIA-06-FUENTES.zip' | relative_url }}) en Descargas. El ZIP trae una copia completa de la etapa. Desde la raíz de `MERN-electron`, extráelo si todavía no existe `gpb-dev/guia-06`. Si ya tienes esa carpeta, úsala directamente.

```sh
unzip -n "$HOME/Downloads/GPB-GUIA-06-FUENTES.zip"
cd gpb-dev/guia-06
```

Los comandos siguientes parten de `gpb-dev/guia-06`. Conserva el archivo `pnpm-lock.yaml` incluido.

| Herramienta | Función en GPB | Inicio oficial |
|---|---|---|
| Electron **45.4.1** | Ejecuta React en Chromium y permite que el proceso principal gestione HTTPS y la sesión. | [Electron Get Started](https://www.electronjs.org/docs/latest/) |
| electron-builder **26.18.0** | Empaqueta Electron y React en un DMG y un ZIP para Apple Silicon. | [electron-builder 26 Get Started](https://www.electron.build/v26/docs/) |

```sh
uname -m
xcode-select -p
node --version
pnpm --version
pnpm install --frozen-lockfile
pnpm exec install-electron
pnpm exec electron --version
pnpm exec electron-builder --version
```

Espera `arm64`, una ruta de herramientas de Apple, Node.js `v26.13.1`, pnpm `12.18.0`, Electron `v45.4.1` y electron-builder `26.18.0`. El binario de Electron incorpora su propia versión de Node.js para ejecutar la aplicación. [Versión oficial de Electron](https://releases.electronjs.org/release/v45.4.1)

## 3. Integrar React en la ventana de escritorio

Abre `electron/main.js`. Registra el protocolo `gpb://` antes de que Electron esté listo. Después sirve `client/dist/index.html` y los recursos compilados de la carpeta `client/dist/assets`. La ventana carga `gpb://app/index.html` con aislamiento de contexto, sandbox y acceso directo a Node.js desactivado.

En `client/src/App.jsx`, importa `HashRouter` y selecciona el enrutador al entrar en `App`:

```jsx
const Router = window.gpbDesktop ? HashRouter : BrowserRouter;
```

Usa `<Router>` alrededor de `AuthProvider`. Así, rutas de escritorio como `#/coleccion` cambian la vista sin que Electron tenga que buscar otro archivo HTML. La versión web sigue con `BrowserRouter` y la reescritura de la guía 5.

## 4. Conectar React con la API y conservar la sesión

Revisa y aplica estos archivos en orden si estás siguiendo los cambios desde tu copia de la guía 5. El ZIP contiene las versiones completas.

1. `electron/preload.cjs` expone únicamente `window.gpbDesktop.request(action)` mediante `contextBridge`. Este archivo es la entrada CommonJS que carga el sandbox de Electron. El resto de la implementación nueva usa ES Modules.
2. `electron/actions.js` permite los métodos y rutas que usa GPB. Valida el tipo y tamaño del cuerpo y reconstruye el formulario multipart con la imagen. Express mantiene los controles de propiedad, formatos y cantidad de archivos.
3. `electron/session-api.js` administra `gpb.sid` en una partición persistente de Electron y el token CSRF en memoria. Comprueba los atributos de la cookie, pide el token antes de escribir cuando hace falta y retira el token de la respuesta antes de entregarla a React.
4. `electron/main.js` valida que cada mensaje provenga del fotograma principal de la ventana de GPB y aplica la lista de acciones. En este archivo, `apiOrigin` apunta al servicio HTTPS de Express y `webOrigin` coincide con `WEB_ORIGIN` de Express. Para tu propio despliegue, usa ambos orígenes de tu guía 5 y vuelve a empaquetar.
5. `client/src/lib/api.js` usa el puente si corre en Electron. Envía JSON o los bytes y metadatos básicos del archivo. En el navegador mantiene las solicitudes relativas a `/api`.

El proceso principal limita las ventanas nuevas, bloquea la navegación principal fuera de GPB y abre en el navegador las fotografías que coinciden con la ruta HTTPS permitida de Cloudinary. El iframe de YouTube recibe el identificador de aplicación en `Referer`. [Seguridad en Electron](https://www.electronjs.org/docs/latest/tutorial/security) · [Identidad del reproductor de YouTube](https://developers.google.com/youtube/terms/required-minimum-functionality)

## 5. Revisar y abrir GPB antes de empaquetar

```sh
pnpm check
pnpm test
pnpm desktop
```

La revisión de React debe pasar y la API debe aprobar **22 pruebas**. `pnpm desktop` compila React y abre GPB. Si la API alojada está despertando, deja que termine la comprobación de conexión hasta que aparezca el formulario de acceso. Sal de Electron con **⌘Q** antes de empaquetar.

## 6. Crear e instalar el paquete de práctica

Revisa `electron/builder.yml`. La lista `files` incorpora el manifiesto, los cuatro archivos de Electron y `client/dist`. Los destinos `dmg` y `zip` están fijados a `arm64`. Los scripts de construcción y el punto de entrada `electron/main.js` están en `package.json`.

```sh
pnpm package:mac
file release/mac-arm64/GPB.app/Contents/MacOS/GPB
hdiutil verify release/GPB-0.1.0-arm64.dmg
unzip -tq release/GPB-0.1.0-arm64-mac.zip
```

El ejecutable debe aparecer como **Mach-O arm64** y ambas verificaciones deben pasar. Abre el DMG en Finder, arrastra **GPB** a **Aplicaciones** y expulsa el disco. También puedes descomprimir el ZIP y abrir **GPB.app**. El paquete de práctica conserva la firma ad hoc del binario. Una distribución pública fuera de la Mac App Store suele usar una firma Developer ID y la notarización de Apple. Si Gatekeeper muestra un aviso, consulta las indicaciones de Apple para el paquete generado localmente. [Abrir apps de forma segura en el Mac](https://support.apple.com/es-es/102445)

## 7. Comprobar la aplicación empaquetada

1. Abre **GPB.app** e inicia sesión con una cuenta de prueba. Abre **Mi colección**, sal de GPB con **⌘Q** y vuelve a abrirla. Debes conservar el acceso.
2. Crea un Gunpla con un grado y una escala del catálogo. Edita un campo y comprueba que el detalle se actualice. Carga una portada y una foto de galería. Ambas deben mostrarse.
3. Añade un enlace válido de YouTube que permita inserción. En el detalle, pulsa el reproductor y comprueba que avance el video.
4. Retira la foto de galería, borra el Gunpla de prueba y cierra sesión. Sal y vuelve a abrir GPB. Debe aparecer el formulario de acceso.

El recorrido con el paquete y Render comprobó el registro, la persistencia al reiniciar GPB, la colección, las imágenes reales de Cloudinary y la revocación. La reproducción de YouTube se verificó en un recorrido separado con el mismo paquete y la API local. La prueba de persistencia tras un reinicio remoto controlado de la API sigue pendiente.

![Detalle de un Gunpla de práctica en el paquete de Electron, en modo oscuro]({{ '/assets/downloads/gpb/guia-06/detalle-electron.png' | relative_url }})

## 8. Resolver problemas frecuentes

| Síntoma | Qué revisar |
|---|---|
| Electron no encuentra su binario | Ejecuta `pnpm exec install-electron` desde la etapa y repite la comprobación de versión. |
| pnpm marca un script de instalación ignorado | Usa el `pnpm-workspace.yaml` de la etapa. Declara desactivado el script de `electron-winstaller` para este ejercicio. |
| GPB se queda esperando la conexión | Comprueba `/api/health` en el host de Express y vuelve a intentar cuando Render esté disponible. |
| La API responde 403 al iniciar sesión o guardar | Comprueba que `webOrigin` coincida exactamente con `WEB_ORIGIN` de Express, incluido HTTPS. Si cambiaste el origen en Electron, recompila y empaqueta otra vez. |
| YouTube carga el cuadro pero el video no reproduce | Confirma que el video admite inserción. Si muestra el error 153, revisa la identificación de la app en el `Referer` del iframe. [Errores del reproductor](https://developers.google.com/youtube/iframe_api_reference) |
| macOS muestra un aviso al abrir GPB | Verifica que el paquete sea el que acabas de generar, compara su integridad y consulta la documentación de Apple de la sección 6. |

## 9. Cierre

Con esta entrega se completan las seis guías de GPB. La aplicación web y el paquete de macOS usan la misma API alojada. Puedes comprobarlo entrando con tu cuenta desde ambos clientes y consultando el mismo registro de la colección.
