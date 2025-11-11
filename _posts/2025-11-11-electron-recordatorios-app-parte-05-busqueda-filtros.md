---
title: Electron - Recordatorios App | Parte 5 - Búsqueda y Filtros
date: 2025-11-11 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 5: Búsqueda y Filtros

## Objetivo
Implementar sistema de búsqueda en tiempo real y filtros por categoría, estado y ordenamiento.

## Paso 1: Actualizar core.js con funciones de filtrado

Agrega estas funciones en `renderer/js/core.js`:

```javascript
// ===========================================
// BÚSQUEDA Y FILTROS
// ===========================================

// Manejar búsqueda
function handleSearch() {
    const searchTerm = searchInput.value.trim();
    
    if (searchTerm) {
        clearSearchBtn.style.display = 'block';
    } else {
        clearSearchBtn.style.display = 'none';
    }
    
    renderReminders();
}

// Limpiar búsqueda
function clearSearch() {
    searchInput.value = '';
    clearSearchBtn.style.display = 'none';
    renderReminders();
}

// Limpiar todos los filtros
function clearAllFilters() {
    // Limpiar búsqueda
    if (searchInput) {
        searchInput.value = '';
        if (clearSearchBtn) {
            clearSearchBtn.style.display = 'none';
        }
    }
    
    // Restablecer filtros
    const filterCategory = document.getElementById('filterCategory');
    const filterStatus = document.getElementById('filterStatus');
    const sortBy = document.getElementById('sortBy');
    
    if (filterCategory) filterCategory.value = '';
    if (filterStatus) filterStatus.value = '';
    if (sortBy) sortBy.value = 'newest';
    
    renderReminders();
    showNotification('Filtros limpiados', 'info');
}

// Obtener recordatorios filtrados (actualizar esta función)
function getFilteredReminders() {
    const categoryFilter = document.getElementById('filterCategory')?.value || '';
    const statusFilter = document.getElementById('filterStatus')?.value || '';
    const sortBy = document.getElementById('sortBy')?.value || 'newest';
    const searchTerm = searchInput?.value.toLowerCase().trim() || '';
    
    // Aplicar filtros
    let filtered = reminders.filter(reminder => {
        // Filtro por categoría
        const categoryMatch = !categoryFilter || reminder.category === categoryFilter;
        
        // Filtro por estado
        let statusMatch = true;
        if (statusFilter === 'pending') {
            statusMatch = !reminder.completed;
        } else if (statusFilter === 'completed') {
            statusMatch = reminder.completed;
        }
        
        // Filtro por búsqueda
        const searchMatch = !searchTerm || 
            reminder.title.toLowerCase().includes(searchTerm) ||
            (reminder.description && reminder.description.toLowerCase().includes(searchTerm)) ||
            reminder.category.toLowerCase().includes(searchTerm);
        
        return categoryMatch && statusMatch && searchMatch;
    });
    
    // Aplicar ordenamiento
    filtered.sort((a, b) => {
        switch(sortBy) {
            case 'oldest':
                return new Date(a.createdAt) - new Date(b.createdAt);
            case 'priority':
                const priorityOrder = { 'alta': 3, 'media': 2, 'baja': 1 };
                return priorityOrder[b.priority] - priorityOrder[a.priority];
            case 'dueDate':
                if (!a.dueDate && !b.dueDate) return 0;
                if (!a.dueDate) return 1;
                if (!b.dueDate) return -1;
                return new Date(a.dueDate) - new Date(b.dueDate);
            case 'newest':
            default:
                return new Date(b.createdAt) - new Date(a.createdAt);
        }
    });
    
    return filtered;
}
```

## Paso 2: Crear eventListeners.js

Crea `renderer/js/eventListeners.js`:

```javascript
// Configurar event listeners
function setupEventListeners() {
    // Formulario
    if (reminderForm) {
        reminderForm.addEventListener('submit', handleFormSubmit);
    }
    
    // Búsqueda
    if (searchInput) {
        searchInput.addEventListener('input', handleSearch);
    }
    if (clearSearchBtn) {
        clearSearchBtn.addEventListener('click', clearSearch);
    }
    
    // Tema
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleTheme);
    }
    
    // Filtros
    const filterCategory = document.getElementById('filterCategory');
    const filterStatus = document.getElementById('filterStatus');
    const sortBy = document.getElementById('sortBy');
    const clearFiltersBtn = document.getElementById('clearFilters');
    
    if (filterCategory) {
        filterCategory.addEventListener('change', renderReminders);
    }
    if (filterStatus) {
        filterStatus.addEventListener('change', renderReminders);
    }
    if (sortBy) {
        sortBy.addEventListener('change', renderReminders);
    }
    if (clearFiltersBtn) {
        clearFiltersBtn.addEventListener('click', clearAllFilters);
    }
    
    // Modal
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener('click', confirmDelete);
    }
    if (cancelDeleteBtn) {
        cancelDeleteBtn.addEventListener('click', closeDeleteModal);
    }
    if (modalClose) {
        modalClose.addEventListener('click', closeDeleteModal);
    }
    if (deleteModal) {
        deleteModal.addEventListener('click', (e) => {
            if (e.target === deleteModal) closeDeleteModal();
        });
    }
    
    // Cancelar edición
    if (cancelBtn) {
        cancelBtn.addEventListener('click', resetForm);
    }
    
    // Atajos de teclado
    document.addEventListener('keydown', handleKeyboardShortcuts);
}

// Manejar atajos de teclado
function handleKeyboardShortcuts(e) {
    // Escape para cancelar
    if (e.key === 'Escape') {
        if (deleteModal.classList.contains('show')) {
            closeDeleteModal();
        } else if (editingId) {
            resetForm();
        }
    }
    
    // Ctrl/Cmd + K para enfocar búsqueda
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        searchInput.focus();
    }
}
```

