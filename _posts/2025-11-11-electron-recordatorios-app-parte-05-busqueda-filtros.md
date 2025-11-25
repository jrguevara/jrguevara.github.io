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
// FUNCIONES DE BÚSQUEDA Y FILTROS
// ===========================================

// Obtener recordatorios filtrados
function getFilteredReminders() {
    const categoryFilter = document.getElementById('filterCategory')?.value || 'all';
    const statusFilter = document.getElementById('filterStatus')?.value || 'all';
    const sortBy = document.getElementById('sortBy')?.value || 'newest';
    const searchTerm = searchInput?.value.toLowerCase().trim() || '';
    
    // Aplicar filtros
    let filtered = reminders.filter(reminder => {
        // Filtro por categoría
        const categoryMatch = categoryFilter === 'all' || reminder.category === categoryFilter;
        
        // Filtro por estado
        let statusMatch;
        if (statusFilter === 'all') {
            statusMatch = true;
        } else if (statusFilter === 'completed') {
            statusMatch = reminder.completed === true;
        } else if (statusFilter === 'pending') {
            statusMatch = reminder.completed !== true;
        } else {
            statusMatch = true;
        }
        
        // Filtro por búsqueda de texto
        const searchMatch = !searchTerm || 
            reminder.title.toLowerCase().includes(searchTerm) ||
            reminder.description.toLowerCase().includes(searchTerm) ||
            reminder.category.toLowerCase().includes(searchTerm);
        
        return categoryMatch && statusMatch && searchMatch;
    });
    
    // Aplicar ordenamiento
    filtered.sort((a, b) => {
        switch(sortBy) {
            case 'oldest':
                return new Date(a.dueDate || a.createdAt) - new Date(b.dueDate || b.createdAt);
            case 'alphabetical':
                return a.title.localeCompare(b.title);
            case 'category':
                return a.category.localeCompare(b.category);
            case 'priority':
                const priorityOrder = { 'alta': 3, 'media': 2, 'baja': 1 };
                return (priorityOrder[b.priority] || 0) - (priorityOrder[a.priority] || 0);
            case 'dueDate':
                const aDate = a.dueDate ? new Date(a.dueDate) : new Date('9999-12-31');
                const bDate = b.dueDate ? new Date(b.dueDate) : new Date('9999-12-31');
                return aDate - bDate;
            case 'newest':
            default:
                return new Date(b.dueDate || b.createdAt) - new Date(a.dueDate || a.createdAt);
        }
    });
    
    return filtered;
}

// Variable para el debounce de búsqueda
let searchTimeout;

// Manejar búsqueda con debounce
function handleSearch() {
    // Obtener elemento si no está disponible
    if (!searchInput) {
        searchInput = document.getElementById('searchInput');
    }
    
    // Limpiar timeout anterior
    if (searchTimeout) {
        clearTimeout(searchTimeout);
    }
    
    const term = searchInput ? searchInput.value.trim() : '';
    
    // Si el campo está vacío, ejecutar inmediatamente
    if (!term) {
        const clearBtn = clearSearchBtn || document.getElementById('clearSearch');
        if (clearBtn) clearBtn.style.display = 'none';
        renderReminders();
        return;
    }
    
    // Para búsquedas con texto, usar debounce
    const clearBtn = clearSearchBtn || document.getElementById('clearSearch');
    if (clearBtn) clearBtn.style.display = 'block';
    
    searchTimeout = setTimeout(() => {
        renderReminders();
    }, 200);
}

// Función de búsqueda inmediata (sin debounce)
function handleSearchImmediate() {
    // Obtener elemento si no está disponible
    if (!searchInput) {
        searchInput = document.getElementById('searchInput');
    }
    
    const term = searchInput ? searchInput.value.trim() : '';
    
    const clearBtn = clearSearchBtn || document.getElementById('clearSearch');
    if (term) {
        if (clearBtn) clearBtn.style.display = 'block';
    } else {
        if (clearBtn) clearBtn.style.display = 'none';
    }
    
    renderReminders();
}

// Limpiar búsqueda
function clearSearch() {
    // Obtener elemento si no está disponible
    if (!searchInput) {
        searchInput = document.getElementById('searchInput');
    }
    
    if (searchInput) {
        searchInput.value = '';
        const clearBtn = clearSearchBtn || document.getElementById('clearSearch');
        if (clearBtn) clearBtn.style.display = 'none';
        renderReminders();
        showNotification('Búsqueda limpiada', 'info');
    }
}

