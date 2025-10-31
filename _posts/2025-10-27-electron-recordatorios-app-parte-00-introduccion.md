---
title: Electron - RecordatoriosApp| Parte 0 - Introducción al Tutorial
date: 2025-10-27 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 0: Introducción al Tutorial

## ⚡ ¿Qué es Electron?

![Electron](/assets/images/electron.png)_Electron_ 

**Electron** es un framework de código abierto desarrollado por GitHub que permite crear aplicaciones de escritorio multiplataforma usando tecnologías web (HTML, CSS y JavaScript). 

### Características Principales

**🌍 Multiplataforma**
- Escribe una vez, ejecuta en Windows, macOS y Linux
- Sin necesidad de aprender lenguajes nativos diferentes para cada plataforma
- Mismo código base para todas las plataformas

**🔧 Tecnologías Web**
- Usa HTML, CSS y JavaScript que ya conoces
- Aprovecha todo el ecosistema de npm
- Mismas herramientas de desarrollo web (DevTools, debuggers)

**⚙️ Acceso al Sistema**
- APIs de Node.js para acceso al sistema de archivos
- Comunicación con el sistema operativo
- Integración con características nativas (notificaciones, menús)

### Arquitectura de Electron

Electron combina **Chromium** (navegador) y **Node.js** en dos tipos de procesos:

#### 1. Proceso Principal (Main Process)
- **Un solo proceso** por aplicación
- Ejecuta Node.js con acceso completo al sistema
- Gestiona ventanas y ciclo de vida de la aplicación
- Maneja operaciones del sistema (archivos, menús, notificaciones)
- **Archivo**: `main.js`

#### 2. Proceso Renderizador (Renderer Process)
- **Múltiples procesos** (uno por ventana)
- Ejecuta en entorno de navegador (Chromium)
- Renderiza la interfaz de usuario (HTML/CSS/JS)
- Aislado del sistema por seguridad
- **Archivos**: HTML, CSS, JavaScript del frontend

```
┌─────────────────────────────────────────┐
│         PROCESO PRINCIPAL               │
│         (main.js - Node.js)             │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  - Gestión de ventanas          │    │
│  │  - Sistema de archivos          │    │
│  │  - APIs del sistema operativo   │    │
│  │  - Menús y notificaciones       │    │
│  └─────────────────────────────────┘    │
│                 ▲                       │
│                 │ IPC                   │
│                 ▼                       │
│  ┌─────────────────────────────────┐    │
│  │    PROCESO RENDERIZADOR         │    │
│  │    (HTML/CSS/JS - Chromium)     │    │
│  │                                 │    │
│  │  ┌───────────────────────────┐  │    │
│  │  │  Interfaz de Usuario      │  │    │
│  │  │  (HTML, CSS)              │  │    │
│  │  └───────────────────────────┘  │    │
│  │  ┌───────────────────────────┐  │    │
│  │  │  Lógica de la aplicación  │  │    │
│  │  │  (JavaScript)             │  │    │
│  │  └───────────────────────────┘  │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### Comunicación IPC (Inter-Process Communication)

Los procesos se comunican de forma segura usando **IPC**:

```javascript
// Main Process (main.js)
ipcMain.handle('get-data', async () => {
    return await loadData();
});

