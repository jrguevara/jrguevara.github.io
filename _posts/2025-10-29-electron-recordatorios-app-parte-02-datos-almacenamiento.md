---
title: Electron - Recordatorios App | Parte 2 - Datos y Almacenamiento
date: 2025-10-29 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 2: Sistema de Datos y Almacenamiento

## Objetivo
Implementar el sistema de almacenamiento de datos con comunicación IPC entre proceso principal y renderer.

## Paso 1: Actualizar main.js con funciones IPC

Reemplaza el contenido de `main.js`:

```javascript
const { app, BrowserWindow, ipcMain, Menu, dialog } = require('electron');
const path = require('path');
const fs = require('fs').promises;

let mainWindow;
const DATA_FILE = path.join(__dirname, 'renderer', 'data', 'reminders.json');
const PREFERENCES_FILE = path.join(__dirname, 'preferences.json');

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
    show: false
  });

  mainWindow.loadFile('renderer/views/index.html');

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });
}

// IPC Handlers para recordatorios
ipcMain.handle('get-reminders', async () => {
  try {
    const data = await fs.readFile(DATA_FILE, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    return [];
  }
});

ipcMain.handle('save-reminders', async (event, reminders) => {
  try {
    await fs.writeFile(DATA_FILE, JSON.stringify(reminders, null, 2));
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// IPC Handlers para preferencias
ipcMain.handle('get-preference', async (event, key) => {
  try {
    const data = await fs.readFile(PREFERENCES_FILE, 'utf-8');
    const preferences = JSON.parse(data);
    return preferences[key];
  } catch (error) {
    return null;
  }
});

ipcMain.handle('set-preference', async (event, key, value) => {
  try {
    let preferences = {};
    try {
      const data = await fs.readFile(PREFERENCES_FILE, 'utf-8');
      preferences = JSON.parse(data);
    } catch (error) {}
    
    preferences[key] = value;
    await fs.writeFile(PREFERENCES_FILE, JSON.stringify(preferences, null, 2));
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

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

## Paso 2: Actualizar preload.js

Reemplaza `preload.js`:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  getReminders: () => ipcRenderer.invoke('get-reminders'),
  saveReminders: (reminders) => ipcRenderer.invoke('save-reminders', reminders),
  getPreference: (key) => ipcRenderer.invoke('get-preference', key),
  setPreference: (key, value) => ipcRenderer.invoke('set-preference', key, value)
});
```

## Paso 3: Crear archivo de variables globales

Crea `renderer/js/variables.js`:

```javascript
// Variables globales
let reminders = [];
let editingId = null;
let currentTheme = 'light';
let sidebarCollapsed = false;

// Claves para preferencias
const THEME_KEY = 'theme';
const SIDEBAR_KEY = 'sidebarCollapsed';

// Elementos del DOM
let reminderForm, remindersList, emptyState, searchInput, clearSearchBtn;
let darkModeToggle, submitBtn, cancelBtn, sidebar;
let deleteModal, confirmDeleteBtn, cancelDeleteBtn, modalClose, modalReminderTitle;

let reminderToDelete = null;
```

## Paso 4: Crear sistema de almacenamiento

Crea `renderer/js/storage.js`:

```javascript
// Cargar preferencias
async function loadPreferences() {
    try {
        currentTheme = await window.electronAPI.getPreference(THEME_KEY) || 'light';
        const sidebarPref = await window.electronAPI.getPreference(SIDEBAR_KEY);
        sidebarCollapsed = sidebarPref === true || sidebarPref === 'true';
    } catch (error) {
        currentTheme = 'light';
        sidebarCollapsed = false;
    }
}

// Guardar preferencia
async function savePreference(key, value) {
    try {
        await window.electronAPI.setPreference(key, value);
    } catch (error) {
        console.error('Error guardando preferencia:', error);
    }
}

// Cargar recordatorios
async function loadReminders() {
    try {
        reminders = await window.electronAPI.getReminders();
        renderReminders();
    } catch (error) {
        console.error('Error al cargar recordatorios:', error);
        reminders = [];
    }
}

// Guardar recordatorios
async function saveReminders() {
    try {
        const result = await window.electronAPI.saveReminders(reminders);
        return result.success;
    } catch (error) {
        console.error('Error al guardar recordatorios:', error);
        return false;
    }
}
```

## Paso 5: Crear archivo de datos inicial

Crea `renderer/data/reminders.json`:

```json
[]
```

## Paso 6: Crear archivo de inicialización

Crea `renderer/js/init.js`:

```javascript
// Inicializar aplicación
async function initApp() {
    console.log('Iniciando aplicación...');
    
    // Cargar preferencias
    await loadPreferences();
    
    // Aplicar tema
    applyTheme();
    
    // Cargar recordatorios
    await loadReminders();
    
    console.log('Aplicación iniciada correctamente');
}

// Aplicar tema
function applyTheme() {
    if (currentTheme === 'dark') {
        document.body.classList.add('dark-mode');
    } else {
        document.body.classList.remove('dark-mode');
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', initApp);
```

## Paso 7: Actualizar index.html

Actualiza `renderer/views/index.html`:

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
        <div id="app">
            <div id="remindersList"></div>
        </div>
    </div>

    <script src="../js/variables.js"></script>
    <script src="../js/storage.js"></script>
    <script src="../js/init.js"></script>
</body>
</html>
```

## Paso 8: Crear función temporal de renderizado

Agrega al final de `renderer/js/storage.js`:

```javascript
// Función temporal de renderizado (se mejorará en Parte 3)
function renderReminders() {
    const container = document.getElementById('remindersList');
    if (!container) return;
    
    if (reminders.length === 0) {
        container.innerHTML = '<p>No hay recordatorios todavía.</p>';
    } else {
        container.innerHTML = `<p>Tienes ${reminders.length} recordatorio(s)</p>`;
    }
}
```

## Paso 9: Probar

```bash
npm start
```

Abre la consola de desarrollador (F12) y ejecuta:

```javascript
// Crear un recordatorio de prueba
reminders.push({
    id: Date.now(),
    title: 'Recordatorio de prueba',
    description: 'Esto es una prueba',
    category: 'personal',
    priority: 'media',
    completed: false,
    createdAt: new Date().toISOString()
});

// Guardar
await saveReminders();

// Recargar
await loadReminders();
```

## Resultado esperado
✅ Sistema de almacenamiento IPC funcionando
✅ Datos persistentes en JSON
✅ Sistema de preferencias operativo
✅ Carga y guardado de recordatorios

## Siguiente paso
En la Parte 3, crearemos la interfaz de usuario principal con el formulario de recordatorios.
