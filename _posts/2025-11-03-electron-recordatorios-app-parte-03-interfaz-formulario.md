---
title: Electron - Recordatorios App | Parte 3 - Interfaz de Usuario y Formulario
date: 2025-11-03 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 3: Interfaz de Usuario y Formulario de Recordatorios

## Objetivo
Crear la interfaz principal con formulario para agregar y editar recordatorios.

## Paso 1: Actualizar HTML principal

Actualiza `renderer/views/index.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recordatorios App</title>
    <link rel="stylesheet" href="../assets/css/styles.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="main-container">
        <!-- Barra lateral con formulario -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h2>Nuevo Recordatorio</h2>
                <button class="btn-icon" id="toggleSidebar" title="Ocultar formulario">
                    <i class="fas fa-chevron-left"></i>
                </button>
            </div>
            
            <form id="reminderForm">
                <div class="form-group">
                    <label for="title">
                        <i class="fas fa-heading"></i> Título *
                    </label>
                    <input type="text" id="title" required placeholder="Ej: Reunión con el equipo">
                </div>
                
                <div class="form-group">
                    <label for="description">
                        <i class="fas fa-align-left"></i> Descripción
                    </label>
                    <textarea id="description" rows="3" placeholder="Añade más detalles..."></textarea>
                </div>
                
                <div class="form-group">
                    <label for="category">
                        <i class="fas fa-folder"></i> Categoría *
                    </label>
                    <select id="category" required>
                        <option value="personal">Personal</option>
                        <option value="trabajo">Trabajo</option>
                        <option value="estudio">Estudio</option>
                        <option value="salud">Salud</option>
                        <option value="otro">Otro</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="priority">
                        <i class="fas fa-flag"></i> Prioridad *
                    </label>
                    <select id="priority" required>
                        <option value="baja">Baja</option>
                        <option value="media" selected>Media</option>
                        <option value="alta">Alta</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="dueDate">
                        <i class="fas fa-calendar"></i> Fecha límite
                    </label>
                    <input type="text" id="dueDate" placeholder="dd/mm/yyyy hh:mm" readonly>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" id="submitBtn">
                        <i class="fas fa-plus"></i> Agregar
                    </button>
                    <button type="button" class="btn btn-secondary" id="cancelBtn">
                        <i class="fas fa-times"></i> Cancelar
                    </button>
                </div>
            </form>
        </aside>

        <!-- Contenido principal -->
        <main class="content">
            <!-- Encabezado -->
            <header class="content-header">
                <div class="header-left">
                    <button class="btn-icon" id="showSidebarBtn" style="display: none;">
                        <i class="fas fa-chevron-right"></i>
                    </button>
                    <h1><i class="fas fa-bell"></i> Mis Recordatorios</h1>
                </div>
                <div class="header-right">
                    <button class="btn-icon" id="darkModeToggle" title="Cambiar tema">
                        <i class="fas fa-moon"></i>
                    </button>
                </div>
            </header>

            <!-- Barra de búsqueda -->
            <div class="search-bar">
                <i class="fas fa-search search-icon"></i>
                <input type="text" id="searchInput" placeholder="Buscar recordatorios...">
                <button class="btn-icon clear-search" id="clearSearch" style="display: none;">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Filtros -->
            <div class="filters">
                <select id="filterCategory" class="filter-select">
                    <option value="">Todas las categorías</option>
                    <option value="personal">Personal</option>
                    <option value="trabajo">Trabajo</option>
                    <option value="estudio">Estudio</option>
                    <option value="salud">Salud</option>
                    <option value="otro">Otro</option>
                </select>
                
                <select id="filterStatus" class="filter-select">
                    <option value="">Todos los estados</option>
                    <option value="pending">Pendientes</option>
                    <option value="completed">Completados</option>
                </select>
                
                <select id="sortBy" class="filter-select">
                    <option value="newest">Más recientes</option>
                    <option value="oldest">Más antiguos</option>
                    <option value="priority">Por prioridad</option>
                    <option value="dueDate">Por fecha límite</option>
                </select>
                
                <button class="btn btn-secondary btn-sm" id="clearFilters">
                    <i class="fas fa-filter-circle-xmark"></i> Limpiar filtros
                </button>
            </div>

            <!-- Estadísticas -->
            <div class="stats-container">
                <div class="stat-card">
                    <i class="fas fa-list-check"></i>
                    <div class="stat-info">
                        <span class="stat-value" id="totalReminders">0</span>
                        <span class="stat-label">Total</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-clock"></i>
                    <div class="stat-info">
                        <span class="stat-value" id="pendingReminders">0</span>
                        <span class="stat-label">Pendientes</span>
                    </div>
                </div>
                <div class="stat-card">
                    <i class="fas fa-circle-check"></i>
                    <div class="stat-info">
                        <span class="stat-value" id="completedReminders">0</span>
                        <span class="stat-label">Completados</span>
                    </div>
                </div>
            </div>

            <!-- Lista de recordatorios -->
            <div class="reminders-container">
                <div id="remindersList"></div>
                <div id="emptyState" class="empty-state" style="display: none;">
                    <i class="fas fa-inbox"></i>
                    <h3>No hay recordatorios</h3>
                    <p>Comienza creando tu primer recordatorio</p>
                </div>
            </div>
        </main>
    </div>

    <!-- Modal de confirmación -->
    <div class="modal" id="deleteModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-trash-alt"></i> Confirmar eliminación</h3>
                <button class="modal-close" id="modalClose">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <p>¿Estás seguro de que quieres eliminar el recordatorio?</p>
                <p class="reminder-title" id="modalReminderTitle"></p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelDelete">Cancelar</button>
                <button class="btn btn-danger" id="confirmDelete">Eliminar</button>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="../js/variables.js"></script>
    <script src="../js/storage.js"></script>
    <script src="../js/init.js"></script>
</body>
</html>
```

