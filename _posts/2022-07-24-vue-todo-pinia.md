---
title: Aplicacion TODO con VUE + PINIA 
date: 2022-07-24 01:00:00 -500
categories: [vue]
tags: [vue, frontend, programacion]
published: true
hidden: false
---

## PINIA
Pinia comenzó como un experimento para rediseñar cómo se vería una tienda para Vue con la API de composición alrededor de noviembre de 2019. Desde entonces, los principios iniciales siguen siendo los mismos, pero Pinia funciona tanto para Vue 2 como para Vue 3 y no requiere que usted para usar la API de composición. La API es la misma para ambos excepto para la instalación y SSR, y estos documentos están dirigidos a Vue 3 con notas sobre Vue 2 siempre que sea necesario para que los usuarios de Vue 2 y Vue 3 puedan leerlos. [Sitio oficial](https://pinia.vuejs.org/)

 ![VUEX](/assets/images/vue-pinia.png)
_PINIA (VUEX 5)_

## ¿Por qué debería usar Pinia?

Pinia es una biblioteca de tiendas para Vue, le permite compartir un estado entre componentes/páginas. Si está familiarizado con la API de composición, es posible que esté pensando que ya puede compartir un estado global con una exportación simple const state = reactive({}). Esto es cierto para las aplicaciones de una sola página, pero expone su aplicación a vulnerabilidades de seguridad si se representa en el lado del servidor. Pero incluso en aplicaciones pequeñas de una sola página, obtienes mucho del uso de Pinia:

- Soporte de herramientas de desarrollo
  - Una línea de tiempo para rastrear acciones, mutaciones.
  - Las tiendas aparecen en los componentes donde se utilizan
  - Viaje en el tiempo y depuración más fácil
- Reemplazo de módulo caliente
  - Modifica tus tiendas sin recargar tu página
  - Mantener cualquier estado existente mientras se desarrolla
- Complementos: amplíe las funciones de Pinia con complementos
- Compatibilidad adecuada con TypeScript o autocompletado para usuarios de JS
-Soporte de representación del lado del servidor

## Creacion de Proyecto
* Crear Proyecto con Vite

 ``` powershell
npm init vue@latest
 ```

 ![VUE CLI](/assets/images/vue-pinia-1.png)
_CLI de Vue_

* Limpiar App.vue y borrar componente HelloWorld.vue

 ``` vue
<template>
Hello World!
</template>

<script>

export default {
  name: 'App',
}
</script>
 ```

* Agregar CDN de BootStrap y de Font Awesome a index.html
1. [Font Awesome](https://cdnjs.com/libraries/font-awesome)
2. [BootStrap](https://getbootstrap.com/)

``` html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <link rel="icon" href="/favicon.ico" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous"
    referrerpolicy="no-referrer" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-0evHe/X+R7YkIZDRvuzKMRqM+OrBnVFBL6DOitfPri4tjfHxaWutUpFmBp4vmVor" crossorigin="anonymous">
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Vite App</title>
</head>

<body>
  <div id="app"></div>
  <script type="module" src="/src/main.js"></script>
</body>

</html>
```
## Modificar App.vue

``` vue
<template>
  <div class="container">
    <todo-app />
  </div>

</template>

<script>
import TodoApp from './components/TodoApp.vue'

export default {
  components: { TodoApp },
  name: 'App',
}
</script>

<style>
body {
  background-image: url(./assets/bg-desktop-dark.jpg);
  background-repeat: no-repeat;
  background-size: 100% 200px;
  background-color:#222222
}

.container {
  margin-top: 70px;
  max-width: 700px;
}
</style>
```

## Modificar main.js

``` javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

//import './assets/main.css'

const app = createApp(App)

app.use(createPinia())

app.mount('#app')
```

## Crear Store

* Buscar dentro de src una carpeta llamada ***stores*** y dentro crear un archivo ***TodoStore.js***

``` javascript
import { defineStore } from 'pinia'

export const useTodoStore = defineStore({
    id: 'todoStore',
    state: () => ({
        titulo: 'ToDo con PINIA',
        todoList: [],
        estado: 'all'
    }),
    getters: {
        todosGetter(state) {
            if (state.estado === 'all') {
                return state.todoList
            }
            if (state.estado === 'pendientes') {
                return state.todoList.filter(item => item.estado === false)
            }
            if (state.estado === 'completados') {
                return state.todoList.filter(item => item.estado === true)
            }
        },
        estados(state) {
            return state.estado
        },
        contarPendientes(state) {
            return state.todoList.filter(item => item.estado === false).length
        }
    },
    actions: {
        agregarTodoAction(todo) {
            this.todoList.push(todo)
        },
        borrarAction(id) {
            this.todoList = this.todosGetter.filter(item => item.id !== id)
        },
        completadoAction(id) {
            this.todoList = this.todosGetter.map(item => {
                if (item.id === id) {
                    item.estado = !item.estado
                }
                return item
            })
        },
        eliminarCompletadosAction() {
            this.todoList = this.todosGetter.filter(item => item.estado === false)
        },
        filtroAction(valor) {
            this.estado = valor
        }
    }
})
```

## Componente TodoApp.vue 

``` vue
<template>
    <h1>{ { todoStore.titulo } }</h1>
    <todo-formulario />
    <todo-listado />
</template>

<script>
import { useTodoStore } from '../stores/TodoStore'
import TodoFormulario from './TodoFormulario.vue'
import TodoListado from './TodoListado.vue'
export default {
    components: { TodoFormulario, TodoListado },
    setup() {
        const todoStore = useTodoStore()

        todoStore.$subscribe((mutation, state) => {
            localStorage.setItem('pinia', JSON.stringify(state.todoList));
        });

        if (localStorage.getItem('pinia')) {
            todoStore.todoList = JSON.parse(localStorage.getItem('pinia'));
        }

        return { todoStore }
    }
}
</script>

<style>
h1 {
    color: #ffffff;
}
</style>
```

## Componente TodoFormulario.vue 

``` vue
<template>
    <form @submit.prevent="agregarToDo">
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo"
          v-model.trim="texto">
    </form>
</template>

<script>
import { ref } from '@vue/runtime-core'
import { useTodoStore } from '../stores/TodoStore'
export default {
    setup(){
        const todoStore = useTodoStore()
        const texto = ref('')
        
        const agregarToDo = () => {
            if(texto.value === ''){
                console.log('vacio')
                return
            }
            const todo = {
                descripcion: texto.value,
                estado: false,
                id: Date.now()
            }

            todoStore.agregarTodoAction(todo)

            texto.value = ''
        }
        return { agregarToDo, texto }
    }
}
</script>

<style>
input[type="text"] {
    font-family: sans-serif;
    font-size: 18px;
    font-weight: 400;
    line-height: 12px;
    color: #d8d8d8;
    border: none;
    flex-grow: 1;
    background-color: #25273d;
    box-sizing: border-box;
    height: 48px;
}

input[type="text"]:focus {
    outline: none;
    color: #d8d8d8;
    background-color: #25273d;
}
</style>
```

## Componente TodoListado.vue 

``` vue
<template>
    <ul class="list-group">
        <todo-item
            v-for="todo in todos"
            :key="todo.id"
            :todo="todo" />
        <li
            v-if="todos.length == 0"
            class="list-group-item">
            No hay ToDos
        </li>
        <todo-footer 
            v-if="todos.length !== 0"
        />
    </ul>

    <todo-filtro />
</template>

<script>
import { computed } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
import TodoFiltro from './TodoFiltro.vue'
import { useTodoStore } from '../stores/TodoStore'

export default {
    components: { TodoItem, TodoFooter, TodoFiltro },
    setup() {
        const todoStore = useTodoStore()

        const todos = computed(() => todoStore.todosGetter)

        return { todos }
    }
}
</script>

<style>
</style>
```

## Componente TodoItem.vue 

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span
          role="button"
          @click="completado(todo.id)"
          :class="{'tachado': todo.estado}">
             { { todo.descripcion } }
        </span>
        <span
          role="button"
          @click="borrar(todo.id)">
            <i class="fas fa-times"></i>
        </span>
    </li>
</template>

<script>
import { useTodoStore } from '../stores/TodoStore'
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    },
    setup(){

        const todoStore = useTodoStore()

        const borrar = id => {
            todoStore.borrarAction(id)
        }

        const completado = id => {
            todoStore.completadoAction(id)
        }

        return { borrar, completado }
    }
}
</script>

<style>
.tachado {
    text-decoration: line-through;
}

.list-group-item {
    min-width: 300px;
    width: 100%;
    background-color: #25273d;
    border-radius: 5px;
    color: #d8d8d8;
}

.fa-times {
    color: red;
}
</style>
```

## Componente TodoFooter.vue

* Crear componente TodoFooter.vue

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span>
            { { contarPendientes } } Pendientes
        </span>
        <span role="button" @click="eliminarCompletados">
            Eliminar completados
        </span>
    </li>    
</template>

<script>
import { computed } from '@vue/runtime-core'
import { useTodoStore } from '../stores/TodoStore'
export default {
    setup(){
        const todoStore = useTodoStore()

        const contarPendientes = computed(() => todoStore.contarPendientes)

        const eliminarCompletados = () => {
            todoStore.eliminarCompletadosAction()
        }

        return { contarPendientes, eliminarCompletados }
    }
}
</script>

<style>
</style>
```

## Componente TodoFiltro.vue

``` vue
<template>
    <div class="btn-group mt-3 d-flex" role="group" aria-label="Filtro">
        <button
          type="button"
          class="btn"
          @click="filtro('pendientes')"
          :class="estado === 'pendientes' ? 'btn-success' : 'btn-dark'"
          >Pendientes</button>
        <button
          type="button"
          class="btn"
          @click="filtro('all')"
          :class="estado === 'all' ? 'btn-success' : 'btn-dark'"
          >Todos</button>
        <button
          type="button"
          class="btn"
          @click="filtro('completados')"
          :class="estado === 'completados' ? 'btn-success' : 'btn-dark'"
          >Completados</button>
    </div>
</template>

<script>
import { computed, inject } from '@vue/runtime-core';
import { useTodoStore } from '../stores/TodoStore'
export default {
    setup(){
        const todoStore = useTodoStore()
        const estado = computed(() => todoStore.estados)

        const filtro = (valor) => {
            todoStore.filtroAction(valor)
        }
        return { filtro, estado}
    }
}
</script>

<style>
</style>
```

* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-6.png)
_Aplicacion de Vue en el navegador_

* Finalmente ejecutamos el comando ***npm run build***. La aplicacion quedara lista para ser distribuida en la carpeta dist del proyecto

``` powershell
npm run dev
```