// Renderer Process (renderer.js)
const data = await window.electronAPI.getData();
```

### Context Bridge - Seguridad

El **preload script** expone APIs de forma segura al renderer:

```javascript
// preload.js
contextBridge.exposeInMainWorld('electronAPI', {
    getData: () => ipcRenderer.invoke('get-data')
});
```

Esto protege tu aplicación al:
- ✅ Aislar Node.js del código de la interfaz
- ✅ Exponer solo APIs específicas y controladas
- ✅ Prevenir acceso directo al sistema desde el navegador

### Aplicaciones Famosas con Electron

- **Visual Studio Code** - Editor de código de Microsoft
- **Slack** - Plataforma de comunicación
- **Discord** - Chat para gamers y comunidades
- **WhatsApp Desktop** - Mensajería
- **Figma** - Diseño colaborativo
- **Notion** - Gestión de notas y proyectos
- **Spotify** - Streaming de música (versión anterior)

### ¿Por qué Electron para este Tutorial?

✅ **Curva de aprendizaje suave** - Si sabes web, ya sabes Electron
✅ **Desarrollo rápido** - Prototipa e itera rápidamente
✅ **Ecosistema rico** - Miles de paquetes npm disponibles
✅ **Multiplataforma real** - Un código, tres sistemas operativos
✅ **Comunidad activa** - Amplia documentación y soporte
✅ **Herramientas familiares** - Usa las mismas que en desarrollo web

## 🎯 Objetivo del Tutorial

Construir desde cero una **aplicación de escritorio profesional de recordatorios** utilizando Electron, siguiendo un enfoque práctico y progresivo que culmina en una réplica exacta de la aplicación proporcionada.

## 📱 Aplicación Final

![Aplicación de Recordatorios](/assets/images/recordatorios-app.png)_AppFinal_


Al completar este tutorial habrás creado una aplicación completa con:

### Funcionalidades Principales
- ✅ **Gestión de Recordatorios**: Crear, editar, eliminar y completar recordatorios
- ✅ **Categorización**: Organización por categorías (Personal, Trabajo, Estudio, Salud, Otro)
- ✅ **Prioridades**: Sistema de prioridades (Alta, Media, Baja) con indicadores visuales
- ✅ **Fechas Límite**: Calendario personalizado con selector de hora
- ✅ **Búsqueda Inteligente**: Búsqueda en tiempo real por título, descripción o categoría
- ✅ **Filtros Avanzados**: Filtrar por categoría, estado y ordenar de múltiples formas

### Características Técnicas
- 🎨 **Modo Claro/Oscuro**: Sistema de temas con persistencia de preferencia
- 💾 **Persistencia Local**: Almacenamiento en JSON sin dependencias externas
- 📊 **Estadísticas**: Contador en tiempo real de recordatorios totales, pendientes y completados
- 🔔 **Notificaciones**: Sistema visual de notificaciones para feedback inmediato
- ⌨️ **Atajos de Teclado**: Navegación rápida (Ctrl/Cmd+K, Ctrl/Cmd+B, Ctrl/Cmd+N, Escape)
- 🎭 **Animaciones**: Transiciones suaves y efectos visuales profesionales

### Arquitectura
- 🏗️ **Proceso Principal**: Node.js con acceso al sistema de archivos
- 🌐 **Proceso Renderizador**: HTML, CSS y JavaScript modular
- 🔒 **IPC Seguro**: Comunicación entre procesos usando contextBridge
- 📦 **Modular**: Código organizado en módulos independientes
- 🎯 **Sin Frameworks**: JavaScript vanilla para aprendizaje fundamental

## 🗺️ Roadmap del Tutorial

### Fase 1: Fundamentos (Partes 1-2)
Configurar Electron y establecer la arquitectura básica con comunicación IPC y persistencia de datos.

**Parte 1**: Configuración Inicial
- Instalación de Electron
- Estructura del proyecto
- Primera ventana funcionando

**Parte 2**: Sistema de Datos
- Comunicación IPC
- Almacenamiento en JSON
- Handlers de datos y preferencias

### Fase 2: Interfaz y CRUD (Partes 3-4)
Construir la interfaz completa y las operaciones fundamentales.

**Parte 3**: Interfaz de Usuario
- HTML completo con sidebar
- Formulario de recordatorios
- Componentes visuales

**Parte 4**: Operaciones CRUD
- Crear recordatorios
- Editar recordatorios
- Eliminar con confirmación
- Marcar como completado

### Fase 3: Funcionalidades Avanzadas (Partes 5-6)
Agregar búsqueda, filtros y selector de fechas.

**Parte 5**: Búsqueda y Filtros
- Búsqueda en tiempo real
- Filtros por categoría y estado
- Ordenamiento múltiple

**Parte 6**: Calendario
- Calendario personalizado
- Selector de fecha y hora
- Formato dd/mm/yyyy hh:mm

### Fase 4: Experiencia de Usuario (Partes 7-9)
Mejorar la UX con temas, navegación y notificaciones.

**Parte 7**: Sistema de Temas
- Modo claro y oscuro
- Variables CSS
- Persistencia de preferencia

**Parte 8**: Sidebar y Navegación
- Mostrar/ocultar sidebar
- Atajos de teclado
- Estado persistente

**Parte 9**: Notificaciones y UX
- Sistema de notificaciones visuales
- Animaciones mejoradas
- Validación de formularios

### Fase 5: Distribución (Parte 10)
Empaquetar la aplicación para distribución.

**Parte 10**: Empaquetado
- Configuración de electron-builder
- Compilación multiplataforma
- Optimizaciones de producción

## 📚 Metodología de Aprendizaje

### Enfoque Práctico
- **Código Real**: Cada línea de código es funcional y probada
- **Sin Teoría Excesiva**: Explicaciones concisas enfocadas en implementación
- **Construcción Incremental**: Cada parte agrega funcionalidad visible
- **Verificación Continua**: Pruebas después de cada parte

### Progresión Lógica
1. **Configurar** → Electron funcionando
2. **Almacenar** → Datos persistentes
3. **Visualizar** → Interfaz completa
4. **Operar** → CRUD funcional
5. **Filtrar** → Búsqueda y filtros
6. **Seleccionar** → Calendario
7. **Personalizar** → Temas
8. **Navegar** → Sidebar
9. **Notificar** → UX mejorada
10. **Distribuir** → Aplicación empaquetada

## 🎓 Conocimientos Previos

### Requeridos
- JavaScript básico (variables, funciones, arrays, objetos)
- HTML y CSS fundamentales
- Manejo de línea de comandos básica
- Node.js y npm (instalación de paquetes)

### Opcionales
- Eventos del DOM
- Promesas y async/await
- CSS variables
- JSON

### Aprenderás en el Tutorial
- ✅ Arquitectura de Electron (main/renderer processes)
- ✅ Comunicación IPC (Inter-Process Communication)
- ✅ Context Bridge para seguridad
- ✅ Manejo de sistema de archivos con Node.js
- ✅ Gestión de estado en aplicaciones de escritorio
- ✅ Desarrollo de interfaces complejas
- ✅ Implementación de calendarios personalizados
- ✅ Sistema de temas con CSS variables
- ✅ Empaquetado con electron-builder

## 💻 Requisitos del Sistema

### Software Necesario
- **Node.js**: versión 16 o superior
- **npm** o **yarn**: gestor de paquetes
- **Editor de código**: VS Code recomendado
- **Terminal**: bash, zsh o PowerShell

### Espacio en Disco
- ~500 MB para node_modules
- ~200 MB para aplicación empaquetada

### Compatibilidad
- ✅ macOS 10.13 o superior
- ✅ Windows 10/11
- ✅ Linux (Ubuntu 18.04+, Fedora 32+)

## ⏱️ Duración Estimada

- **Tutorial Completo**: 4-6 horas
- **Por Parte**: 20-40 minutos
- **Configuración Inicial**: 15 minutos
- **Empaquetado Final**: 30 minutos

**Recomendación**: Toma descansos entre partes y experimenta con el código.

## 📂 Estructura Final del Proyecto

```
reminders-app/
├── main.js                         # Proceso principal de Electron
├── preload.js                      # Script de preload (seguridad)
├── package.json                    # Configuración y dependencias
├── package-lock.json               # Dependencias bloqueadas
├── README.md                       # Documentación del proyecto
├── .gitignore                      # Archivos ignorados por git
│
├── renderer/                       # Frontend (proceso renderizador)
│   ├── views/
│   │   ├── index.html              # HTML principal
│   │   └── components/             # Componentes HTML modulares
│   │       ├── navbar.html         # Barra de navegación superior
│   │       ├── sidebar.html        # Formulario de recordatorios
│   │       ├── stats-filters.html  # Estadísticas y filtros
│   │       ├── reminders-list.html # Lista de recordatorios
│   │       ├── floating-button.html# Botón flotante
│   │       ├── delete-modal.html   # Modal de confirmación
│   │       ├── about-modal.html    # Modal acerca de
│   │       └── footer.html         # Pie de página
│   │
│   ├── js/                         # Scripts JavaScript modulares
│   │   ├── component-loader.js     # Cargador de componentes HTML
│   │   ├── variables.js            # Variables globales
│   │   ├── storage.js              # Persistencia de datos
│   │   ├── core.js                 # Funciones principales
│   │   ├── calendar.js             # Sistema de calendario
│   │   ├── formHandlers.js         # Manejo de formularios
│   │   ├── eventListeners.js       # Event listeners
│   │   ├── init.js                 # Inicialización de la app
│   │   └── script.js               # Coordinador principal
│   │
│   ├── assets/
│   │   ├── css/
│   │   │   └── styles.css          # Estilos (modo claro/oscuro)
│   │   └── images/
│   │       └── icon.png            # Icono de la aplicación
│   │
│   └── data/                       # Datos persistentes (auto-generado)
│       ├── reminders.json          # Recordatorios guardados
│       └── preferences.json        # Preferencias de usuario
│
└── node_modules/                  # Dependencias de npm
```

### Descripción de Archivos Clave

**Proceso Principal**
- `main.js` - Gestiona ventanas, IPC handlers, menús del sistema
- `preload.js` - Expone APIs seguras al renderer mediante contextBridge

**Componentes HTML** (Arquitectura modular)
- `navbar.html` - Barra superior con búsqueda y toggle de tema
- `sidebar.html` - Formulario para crear/editar con calendario integrado
- `stats-filters.html` - Tarjetas de estadísticas y controles de filtrado
- `reminders-list.html` - Área principal para mostrar recordatorios

**Scripts JavaScript** (Separación de responsabilidades)
- `component-loader.js` - Carga dinámica de componentes HTML
- `variables.js` - Estado global de la aplicación
- `storage.js` - Funciones de persistencia (IPC)
- `core.js` - Lógica de recordatorios, filtros, renderizado
- `calendar.js` - Selector de fechas personalizado
- `formHandlers.js` - Validación y envío de formularios
- `eventListeners.js` - Todos los event listeners
- `init.js` - Inicialización y carga inicial
- `script.js` - Verificación de módulos y coordinación

**Datos**
- `reminders.json` - Array de objetos de recordatorios
- `preferences.json` - Configuración de usuario (tema, sidebar)

## 🚀 Comenzar

### Paso 1: Preparación
1. Instala Node.js desde [nodejs.org](https://nodejs.org/)
2. Verifica la instalación: `node --version` y `npm --version`
3. Instala un editor de código (VS Code recomendado)

### Paso 2: Crear Proyecto
```bash
# Crear carpeta
mkdir reminders-app
cd reminders-app

