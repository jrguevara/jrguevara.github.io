---
title: Aplicacion TODO con VUE 
date: 2022-07-08 20:00:00 -500
categories: [vue]
tags: [vue, frontend, programacion]
published: true
hidden: false
---

## Plugins y extensiones recomendadas
* Instalar plugins y extensiones de Visual Studio Code
1. [Vue.js devtools](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/)
2. [Split HTML Attributes (Vue, React, Angular)](https://marketplace.visualstudio.com/items?itemName=dannyconnell.split-html-attributes)
3. [Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)
4. [Vue Language Features (Volar)](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
5. [Vue VSCode Snippets](https://marketplace.visualstudio.com/items?itemName=sdras.vue-vscode-snippets)
6. [vscode-pets](https://marketplace.visualstudio.com/items?itemName=tonybaloney.vscode-pets) 🐾

## Creacion de Proyecto
* Crear Proyecto con Vue CLI o UI
 ![VUE CLI](/assets/images/vue-todo-7.png)
_CLI de Vue_

 ![VUE CLI](/assets/images/vue-todo-8.png)
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

## Componente TodoApp.vue 

* Crear componentes TodoApp.vue (componente principal)

``` vue
<template>
  <h1>ToDos</h1>
</template>

<script>
export default {

}
</script>

```

* Llamar componente TodoApp.vue a App.vue. Agregar div con class container

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
```

* Revisar App en navegador

 ![VUE APP](/assets/images/vue-todo-1.png)
_Aplicacion de Vue en el navegador_

## Componente TodoFormulario.vue 

* Crear Componente TodoFormulario.vue

``` vue
<template>
    <form>
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo">
    </form>
</template>

<script>
export default {

}
</script>
```

* Importar componente TodFormulario.vue a Todoapp-vue

``` vue
<template>
  <h1>ToDos</h1>
  <todo-formulario />
</template>

<script>
import TodoFormulario from './TodoFormulario.vue'
export default {
  components: { TodoFormulario },

}
</script>
```

* Revisar App en el navegador

 ![VUE APP](/assets/images/vue-todo-2.png)
_Aplicacion de Vue en el navegador_

* Utilizando composition API crearemos un arreglo en el componente padre TodoApp que podra ser accedido por sus componentes hijos. Creando una constante ***ref*** y enviandola a traves de un ***provide***.

[Vue Ref](https://vuejs.org/guide/essentials/template-refs.vue)

[Vue Provide-Inject](https://vuejs.org/guide/components/provide-inject.vue)


``` vue
<template>
    <h1>ToDos</h1>
    <todo-formulario />
</template>

<script>
import { provide, ref } from 'vue'
import TodoFormulario from './TodoFormulario.vue'
export default {
    components: { TodoFormulario },
    setup(){
        const todos = ref([])
        provide('todos', todos)
    }
}
</script>
```

* Se configura TodoFormulario.vue para recibir data del padre a traves de ***inject***

``` vue
<template>
    <form>
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo">
    </form>
</template>

<script>
import { inject } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
        console.log(todos.value)
    }
}
</script>
```

* Inspeccionar consola en el navegador y ver tambien Vuetools

* Crear funcion agregarToDo en TodoFormulario.vue y vincularlo con el template, verificar funcionamiento en consola del navegador

``` vue
<template>
    <form @submit.prevent="agregarToDo">
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo">
    </form>
</template>

<script>
import { inject } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
        
        const agregarToDo = () => {
            console.log('agregaste un TODO')
        }

        return{agregarToDo}
    }
}
</script>
```

* Agregar en TodoFormulario.vue un v-model para enviar datos del input a la funcion agregarToDo

``` vue
<template>
    <form @submit.prevent="agregarToDo">
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo"
          v-model="texto">
    </form>
</template>

<script>
import { inject, ref } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
        const texto = ref('')
        
        const agregarToDo = () => {
            console.log(texto.value)
        }

        return{agregarToDo, texto}
    }
}
</script>
```

* Construir objeto todo (singular) que contenga los datos a utilizar: id, texto, estado.

``` vue
<template>
    <form @submit.prevent="agregarToDo">
        <input
          type="text"
          class="form-control my-3"
          placeholder="Ingresar ToDo"
          v-model="texto">
    </form>
</template>

