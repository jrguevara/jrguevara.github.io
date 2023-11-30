---
title: Electron - parte 2
date: 2022-12-02 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, nodeJS, programacion]
published: true
hidden: false
---

## App redimensionador de imagenes

  

- Crear un nuevo boilerplate de electron e instalar las dependencias

```powershell
npm init
npm install resize-img toastify-js 
npm install --save-dev npx electron electronmon electron-builder @electron-forge/cli 
npx electron-forge import

```

  

- Archivo `package.json`

```json
{
  "name": "imagen-univo-v2",
  "productName": "ImagenUNIVO",
  "version": "2.0.0",
  "description": "Redimensionador de imagenes",
  "main": "main.js",
  "scripts": {
    "test": "npx electronmon .",
    "start": "electron-forge start",
    "package": "electron-forge package",
    "make": "electron-forge make"
  },
  "keywords": [
    "UNIVO",
    "Electron"
  ],
  "author": "Jaime Guevara",
  "license": "MIT",
  "dependencies": {
    "electron-squirrel-startup": "^1.0.0",
    "resize-img": "^2.0.0",
    "toastify-js": "^1.12.0"
  },
  "devDependencies": {
    "@electron-forge/cli": "^7.1.0",
    "@electron-forge/maker-deb": "^7.1.0",
    "@electron-forge/maker-rpm": "^7.1.0",
    "@electron-forge/maker-squirrel": "^7.1.0",
    "@electron-forge/maker-zip": "^7.1.0",
    "@electron-forge/plugin-auto-unpack-natives": "^7.1.0",
    "electron": "^27.1.2",
    "electron-builder": "^24.9.1",
    "electronmon": "^2.0.2",
    "npx": "^10.2.2"
  }
}


```

  

- Crear `main.js`

```javascript
const { app, BrowserWindow } = require('electron')
const path = require('path')

process.env.NODE_ENV = 'dev'

const isMac = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV === 'dev'

// Crear ventana Principal
function createMainWindow(
) {
    const mainWindow = new BrowserWindow({
        title: 'Redimensionar Imagen',
        width: isDev ? 1200 : 600,
        height: 800
    })

    //Abre DevTools si esta en env dev
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

// Cuando la app esta lista cre la ventana
app.whenReady().then(() => {
    createMainWindow()

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createMainWindow()
        }
    })
})

app.on('window-all-closed', () => {
    if (!isMac) app.quit()
})

```

  

- Crear `renderer/index.html` 

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Redimensionar imagen</title>
</head>
<body>
    Hello World!
</body>
</html>

```

  

- Probar app con `npm run test` 

  

## Personalizar UI

- Modificar `index.html` 

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline';" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/style.css" />
    <script src="js/script.js" defer></script>
    <title>Redimensionar imagen</title>
</head>

<body class="bg-dark">
    <div class="max-w-xl m-auto h-screen flex flex-col align-center justify-center">
        <div class="flex flex-col w-full items-center justify-center bg-grey-lighter">
            <label class="w-64 flex flex-col items-center px-4 py-7 bg-white text-gray-500 rounded-lg shadow-lg tracking-wide uppercase border border-blue cursor-pointer">
                <img src="./images/folder.png" width="32" />
                <span class="mt-2 leading-normal">Abrir imagen</span>
                <input id="img" type="file" class="hidden" />
            </label>
        </div>

        <!-- Form -->
        <form id="img-form" class="hidden">
            <div class="mt-6">
                <label class="mt-1 block text-white text-center w-80 m-auto py-3 shadow-sm border-gray-300 rounded-md">Ancho</label>
                <input type="number" name="width" id="width" class="mt-1 block w-80 m-auto p-3 shadow-sm border-gray-300 rounded-md" placeholder="Ancho" />
            </div>

            <div class="mt-4">
                <label class="mt-1 block text-white text-center w-80 m-auto py-3 shadow-sm border-gray-300 rounded-md">Alto</label>
                <input type="number" name="height" id="height" class="mt-1 block w-80 m-auto p-3 shadow-sm border-gray-300 rounded-md" placeholder="Alto" />
            </div>

            <!-- Button -->
            <div class="mt-6">
                <button type="submit"
                    class="w-80 m-auto flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-teal-500 hover:bg-teal-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                    Redimensionar
                </button>

        </form>

        <p class="text-white text-lg text-center font-mono mt-6"><strong>Archivo: </strong><span id="filename"></span></p>
        <!-- Delete hardcoded path -->
        <p class="text-white text-lg text-center font-mono mt-2"><strong>Salida: </strong><span id="output-path"></span></p>
    </div>
</body>

</html>

```

  

- Crear `css/style.css` 