// Limpiar todos los filtros
function clearAllFilters() {
    try {
        // Limpiar búsqueda
        if (searchInput) {
            searchInput.value = '';
            if (clearSearchBtn) clearSearchBtn.style.display = 'none';
        }
        
        // Restablecer filtros
        const filterCategory = document.getElementById('filterCategory');
        const filterStatus = document.getElementById('filterStatus');
        const sortBy = document.getElementById('sortBy');
        
        if (filterCategory) {
            filterCategory.value = 'all';
        }
        
        if (filterStatus) {
            filterStatus.value = 'all';
        }
        
        if (sortBy) {
            sortBy.value = 'newest';
        }
        
        renderReminders();
        showNotification('Filtros limpiados', 'info');
        
    } catch (error) {
        showNotification('Error al limpiar filtros', 'error');
    }
}

// ===========================================
// FUNCIONES DE FILTROS Y RENDERIZADO
// ===========================================

// Inicializar filtros en estado limpio al cargar la aplicación
function initializeFilters() {
    // Verificar que los elementos críticos estén disponibles
    if (!remindersList || !emptyState) {
        setTimeout(initializeFilters, 200);
        return;
    }
    
    // Obtener elementos de filtros
    const filterCategory = document.getElementById('filterCategory');
    const filterStatus = document.getElementById('filterStatus');
    const sortBy = document.getElementById('sortBy');
    
    // Limpiar búsqueda si existe
    if (searchInput) {
        searchInput.value = '';
        if (clearSearchBtn) {
            clearSearchBtn.style.display = 'none';
        }
    }
    
    // Restablecer filtros a valores por defecto si existen
    if (filterCategory) filterCategory.value = 'all';
    if (filterStatus) filterStatus.value = 'all';
    if (sortBy) sortBy.value = 'newest';
    
    // Renderizar recordatorios con filtros limpios
    renderReminders();
}

