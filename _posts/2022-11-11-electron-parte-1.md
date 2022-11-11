---
title: Electron - parte 1
date: 2022-11-11 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, nodeJS, programacion]
published: true
hidden: false
---

## Introducción a Electron

Electron es un marco para crear aplicaciones de escritorio utilizando JavaScript, HTML y CSS. Al incorporar Chromium y Node.js en su binario, Electron le permite mantener una base de código JavaScript y crear aplicaciones multiplataforma que funcionan en Windows, macOS y Linux, sin necesidad de experiencia en desarrollo nativo. [Sitio Oficial](https://www.electronjs.org/)  

![Electron](/assets/images/electron.png)_Electron_  

- Iniciar proyecto con Node.js

`⁠npm init`   

```powershell
package name: app-electron
version: (1.0.0)
description: app en electron
entry point: (index.js) main.js
test command:
git repository:
keywords: electron, app, UNIVO
author: Jaime Guevara
license: (ISC) MIT
```

- Instalar dependencias `npm i electron`
- Crear `main.js`

```javascript
console.log("Hola Mundo!")

```

  

- Modificar `package.json` 

```json
{
  "name": "app-electron",
  "productName": "app-electron",
  "version": "1.0.0",
  "description": "app en electron",
  "main": "main.js",
  "scripts": {
    "start": "electron ."
  },
  "keywords": [
    "electron",
    "app",
    "UNIVO"
  ],
  "author": "Jaime Guevara",
  "license": "MIT"
}

```

  

- Ejecutar a aplicación con el comando `npm start` se detiene con Ctrl+C

## Electron Boilerplate

- Copiar contenido según se describa en la documentación oficial: [https://www.electronjs.org/docs/latest](https://www.electronjs.org/docs/latest)
- Modificar `main.js`

```javascript
const { app, BrowserWindow } = require('electron')
const path = require('path')

function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

```

  

- Crear `preload.js`

```javascript
window.addEventListener('DOMContentLoaded', () => {
    const replaceText = (selector, text) => {
        const element = document.getElementById(selector)
        if (element) element.innerText = text
    }

    for (const type of ['chrome', 'node', 'electron']) {
        replaceText(`${type}-version`, process.versions[type])
    }
})

```

  

- Crear `index.html`

```html
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Hello World!</title>
    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline';" />
</head>

<body>
    <h1>Hello World!</h1>
    <p>
        We are using Node.js <span id="node-version"></span>,
        Chromium <span id="chrome-version"></span>,
        and Electron <span id="electron-version"></span>.
    </p>
</body>

</html>

```

  

- Personalizar el comportamiento de comprobación de sistema operativo Mac y uso de DevTools modificando el archivo `main.js`

```javascript
const { app, BrowserWindow } = require('electron')
const path = require('path')

process.env.NODE_ENV = 'dev'

const isMAc = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV !== 'production'

function createWindow () {
  const win = new BrowserWindow({
    width: isDev ? 1200 : 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  //Abre DevTools si esta en env dev
  if (isDev) {
    win.webContents.openDevTools()
  }

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (!isMAc) {
    app.quit()
  }
})

```

  

- Establecer hotreload con el comando `npx electronmon .` esto instala un nuevo paquete. Se puede cambiar el script en el archivo `package.json` 

```json
{
  "name": "app-electron",
  "productName": "app-electron",
  "version": "1.0.0",
  "description": "app en electron",
  "main": "main.js",
  "scripts": {
    "start": "npx electronmon ."
  },
  "keywords": [
    "electron",
    "app",
    "UNIVO"
  ],
  "author": "Jaime Guevara",
  "license": "MIT",
  "dependencies": {
    "electron": "^6.1.12"
  }
}

```

  

## Calculadora en Electron

- Crear un nuevo boilerplate de electron e instalar las dependencias

```powershell
npm init
npm i npx electronmon
npm install --save-dev electron

```

  

- Modificar `package.json` 

```json
{
  "name": "calc-electron",
  "productName": "calc-electron",
  "version": "1.0.0",
  "description": "calculadora en electron",
  "main": "main.js",
  "scripts": {
    "start": "npx electronmon ."
  },
  "keywords": [],
  "author": "Jaime Guevara",
  "license": "MIT",
  "dependencies": {
    "electron": "^21.2.3",
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

const isMAc = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV !== 'production'

function createMainWindow () {
  const mainWindow = new BrowserWindow({
    width: isDev ? 1200 : 350,
    height: 800
  })

  //Abre DevTools si esta en env dev
  if (isDev) {
    mainWindow.webContents.openDevTools()
  }

  mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
}

app.whenReady().then(() => {
  createMainWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (!isMAc) {
    app.quit()
  }
})

```

  

- Crear carpeta renderer en el proyecto y copiar los archivos de la calculadora creada en JavaScript anteriormente
- Modificar `renderer/index.html`

```html
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>Calculadora - Vanilla JS</title>
    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline';" />
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32x32.png">
  </head>

```

  

- Modificar tamaño de venta y ocultar barra de menu modificando main.js

```javascript
const { app, BrowserWindow } = require('electron')
const path = require('path')

process.env.NODE_ENV = 'dev'

const isMAc = process.platform !== 'darwin'
const isDev = process.env.NODE_ENV !== 'production'

function createMainWindow () {
  const mainWindow = new BrowserWindow({
    width: isDev ? 1200 : 350,
    height: isDev ? 800 : 550
  })

  //Abre DevTools si esta en env dev
  if (isDev) {
    mainWindow.webContents.openDevTools()
  }

  mainWindow.loadFile(path.join(__dirname, './renderer/index.html'))
  mainWindow.setMenuBarVisibility(false)
}

app.whenReady().then(() => {
  createMainWindow()

  app.on('ready', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (!isMAc) {
    app.quit()
  }
})

```

  

### Empaquetado con Electron Builder

- Instalar dependencias

```powershell
npm install --save-dev electron-builder
```

  

- Modificar `package.json`

```json
{
  "name": "calc-electron",
  "productName": "calc-electron",
  "version": "1.0.0",
  "description": "calculadora en electron",
  "main": "main.js",
  "scripts": {
    "iniciar": "npx electronmon .",
    "package": "electron-builder --win"
  },
  "keywords": [],
  "author": "Jaime Guevara",
  "license": "MIT",
  "dependencies": {
    "electronmon": "^2.0.2",
    "npx": "^10.2.2"
  },
  "devDependencies": {
    "electron": "^21.2.3",
    "electron-builder": "^23.6.0"
  }
}

```

  

- Ejecutar comando `npm run package`

## Empaquetado con Electron Forge

Electron no tiene ninguna herramienta para empaquetado y distribución incluida en sus módulos principales. Una vez que tenga una aplicación Electron en funcionamiento en modo de desarrollo, debe usar herramientas adicionales para crear una aplicación empaquetada que pueda distribuir a sus usuarios (también conocida como distribuible). Los distribuibles pueden ser instaladores (p. ej., MSI en Windows) o archivos ejecutables portátiles (p. ej., .app en macOS).

 Electron Forge es una herramienta todo en uno que maneja el empaquetado y la distribución de las aplicaciones de Electron. Bajo el capó, combina una gran cantidad de herramientas Electron existentes (por ejemplo, electron-packager, @electron/osx-sign, electron-winstaller, etc.) en una única interfaz para que no tenga que preocuparse por conectarlas todas juntas.  
  

### Importación de su proyecto en Forge

- Puede instalar la CLI de Electron Forge en las dependencias de desarrollo de su proyecto e importar su proyecto existente con un práctico script de conversión. 

```powershell
npm install --save-dev @electron-forge/cli
npx electron-forge import

```

  

- Una vez que se realiza el script de conversión, Forge debería haber agregado algunos scripts a su archivo `package.json`   
    

```json
{
  "name": "calc-electron",
  "productName": "calc-electron",
  "version": "1.0.0",
  "description": "calculadora en electron",
  "main": "main.js",
  "scripts": {
    "iniciar": "npx electronmon .",
    "start": "electron-forge start",
    "package": "electron-forge package",
    "make": "electron-forge make"
  },
  "keywords": [],
  "author": "Jaime Guevara",
  "license": "MIT",
  "dependencies": {
    "electron-squirrel-startup": "^1.0.0",
    "electronmon": "^2.0.2",
    "npx": "^10.2.2"
  },
  "devDependencies": {
    "@electron-forge/cli": "^6.0.1",
    "@electron-forge/maker-deb": "^6.0.1",
    "@electron-forge/maker-rpm": "^6.0.1",
    "@electron-forge/maker-squirrel": "^6.0.1",
    "@electron-forge/maker-zip": "^6.0.1",
    "electron": "^21.2.3"
  }
}

```

  

También debe notar que su `paquete.json` ahora tiene algunos paquetes más instalados en sus dependencias de desarrollo y contiene un campo config.forge agregado con una variedad de creadores configurados. Los creadores son complementos de Forge que crean distribuibles a partir de su código fuente. Debería ver varios fabricantes en la configuración precargada, uno para cada plataforma de destino.

  

### Creando un distribuible

- Para crear un distribuible, use el nuevo script `make` de su proyecto, que ejecutando el comando `⁠npm run make`

- Este comando make contiene dos pasos:

1. Primero ejecutará el paquete de forja de electrones debajo del capó, que agrupa el código de su aplicación junto con el binario de Electron. El código empaquetado se genera en una carpeta.
2. Luego usará esta carpeta de aplicaciones empaquetadas para crear un distribuible separado para cada fabricante configurado.

  

Después de que se ejecute el script, debería ver una carpeta de salida que contiene tanto el distribuible como una carpeta que contiene el código de la aplicación empaquetada.