# Inicializar proyecto
npm init -y

# Instalar Electron
npm install electron --save-dev
```

### Paso 3: Seguir el Tutorial
Ve a [Parte 1: Configuración Inicial](https://jrguevara.github.io/posts/electron-recordatorios-app-parte-01-configuracion-inicial/) para comenzar con la configuración de tu aplicación Electron.

## 💡 Consejos para el Éxito

1. **Lee primero, código después**: Entiende qué hace cada sección antes de copiar
2. **Prueba frecuentemente**: Ejecuta `npm start` después de cada cambio importante
3. **Usa DevTools**: Presiona F12 para ver errores y hacer debugging
4. **Experimenta**: Cambia colores, textos y funcionalidades para aprender
5. **Toma notas**: Documenta lo que aprendes con tus propias palabras
6. **No te frustres**: Es normal tener errores, usa la consola para identificarlos

## 🐛 Recursos de Ayuda

- **Documentación de Electron**: https://www.electronjs.org/docs
- **MDN Web Docs**: https://developer.mozilla.org/
- **Node.js Docs**: https://nodejs.org/docs/

## 📝 Convenciones del Tutorial

### Bloques de Código
```javascript
// Código JavaScript
function ejemplo() {
    console.log('Esto es un ejemplo');
}
```

### Comandos de Terminal
```bash
npm install paquete
npm start
```

### Notas Importantes
> ⚠️ **Importante**: Información crítica que debes tener en cuenta

### Verificaciones
✅ Marca cuando completes cada verificación

## 🎯 Resultado Final

Al finalizar el tutorial tendrás:
- ✅ Una aplicación de escritorio completamente funcional
- ✅ Conocimiento profundo de Electron
- ✅ Experiencia en arquitectura de aplicaciones de escritorio
- ✅ Base sólida para crear tus propias aplicaciones
- ✅ Aplicación lista para empaquetar y distribuir

## 🚦 ¡Listo para Empezar!

Ahora que conoces el panorama completo, estás listo para comenzar tu viaje en el desarrollo con Electron.

Sigue a la [Parte 1: Configuración Inicial](https://jrguevara.github.io/posts/electron-recordatorios-app-parte-01-configuracion-inicial/) para dar el primer paso hacia la creación de tu aplicación de recordatorios.

**¡Mucho éxito en tu aprendizaje!** 🎉

Si tienes preguntas o encuentras problemas, revisa la documentación oficial de Electron o la sección de solución de problemas en cada parte del tutorial.
