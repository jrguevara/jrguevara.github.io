---
title: Electron - Recordatorios App | Parte 4 - CRUD de Recordatorios
date: 2025-11-06 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 4: CRUD de Recordatorios

## Objetivo
Implementar las operaciones de Crear, Leer, Actualizar y Eliminar recordatorios.

## Paso 1: Actualizar handlers IPC en main.js

Agrega los handlers después del handler 'set-preference' en el archivo `main.js`:

```javascript

// Función para asegurar que el directorio de datos exista
async function ensureDataDirectory() {
    try {
        const dataDir = path.join(__dirname, 'renderer', 'data');
        await fs.mkdir(dataDir, { recursive: true });
    } catch (error) {
        console.error('Error creating data directory:', error);
    }
}

// Funciones para manejar los recordatorios
async function loadReminders() {
    try {
        await ensureDataDirectory();
        const data = await fs.readFile(DATA_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        // Si no existe el archivo, crear uno vacío
        return [];
    }
}

async function saveReminders(reminders) {
    try {
        await ensureDataDirectory();
        await fs.writeFile(DATA_FILE, JSON.stringify(reminders, null, 2));
        return true;
    } catch (error) {
        console.error('Error guardando recordatorios:', error);
        return false;
    }
}

// IPC Handlers
ipcMain.handle('get-reminders', async () => {
    return await loadReminders();
});

ipcMain.handle('save-reminder', async (event, reminder) => {
    const reminders = await loadReminders();
    reminder.id = Date.now().toString();
    reminder.createdAt = new Date().toISOString();
    reminder.completed = false;
    reminders.push(reminder);
    const success = await saveReminders(reminders);
    return success ? reminder : null;
});

ipcMain.handle('update-reminder', async (event, updatedReminder) => {
    const reminders = await loadReminders();
    const index = reminders.findIndex(r => r.id === updatedReminder.id);
    if (index !== -1) {
        reminders[index] = { ...reminders[index], ...updatedReminder };
        const success = await saveReminders(reminders);
        return success ? reminders[index] : null;
    }
    return null;
});

ipcMain.handle('delete-reminder', async (event, id) => {
    const reminders = await loadReminders();
    const filteredReminders = reminders.filter(r => r.id !== id);
    return await saveReminders(filteredReminders);
});

ipcMain.handle('toggle-reminder', async (event, id) => {
    const reminders = await loadReminders();
    const reminder = reminders.find(r => r.id === id);
    if (reminder) {
        reminder.completed = !reminder.completed;
        const success = await saveReminders(reminders);
        return success ? reminder : null;
    }
    return null;
});
```

## Paso 2: Actualizar preload.js

Agrega los métodos en `contextBridge.exposeInMainWorld`:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    // Preferencias
    getPreference: (key) => ipcRenderer.invoke('get-preference', key),
    setPreference: (key, value) => ipcRenderer.invoke('set-preference', key, value),
    
    // Recordatorios
    getReminders: () => ipcRenderer.invoke('get-reminders'),
    saveReminder: (reminder) => ipcRenderer.invoke('save-reminder', reminder),
    updateReminder: (reminder) => ipcRenderer.invoke('update-reminder', reminder),
    deleteReminder: (id) => ipcRenderer.invoke('delete-reminder', id),
    toggleReminder: (id) => ipcRenderer.invoke('toggle-reminder', id)
});
```

## Paso 3: Crear core.js con funciones principales

Crea `renderer/js/core.js`:

```javascript
// ===========================================
// FUNCIONES DE RECORDATORIOS
// ===========================================