<script>
import { inject, ref } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
        const texto = ref('')
        
        const agregarToDo = () => {

            const todo = {
                descripcion: texto.value,
                estado: false,
                id: Date.now()
            }
            console.log(todo)
        }   

        return{agregarToDo, texto}
    }
}
</script>
```

* Se crean validaciones para texto, vacio y tambien se limpia el texto del formulario

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
import { inject, ref } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
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

            texto.value = ''
            console.log(todo)
        }   

        return{agregarToDo, texto}
    }
}
</script>
```

* A traves del metodo ***push*** empujamos o enviamos el objeto todo al arreglo todos que se almacenara en el componente padre TodoApp.vue

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
import { inject, ref } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')
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

            todos.value.push(todo)
            console.log(todos.value)

            texto.value = ''
            //console.log(todo)
        }   

        return{agregarToDo, texto}
    }
}
</script>
```

* Verificar arreglo en la consola del navegador
* Agregar ***watchEffect*** a TodoApp.vue para esperar el retorno de los todo individuales. Comentar console.log(todo.value) de TodoFormulario.vue

``` vue
<template>
    <h1>ToDos</h1>
    <todo-formulario />
</template>

<script>
import { provide, ref, watchEffect } from 'vue'
import TodoFormulario from './TodoFormulario.vue'
export default {
    components: { TodoFormulario },
    setup(){
        const todos = ref([])
        provide('todos', todos)

        watchEffect(() => {
            console.log(todos.value.length)
            console.log(todos.value)
        })
    }
}
</script>
```

## Componente TodoListado.vue 

* Crear componente TodoListado.vue, que mostrara el contenido del arreglo con los todos e importarlo a TodoApp.vue

``` vue
<template>
    Listado de TODOS
</template>

<script>
export default {

}
</script>
```

```vue
<template>
    <h1>ToDos</h1>
    <todo-formulario />
    <todo-listado />
</template>

<script>
import { provide, ref, watchEffect } from 'vue'
import TodoFormulario from './TodoFormulario.vue'
import TodoListado from './TodoListado.vue'
export default {
    components: { TodoFormulario, TodoListado },
    setup(){
        const todos = ref([])
        provide('todos', todos)

        watchEffect(() => {
            console.log(todos.value.length)
            console.log(todos.value)
        })
    }
}
</script>
```

* Verificar en el navegador con la consola

## Componente TodoItem.vue 

* Modificar TodoListado.vue para contener un list group como el ejemplo de [List group BootStrap](https://getbootstrap.com/docs/4.0/components/list-group/), donde el ***ul*** quedara en TodoListado.vue y el ***li*** en un nuevo componente llamado TodoItem.vue (el cual estara dentro de TodoListado)

``` vue
<template>
    <ul class="list-group">
        <todo-item />
    </ul>
</template>

<script>
import TodoItem from './TodoItem.vue'
export default {
  components: { TodoItem },

}
</script>
```

``` vue
<template>
      <li class="list-group-item">Cras justo odio</li>
</template>

<script>
export default {

}
</script>
```

* Recorrer el arreglo todo disponible en el componente padre con un ***v-for*** dentro del componente TodoListado.vue. Se manda a traves de un prop el valor del todo a TodoItem.vue. [Vue props](https://vuejs.org/guide/components/props.vue)

``` vue
<template>
    <ul class="list-group">
        <todo-item 
            v-for="todo in todos" :key="todo.id"
            :todo="todo"
        />
    </ul>
</template>

<script>
import { inject } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
export default {
  components: { TodoItem },
  setup(){
    const todos = inject('todos')

    return {todos}
  }
}
</script>
```

* Se modifica TodoItem.vue para recibir el prop, agregando estilos para cada item en el listado

``` vue
<template>
      <li class="list-group-item d-flex justify-content-between">
        <span role="button">
            { { todo.descripcion } }
        </span>
        <span role="button">
            <i class="fas fa-times"></i>
        </span>
      </li>
</template>

<script>
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    }
}
</script>
```

* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-3.png)
_Aplicacion de Vue en el navegador_

* Agregar funcionabilidad de borrar item utilizar el metodo ***filter***. [Filter JS](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/filter) 

```vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button">
            { { todo.descripcion } }
        </span>
        <span role="button" @click="borrar(todo.id)">
            <i class="fas fa-times"></i>
        </span>
    </li>