```css
/*
! tailwindcss v3.1.8 | MIT License | https://tailwindcss.com
*/

*,
::before,
::after {
  box-sizing: border-box;
  border-width: 0;
  border-style: solid;
  border-color: #e5e7eb;
}

::before,
::after {
  --tw-content: '';
}

html {
  line-height: 1.5;
  -webkit-text-size-adjust: 100%;
  -moz-tab-size: 4;
  -o-tab-size: 4;
  tab-size: 4;
  font-family: Poppins, sans-serif;
}

body {
  margin: 0;
  line-height: inherit;
  overflow: hidden;
}

hr {
  height: 0;
  color: inherit;
  border-top-width: 1px;
}

abbr:where([title]) {
  -webkit-text-decoration: underline dotted;
  text-decoration: underline dotted;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  font-size: inherit;
  font-weight: inherit;
}

a {
  color: inherit;
  text-decoration: inherit;
}

b,
strong {
  font-weight: bolder;
}

code,
kbd,
samp,
pre {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    'Liberation Mono', 'Courier New', monospace;
  font-size: 1em;
}

small {
  font-size: 80%;
}

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

table {
  text-indent: 0;
  border-color: inherit;
  border-collapse: collapse;
}

button,
input,
optgroup,
select,
textarea {
  font-family: inherit;
  font-size: 100%;
  font-weight: inherit;
  line-height: inherit;
  color: inherit;
  margin: 0;
  padding: 0;
}

button,
select {
  text-transform: none;
}

button,
[type='button'],
[type='reset'],
[type='submit'] {
  -webkit-appearance: button;
  background-color: transparent;
  background-image: none;
}

:-moz-focusring {
  outline: auto;
}

:-moz-ui-invalid {
  box-shadow: none;
}

progress {
  vertical-align: baseline;
}

::-webkit-inner-spin-button,
::-webkit-outer-spin-button {
  height: auto;
}

[type='search'] {
  -webkit-appearance: textfield;
  outline-offset: -2px;
}

::-webkit-search-decoration {
  -webkit-appearance: none;
}

::-webkit-file-upload-button {
  -webkit-appearance: button;
  font: inherit;
}

summary {
  display: list-item;
}

blockquote,
dl,
dd,
h1,
h2,
h3,
h4,
h5,
h6,
hr,
figure,
p,
pre {
  margin: 0;
}

fieldset {
  margin: 0;
  padding: 0;
}

legend {
  padding: 0;
}

ol,
ul,
menu {
  list-style: none;
  margin: 0;
  padding: 0;
}

textarea {
  resize: vertical;
}

input::-moz-placeholder,
textarea::-moz-placeholder {
  opacity: 1;
  color: #9ca3af;
}

input::placeholder,
textarea::placeholder {
  opacity: 1;
  color: #9ca3af;
}

button,
[role='button'] {
  cursor: pointer;
}

:disabled {
  cursor: default;
}

img,
svg,
video,
canvas,
audio,
iframe,
embed,
object {
  display: block;
  vertical-align: middle;
}

/*
Constrain images and videos to the parent width and preserve their intrinsic aspect ratio. (https://github.com/mozdevs/cssremedy/issues/14)
*/

img,
video {
  max-width: 100%;
  height: auto;
}

*,
::before,
::after {
  --tw-border-spacing-x: 0;
  --tw-border-spacing-y: 0;
  --tw-translate-x: 0;
  --tw-translate-y: 0;
  --tw-rotate: 0;
  --tw-skew-x: 0;
  --tw-skew-y: 0;
  --tw-scale-x: 1;
  --tw-scale-y: 1;
  --tw-pan-x: ;
  --tw-pan-y: ;
  --tw-pinch-zoom: ;
  --tw-scroll-snap-strictness: proximity;
  --tw-ordinal: ;
  --tw-slashed-zero: ;
  --tw-numeric-figure: ;
  --tw-numeric-spacing: ;
  --tw-numeric-fraction: ;
  --tw-ring-inset: ;
  --tw-ring-offset-width: 0px;
  --tw-ring-offset-color: #fff;
  --tw-ring-color: rgb(59 130 246 / 0.5);
  --tw-ring-offset-shadow: 0 0 #0000;
  --tw-ring-shadow: 0 0 #0000;
  --tw-shadow: 0 0 #0000;
  --tw-shadow-colored: 0 0 #0000;
  --tw-blur: ;
  --tw-brightness: ;
  --tw-contrast: ;
  --tw-grayscale: ;
  --tw-hue-rotate: ;
  --tw-invert: ;
  --tw-saturate: ;
  --tw-sepia: ;
  --tw-drop-shadow: ;
  --tw-backdrop-blur: ;
  --tw-backdrop-brightness: ;
  --tw-backdrop-contrast: ;
  --tw-backdrop-grayscale: ;
  --tw-backdrop-hue-rotate: ;
  --tw-backdrop-invert: ;
  --tw-backdrop-opacity: ;
  --tw-backdrop-saturate: ;
  --tw-backdrop-sepia: ;
}

::-webkit-backdrop {
  --tw-border-spacing-x: 0;
  --tw-border-spacing-y: 0;
  --tw-translate-x: 0;
  --tw-translate-y: 0;
  --tw-rotate: 0;
  --tw-skew-x: 0;
  --tw-skew-y: 0;
  --tw-scale-x: 1;
  --tw-scale-y: 1;
  --tw-pan-x: ;
  --tw-pan-y: ;
  --tw-pinch-zoom: ;
  --tw-scroll-snap-strictness: proximity;
  --tw-ordinal: ;
  --tw-slashed-zero: ;
  --tw-numeric-figure: ;
  --tw-numeric-spacing: ;
  --tw-numeric-fraction: ;
  --tw-ring-inset: ;
  --tw-ring-offset-width: 0px;
  --tw-ring-offset-color: #fff;
  --tw-ring-color: rgb(59 130 246 / 0.5);
  --tw-ring-offset-shadow: 0 0 #0000;
  --tw-ring-shadow: 0 0 #0000;
  --tw-shadow: 0 0 #0000;
  --tw-shadow-colored: 0 0 #0000;
  --tw-blur: ;
  --tw-brightness: ;
  --tw-contrast: ;
  --tw-grayscale: ;
  --tw-hue-rotate: ;
  --tw-invert: ;
  --tw-saturate: ;
  --tw-sepia: ;
  --tw-drop-shadow: ;
  --tw-backdrop-blur: ;
  --tw-backdrop-brightness: ;
  --tw-backdrop-contrast: ;
  --tw-backdrop-grayscale: ;
  --tw-backdrop-hue-rotate: ;
  --tw-backdrop-invert: ;
  --tw-backdrop-opacity: ;
  --tw-backdrop-saturate: ;
  --tw-backdrop-sepia: ;
}

::backdrop {
  --tw-border-spacing-x: 0;
  --tw-border-spacing-y: 0;
  --tw-translate-x: 0;
  --tw-translate-y: 0;
  --tw-rotate: 0;
  --tw-skew-x: 0;
  --tw-skew-y: 0;
  --tw-scale-x: 1;
  --tw-scale-y: 1;
  --tw-pan-x: ;
  --tw-pan-y: ;
  --tw-pinch-zoom: ;
  --tw-scroll-snap-strictness: proximity;
  --tw-ordinal: ;
  --tw-slashed-zero: ;
  --tw-numeric-figure: ;
  --tw-numeric-spacing: ;
  --tw-numeric-fraction: ;
  --tw-ring-inset: ;
  --tw-ring-offset-width: 0px;
  --tw-ring-offset-color: #fff;
  --tw-ring-color: rgb(59 130 246 / 0.5);
  --tw-ring-offset-shadow: 0 0 #0000;
  --tw-ring-shadow: 0 0 #0000;
  --tw-shadow: 0 0 #0000;
  --tw-shadow-colored: 0 0 #0000;
  --tw-blur: ;
  --tw-brightness: ;
  --tw-contrast: ;
  --tw-grayscale: ;
  --tw-hue-rotate: ;
  --tw-invert: ;
  --tw-saturate: ;
  --tw-sepia: ;
  --tw-drop-shadow: ;
  --tw-backdrop-blur: ;
  --tw-backdrop-brightness: ;
  --tw-backdrop-contrast: ;
  --tw-backdrop-grayscale: ;
  --tw-backdrop-hue-rotate: ;
  --tw-backdrop-invert: ;
  --tw-backdrop-opacity: ;
  --tw-backdrop-saturate: ;
  --tw-backdrop-sepia: ;
}

.m-auto {
  margin: auto;
}

.mx-auto {
  margin-left: auto;
  margin-right: auto;
}

.mb-5 {
  margin-bottom: 1.25rem;
}

.mt-2 {
  margin-top: 0.5rem;
}

.mt-6 {
  margin-top: 1.5rem;
}

.mt-1 {
  margin-top: 0.25rem;
}

.mt-4 {
  margin-top: 1rem;
}

.block {
  display: block;
}

.flex {
  display: flex;
}

.hidden {
  display: none;
}

.h-screen {
  height: 100vh;
}

.w-full {
  width: 100%;
}

.w-64 {
  width: 16rem;
}

.w-80 {
  width: 20rem;
}

.max-w-xl {
  max-width: 36rem;
}

.cursor-pointer {
  cursor: pointer;
}

.resize {
  resize: both;
}

.flex-col {
  flex-direction: column;
}

.items-center {
  align-items: center;
}

.justify-center {
  justify-content: center;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.rounded-md {
  border-radius: 0.375rem;
}

.border {
  border-width: 1px;
}

.border-gray-300 {
  --tw-border-opacity: 1;
  border-color: rgb(209 213 219 / var(--tw-border-opacity));
}

.border-transparent {
  border-color: transparent;
}

.bg-dark {
  --tw-bg-opacity: 1;
  background-color: rgb(50 47 47 / var(--tw-bg-opacity));
}

.bg-white {
  --tw-bg-opacity: 1;
  background-color: rgb(255 255 255 / var(--tw-bg-opacity));
}

.bg-purple-500 {
  --tw-bg-opacity: 1;
  background-color: rgb(138 98 193 / var(--tw-bg-opacity));
}

.p-3 {
  padding: 0.75rem;
}

.px-4 {
  padding-left: 1rem;
  padding-right: 1rem;
}

.py-7 {
  padding-top: 1.75rem;
  padding-bottom: 1.75rem;
}

.py-2 {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
}

.text-center {
  text-align: center;
}

.font-mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    'Liberation Mono', 'Courier New', monospace;
}

.text-xl {
  font-size: 1.25rem;
  line-height: 1.75rem;
}

.text-sm {
  font-size: 0.875rem;
  line-height: 1.25rem;
}

.text-lg {
  font-size: 1.125rem;
  line-height: 1.75rem;
}

.font-medium {
  font-weight: 500;
}

.uppercase {
  text-transform: uppercase;
}

.leading-normal {
  line-height: 1.5;
}

.tracking-wide {
  letter-spacing: 0.025em;
}

.text-teal-100 {
  --tw-text-opacity: 1;
  color: rgb(204 251 241 / var(--tw-text-opacity));
}

.text-teal-300 {
  --tw-text-opacity: 1;
  color: rgb(94 234 212 / var(--tw-text-opacity));
}

.text-gray-500 {
  --tw-text-opacity: 1;
  color: rgb(107 114 128 / var(--tw-text-opacity));
}

.text-white {
  --tw-text-opacity: 1;
  color: rgb(255 255 255 / var(--tw-text-opacity));
}

.shadow-lg {
  --tw-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1),
    0 4px 6px -4px rgb(0 0 0 / 0.1);
  --tw-shadow-colored: 0 10px 15px -3px var(--tw-shadow-color),
    0 4px 6px -4px var(--tw-shadow-color);
  box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000),
    var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);
}

.shadow-sm {
  --tw-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --tw-shadow-colored: 0 1px 2px 0 var(--tw-shadow-color);
  box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000),
    var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);
}

.focus\:outline-none:focus {
  outline: 2px solid transparent;
  outline-offset: 2px;
}

.focus\:ring-2:focus {
  --tw-ring-offset-shadow: var(--tw-ring-inset) 0 0 0
    var(--tw-ring-offset-width) var(--tw-ring-offset-color);
  --tw-ring-shadow: var(--tw-ring-inset) 0 0 0
    calc(2px + var(--tw-ring-offset-width)) var(--tw-ring-color);
  box-shadow: var(--tw-ring-offset-shadow), var(--tw-ring-shadow),
    var(--tw-shadow, 0 0 #0000);
}

.focus\:ring-blue-500:focus {
  --tw-ring-opacity: 1;
  --tw-ring-color: rgb(59 130 246 / var(--tw-ring-opacity));
}

.focus\:ring-offset-2:focus {
  --tw-ring-offset-width: 2px;
}


```

  