## Paso 2: Expandir estilos CSS

Reemplaza `renderer/assets/css/styles.css`:

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --success-color: #10b981;
    --danger-color: #ef4444;
    --warning-color: #f59e0b;
    --text-primary: #1f2937;
    --text-secondary: #6b7280;
    --bg-primary: #ffffff;
    --bg-secondary: #f3f4f6;
    --border-color: #e5e7eb;
    --shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
    min-height: 100vh;
    padding: 20px;
}

/* Contenedor principal */
.main-container {
    max-width: 1400px;
    margin: 0 auto;
    background: var(--bg-primary);
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    display: flex;
    overflow: hidden;
    min-height: calc(100vh - 40px);
}

/* Sidebar */
.sidebar {
    width: 350px;
    background: var(--bg-secondary);
    padding: 20px;
    border-right: 1px solid var(--border-color);
    overflow-y: auto;
    transition: transform 0.3s ease;
}

.sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.sidebar-header h2 {
    font-size: 1.5rem;
    color: var(--text-primary);
}

/* Formulario */
.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    color: var(--text-primary);
    font-weight: 500;
}

.form-group label i {
    margin-right: 5px;
    color: var(--primary-color);
}

.form-group input,
.form-group textarea,
.form-group select {
    width: 100%;
    padding: 10px 15px;
    border: 2px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.3s;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
    outline: none;
    border-color: var(--primary-color);
}

.form-group textarea {
    resize: vertical;
}

/* Botones */
.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
    background: var(--text-secondary);
    color: white;
}

.btn-secondary:hover {
    background: var(--text-primary);
}

.btn-danger {
    background: var(--danger-color);
    color: white;
}

.btn-icon {
    width: 36px;
    height: 36px;
    border: none;
    background: transparent;
    cursor: pointer;
    border-radius: 8px;
    transition: background 0.3s;
}

.btn-icon:hover {
    background: rgba(0, 0, 0, 0.05);
}

.form-actions {
    display: flex;
    gap: 10px;
}

.form-actions .btn {
    flex: 1;
}

#cancelBtn {
    display: none;
}

#cancelBtn.show {
    display: inline-flex;
}

/* Contenido principal */
.content {
    flex: 1;
    padding: 30px;
    overflow-y: auto;
}

.content-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.header-left {
    display: flex;
    align-items: center;
    gap: 15px;
}

.content-header h1 {
    font-size: 2rem;
    color: var(--text-primary);
    display: flex;
    align-items: center;
    gap: 10px;
}

/* Búsqueda */
.search-bar {
    position: relative;
    margin-bottom: 20px;
}

.search-bar input {
    width: 100%;
    padding: 12px 45px 12px 45px;
    border: 2px solid var(--border-color);
    border-radius: 12px;
    font-size: 15px;
}

.search-icon {
    position: absolute;
    left: 15px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-secondary);
}

.clear-search {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
}

/* Filtros */
.filters {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.filter-select {
    padding: 8px 15px;
    border: 2px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
}

/* Estadísticas */
.stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.stat-card {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
    padding: 20px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 15px;
}

.stat-card i {
    font-size: 2rem;
}

.stat-info {
    display: flex;
    flex-direction: column;
}

.stat-value {
    font-size: 1.5rem;
    font-weight: 700;
}

.stat-label {
    font-size: 0.9rem;
    opacity: 0.9;
}

/* Lista de recordatorios */
.reminders-container {
    background: white;
    border-radius: 12px;
    padding: 20px;
}

#remindersList {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.reminder-item {
    background: var(--bg-secondary);
    border: 2px solid var(--border-color);
    border-radius: 12px;
    padding: 20px;
    transition: all 0.3s;
}