// Obtener recordatorios filtrados
function getFilteredReminders() {
    const categoryFilter = document.getElementById('filterCategory')?.value || 'all';
    const statusFilter = document.getElementById('filterStatus')?.value || 'all';
    const sortBy = document.getElementById('sortBy')?.value || 'newest';
    const searchTerm = searchInput?.value.toLowerCase().trim() || '';
    
    // Aplicar filtros
    let filtered = reminders.filter(reminder => {
        // Filtro por categoría
        const categoryMatch = categoryFilter === 'all' || reminder.category === categoryFilter;
        
        // Filtro por estado
        let statusMatch;
        if (statusFilter === 'all') {
            statusMatch = true;
        } else if (statusFilter === 'completed') {
            statusMatch = reminder.completed === true;
        } else if (statusFilter === 'pending') {
            statusMatch = reminder.completed !== true;
        } else {
            statusMatch = true;
        }
        
        // Filtro por búsqueda de texto
        const searchMatch = !searchTerm || 
            reminder.title.toLowerCase().includes(searchTerm) ||
            reminder.description.toLowerCase().includes(searchTerm) ||
            reminder.category.toLowerCase().includes(searchTerm);
        
        return categoryMatch && statusMatch && searchMatch;
    });
    
    // Aplicar ordenamiento
    filtered.sort((a, b) => {
        switch(sortBy) {
            case 'oldest':
                return new Date(a.dueDate || a.createdAt) - new Date(b.dueDate || b.createdAt);
            case 'alphabetical':
                return a.title.localeCompare(b.title);
            case 'category':
                return a.category.localeCompare(b.category);
            case 'priority':
                const priorityOrder = { 'alta': 3, 'media': 2, 'baja': 1 };
                return (priorityOrder[b.priority] || 0) - (priorityOrder[a.priority] || 0);
            case 'dueDate':
                const aDate = a.dueDate ? new Date(a.dueDate) : new Date('9999-12-31');
                const bDate = b.dueDate ? new Date(b.dueDate) : new Date('9999-12-31');
                return aDate - bDate;
            case 'newest':
            default:
                return new Date(b.dueDate || b.createdAt) - new Date(a.dueDate || a.createdAt);
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
        // Evento principal de búsqueda (input para búsqueda en tiempo real)
        searchInput.addEventListener('input', function(e) {
            handleSearch();
        });
        
        // Event listener de respaldo
        searchInput.oninput = function() {
            handleSearch();
        };
        
        // Evento de keyup adicional
        searchInput.addEventListener('keyup', function(e) {
            handleSearch();
        });
        
        // Eventos adicionales para mejor responsividad
        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                if (searchTimeout) clearTimeout(searchTimeout);
                handleSearchImmediate();
            }
            // Búsqueda inmediata al borrar (Backspace/Delete)
            if (e.key === 'Backspace' || e.key === 'Delete') {
                setTimeout(() => {
                    handleSearchImmediate();
                }, 50);
            }
        });
        
        // Evento para cuando el campo pierde el foco
        searchInput.addEventListener('blur', function() {
            handleSearchImmediate();
        });
    } else {
        console.error('❌ searchInput no encontrado');
    }
    if (clearSearchBtn) {
        clearSearchBtn.addEventListener('click', clearSearch);
        
        // Event listener de respaldo
        clearSearchBtn.onclick = function() {
            clearSearch();
        };
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
        filterCategory.addEventListener('change', function(e) {
            renderReminders();
        });
    }
    if (filterStatus) {
        filterStatus.addEventListener('change', function(e) {
            renderReminders();
        });
    }
    if (sortBy) {
        sortBy.addEventListener('change', function(e) {
            renderReminders();
        });
    }
    if (clearFiltersBtn) {
        clearFiltersBtn.addEventListener('click', clearAllFilters);
        
        // Event listener adicional de respaldo
        clearFiltersBtn.onclick = function(e) {
            e.preventDefault();
            clearAllFilters();
        };
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
    
    // Tema
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleTheme);
    }
    
    // Atajos de teclado
    document.addEventListener('keydown', handleKeyboardShortcuts);
}
```

## Paso 3: Actualizar init.js

Actualizar contenido completo de `renderer/js/init.js`:

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
    
    // Verificar elementos de filtros
    const filterCategory = document.getElementById('filterCategory');
    const filterStatus = document.getElementById('filterStatus'); 
    const sortBy = document.getElementById('sortBy');
    const clearFiltersBtn = document.getElementById('clearFilters');

    // Modal
    deleteModal = document.getElementById('deleteModal');
    confirmDeleteBtn = document.getElementById('confirmDelete');
    cancelDeleteBtn = document.getElementById('cancelDelete');
    modalClose = document.getElementById('modalClose');
    modalReminderTitle = document.getElementById('modalReminderTitle');
}

// Inicializar aplicación
async function initApp() {
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
    
    // Inicializar filtros
    setTimeout(() => {
        // Configurar event listeners de respaldo
        const filterCategory = document.getElementById('filterCategory');
        const filterStatus = document.getElementById('filterStatus');
        const sortBy = document.getElementById('sortBy');
        const searchField = document.getElementById('searchInput');
        
        if (filterCategory) {
            filterCategory.onchange = function() {
                renderReminders();
            };
        }
        if (filterStatus) {
            filterStatus.onchange = function() {
                renderReminders();
            };
        }
        if (sortBy) {
            sortBy.onchange = function() {
                renderReminders();
            };
        }
        
        if (searchField) {
            searchField.oninput = function() {
                handleSearch();
            };
        }
        
        renderReminders();
    }, 200);

    // Renderizar recordatorios iniciales
    renderReminders();

    // Hacer funciones disponibles globalmente para onclick
    window.showDeleteModal = showDeleteModal;
    window.editReminder = editReminder;
    window.toggleReminder = toggleReminder;
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

## Paso 4: Actualizar index.html con los scripts

Reemplaza la secciens siguientes del `<body>`:

```html
            <div class="search-bar">
                <i class="fas fa-search search-icon"></i>
                <input type="text" id="searchInput" placeholder="Buscar recordatorios..." 
                       oninput="handleSearch();" 
                       onkeyup="handleSearch();">
                <button class="btn-icon clear-search" id="clearSearch" style="display: none;" 
                        onclick="clearSearch();">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Filtros -->
            <div class="filters">
                <select id="filterCategory" class="filter-select" onchange="renderReminders();">
                    <option value="all">Todas las categorías</option>
                    <option value="personal">Personal</option>
                    <option value="trabajo">Trabajo</option>
                    <option value="estudio">Estudio</option>
                    <option value="salud">Salud</option>
                    <option value="otro">Otro</option>
                </select>
                
                <select id="filterStatus" class="filter-select" onchange="renderReminders();">
                    <option value="all">Todos los estados</option>
                    <option value="pending">Pendientes</option>
                    <option value="completed">Completados</option>
                </select>
                
                <select id="sortBy" class="filter-select" onchange="renderReminders();">
                    <option value="newest">Más recientes</option>
                    <option value="oldest">Más antiguos</option>
                    <option value="alphabetical">Alfabético</option>
                    <option value="category">Por categoría</option>
                    <option value="priority">Por prioridad</option>
                    <option value="dueDate">Por fecha límite</option>
                </select>
                
                <button type="button" class="btn btn-secondary btn-sm" id="clearFilters" onclick="clearAllFilters();">
                    <i class="fas fa-filter-circle-xmark"></i> Limpiar filtros
                </button>
            </div>

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

Mejora el diseño del estado vacío en `styles.css` y agregar clases de filtros y búsqueda:

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
// Renderizar lista de recordatorios
function renderReminders() {
    if (!remindersList) {
        return;
    }
    
    const filtered = getFilteredReminders();
    
    if (filtered.length === 0) {
        remindersList.style.display = 'none';
        if (emptyState) emptyState.style.display = 'block';
        return;
    }
    
    remindersList.style.display = 'grid';
    if (emptyState) emptyState.style.display = 'none';
    
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
