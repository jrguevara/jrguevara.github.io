---
title: VUE Router 
date: 2022-10-22 01:00:00 -500
categories: [vue]
tags: [vue, frontend, programacion]
published: true
hidden: false
---

## Vite Router

Vue Router es el enrutador oficial de Vue.js. Se integra profundamente con el núcleo de Vue.js para facilitar la creación de aplicaciones de una sola página con Vue.js. Las características incluyen: 

-  Mapeo de rutas anidadas 
- Enrutamiento dinámico
- Configuración de enrutador modular basada en componentes 
- Parámetros de ruta, consulta, comodines
- Control de navegación detallado
- Enlaces con clases CSS activas automáticas 
- Modo historial HTML5 o modo hash 
-  Comportamiento de desplazamiento personalizable 
- Codificación adecuada para URL

  

- Crear proyecto

`npm init vue@latest`
 

- Agregar CDN de BootStrap y de Font Awesome a index.html

1. [Font Awesome](https://cdnjs.com/libraries/font-awesome)
2. [BootStrap](https://getbootstrap.com/)

  

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <link rel="icon" href="/favicon.ico">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous"
    referrerpolicy="no-referrer" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-0evHe/X+R7YkIZDRvuzKMRqM+OrBnVFBL6DOitfPri4tjfHxaWutUpFmBp4vmVor" crossorigin="anonymous">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vite App</title>
</head>

<body>
  <div id="app"></div>
  <script type="module" src="/src/main.js"></script>
</body>

</html>

```

  

- Limpiar App.vue

```javascript
⁠<script setup>
</script>

<template>

</template>

```

  

- Borrar contenido de la carpeta `⁠components`⁠ 
- Borrar contenido de la carpeta `views`
- Borrar contenido de archivo `/src/router/index.js` 
- Editar archivo `/src/main.js`

```javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

//import './assets/main.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)

app.mount('#app')

```

  

crear archivo en `src/data.json`

```json
[
    {
        "id": 1,
        "marca": "Ford",
        "estilo": "coupe",
        "precio": 45323,
        "anio": 2020
    },
    {
        "id": 3,
        "marca": "Porsche",
        "estilo": "SUV",
        "precio": 77693,
        "anio": 2018
    },
    {
        "id": 5,
        "marca": "Audi",
        "estilo": "SUV",
        "precio": 12242,
        "anio": 2011
    },
    {
        "id": 6,
        "marca": "Ford",
        "estilo": "coupe",
        "precio": 145323,
        "anio": 2023
    },
    {
        "id": 7,
        "marca": "Ford",
        "estilo": "SUV",
        "precio": 434,
        "anio": 2003
    },
    {
        "id": 8,
        "marca": "Porsche",
        "estilo": "Coupe",
        "precio": 277693,
        "anio": 2023
    },
    {
        "id": 9,
        "marca": "Audi",
        "estilo": "sedan",
        "precio": 82242,
        "anio": 2019
    },
    {
        "id": 10,
        "marca": "Ford",
        "estilo": "coupe",
        "precio": 45323,
        "anio": 2020
    }
]

```

  

- modificar App.vue

```html
<script setup>
import { ref } from "vue";
import vehiculosData from "./data.json"

const vehiculos = ref(vehiculosData)

</script>

<template>
  <main class="container">
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="/">Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/acerca">Quienes somos?</a>
          </li>
        </ul>
    </nav>


    <h1>Nuestros Vehiculos</h1>
    <div class="row text-center">
      <div v-for="vehiculo in vehiculos" :key="vehiculo.id" class="card">
        <div class="card-body">
          <h3 class="card-title">{ { vehiculo.marca } }</h3>
          <p class="lead">${ { vehiculo.precio } }</p>
          <button class="btn btn-primary">Detalles</button>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
.card {
  box-shadow: 1px 1px 10px rgba(0, 0, 0, 0.207);
  padding: 15px;
  width: 200px;
  margin-right: 15px;
  margin-bottom: 20px;
}

.links {
  padding: 20px
}

.links a {
  margin: 0 5px
}
</style>

```

  

## Vue Router

  

[https://router.vuejs.org/](https://router.vuejs.org/)

`⁠npm install vue-router   `

  

Pasos para configurar rutas:

1. Definir las reglas de las rutas
2. Decirle a Vue sobre las reglas
3. Definir donde renderizar los componentes 

  

- Crear `router/index.js` en nuestra aplicación

```javascript
import {createRouter, createWebHistory} from "vue-router"
import InicioView from "../views/InicioView.vue"
import AcercaView from "../views/AcercaView.vue"

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "inicio",
            component: () => InicioView
        },
        {
            path: "/acerca",
            name: "acerca",
            component: () => AcercaView
        }

    ] 
})

export default router

```

  

- Crear `views/InicioView.vue`
- Copiar contenido de `App.vue` a `InicioView.vue` 

```html
<script setup>
import { ref } from "vue";
import vehiculosData from "../data.json"

const vehiculos = ref(vehiculosData)

</script>