// Editar recordatorio
function editReminder(id) {
    const reminder = reminders.find(r => r.id === id);
    if (!reminder) return;
    
    // Llenar formulario
    document.getElementById('title').value = reminder.title;
    document.getElementById('description').value = reminder.description || '';
    document.getElementById('category').value = reminder.category;
    document.getElementById('priority').value = reminder.priority;
    
    // Formatear fecha si existe
    if (reminder.dueDate) {
        const date = new Date(reminder.dueDate);
        const formatted = `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
        document.getElementById('dueDate').value = formatted;
    }
    
    // Actualizar estado de edición
    editingId = id;
    submitBtn.innerHTML = '<i class="fas fa-save"></i> Actualizar';
    submitBtn.className = 'btn btn-primary';
    document.querySelector('.sidebar-header h2').textContent = 'Editar Recordatorio';
    cancelBtn.classList.add('show');
    
    // Mostrar sidebar si está oculta
    if (sidebar.classList.contains('collapsed')) {
        toggleSidebar();
    }
    
    // Scroll al inicio del formulario
    sidebar.scrollTop = 0;
}

// Mostrar modal de eliminación
function showDeleteModal(id) {
    const reminder = reminders.find(r => r.id === id);
    if (!reminder) return;
    
    reminderToDelete = id;
    modalReminderTitle.textContent = `"${reminder.title}"`;
    deleteModal.classList.add('show');
}

// Cerrar modal de eliminación
function closeDeleteModal() {
    deleteModal.classList.remove('show');
    reminderToDelete = null;
}

// Confirmar eliminación
async function confirmDelete() {
    if (!reminderToDelete) return;
    
    try {
        const success = await window.electronAPI.deleteReminder(reminderToDelete);
        if (success) {
            reminders = reminders.filter(r => r.id !== reminderToDelete);
            showNotification('Recordatorio eliminado correctamente', 'success');
            updateStats();
            renderReminders();
        } else {
            showNotification('Error al eliminar recordatorio', 'error');
        }
    } catch (error) {
        showNotification('Error al eliminar recordatorio', 'error');
    }
    
    closeDeleteModal();
}

// Alternar estado completado
async function toggleReminder(id) {
    try {
        const updated = await window.electronAPI.toggleReminder(id);
        if (updated) {
            const index = reminders.findIndex(r => r.id === id);
            if (index !== -1) {
                reminders[index] = updated;
            }
            updateStats();
            renderReminders();
        }
    } catch (error) {
        showNotification('Error al actualizar recordatorio', 'error');
    }
}

// ===========================================
// RENDERIZADO DE RECORDATORIOS
// ===========================================

// Renderizar lista de recordatorios
function renderReminders() {
    const filtered = getFilteredReminders();
    
    if (filtered.length === 0) {
        remindersList.style.display = 'none';
        emptyState.style.display = 'block';
        return;
    }
    
    remindersList.style.display = 'grid';
    emptyState.style.display = 'none';
    
    remindersList.innerHTML = filtered.map(reminder => createReminderCard(reminder)).join('');
    updateStats();
}

// Crear tarjeta de recordatorio
function createReminderCard(reminder) {
    const dueDate = reminder.dueDate ? new Date(reminder.dueDate) : null;
    const now = new Date();
    let dueDateClass = '';
    let dueDateText = '';
    
    if (dueDate) {
        const timeDiff = dueDate - now;
        const daysDiff = Math.ceil(timeDiff / (1000 * 60 * 60 * 24));
        
        if (timeDiff < 0) {
            dueDateClass = 'overdue';
            dueDateText = 'Vencido';
        } else if (daysDiff === 0) {
            dueDateClass = 'due-today';
            dueDateText = 'Hoy';
        } else if (daysDiff === 1) {
            dueDateClass = 'due-tomorrow';
            dueDateText = 'Mañana';
        } else if (daysDiff <= 7) {
            dueDateClass = 'due-soon';
            dueDateText = `En ${daysDiff} días`;
        } else {
            dueDateText = dueDate.toLocaleDateString('es-ES', {
                day: 'numeric',
                month: 'short',
                year: dueDate.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
            });
        }
    }
    
    const categoryIcons = {
        'personal': 'fas fa-user',
        'trabajo': 'fas fa-briefcase',
        'estudio': 'fas fa-graduation-cap',
        'salud': 'fas fa-heart',
        'otro': 'fas fa-tag'
    };
    
    const priorityColors = {
        'alta': 'priority-high',
        'media': 'priority-medium',
        'baja': 'priority-low'
    };
    
    return `
        <div class="reminder-item ${reminder.completed ? 'completed' : ''} ${priorityColors[reminder.priority]}" data-id="${reminder.id}">
            <div class="reminder-header">
                <div class="reminder-checkbox">
                    <input type="checkbox" id="check-${reminder.id}" ${reminder.completed ? 'checked' : ''} onchange="toggleReminder('${reminder.id}')">
                    <label for="check-${reminder.id}">
                        <i class="fas fa-check"></i>
                    </label>
                </div>
                <div class="reminder-actions">
                    <button class="btn-icon" onclick="editReminder('${reminder.id}')" title="Editar">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-icon" onclick="showDeleteModal('${reminder.id}')" title="Eliminar">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="reminder-body">
                <h3 class="reminder-title">${escapeHtml(reminder.title)}</h3>
                ${reminder.description ? `<p class="reminder-description">${escapeHtml(reminder.description)}</p>` : ''}
                <div class="reminder-meta">
                    <span class="reminder-category">
                        <i class="${categoryIcons[reminder.category]}"></i>
                        ${reminder.category}
                    </span>
                    <span class="reminder-priority">
                        <i class="fas fa-flag"></i>
                        ${reminder.priority}
                    </span>
                    ${dueDate ? `<span class="reminder-due ${dueDateClass}">
                        <i class="fas fa-calendar"></i>
                        ${dueDateText}
                    </span>` : ''}
                </div>
            </div>
        </div>
    `;
}

// Obtener recordatorios filtrados
function getFilteredReminders() {
    return reminders;
}

// Actualizar estadísticas
function updateStats() {
    const total = reminders.length;
    const completed = reminders.filter(r => r.completed).length;
    const pending = total - completed;
    
    document.getElementById('totalReminders').textContent = total;
    document.getElementById('pendingReminders').textContent = pending;
    document.getElementById('completedReminders').textContent = completed;
}

// Escapar HTML
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Mostrar notificación
function showNotification(message, type = 'info') {
    console.log(`[${type.toUpperCase()}] ${message}`);
}
```

## Paso 4: Crear formHandlers.js

Crea `renderer/js/formHandlers.js`:

```javascript
// Manejar envío del formulario
async function handleFormSubmit(e) {
    e.preventDefault();
    
    const title = document.getElementById('title').value.trim();
    const description = document.getElementById('description').value.trim();
    const category = document.getElementById('category').value;
    const priority = document.getElementById('priority').value;
    let dueDate = document.getElementById('dueDate').value;
    
    // Convertir fecha si existe
    if (dueDate) {
        try {
            const [datePart, timePart] = dueDate.split(' ');
            const [day, month, year] = datePart.split('/');
            const [hour, minute] = timePart.split(':');
            const dateObject = new Date(year, month - 1, day, hour, minute);
            dueDate = dateObject.toISOString();
        } catch (error) {
            dueDate = null;
        }
    }
    
    const reminderData = {
        title,
        description,
        category,
        priority,
        dueDate
    };
    
    if (!title) {
        showNotification('El título es obligatorio', 'error');
        return;
    }
    
    try {
        if (editingId) {
            // Actualizar
            reminderData.id = editingId;
            const updated = await window.electronAPI.updateReminder(reminderData);
            if (updated) {
                const index = reminders.findIndex(r => r.id === editingId);
                if (index !== -1) {
                    reminders[index] = updated;
                }
                showNotification('Recordatorio actualizado', 'success');
                resetForm();
            }
        } else {
            // Crear
            const newReminder = await window.electronAPI.saveReminder(reminderData);
            if (newReminder) {
                reminders.push(newReminder);
                showNotification('Recordatorio creado', 'success');
                resetForm();
            }
        }
        
        updateStats();
        renderReminders();
    } catch (error) {
        showNotification('Error al guardar', 'error');
    }
}

// Resetear formulario
function resetForm() {
    reminderForm.reset();
    editingId = null;
    submitBtn.innerHTML = '<i class="fas fa-plus"></i> Agregar';
    submitBtn.className = 'btn btn-primary';
    cancelBtn.classList.remove('show');
    document.querySelector('.sidebar-header h2').textContent = 'Nuevo Recordatorio';
}
```

## Paso 5: Actualizar init.js

Actualiza `renderer/js/init.js` para incluir los event listeners:

```javascript
// Configurar event listeners
function setupEventListeners() {
    // Formulario
    if (reminderForm) {
        reminderForm.addEventListener('submit', handleFormSubmit);
    }
    
    // Tema
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleTheme);
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
    
    // Cancelar edición
    if (cancelBtn) {
        cancelBtn.addEventListener('click', resetForm);
    }
}
```

## Paso 6: Actualizar index.html

Agrega los nuevos scripts antes del cierre de `</body>`:

```html
    <script src="../js/variables.js"></script>
    <script src="../js/storage.js"></script>
    <script src="../js/core.js"></script>
    <script src="../js/formHandlers.js"></script>
    <script src="../js/init.js"></script>
</body>
```

## Paso 7: Agregar estilos para recordatorios

Agrega al final de `styles.css`:

```css
/* Recordatorios */
.reminder-item {
    background: white;
    border-radius: 12px;
    padding: 20px;
    border: 2px solid var(--border-color);
    transition: all 0.3s;
}

.reminder-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.reminder-item.completed {
    opacity: 0.6;
}

.reminder-item.completed .reminder-title {
    text-decoration: line-through;
}

.reminder-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.reminder-checkbox {
    position: relative;
}

.reminder-checkbox input[type="checkbox"] {
    display: none;
}

.reminder-checkbox label {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    border: 2px solid var(--primary-color);
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.3s;
}

.reminder-checkbox input:checked + label {
    background: var(--primary-color);
    color: white;
}

.reminder-actions {
    display: flex;
    gap: 5px;
}

.reminder-body {
    padding-left: 34px;
}

.reminder-title {
    font-size: 1.1rem;
    color: var(--text-primary);
    margin-bottom: 8px;
}

.reminder-description {
    color: var(--text-secondary);
    margin-bottom: 12px;
    line-height: 1.5;
}

.reminder-meta {
    display: flex;
    gap: 15px;
    flex-wrap: wrap;
    font-size: 0.85rem;
}

.reminder-meta span {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    background: var(--bg-secondary);
    border-radius: 6px;
    color: var(--text-secondary);
}

.reminder-category i {
    color: var(--primary-color);
}

.priority-high {
    border-left: 4px solid var(--danger-color);
}

.priority-medium {
    border-left: 4px solid var(--warning-color);
}

.priority-low {
    border-left: 4px solid var(--success-color);
}

.reminder-due.overdue {
    background: var(--danger-color);
    color: white;
}

.reminder-due.due-today {
    background: var(--warning-color);
    color: white;
}
```

## Paso 8: Probar funcionalidad

```bash
npm start
```

Prueba:
- ✅ Crear recordatorio
- ✅ Editar recordatorio
- ✅ Completar/Descompletar
- ✅ Eliminar recordatorio
- ✅ Persistencia de datos

## Resultado esperado
- ✅ CRUD completo funcionando
- ✅ Recordatorios se guardan en JSON
- ✅ Modal de confirmación funciona
- ✅ Estadísticas se actualizan
- ✅ UI responde correctamente

## Siguiente paso
En la Parte 5, implementaremos búsqueda y filtros.