## Ventana Acerca de

- modificar `main.js`

```javascript
const { app, BrowserWindow } = require('electron')
const path = require('path')

process.env.NODE_ENV = 'dev'

const isMac = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV === 'dev'

// Crear ventana Principal
function createMainWindow(
) {
    const mainWindow = new BrowserWindow({
        title: 'Redimensionar Imagen',
        width: isDev ? 1200 : 600,
        height: 800
    })

    //Abre DevTools si esta en env dev
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

// Ventana About
function createAboutWindow(
) {
    aboutWindow = new BrowserWindow({
      width: 300,
      height: 300,
      title: 'Acerca',
      icon: `${__dirname}/assets/icons/icon_256x256.png`,
    });
  
     aboutWindow.loadFile(path.join(__dirname, './renderer/about.html'))
     aboutWindow.setMenuBarVisibility(false)
  }

// Cuando la app esta lista cre la ventana
app.whenReady().then(() => {
    createMainWindow()

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createMainWindow()
        }
    })
})

app.on('window-all-closed', () => {
    if (!isMac) app.quit()
})

```

  

- Crear `renderer/about.html`

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline';" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="css/style.css" />
    <script src="js/script.js" defer></script>
    <title>ImagenUNIVO</title>
</head>

<body class="bg-dark">
    <div
      class="max-w-xl m-auto h-screen flex flex-col align-center justify-center text-center"
    >
      <img
        src="./images/logo.png"
        alt="ImageResizer"
        width="100"
        class="mx-auto mb-5"
      />
      <h2 class="text-xl text-teal-100 text-center">ImagenUNIVO App</h2>
      <p class="text-xl text-teal-100 mt-2">Version 2.0.0</p>
      <p class="text-xl text-teal-100 mt-2">MIT License</p>
    </div>