<template>
  <main class="container">
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="/">Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/acerca">Quienes somos?</a>
          </li>
        </ul>
    </nav>


    <h1>Nuestros Vehiculos</h1>
    <div class="row text-center">
      <div v-for="vehiculo in vehiculos" :key="vehiculo.id" class="card">
        <div class="card-body">
          <h3 class="card-title">{ { vehiculo.marca } }</h3>
          <p class="lead">${ { vehiculo.precio } }</p>
          <button class="btn btn-primary">Detalles</button>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
.card {
  box-shadow: 1px 1px 10px rgba(0, 0, 0, 0.207);
  padding: 15px;
  width: 200px;
  margin-right: 15px;
  margin-bottom: 20px;
}

.links {
  padding: 20px
}

.links a {
  margin: 0 5px
}
</style>

```

  

- `AcercaView.vue`

```html
<template>
    <main class="container">
        <h1>Quienes somos?</h1>
        <p>"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."</p>
    </main>
</template>

```

  

- Modificar  `src/main.js` 

```javascript
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

//import './assets/main.css'

//createApp(App).mount('#app')

const app = createApp(App)
app.use(router)
app.mount('#app')

```

  

- ⁠Modificar `App.vue`

```javascript
<script setup>
import { RouterView } from "vue-router"
</script>

<template>
<main>
  <RouterView />
</main>
</template>

```

  

- Remover nav de `InicioView.vue` y colocarlo en `App.vue`

```html
<script setup>
import { RouterView } from "vue-router"
</script>

<template>
<main>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="/">Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/acerca">Quienes somos?</a>
          </li>
        </ul>
    </nav>
  <RouterView />
</main>
</template>

```

  

- Añadir counter a `App.vue`

```html
<script setup>
import { RouterView } from "vue-router"
import { ref } from "vue"
const counter = ref(0)
</script>

<template>
<main>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="/">Inicio</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/acerca">Quienes somos?</a>
          </li>
        </ul>
    </nav>
    <h1>{ { counter } }</h1>
    <button class="btn btn-warning" @click="counter++">Click</button>
  <RouterView />
</main>
</template>

```

  

    - Añadir routerLink a `App.vue`   
    

```html
<script setup>
import { RouterView, RouterLink } from "vue-router"
import { ref } from "vue"
const counter = ref(0)
</script>

<template>
<main>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <RouterLink class="nav-link" to="/">Inicio</RouterLink>
          </li>
          <li class="nav-item">
            <RouterLink class="nav-link" to="/acerca">Quienes somos?</RouterLink>
          </li>
        </ul>
    </nav>
    <h1>{ { counter } }</h1>
    <button class="btn btn-warning" @click="counter++">Click</button>
  <RouterView />
</main>
</template>

```

  

- Remover counter ksa

## Links Dinamicos

- Editar `src/router/index.js`  

```javascript
import {createRouter, createWebHistory} from "vue-router"
import InicioView from "../views/InicioView.vue"
import AcercaView from "../views/AcercaView.vue"
import DetallesVehiculoView from "../views/DetallesVehiculoView.vue"

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "inicio",
            component: () => InicioView
        },
        {
            path: "/acerca",
            name: "acerca",
            component: () => AcercaView
        },
        {
            path: "/detalle/:id",
            name: "detalle",
            component: () => DetallesVehiculoView
        }
    ] 
})

export default router

```

  

  

- Crear `DetallesVehiculoView.vue`

```html
<script setup>
import { useRoute } from 'vue-router' //permite extraer informacion
import { ref, onBeforeMount} from 'vue';
import vehiculos from '../data.json'

const vehiculo = ref(null)
const route = useRoute()

//console.log(route.params)
onBeforeMount(() => {
    vehiculo.value = vehiculos.find(v => v.id === parseInt(id))
})

const { id } = route.params
</script>

<template>
    <div class="container">
        <h1>Detalles de vehiculo</h1>
        <p>Marca: { { vehiculo.marca } }</p>
        <p>Precio: { { vehiculo.precio } }</p>
        <p>Estilo: { { vehiculo.estilo } }</p>
        <p>Año: { { vehiculo.anio } }</p>
    </div>
</template>

```

  

- Agregar link dinámicos a `InicioView.vue`

```html
<script setup>
import { ref } from "vue";
import vehiculosData from "../data.json"
import { useRouter } from "vue-router"

const router = useRouter()

const vehiculos = ref(vehiculosData)

</script>

<template>
    <main class="container">
        <h1>Nuestros Vehiculos</h1>
        <div class="row text-center">
            <div v-for="vehiculo in vehiculos" :key="vehiculo.id" class="card">
                <div class="card-body">
                    <h3 class="card-title">{ { vehiculo.marca } }</h3>
                    <p class="lead">${ { vehiculo.precio } }</p>
                    <button @click="router.push(`/detalle/${vehiculo.id}`)" class="btn btn-primary">Detalles</button>
                </div>
            </div>
        </div>
    </main>
</template>

<style scoped>
.card {
    box-shadow: 1px 1px 10px rgba(0, 0, 0, 0.207);
    padding: 15px;
    width: 200px;
    margin-right: 15px;
    margin-bottom: 20px;
}
</style>

