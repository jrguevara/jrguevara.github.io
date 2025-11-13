---
title: Electron - Recordatorios App | Parte 6 - Calendario
date: 2025-11-13 00:00:00 -500
categories: [Electron]
tags: [javascript, electron, desktop-app, tutorial]
published: true
hidden: false
---

# Parte 6: Selector de Fechas (Calendario)

## Objetivo
Implementar un calendario personalizado para seleccionar fecha y hora de vencimiento de recordatorios.

## Paso 1: Agregar HTML del calendario en el formulario

Actualiza la sección de fecha en el formulario dentro de `index.html`:

```html
<div class="form-group">
    <label for="dueDate">
        <i class="fas fa-calendar"></i> Fecha límite
    </label>
    <div class="date-field-container">
        <input type="text" id="dueDate" placeholder="dd/mm/yyyy hh:mm" readonly autocomplete="off">
        
        <!-- Popup del calendario -->
        <div class="calendar-popup" id="calendarPopup">
            <div class="calendar-header">
                <button type="button" class="calendar-nav" id="prevMonth">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <span class="calendar-title" id="calendarTitle"></span>
                <button type="button" class="calendar-nav" id="nextMonth">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
            
            <div class="calendar-weekdays">
                <div class="calendar-weekday">Dom</div>
                <div class="calendar-weekday">Lun</div>
                <div class="calendar-weekday">Mar</div>
                <div class="calendar-weekday">Mié</div>
                <div class="calendar-weekday">Jue</div>
                <div class="calendar-weekday">Vie</div>
                <div class="calendar-weekday">Sáb</div>
            </div>
            
            <div class="calendar-days" id="calendarDays"></div>
            
            <div class="calendar-time">
                <div class="time-inputs">
                    <input type="number" id="hourInput" min="1" max="12" placeholder="09" maxlength="2">
                    <span>:</span>
                    <input type="number" id="minuteInput" min="0" max="59" placeholder="00" maxlength="2">
                    <select id="ampmSelect">
                        <option value="AM">AM</option>
                        <option value="PM">PM</option>
                    </select>
                </div>
                <div class="calendar-actions">
                    <button type="button" class="calendar-btn clear-btn" id="clearDate">Limpiar</button>
                    <button type="button" class="calendar-btn confirm-btn" id="confirmDate">Confirmar</button>
                </div>
            </div>
        </div>
    </div>
</div>
```

## Paso 2: Crear calendar.js

Crea `renderer/js/calendar.js`:

```javascript
// Variables del calendario
let currentCalendarDate = new Date();
let selectedDate = null;

// Inicializar calendario
function initializeCustomCalendar() {
    const dueDateInput = document.getElementById('dueDate');
    const calendarPopup = document.getElementById('calendarPopup');
    const prevMonthBtn = document.getElementById('prevMonth');
    const nextMonthBtn = document.getElementById('nextMonth');
    const clearDateBtn = document.getElementById('clearDate');
    const confirmDateBtn = document.getElementById('confirmDate');
    const hourInput = document.getElementById('hourInput');
    const minuteInput = document.getElementById('minuteInput');
    const ampmSelect = document.getElementById('ampmSelect');
    
    if (!dueDateInput || !calendarPopup) {
        return;
    }
    
    // Mostrar calendario al hacer clic
    dueDateInput.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        calendarPopup.classList.toggle('show');
        if (calendarPopup.classList.contains('show')) {
            renderCalendar();
        }
    });
    
    // Prevenir escritura manual
    dueDateInput.addEventListener('keydown', (e) => {
        e.preventDefault();
        return false;
    });
    
    // Cerrar al hacer clic fuera
    document.addEventListener('click', (e) => {
        if (!dueDateInput.contains(e.target) && !calendarPopup.contains(e.target)) {
            calendarPopup.classList.remove('show');
        }
    });
    
    // Navegación de meses
    if (prevMonthBtn) {
        prevMonthBtn.addEventListener('click', () => {
            currentCalendarDate.setMonth(currentCalendarDate.getMonth() - 1);
            renderCalendar();
        });
    }
    
    if (nextMonthBtn) {
        nextMonthBtn.addEventListener('click', () => {
            currentCalendarDate.setMonth(currentCalendarDate.getMonth() + 1);
            renderCalendar();
        });
    }
    
    // Limpiar fecha
    if (clearDateBtn) {
        clearDateBtn.addEventListener('click', () => {
            dueDateInput.value = '';
            selectedDate = null;
            calendarPopup.classList.remove('show');
            showNotification('Fecha eliminada', 'info');
        });
    }
    
    // Confirmar fecha
    if (confirmDateBtn) {
        confirmDateBtn.addEventListener('click', () => {
            if (selectedDate) {
                let hour = parseInt(hourInput.value) || 9;
                const minute = parseInt(minuteInput.value) || 0;
                const ampm = ampmSelect.value;
                
                // Convertir de 12 horas a 24 horas
                if (ampm === 'PM' && hour !== 12) {
                    hour += 12;
                } else if (ampm === 'AM' && hour === 12) {
                    hour = 0;
                }
                
                selectedDate.setHours(hour, minute, 0, 0);
                
                // Formatear fecha
                const day = String(selectedDate.getDate()).padStart(2, '0');
                const month = String(selectedDate.getMonth() + 1).padStart(2, '0');
                const year = selectedDate.getFullYear();
                const formattedHour = String(selectedDate.getHours()).padStart(2, '0');
                const formattedMinute = String(selectedDate.getMinutes()).padStart(2, '0');
                
                dueDateInput.value = `${day}/${month}/${year} ${formattedHour}:${formattedMinute}`;
                calendarPopup.classList.remove('show');
                showNotification('Fecha establecida', 'success');
            }
        });
    }
    
    // Validación de inputs de tiempo
    if (hourInput) {
        hourInput.addEventListener('input', (e) => {
            let value = parseInt(e.target.value);
            if (value > 12) e.target.value = 12;
            if (value < 1) e.target.value = 1;
        });
    }
    
    if (minuteInput) {
        minuteInput.addEventListener('input', (e) => {
            let value = parseInt(e.target.value);
            if (value > 59) e.target.value = 59;
            if (value < 0) e.target.value = 0;
        });
    }
}

// Renderizar calendario
function renderCalendar() {
    const calendarTitle = document.getElementById('calendarTitle');
    const calendarDays = document.getElementById('calendarDays');
    const hourInput = document.getElementById('hourInput');
    const minuteInput = document.getElementById('minuteInput');
    const ampmSelect = document.getElementById('ampmSelect');
    
    if (!calendarTitle || !calendarDays) {
        return;
    }
    
    // Nombres de meses
    const monthNames = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    calendarTitle.textContent = `${monthNames[currentCalendarDate.getMonth()]} ${currentCalendarDate.getFullYear()}`;
    
    // Limpiar días
    calendarDays.innerHTML = '';
    
    // Primer y último día del mes
    const firstDay = new Date(currentCalendarDate.getFullYear(), currentCalendarDate.getMonth(), 1);
    const lastDay = new Date(currentCalendarDate.getFullYear(), currentCalendarDate.getMonth() + 1, 0);
    
    // Día inicial (domingo de la semana del primer día)
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());
    
    // Generar 42 días (6 semanas)
    for (let i = 0; i < 42; i++) {
        const date = new Date(startDate);
        date.setDate(startDate.getDate() + i);
        
        const dayElement = document.createElement('div');
        dayElement.className = 'calendar-day';
        dayElement.textContent = date.getDate();
        
        // Estilos según estado
        if (date.getMonth() !== currentCalendarDate.getMonth()) {
            dayElement.classList.add('other-month');
        }
        
        if (isToday(date)) {
            dayElement.classList.add('today');
        }
        
        if (selectedDate && isSameDay(date, selectedDate)) {
            dayElement.classList.add('selected');
        }
        
        // Evento clic
        dayElement.addEventListener('click', () => {
            document.querySelectorAll('.calendar-day.selected').forEach(el => {
                el.classList.remove('selected');
            });
            
            dayElement.classList.add('selected');
            selectedDate = new Date(date);
            
            // Si es de otro mes, navegar
            if (date.getMonth() !== currentCalendarDate.getMonth()) {
                currentCalendarDate = new Date(date);
                renderCalendar();
            }
        });
        
        calendarDays.appendChild(dayElement);
    }
    
    // Valores por defecto de tiempo
    if (!hourInput.value) hourInput.value = '9';
    if (!minuteInput.value) minuteInput.value = '00';
    if (!ampmSelect.value) ampmSelect.value = 'AM';
}

// Funciones auxiliares
function isToday(date) {
    const today = new Date();
    return isSameDay(date, today);
}

function isSameDay(date1, date2) {
    return date1.getDate() === date2.getDate() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getFullYear() === date2.getFullYear();
}
```