.reminder-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.reminder-item.completed {
    opacity: 0.6;
}

/* Estado vacío */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: var(--text-secondary);
}

.empty-state i {
    font-size: 4rem;
    margin-bottom: 20px;
    opacity: 0.5;
}

.empty-state h3 {
    font-size: 1.5rem;
    margin-bottom: 10px;
}

/* Modal */
.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
}

.modal.show {
    display: flex;
}

.modal-content {
    background: white;
    border-radius: 12px;
    width: 90%;
    max-width: 500px;
    overflow: hidden;
}

.modal-header,
.modal-body,
.modal-footer {
    padding: 20px;
}

.modal-header {
    background: var(--bg-secondary);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-footer {
    background: var(--bg-secondary);
    display: flex;
    justify-content: flex-end;
    gap: 10px;
}
```

## Paso 3: Actualizar sistema de inicialización

Actualiza `renderer/js/init.js`:

```javascript
// Inicializar elementos del DOM
function initDOMElements() {
    // Formulario y controles
    reminderForm = document.getElementById('reminderForm');
    submitBtn = document.getElementById('submitBtn');
    cancelBtn = document.getElementById('cancelBtn');
    
    // Sidebar
    sidebar = document.getElementById('sidebar');
    
    // Lista y estados
    remindersList = document.getElementById('remindersList');
    emptyState = document.getElementById('emptyState');
    
    // Búsqueda
    searchInput = document.getElementById('searchInput');
    clearSearchBtn = document.getElementById('clearSearch');
    
    // Tema
    darkModeToggle = document.getElementById('darkModeToggle');
    
    // Modal
    deleteModal = document.getElementById('deleteModal');
    confirmDeleteBtn = document.getElementById('confirmDelete');
    cancelDeleteBtn = document.getElementById('cancelDelete');
    modalClose = document.getElementById('modalClose');
    modalReminderTitle = document.getElementById('modalReminderTitle');
}

// Inicializar aplicación
async function initApp() {
    console.log('Iniciando aplicación...');
    
    // Inicializar elementos DOM
    initDOMElements();
    
    // Cargar preferencias
    await loadPreferences();
    
    // Aplicar tema
    applyTheme();
    
    // Cargar recordatorios
    await loadReminders();
    
    // Configurar event listeners
    setupEventListeners();
    
    console.log('Aplicación iniciada correctamente');
}

// Aplicar tema
function applyTheme() {
    if (currentTheme === 'dark') {
        document.body.classList.add('dark-mode');
        if (darkModeToggle) {
            darkModeToggle.querySelector('i').className = 'fas fa-sun';
        }
    } else {
        document.body.classList.remove('dark-mode');
        if (darkModeToggle) {
            darkModeToggle.querySelector('i').className = 'fas fa-moon';
        }
    }
}

// Configurar event listeners básicos
function setupEventListeners() {
    // Tema
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleTheme);
    }
    
    // Modal
    if (cancelDeleteBtn) {
        cancelDeleteBtn.addEventListener('click', closeDeleteModal);
    }
    if (modalClose) {
        modalClose.addEventListener('click', closeDeleteModal);
    }
    
    // Cancelar edición
    if (cancelBtn) {
        cancelBtn.addEventListener('click', cancelEdit);
    }
}

// Función para cancelar edición
function cancelEdit() {
    editingId = null;
    reminderForm.reset();
    submitBtn.innerHTML = '<i class="fas fa-plus"></i> Agregar';
    submitBtn.className = 'btn btn-primary';
    cancelBtn.classList.remove('show');
    document.querySelector('.sidebar-header h2').textContent = 'Nuevo Recordatorio';
}

// Alternar tema
async function toggleTheme() {
    currentTheme = currentTheme === 'light' ? 'dark' : 'light';
    applyTheme();
    await savePreference(THEME_KEY, currentTheme);
}

// Cerrar modal
function closeDeleteModal() {
    if (deleteModal) {
        deleteModal.classList.remove('show');
    }
    reminderToDelete = null;
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', initApp);
```

## Paso 4: Probar la interfaz

```bash
npm start
```

Deberías ver:
- ✅ Formulario en sidebar izquierdo
- ✅ Área principal con encabezado
- ✅ Barra de búsqueda
- ✅ Filtros
- ✅ Tarjetas de estadísticas
- ✅ Botón de tema claro/oscuro

## Resultado esperado
✅ Interfaz completa renderizada
✅ Formulario funcional visualmente
✅ Modal de confirmación creado
✅ Sistema de temas funcionando

## Siguiente paso
En la Parte 4, implementaremos la lógica para crear, editar y eliminar recordatorios.