</template>

<script>
import { inject } from '@vue/runtime-core'
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    },
    setup() {
        const todos = inject('todos')

        const borrar = id => {
            todos.value = todos.value.filter(item => item.id !== id)
        }

        return {borrar}
    }
}
</script>
```

* Agregar funcionalidad de cambiar estado completado, tachado es ***true***, sin completar es ***false***. Podemos utilizar el metodo ***map***. [Map JS](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/map)

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button" @click="completado(todo.id)">
            { { todo.descripcion } }
        </span>
        <span role="button" @click="borrar(todo.id)">
            <i class="fas fa-times"></i>
        </span>
    </li>
</template>

<script>
import { inject } from '@vue/runtime-core'
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    },
    setup() {
        const todos = inject('todos')

        const borrar = id => {
            todos.value = todos.value.filter(item => item.id !== id)
        }

        const completado = id => {
            todos.value = todos.value.map(item => {
                if(item.id === id){
                    item.estado = true
                }
                return item
            })
        }

        return { borrar, completado }
    }
}
</script>
```

* Agregamos que al cambiar estado tache el texto del item. Ademas modificamos para que cambie entre estado al dar click nuevamente al item.

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button" @click="completado(todo.id)" :class="{ 'tachado': todo.estado }">
            { { todo.descripcion } }
        </span>
        <span role="button" @click="borrar(todo.id)">
            <i class="fas fa-times"></i>
        </span>
    </li>
</template>

<script>
import { inject } from '@vue/runtime-core'
export default {
    props: {
        todo: {
            type: Object,
            required: true
        }
    },
    setup() {
        const todos = inject('todos')

        const borrar = id => {
            todos.value = todos.value.filter(item => item.id !== id)
        }

        const completado = id => {
            todos.value = todos.value.map(item => {
                if (item.id === id) {
                    /*if (item.estado == false) {
                        item.estado = true
                    } else {
                        item.estado = false
                    }*/
                    item.estado = !item.estado
                }
                return item
            })
        }

        return { borrar, completado }
    }
}
</script>

<style>
.tachado {
    text-decoration: line-through;
}
</style>
```
## Componente TodoFooter.vue

* Crear componente TodoFooter.vue

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button">
            ## Pendientes
        </span>
        <span role="button">
            Eliminar completados
        </span>
    </li>
</template>

<script>
export default {

}
</script>
```
* Agregar el componente TodoFooter.vue al componente TodoListado.vue

```vue
<template>
    <ul class="list-group">
        <todo-item 
            v-for="todo in todos" :key="todo.id"
            :todo="todo"
        />

        <todo-footer />
    </ul>
</template>

<script>
import { inject } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
export default {
  components: { TodoItem, TodoFooter },
  setup(){
    const todos = inject('todos')

    return {todos}
  }
}
</script>
```

* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-4.png)
_Aplicacion de Vue en el navegador_

* Agregar funcionalidad para que el footer sea dinamico. Debe mostrarse cuando hay items en la lista y ocultarse cuando no existan.

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
      v-if="todos.length !== 0" />
  </ul>
</template>

<script>
import { inject } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
export default {
  components: { TodoItem, TodoFooter },
  setup() {
    const todos = inject('todos')

    return { todos }
  }
}
</script>
```

* Se implementa en TodoFooter.vue un funcion de tipo ***computed*** para el conteo de items pendientes (estado == false)

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button">
            { { contarPendientes } } Pendientes
        </span>
        <span role="button">
            Eliminar completados
        </span>
    </li>
</template>

<script>
import { computed, inject } from '@vue/runtime-core'
export default {
    setup(){
        const todos = inject('todos')

        const contarPendientes = computed(() => {
            return todos.value.filter(item => item.estado === false).length
        })

        return { contarPendientes }
    }
}
</script>
```
* Se implementa en TodoFooter.vue un funcion para Eliminar items completados (estado == true) pero al utilizar ***filter*** le solicitamos crear un nuevo array solo con los elementos pendientes o que esten en false.