</body>

</html>

```

  

## Menu en electron

- Modificar `main.js`

```javascript
const { app, BrowserWindow, Menu } = require('electron')
const path = require('path')

process.env.NODE_ENV = 'dev'

const isMAc = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV === 'dev'

// Crear ventana Principal
function createMainWindow(
) {
    const mainWindow = new BrowserWindow({
        title: 'Redimensionar Imagen',
        width: isDev ? 1200 : 600,
        height: 800
    })

    //Abre DevTools si esta en env dev
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

// Ventana About
function createAboutWindow(
) {
    aboutWindow = new BrowserWindow({
      width: 300,
      height: 300,
      title: 'Acerca',
      icon: `${__dirname}/assets/icons/icon_256x256.png`,
    });
  
     aboutWindow.loadFile(path.join(__dirname, './renderer/about.html'))
     aboutWindow.setMenuBarVisibility(false)
  }

// Cuando la app esta lista cre la ventana
app.whenReady().then(() => {
    createMainWindow()
    //Implementacion del menu
    const mainMenu = Menu.buildFromTemplate(menu)
    Menu.setApplicationMenu(mainMenu)

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createMainWindow()
        }
    })
})

// Plantilla de menu
const menu = [
    /*{
        role: 'fileMenu',
    },*/
    {
        label: 'Archivo',
        submenu: [
            {
                label: 'Salir',
                click: () => app.quit(),
                accelerator: 'CmdOrCtrl+W',
            },
        ],
    },
]


