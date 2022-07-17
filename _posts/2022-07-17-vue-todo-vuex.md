---
title: Aplicacion TODO con VUE + VUEX 
date: 2022-07-17 08:00:00 -500
categories: [vue]
tags: [vue, frontend, programacion]
published: true
hidden: false
---

## VUEX 4.0
Vuex es un patrón de gestión de estado + biblioteca para aplicaciones Vue.js. Sirve como un almacén centralizado para todos los componentes de una aplicación, con reglas que garantizan que el estado solo se puede modificar de forma predecible. [Sitio oficial](https://vuex.vuejs.org/)

Al definir y separar los conceptos involucrados en la administración del estado y hacer cumplir las reglas que mantienen la independencia entre las vistas y los estados, le damos a nuestro código más estructura y mantenibilidad.

Esta es la idea básica detrás de Vuex, inspirada en Flux, Redux y The Elm Architecture. A diferencia de los otros patrones, Vuex también es una implementación de biblioteca diseñada específicamente para Vue.js para aprovechar su sistema de reactividad granular para actualizaciones eficientes.

 ![VUEX](https://vuex.vuejs.org/vuex.png)
_Arquitectura de VUEX_

## ¿Cuándo debo usarlo?

Vuex nos ayuda a lidiar con la administración de estado compartido con el costo de más conceptos y repeticiones. Es una compensación entre la productividad a corto y largo plazo.

Si nunca ha construido un SPA a gran escala y salta directamente a Vuex, puede parecer detallado y desalentador. Eso es perfectamente normal: si su aplicación es simple, lo más probable es que esté bien sin Vuex. Un patrón de tienda simple puede ser todo lo que necesita. Pero si está construyendo un SPA de mediana a gran escala, es probable que se haya encontrado con situaciones que le hagan pensar en cómo manejar mejor el estado fuera de sus componentes de Vue, y Vuex será el próximo paso natural para usted.

## Conceptos principales

### State

Vuex utiliza un único árbol de estado, es decir, este único objeto contiene todo el estado de su aplicación y sirve como la "única fuente de verdad". Esto también significa que, por lo general, solo tendrá una tienda para cada aplicación. Un solo árbol de estado facilita la ubicación de una parte específica del estado y nos permite tomar instantáneas del estado actual de la aplicación para fines de depuración.

El árbol de estado único no entra en conflicto con la modularidad; en capítulos posteriores, discutiremos cómo dividir su estado y mutaciones en submódulos.

Los datos que almacena en Vuex siguen las mismas reglas que los datos en una instancia de Vue, es decir, el objeto de estado debe ser sencillo.

### Getter

Un getter es usado para obtener valores del estado de manera directa. Además este se vuelve a enviar cuando el estado cambia de valor. Es como un computed pero para Vuex.

### Mutations

La única forma de cambiar de estado en una tienda Vuex es cometiendo una mutación. Las mutaciones de Vuex son muy similares a los eventos: cada mutación tiene un tipo de cadena y un controlador. La función de controlador es donde realizamos modificaciones de estado reales, y recibirá el estado como primer argumento

### Actions
Los actions son métodos que realizan mutaciones, generalmente son usados para ejecutar operaciones asíncronas, de tal manera que cuando los datos llegan desde el API, el action se encarga de llamar a una mutación para que este cambie o actualice el state.

## Creacion de Proyecto
* Crear Proyecto con Vue CLI o UI

 ![VUE CLI](/assets/images/vuex-01.png)
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

* Agregar CDN de BootStrap y de Font Awesome a public/index.vue
1. [Font Awesome](https://cdnjs.com/libraries/font-awesome)
2. [BootStrap](https://getbootstrap.com/)

``` html
<!DOCTYPE html>
<html lang="">

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <link rel="icon" href="<%= BASE_URL %>favicon.ico">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous"
    referrerpolicy="no-referrer" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-0evHe/X+R7YkIZDRvuzKMRqM+OrBnVFBL6DOitfPri4tjfHxaWutUpFmBp4vmVor" crossorigin="anonymous">

  <title>
    <%= htmlWebpackPlugin.options.title %>
  </title>
</head>

<body>
  <noscript>
    <strong>We're sorry but <%= htmlWebpackPlugin.options.title %> doesn't work properly without JavaScript enabled. Please enable it to continue.</strong>
  </noscript>
  <div id="app"></div>
  <!-- built files will be auto injected -->
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
  beforeCreate() {
    this.$store.commit('iniciarStore');
  },
  components: { TodoApp },
  name: 'App',
}
</script>

<style>
body {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  background-image: url(./assets/bg-desktop-dark.jpg);
  background-repeat: no-repeat;
  background-size: 100% 200px;
  background-color: #222222
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
import App from './App.vue'
import store from './store'

createApp(App).use(store).mount('#app')
store.subscribe((mutation, state) => {
	// Store the state object as a JSON string
	localStorage.setItem('storeD', JSON.stringify(state.todos));
})
```

## Crear Store

* Crear dentro de src una carpeta ***store*** y dentro de el un archivo ***index.js***

``` javascript
import { createStore } from 'vuex'

export default createStore({
  state: {
    //toda aquella data que sea de uso global
    todos: [],
    estado: 'all'
  },
  getters: {
    // computed para la store
    contarPendientes(state) {
      return state.todos.filter(item => item.estado === false).length
    },
    todos(state) {
      if (state.estado === 'all') {
        return state.todos
      }
      if (state.estado === 'pendientes') {
        return state.todos.filter(item => item.estado === false)
      }
      if (state.estado === 'completados') {
        return state.todos.filter(item => item.estado === true)
      }
    },
    estados(state) {
      return state.estado
    },
  },
  mutations: {
    //modifican el state
    iniciarStore(state) {
      // Check if the ID exists
      if (localStorage.getItem('storeD')) {
        // Replace the state object with the stored item
        state.todos = JSON.parse(localStorage.getItem('storeD'))
      }
    },
    agregarTodoMutation(state, todo) {
      state.todos.push(todo)
    },
    borrarMutation(state, id) {
      state.todos = state.todos.filter(item => item.id !== id)
    },
    completadoMutation(state, id) {
      state.todos = state.todos.map(item => {
        if (item.id === id) {
          item.estado = !item.estado
        }
        return item
      })
    },
    eliminarCompletadosMutation(state) {
      state.todos = state.todos.filter(item => item.estado === false)
    },
    filtroMutation(state, valor) {
      state.estado = valor
    }
  },
  actions: {
    //En lugar de mutar el state, actions ejecutan mutations.
    //Actions pueden contener operaciones asincronas arbitrarioas.
    /*
    agregarTodo({commit}, todo) {
      commit('agregarTodo', todo)
    }
    */
    agregarTodoAction(context, todo) {
      context.commit('agregarTodoMutation', todo)
    },
    borrarAction(context, id) {
      context.commit('borrarMutation', id)
    },
    completadoAction(context, id) {
      context.commit('completadoMutation', id)
    },
    eliminarCompletadosAction(context) {
      context.commit('eliminarCompletadosMutation')
    },
    filtroAction(context, valor) {
      context.commit('filtroMutation', valor)
    }
  },
  modules: {
  }
})
```

## Componente TodoApp.vue 

``` vue
<template>
    <h1>ToDos</h1>
    <todo-formulario />
    <todo-listado />
</template>

<script>
import { computed, watchEffect } from 'vue'
import { useStore } from 'vuex'
import TodoFormulario from './TodoFormulario.vue'
import TodoListado from './TodoListado.vue'
export default {
    components: { TodoFormulario, TodoListado },
    setup() {
        //const estado = computed(() => store.getters.estados)

        const store = useStore()
        
        /*if (localStorage.getItem('todosStore')) {
            store.state.todos = JSON.parse(localStorage.getItem('todosStore'))
        }

        watchEffect(() => {
            localStorage.setItem('todosStore', JSON.stringify(store.state.todos))
        })*/

        //return { estado }
    }
}
</script>

<style>
h1 {
    font-family: Avenir, Helvetica, Arial, sans-serif;
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
import { useStore } from 'vuex'
export default {
    setup() {
        const store = useStore()
        const texto = ref('')

        const agregarToDo = () => {
            if (texto.value === '') {
                console.log('vacio')
                return
            }
            const todo = {
                descripcion: texto.value,
                estado: false,
                id: Date.now()
            }
            //utilizando mutation
            //store.commit("agregarTodoMutation", todo)

            //utilizando action
            store.dispatch("agregarTodoAction", todo)

            texto.value = ''
        }

        return { agregarToDo, texto }
    }
}
</script>

<style>
input[type="text"] {
    font-family: Avenir, Helvetica, Arial, sans-serif;
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
    <todo-item v-for="todo in todos" :key="todo.id" :todo="todo" />
    <li v-if="todos.length == 0" class="list-group-item">
      No hay ToDos
    </li>
    <todo-footer v-if="todos.length" />
  </ul>

  <todo-filtro />
</template>

<script>
import { computed, inject, provide, ref } from '@vue/runtime-core'
import { useStore } from 'vuex'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
import TodoFiltro from './TodoFiltro.vue'
export default {
  components: { TodoItem, TodoFooter, TodoFiltro },
  setup() {
    const store = useStore()

    const todos = computed(() => store.getters.todos)
    
    return { todos }
  }
}
</script>

<style>
.list-group-item {
  font-family: Avenir, Helvetica, Arial, sans-serif;
}
</style>
```

## Componente TodoItem.vue 

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span
          role="button"
          @click="completado(todo.id)"
          :class="{ 'tachado': todo.estado }">
            {{ todo.descripcion }}
        </span>
        <span
          role="button"
          @click="borrar(todo.id)">
            <i class="fas fa-times"></i>
        </span>
    </li>
</template>

<script>
import { useStore } from 'vuex'
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    },
    setup() {
        const store = useStore()

        const borrar = id => {
            store.dispatch("borrarAction", id)
        }

        const completado = id => {
            store.dispatch("completadoAction", id)
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
        <span role="button">
            {{ contarPendientes }} Pendientes
        </span>
        <span
          role="button"
          @click="eliminarCompletados">
            Eliminar completados
        </span>
    </li>
</template>

<script>
import { computed } from '@vue/runtime-core'
import { useStore } from 'vuex'
export default {
    setup() {
        const store = useStore()

        const contarPendientes = computed(() => store.getters.contarPendientes)

        const eliminarCompletados = () => {
            store.dispatch("eliminarCompletadosAction")
        }

        return { contarPendientes, eliminarCompletados }
    }
}
</script>

<style>
</style>
```

## Componente TodoFiltro.vue

* Se crea un nuevo componente llamado TodoFiltro.vue

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
import store from '@/store';
import { computed } from '@vue/runtime-core';
export default {
  setup() {
    //const estado = computed(() => store.state.estado)
    const estado = computed(() => store.getters.estados)
    
    const filtro = (valor) => {
      store.dispatch("filtroAction", valor)
    }
    
    return { filtro, estado };
  },
};
</script>

<style>
</style>
```

* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-6.png)
_Aplicacion de Vue en el navegador_

* Finalmente ejecutamos el comando ***npm run build***. La aplicacion quedara lista para ser distribuida en la carpeta dist del proyecto

``` powershell
npm run build
```