``` vue
<template>
    <li class="list-group-item d-flex justify-content-between">
        <span role="button">
            { { contarPendientes } } Pendientes
        </span>
        <span role="button" @click="eliminarCompletados">
            Eliminar completados
        </span>
    </li>
</template>

<script>
import { computed, inject } from '@vue/runtime-core'
export default {
    setup() {
        const todos = inject('todos')

        const contarPendientes = computed(() => {
            return todos.value.filter(item => item.estado === false).length
        })

        const eliminarCompletados = () => {
            todos.value = todos.value.filter(item => item.estado === false)
        }

        return { contarPendientes, eliminarCompletados }
    }
}
</script>
```

## Componente TodoFiltro.vue

* Se crea un nuevo componente llamado TodoFiltro.vue

``` vue
<template>
    <div class="btn-group mt-3 d-flex" role="group" aria-label="Filtro">
        <button type="button" class="btn">Pendientes</button>
        <button type="button" class="btn">Todos</button>
        <button type="button" class="btn">Completados</button>
    </div>
</template>

<script>
export default {

};

</script>
```

* Este nuevo componente se utilizara dentro de TodoListado.vue

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
      v-if="todos.length !== 0" />
  </ul>

  <todo-filtro />
</template>

<script>
import { inject } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
import TodoFiltro from './TodoFiltro.vue'
export default {
  components: { TodoItem, TodoFooter, TodoFiltro },
  setup() {
    const todos = inject('todos')

    return { todos }
  }
}
</script>
```

* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-5.png)
_Aplicacion de Vue en el navegador_

* En el componente TodoListado.vue creamos una constante que enviaremos por ***ref*** al componente TodoFiltro. Dicha referencia nos servira para recorrer el arreglo y poder enviar variables de estado al filtro

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
      v-if="todos.length" />
  </ul>

  <todo-filtro />
</template>

<script>
import { computed, inject, provide, ref } from '@vue/runtime-core'
import TodoItem from './TodoItem.vue'
import TodoFooter from './TodoFooter.vue'
import TodoFiltro from './TodoFiltro.vue'
export default {
  components: { TodoItem, TodoFooter, TodoFiltro },
  setup() {
    const todosApp = inject('todos')
    const estado = ref('all')

    const todos = computed(() => {
      if(estado.value === 'all'){
        return todosApp.value
      }
      if(estado.value === 'pendientes'){
        return todosApp.value.filter(item => item.estado === false)
      }
      if(estado.value === 'completados'){
        return todosApp.value.filter(item => item.estado === true)
      }
    })

    provide('estado', estado)

    return { todos }
  }
}
</script>
```

* Modificamos el componente TodoFiltro para que pueda acceder a los estados y poder filtrar adecuadamente con los botones de filtro

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
import { inject } from "vue";
export default {
  setup() {
    const estado = inject("estado");
    const filtro = (valor) => {
      estado.value = valor;
    };
    return { filtro, estado };
  },
};
</script>
```

* Finalmente utilizamos [LocalStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) para guardar la data en el navegador. Pro lo que editamos el componente TodoApp.vue 

``` vue
<template>
    <h1>ToDos</h1>
    <todo-formulario />
    <todo-listado />
</template>

<script>
import { provide, ref, watchEffect } from 'vue'
import TodoFormulario from './TodoFormulario.vue'
import TodoListado from './TodoListado.vue'
export default {
    components: { TodoFormulario, TodoListado },
    setup() {
        const todos = ref([])
        provide('todos', todos)

        if (localStorage.getItem('todos')) {
            todos.value = JSON.parse(localStorage.getItem('todos'))
        }

        watchEffect(() => {
            localStorage.setItem('todos', JSON.stringify(todos.value))
            //console.log(todos.value.length)
            //console.log(todos.value)
        })
    }
}
</script>
```
## Estilos CSS

* App.vue CSS

``` css
<style>
body {
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

* TodoApp.vue CSS

``` css
<style>
h1 {
    color: #ffffff;
}
</style>
```

* TodoFormulario.vue CSS

``` css
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

* TodoItem.vue CSS

``` css
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
* Verificar la app en el navegador
 ![VUE APP](/assets/images/vue-todo-6.png)
_Aplicacion de Vue en el navegador_

* Finalmente ejecutamos el comando ***npm run build***. La aplicacion quedara lista para ser distribuida en la carpeta dist del proyecto

``` powershell
npm run build
```