## Paso 3: Actualizar init.js

Modifica el final de `renderer/js/init.js`:

```javascript
// Inicializar aplicación
async function initApp() {
    console.log('Iniciando aplicación...');
    
    initDOMElements();
    await loadPreferences();
    applyTheme();
    await loadReminders();
    setupEventListeners();
    renderReminders();
    
    console.log('Aplicación iniciada correctamente');
}
```

## Paso 4: Actualizar index.html con los scripts

Reemplaza la sección de scripts al final del `<body>`:

```html
    <!-- Scripts -->
    <script src="../js/variables.js"></script>
    <script src="../js/storage.js"></script>
    <script src="../js/core.js"></script>
    <script src="../js/formHandlers.js"></script>
    <script src="../js/eventListeners.js"></script>
    <script src="../js/init.js"></script>
</body>
```

## Paso 5: Actualizar estilos de filtros

Agrega estos estilos en `styles.css`:

```css
/* Mejoras para filtros */
.filter-select {
    padding: 8px 15px;
    border: 2px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    background: white;
    cursor: pointer;
    transition: border-color 0.3s;
}

.filter-select:hover {
    border-color: var(--primary-color);
}

.filter-select:focus {
    outline: none;
    border-color: var(--primary-color);
}

.btn-sm {
    padding: 8px 15px;
    font-size: 14px;
}

/* Indicador de búsqueda activa */
.search-bar input:not(:placeholder-shown) {
    border-color: var(--primary-color);
}

/* Estado de filtros activos */
.filters .filter-select:not([value=""]) {
    border-color: var(--primary-color);
    background: rgba(102, 126, 234, 0.1);
}
```

## Paso 6: Actualizar estilos para estado vacío

Mejora el diseño del estado vacío en `styles.css`:

```css
/* Estado vacío mejorado */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: var(--text-secondary);
}

.empty-state i {
    font-size: 4rem;
    margin-bottom: 20px;
    opacity: 0.3;
    color: var(--primary-color);
}

.empty-state h3 {
    font-size: 1.5rem;
    margin-bottom: 10px;
    color: var(--text-primary);
}

.empty-state p {
    font-size: 1rem;
    color: var(--text-secondary);
}
```

## Paso 7: Agregar contador de resultados

Actualiza la función `renderReminders` en `core.js`:

```javascript
// Renderizar lista de recordatorios (actualizar)
function renderReminders() {
    const filtered = getFilteredReminders();
    
    if (filtered.length === 0) {
        remindersList.style.display = 'none';
        emptyState.style.display = 'block';
        
        // Actualizar mensaje según contexto
        const hasSearch = searchInput && searchInput.value.trim();
        const hasFilters = document.getElementById('filterCategory')?.value || 
                          document.getElementById('filterStatus')?.value;
        
        if (hasSearch || hasFilters) {
            emptyState.querySelector('h3').textContent = 'No se encontraron resultados';
            emptyState.querySelector('p').textContent = 'Intenta con otros filtros o búsqueda';
        } else {
            emptyState.querySelector('h3').textContent = 'No hay recordatorios';
            emptyState.querySelector('p').textContent = 'Comienza creando tu primer recordatorio';
        }
        
        return;
    }
    
    remindersList.style.display = 'grid';
    emptyState.style.display = 'none';
    
    remindersList.innerHTML = filtered.map(reminder => createReminderCard(reminder)).join('');
    updateStats();
}
```

## Paso 8: Probar funcionalidad

```bash
npm start
```

Prueba:
- ✅ Búsqueda en tiempo real
- ✅ Filtro por categoría
- ✅ Filtro por estado (pendiente/completado)
- ✅ Ordenar por fecha, prioridad
- ✅ Limpiar filtros
- ✅ Mensaje contextual cuando no hay resultados
- ✅ Atajo Ctrl/Cmd+K para buscar
- ✅ Escape para cancelar

## Resultado esperado
- ✅ Búsqueda funciona instantáneamente
- ✅ Filtros se aplican correctamente
- ✅ Ordenamiento funciona
- ✅ Botón limpiar filtros funcional
- ✅ Mensajes contextuales apropiados
- ✅ Atajos de teclado funcionando

## Siguiente paso
En la Parte 6, implementaremos el selector de fechas personalizado (calendario).
