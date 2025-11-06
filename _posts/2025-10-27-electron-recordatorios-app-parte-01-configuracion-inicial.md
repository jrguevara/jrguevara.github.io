---
title: Electron - Recordatorios App | Parte 1 - Configuración Inicial del Proyecto
date: 2025-10-27 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 1: Configuración Inicial del Proyecto

## Objetivo
Configurar la estructura básica del proyecto Electron con todos los archivos necesarios.

## Paso 1: Crear estructura de carpetas

```bash
mkdir reminders-app
cd reminders-app
mkdir renderer
mkdir renderer/views
mkdir renderer/assets
mkdir renderer/assets/css
mkdir renderer/assets/images
mkdir renderer/js
mkdir renderer/data
mkdir renderer/components
```

## Paso 2: Inicializar proyecto Node.js

Crea `package.json`:

```json
{
  "name": "reminders-app",
  "version": "3.2.1",
  "description": "Una aplicación simple de recordatorios con Electron",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "dev": "electron . --enable-logging"
  },
  "keywords": ["electron", "recordatorios", "reminders"],
  "author": "Tu nombre",
  "license": "MIT",
  "devDependencies": {
    "electron": "^27.0.0"
  }
}
```

## Paso 3: Instalar Electron

```bash
npm install
```

## Paso 4: Crear archivo principal de Electron

Crea `main.js`:

```javascript
const { app, BrowserWindow } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 900,
    minWidth: 1200,
    minHeight: 900,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    icon: path.join(__dirname, 'renderer', 'assets', 'images', 'icon.png'),
    show: false
  });

  mainWindow.loadFile('renderer/views/index.html');

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
```

## Paso 5: Crear preload script

Crea `preload.js`:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  saveData: (data) => ipcRenderer.invoke('save-data', data),
  loadData: () => ipcRenderer.invoke('load-data'),
  exportData: () => ipcRenderer.invoke('export-data'),
  importData: () => ipcRenderer.invoke('import-data')
});
```

## Paso 6: Crear HTML básico

Crea `renderer/views/index.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recordatorios App</title>
    <link rel="stylesheet" href="../assets/css/styles.css">
</head>
<body>
    <div class="main-container">
        <h1>Aplicación de Recordatorios</h1>
        <div id="app"></div>
    </div>
</body>
</html>
```

## Paso 7: Crear CSS básico

Crea `renderer/assets/css/styles.css`:

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.main-container {
    max-width: 1200px;
    margin: 0 auto;
    background: white;
    border-radius: 20px;
    padding: 30px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

h1 {
    color: #333;
    margin-bottom: 20px;
    text-align: center;
}
```

## Paso 8: Probar la aplicación

```bash
npm start
```

Deberías ver una ventana de Electron con el título "Recordatorios App" y un fondo degradado.

## Resultado esperado
- ✅ Proyecto Electron configurado y ejecutándose
- ✅ Estructura de carpetas creada
- ✅ Ventana principal mostrándose correctamente

## Siguiente paso
En la Parte 2, crearemos el sistema de almacenamiento de datos y las variables globales.