app.on('window-all-closed', () => {
    if (!isMAc) app.quit()
})

```

  

- Plantilla de menu para Mac y Windows

```javascript
// Plantilla de menu
const menu = [
  ...(isMac
    ? [
      {
        label: app.name,
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(!isMac
    ? [
      {
        label: 'Ayuda',
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(isDev
    ? [
      {
        label: 'Developer',
        submenu: [
          { role: 'reload' },
          { role: 'forcereload' },
          { type: 'separator' },
          { role: 'toggledevtools' },
        ],
      },
    ]
    : []),
]

```

  

## Abrir imagen

- Crear `js/script.js`

```javascript
const form = document.querySelector('#img-form')
const widthInput = document.querySelector('#width')
const heightInput = document.querySelector('#height')
const filename = document.querySelector('#filename')
const img = document.querySelector('#img')
const outputPath = document.querySelector('#output-path')

function cargarImagen(e) {
    const file = e.target.files[0]

    if (!esImagen(file)) {
        //console.log('archivo no valido')
        alert('Por favor seleccionar una imagen!')
        return;
    }

    //console.log('Exito')
    
    //Obtener dimensiones
    const image = new Image();
    image.src = URL.createObjectURL(file)
    image.onload = function (
) {
        widthInput.value = this.width
        heightInput.value = this.height 
    }

    form.style.display = 'block';
    filename.innerHTML = file.name
}

function esImagen(file) {
    const formatosAceptados = ['image/gif', 'image/jpeg', 'image/png']
    return file && formatosAceptados.includes(file['type'])
}

img.addEventListener('change', cargarImagen)

```

  

- Crear archivo `preload.js` en raiz del proyecto

```javascript
const { contextBridge } = require('electron')
const os = require('os');
const path = require('path');

//Modulo OS
contextBridge.exposeInMainWorld('os', {
    homedir: () => os.homedir(),
})

//Modulo Ruta
contextBridge.exposeInMainWorld('path', {
    join: (...args) => path.join(...args),
})

```

  

- Modificar `main.js` 

```javascript
// Crear ventana Principal
function createMainWindow(
) {
    const mainWindow = new BrowserWindow({
        title: 'Redimensionar Imagen',
        width: isDev ? 1200 : 600,
        height: 800,
        icon: `${__dirname}/assets/icons/icon_256x256.png`,
        resizable: isDev,
        webPreferences: {
          nodeIntegration: true,
          contextIsolation: true,
          preload: path.join(__dirname, 'preload.js'),
        },
    })

    //Abre DevTools si esta en env dev
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

```

  

- Modificar `script.js`

```javascript
const form = document.querySelector('#img-form')
const widthInput = document.querySelector('#width')
const heightInput = document.querySelector('#height')
const filename = document.querySelector('#filename')
const img = document.querySelector('#img')
const outputPath = document.querySelector('#output-path')

function cargarImagen(e) {
    const file = e.target.files[0]

    if (!esImagen(file)) {
        //console.log('archivo no valido')
        alert('Por favor seleccionar una imagen!')
        return;
    }

    //console.log('Exito')

    //Obtener dimensiones
    const image = new Image();
    image.src = URL.createObjectURL(file)
    image.onload = function (
) {
        widthInput.value = this.width
        heightInput.value = this.height
    }

    form.style.display = 'block';
    filename.innerHTML = file.name
    outputPath.innerHTML = path.join(os.homedir(), 'imagen_univo')
}

function esImagen(file) {
    const formatosAceptados = ['image/gif', 'image/jpeg', 'image/png']
    return file && formatosAceptados.includes(file['type'])
}

img.addEventListener('change', cargarImagen)

```

  

## Alertas

- Modiicar `preload.js`

```javascript
const { contextBridge } = require('electron')
const os = require('os');
const path = require('path');
const Toastify = require('toastify-js')

//Modulo OS
contextBridge.exposeInMainWorld('os', {
    homedir: () => os.homedir(),
})

//Modulo Ruta
contextBridge.exposeInMainWorld('path', {
    join: (...args) => path.join(...args),
})

//Toastify
contextBridge.exposeInMainWorld('Toastify', {
    toast: (options) => Toastify(options).showToast(),
})

```

  

- Modificar `script.js`

```javascript
// const os = require('os');
const form = document.querySelector('#img-form')
const widthInput = document.querySelector('#width')
const heightInput = document.querySelector('#height')
const filename = document.querySelector('#filename')
const img = document.querySelector('#img')
const outputPath = document.querySelector('#output-path')

//console.log(versions.node())

function cargarImagen(e) {
    const file = e.target.files[0]

    if (!esImagen(file)) {
        //console.log('archivo no valido')
        alertError('Por favor seleccionar una imagen!')
        return;
    }

    //console.log('Exito')

    //Obtener dimensiones
    const image = new Image();
    image.src = URL.createObjectURL(file)
    image.onload = function (
) {
        widthInput.value = this.width
        heightInput.value = this.height
    }

    form.style.display = 'block';
    filename.innerHTML = file.name
    outputPath.innerHTML = path.join(os.homedir(), 'imagen_univo')
}

function esImagen(file) {
    const formatosAceptados = ['image/gif', 'image/jpeg', 'image/jpg', 'image/png']
    return file && formatosAceptados.includes(file['type'])
}

function alertSuccess(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'green',
            color: 'white',
            textAlign: 'center',
        },
    });
}

function alertError(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'red',
            color: 'white',
            textAlign: 'center',
        },
    });
}

img.addEventListener('change', cargarImagen)

```

  

## Enviando la data de imagen

- Modiicar `preload.js`

```javascript
const { contextBridge, ipcRenderer } = require('electron')
const os = require('os');
const path = require('path');
const Toastify = require('toastify-js')

//Modulo OS
contextBridge.exposeInMainWorld('os', {
    homedir: () => os.homedir(),
})

//Modulo Ruta
contextBridge.exposeInMainWorld('path', {
    join: (...args) => path.join(...args),
})

//Toastify
contextBridge.exposeInMainWorld('Toastify', {
    toast: (options) => Toastify(options).showToast(),
})

//IPC
contextBridge.exposeInMainWorld('ipcRenderer', {
    send: (channel, data) => ipcRenderer.send(channel, data),
    on: (channel, func) =>
        ipcRenderer.on(channel, (event, ...args) => func(...args)),
})

```

  

- Modificar `script.js`

```javascript
// const os = require('os');
const form = document.querySelector('#img-form')
const widthInput = document.querySelector('#width')
const heightInput = document.querySelector('#height')
const filename = document.querySelector('#filename')
const img = document.querySelector('#img')
const outputPath = document.querySelector('#output-path')

//console.log(versions.node())

function cargarImagen(e) {
    const file = e.target.files[0]

    if (!esImagen(file)) {
        //console.log('archivo no valido')
        alertError('Por favor seleccionar una imagen!')
        return;
    }

    //console.log('Exito')

    //Obtener dimensiones
    const image = new Image();
    image.src = URL.createObjectURL(file)
    image.onload = function (
) {
        widthInput.value = this.width
        heightInput.value = this.height
    }

    form.style.display = 'block';
    filename.innerHTML = file.name
    outputPath.innerHTML = path.join(os.homedir(), 'imagen_univo')
}

// envio de  image
function enviarImagen(e) {
    e.preventDefault();

    if (!img.files[0]) {
        alertError('Por favor subir una imagen');
        return;
    }

    if (widthInput.value === '' || heightInput.value === '') {
        alertError('Por favor introduzaca Ancho y Alto');
        return;
    }

    const imgPath = img.files[0].path;
    const width = widthInput.value;
    const height = heightInput.value;

    ipcRenderer.send('image:resize', {
        imgPath,
        height,
        width,
    });
}

function esImagen(file) {
    const formatosAceptados = ['image/gif', 'image/jpeg', 'image/jpg', 'image/png']
    return file && formatosAceptados.includes(file['type'])
}

function alertSuccess(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'green',
            color: 'white',
            textAlign: 'center',
        },
    });
}