```

  

- id inexistente en `DetallesVehiculoView.vue`

```html
<script setup>
import { useRoute } from 'vue-router' //permite extraer informacion de la ruta
import { ref, onBeforeMount } from 'vue';
import vehiculos from '../data.json'

const vehiculo = ref(null)
const route = useRoute()

//console.log(route.params)
onBeforeMount(() => {
    vehiculo.value = vehiculos.find(v => v.id === parseInt(id))
})

const { id } = route.params
</script>

<template>
    <div class="container">
        <div v-if="vehiculo">
            <h1>Detalles de vehiculo</h1>
            <p>Marca: { { vehiculo.marca } }</p>
            <p>Precio: { { vehiculo.precio } }</p>
            <p>Estilo: { { vehiculo.estilo } }</p>
            <p>Año: { { vehiculo.anio } }</p>
        </div>
        <div v-else>
            <h1>Vehiculo no encontrado</h1>
        </div>
    </div>
</template>

```

  

  

## Not Found (Atrapar todas las peticiones)

- Agregar expresión regular a  `src/router/index.js`

```javascript
import {createRouter, createWebHistory} from "vue-router"
import InicioView from "../views/InicioView.vue"
import AcercaView from "../views/AcercaView.vue"
import DetallesVehiculoView from "../views/DetallesVehiculoView.vue"
import notFoundView from "../views/notFoundView.vue"

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "inicio",
            component: () => InicioView
        },
        {
            path: "/acerca",
            name: "acerca",
            component: () => AcercaView
        },
        {
            path: "/detalle/:id",
            name: "detalle",
            component: () => DetallesVehiculoView
        },
        {
            path: "/:pathMach(.*)*", //expresion regular
            name: "notFound",
            component: () => notFoundView
        }
    ] 
})

export default router

```

  

- Crear `NotFoundView.vue`

```html
<template>
    <div class="container">
        <h1>404. Not Found</h1>
    </div>
</template>

```

  

## Filtros

- Agregar filtros de marca a `InicioView.vue`

```html
<script setup>
import { ref, watch } from "vue";
import vehiculosData from "../data.json"
import { useRouter } from "vue-router"

const router = useRouter()

const vehiculos = ref(vehiculosData)

const marca = ref("")

watch(marca, () => {
    if(marca.value){
        if(marca.value == "Todos") vehiculos.value = vehiculosData
        else {
            vehiculos.value = vehiculosData.filter(c => c.marca === marca.value)
        }
    }
})

</script>

<template>
    <main class="container">
        <h1>Nuestros Vehiculos</h1>
        <select v-model="marca">
            <option value="Todos">Todos</option>
            <option value="Ford">Ford</option>
            <option value="Porsche">Porsche</option>
            <option value="Audi">Audi</option>
        </select>
        <div class="row text-center">
            <div v-for="vehiculo in vehiculos" :key="vehiculo.id" class="card">
                <div class="card-body">
                    <h3 class="card-title">{ { vehiculo.marca } }</h3>
                    <p class="lead">${ { vehiculo.precio } }</p>
                    <button @click="router.push(`/detalle/${vehiculo.id}`)" class="btn btn-primary">Detalles</button>
                </div>
            </div>
        </div>
    </main>
</template>

<style scoped>
.card {
    box-shadow: 1px 1px 10px rgba(0, 0, 0, 0.207);
    padding: 15px;
    width: 200px;
    margin-right: 15px;
    margin-bottom: 20px;
}
</style>

```

  

## Parámetros de consulta

- Modificar  `InicioView.vue`

```html
<script setup>
import { ref, watch, onMounted } from "vue";
import vehiculosData from "../data.json"
import { useRouter, useRoute } from "vue-router"

const router = useRouter()
const route = useRoute()

const vehiculos = ref(vehiculosData)

const marca = ref("")

onMounted(() => {
    marca.value = route.query.marca || ""
})

watch(marca, () => {
    if(marca.value){
        if(marca.value == "Todos") vehiculos.value = vehiculosData
        else {
            vehiculos.value = vehiculosData.filter(c => c.marca === marca.value)
        }
    }
})

const handleFiltro = (
) => {
    router.push({query: {marca: marca.value} })
}

</script>

<template>
    <main class="container">
        <h1>Nuestros Vehiculos</h1>
        <select @change="handleFiltro" v-model="marca">
            <option value="Todos">Todos</option>
            <option value="Ford">Ford</option>
            <option value="Porsche">Porsche</option>
            <option value="Audi">Audi</option>
        </select>
        <div class="row text-center">
            <div v-for="vehiculo in vehiculos" :key="vehiculo.id" class="card">
                <div class="card-body">
                    <h3 class="card-title">{ { vehiculo.marca } }</h3>
                    <p class="lead">${ { vehiculo.precio } }</p>
                    <button @click="router.push(`/detalle/${vehiculo.id}`)" class="btn btn-primary">Detalles</button>
                </div>
            </div>
        </div>
    </main>
</template>

<style scoped>
.card {
    box-shadow: 1px 1px 10px rgba(0, 0, 0, 0.207);
    padding: 15px;
    width: 200px;
    margin-right: 15px;
    margin-bottom: 20px;
}
</style>

```