## Paso 3: Agregar estilos del calendario

Agrega en `styles.css`:

```css
/* Calendario */
.date-field-container {
    position: relative;
}

.calendar-popup {
    position: absolute;
    top: 100%;
    left: 0;
    width: 320px;
    background: white;
    border: 2px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
    padding: 15px;
    z-index: 1000;
    display: none;
    margin-top: 5px;
}

.calendar-popup.show {
    display: block;
}

.calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.calendar-title {
    font-weight: 600;
    color: var(--text-primary);
    font-size: 1rem;
}

.calendar-nav {
    width: 30px;
    height: 30px;
    border: none;
    background: var(--bg-secondary);
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.3s;
}

.calendar-nav:hover {
    background: var(--primary-color);
    color: white;
}

.calendar-weekdays {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 5px;
    margin-bottom: 10px;
}

.calendar-weekday {
    text-align: center;
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--text-secondary);
    padding: 5px;
}

.calendar-days {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 5px;
    margin-bottom: 15px;
}

.calendar-day {
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    cursor: pointer;
    font-size: 0.9rem;
    transition: all 0.3s;
}

.calendar-day:hover {
    background: var(--bg-secondary);
}

.calendar-day.other-month {
    color: var(--text-secondary);
    opacity: 0.4;
}

.calendar-day.today {
    background: var(--primary-color);
    color: white;
    font-weight: 600;
}

.calendar-day.selected {
    background: var(--secondary-color);
    color: white;
    font-weight: 600;
}

.calendar-time {
    border-top: 1px solid var(--border-color);
    padding-top: 15px;
}

.time-inputs {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    margin-bottom: 15px;
}

.time-inputs input {
    width: 50px;
    padding: 8px;
    text-align: center;
    border: 2px solid var(--border-color);
    border-radius: 6px;
    font-size: 1rem;
}

.time-inputs select {
    padding: 8px;
    border: 2px solid var(--border-color);
    border-radius: 6px;
    font-size: 0.9rem;
}

.time-inputs span {
    font-weight: 600;
    font-size: 1.2rem;
}

.calendar-actions {
    display: flex;
    gap: 10px;
}

.calendar-btn {
    flex: 1;
    padding: 8px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: 600;
    transition: all 0.3s;
}

.clear-btn {
    background: var(--bg-secondary);
    color: var(--text-primary);
}

.clear-btn:hover {
    background: var(--danger-color);
    color: white;
}

.confirm-btn {
    background: var(--primary-color);
    color: white;
}

.confirm-btn:hover {
    background: var(--secondary-color);
}
```

## Paso 4: Actualizar eventListeners.js

Agrega la inicialización del calendario en `setupEventListeners()`:

```javascript
// Configurar event listeners
function setupEventListeners() {
    // ... código existente ...
    
    // Inicializar calendario
    setTimeout(() => {
        initializeCustomCalendar();
    }, 100);
}
```

## Paso 5: Actualizar index.html con el script

Verifica que `calendar.js` esté incluido:

```html
    <script src="../js/variables.js"></script>
    <script src="../js/storage.js"></script>
    <script src="../js/calendar.js"></script>
    <script src="../js/core.js"></script>
    <script src="../js/formHandlers.js"></script>
    <script src="../js/eventListeners.js"></script>
    <script src="../js/init.js"></script>
</body>
```

## Paso 6: Probar el calendario

```bash
npm start
```

Prueba:
- ✅ Click en campo de fecha abre calendario
- ✅ Navegación entre meses
- ✅ Selección de día
- ✅ Día actual resaltado
- ✅ Selección de hora (formato 12h)
- ✅ Botón limpiar fecha
- ✅ Botón confirmar guarda fecha
- ✅ Formato dd/mm/yyyy hh:mm
- ✅ Cerrar al hacer clic fuera

## Resultado esperado
- ✅ Calendario se muestra al hacer clic
- ✅ Navegación de meses funciona
- ✅ Selección de fecha funcional
- ✅ Selector de hora funcional
- ✅ Formato correcto de fecha
- ✅ Persistencia en recordatorios

## Siguiente paso
En la Parte 7, implementaremos estadísticas avanzadas y gráficos de progreso.