function alertError(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'red',
            color: 'white',
            textAlign: 'center',
        },
    });
}
// Seleccionar archivo listener
img.addEventListener('change', cargarImagen)

// Formulario listener
form.addEventListener('submit', enviarImagen);

```

  

- Modificar `main.js`

```javascript
const { app, BrowserWindow, Menu, ipcMain } = require('electron')
const path = require('path')
const os = require('os')
const fs = require('fs')

process.env.NODE_ENV = 'dev'

const isMac = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV === 'dev'

// Crear ventana Principal
function createMainWindow() {
    const mainWindow = new BrowserWindow({
        title: 'Redimensionar Imagen',
        width: isDev ? 1200 : 600,
        height: 800,
        icon: `${__dirname}/assets/icons/icon_256x256.png`,
        resizable: isDev,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js'),
        },
    })

    //Abre DevTools si esta en env dev
    if (isDev) {
        mainWindow.webContents.openDevTools()
    }

    mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

// Ventana About
function createAboutWindow() {
    aboutWindow = new BrowserWindow({
        width: 300,
        height: 300,
        title: 'Acerca',
        icon: `${__dirname}/assets/icons/icon_100x100.png`,
    });

    aboutWindow.loadFile(path.join(__dirname, './renderer/about.html'))
    aboutWindow.setMenuBarVisibility(false)
}

// Cuando la app esta lista cre la ventana
app.whenReady().then(() => {
    createMainWindow()
    //Implementacion del menu
    const mainMenu = Menu.buildFromTemplate(menu)
    Menu.setApplicationMenu(mainMenu)

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createMainWindow()
        }
    })
})

// Plantilla de menu
const menu = [
  ...(isMac
    ? [
      {
        label: app.name,
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(!isMac
    ? [
      {
        label: 'Ayuda',
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(isDev
    ? [
      {
        label: 'Developer',
        submenu: [
          { role: 'reload' },
          { role: 'forcereload' },
          { type: 'separator' },
          { role: 'toggledevtools' },
        ],
      },
    ]
    : []),
]

//Respuesta a IPC
ipcMain.on('image:resize', (e, options) => {
    //console.log(options);
    options.dest = path.join(os.homedir(), 'imagen_univo');
    resizeImage(options);
})

app.on('window-all-closed', () => {
    if (!isMac) app.quit()
})

```

  

## Modificar y guardar imagen

- Modificar `main.js`

```javascript
const { app, BrowserWindow, Menu, ipcMain, shell } = require('electron')
const path = require('path')
const os = require('os')
const fs = require('fs')
const resizeImg = require('resize-img')

process.env.NODE_ENV = 'dev'

const isMac = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV === 'dev'

let mainWindow
let aboutWindow

// Crear ventana Principal
function createMainWindow() {
  mainWindow = new BrowserWindow({
    title: 'Redimensionar Imagen',
    width: isDev ? 1200 : 600,
    height: 800,
    icon: `${__dirname}/assets/icons/icon_512x512.png`,
    resizable: isDev,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  })

  //console.log (icon);

  //Abre DevTools si esta en env dev
  if (isDev) {
    mainWindow.webContents.openDevTools()
  }

  mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

// Ventana About
function createAboutWindow() {
  aboutWindow = new BrowserWindow({
    width: 300,
    height: 300,
    title: 'Acerca',
    icon: `${__dirname}/assets/icons/icon_100x100.png`,
  });

  aboutWindow.loadFile(path.join(__dirname, './renderer/about.html'))
  aboutWindow.setMenuBarVisibility(false)
}

// Cuando la app esta lista crea la ventana
app.whenReady().then(() => {
  createMainWindow()
  //Implementacion del menu
  const mainMenu = Menu.buildFromTemplate(menu)
  Menu.setApplicationMenu(mainMenu)

  // Remover variable de memoria
  mainWindow.on('closed', () => (mainWindow = null));

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow()
    }
  })
})

// Plantilla de menu
const menu = [
  ...(isMac
    ? [
      {
        label: app.name,
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(!isMac
    ? [
      {
        label: 'Ayuda',
        submenu: [
          {
            label: 'Acerca',
            click: createAboutWindow,
          },
        ],
      },
    ]
    : []),
  ...(isDev
    ? [
      {
        label: 'Developer',
        submenu: [
          { role: 'reload' },
          { role: 'forcereload' },
          { type: 'separator' },
          { role: 'toggledevtools' },
        ],
      },
    ]
    : []),
]
//Respuesta a IPC
ipcMain.on('image:resize', (e, options) => {
  //console.log(options);
  options.dest = path.join(os.homedir(), 'imagen_univo');
  resizeImage(options);
})

// Modificar y guardar imagen
async function resizeImage({ imgPath, height, width, dest }) {
  try {
    // console.log(imgPath, height, width, dest);

    // Resize image
    const newPath = await resizeImg(fs.readFileSync(imgPath), {
      width: +width,
      height: +height,
    });

    // Get filename
    const filename = path.basename(imgPath);

    // Create destination folder if it doesn't exist
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest);
    }

    // Write the file to the destination folder
    fs.writeFileSync(path.join(dest, filename), newPath);

    // Send success to renderer
    mainWindow.webContents.send('image:done');

    // Open the folder in the file explorer
    shell.openPath(dest);
  } catch (err) {
    console.log(err);
  }
}

app.on('window-all-closed', () => {
  if (!isMac) { app.quit() }
})



```

  

- Modificar `script.js`

```javascript
// const os = require('os');
const form = document.querySelector('#img-form')
const widthInput = document.querySelector('#width')
const heightInput = document.querySelector('#height')
const filename = document.querySelector('#filename')
const img = document.querySelector('#img')
const outputPath = document.querySelector('#output-path')

//console.log(versions.node())

function cargarImagen(e) {
    const file = e.target.files[0]

    if (!esImagen(file)) {
        //console.log('archivo no valido')
        alertError('Por favor seleccionar una imagen!')
        return;
    }

    //console.log('Exito')

    //Obtener dimensiones
    const image = new Image();
    image.src = URL.createObjectURL(file)
    image.onload = function () {
        widthInput.value = this.width
        heightInput.value = this.height
    }

    form.style.display = 'block';
    filename.innerHTML = file.name
    outputPath.innerHTML = path.join(os.homedir(), 'imagen_univo')
}

// envio de  image
function enviarImagen(e) {
    e.preventDefault();

    if (!img.files[0]) {
        alertError('Por favor subir una imagen');
        return;
    }

    if (widthInput.value === '' || heightInput.value === '') {
        alertError('Por favor introduzaca Ancho y Alto');
        return;
    }

    const imgPath = img.files[0].path;
    const width = widthInput.value;
    const height = heightInput.value;

    ipcRenderer.send('image:resize', {
        imgPath,
        height,
        width,
    });
}

function esImagen(file) {
    const formatosAceptados = ['image/gif', 'image/jpeg', 'image/jpg', 'image/png']
    return file && formatosAceptados.includes(file['type'])
}

// Al finalizar mostrar mensaje
ipcRenderer.on('image:done', () =>
    alertSuccess(`Imagen redimensionada a ${heightInput.value} x ${widthInput.value}`)
);

function alertSuccess(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'green',
            color: 'white',
            textAlign: 'center',
        },
    });
}

function alertError(message) {
    Toastify.toast({
        text: message,
        duration: 5000,
        close: false,
        style: {
            background: 'red',
            color: 'white',
            textAlign: 'center',
        },
    });
}
// Seleccionar archivo listener
img.addEventListener('change', cargarImagen)

// Formulario listener
form.addEventListener('submit', enviarImagen);

```

- Modificar `forge.config.js`

```javascript
const path = require('path')

module.exports = {
  packagerConfig: {
    asar: true,
    icon: path.join(__dirname, 'assets/icons/mac/icon.icns'),
  },
  rebuildConfig: {},
  makers: [
    {
      name: '@electron-forge/maker-squirrel',
      config: {},
    },
    {
      name: '@electron-forge/maker-zip',
      platforms: ['darwin'],
    },
    {
      name: '@electron-forge/maker-deb',
      config: {},
    },
    {
      name: '@electron-forge/maker-rpm',
      config: {},
    },
  ],
  plugins: [
    {
      name: '@electron-forge/plugin-auto-unpack-natives',
      config: {},
    },
  ],
};
```