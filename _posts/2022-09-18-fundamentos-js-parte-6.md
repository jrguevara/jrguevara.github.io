---
title: Fundamentos JavaScript - parte 6
date: 2022-09-17 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## Callbacks

- [Callback](https://developer.mozilla.org/es/docs/Glossary/Callback_function): Una función de callback es una función que se pasa a otra función como un argumento, que luego se invoca dentro de la función externa para completar algún tipo de rutina o acción.

- Cada vez se ocupan menos.
- Pasar una función como argumento.

  

## ¿Por qué necesitamos funciones de devolución de llamada?

 JavaScript ejecuta código secuencialmente en orden de arriba hacia abajo. Sin embargo, hay algunos casos en los que el código se ejecuta (o debe ejecutarse) después de que suceda algo más y tampoco de manera secuencial. Esto se llama programación asíncrona. 

Las devoluciones de llamada aseguran que una función no se ejecutará antes de que se complete una tarea, sino que se ejecutará justo después de que se complete la tarea. Nos ayuda a desarrollar código JavaScript asíncrono y nos mantiene a salvo de problemas y errores. 

En JavaScript, la forma de crear una función de devolución de llamada es pasarla como un parámetro a otra función y luego devolverla justo después de que algo haya sucedido o se haya completado alguna tarea.  

  

```javascript
setTimeout(myFunction, 3000);

function myFunction(
) { console.log("Hola mundo!")}
//myFunction se pasa como argumento a setTimeout
```

  

```javascript
const calculo = (numero1, numero2, op) => {
    return op(numero1, numero2)
}

calculo(2, 4, (a, b) => { console.log(a + b) })
calculo(2, 4, (a, b) => { console.log(a - b) })
calculo(2, 4, (a, b) => { console.log(a * b) })
```

  

```javascript
const posts = [
    {
        userId: 1,
        id: 1,
        title: "titulo #1",
    },
    {
        userId: 1,
        id: 2,
        title: "titulo #2",
    },
    {
        userId: 1,
        id: 3,
        title: "titulo #3",
    },
]
```

  

```javascript
const findPostById = (id, callback) => {
    const post = posts.find((item) => item.id === id)

    callback(post)
}

const printPost = (post) => {
    console.log(post)
}

findPostById(2, printPost)
```

  

```javascript
const findPostById = (id, callback) => {
    const post = posts.find((item) => item.id === id)

    callback(post)
}

//De forma anonima
findPostById(1, (post) => {
    console.log(post)
})
```


### Manejo de Errores

```javascript
const findPostById = (id, callback) => {
    const post = posts.find((item) => item.id === id)

    if (post) {
        // mandamos el null ya que no existen errores
        callback(null, post)
    } else {
        // en caso de que no exista el post (error)
        callback("No encontrado por id: " + id)
    }
}

// ser recibe el err como primer argumento
findPostById(4, (err, post) => {
    if (err) {
        return console.log(err)
    }
    console.log(post)
})
```
  

Pues hasta ahí los callbacks parecen cool e inofensivos pero cuando abusamos de ellos se genera algo llamado el **Callback hell**  

### Callback Hell

Usar correctamente los callbacks a veces puede ser poco intuitivo y puede derivar en situaciones como las siguientes:  

```javascript
findPostById(1, (err, post) => {
    if (err) {
        return console.log(err)
    }
    console.log(post.id)

    findPostById(2, (err, post2) => {
        if (err) {
            return console.log(err)
        }
        console.log(post.id, post2.id)

        findPostById(3, (err, post3) => {
            if (err) {
                return console.log(err)
            }
            console.log(post.id, post2.id, post3.id)

            findPostById(4, (err, post4) => {
                if (err) {
                    return console.log(err)
                }
                console.log(post.id, post2.id, post3.id, post4.id)
            })
        })
    })
})
```


Esto pasa cuando no se tiene buenas prácticas, pero ejemplos como estos se pueden mejorar rápidamente usando técnicas de modularización y manejo de errores. Pueden ver más sobre esto en [callbackhell.com](http://callbackhell.com)  

## Promesas

- [promise](https://developer.mozilla.org/es/docs/Web/JavaScript/Guide/Using_promises): Una Promisa es un objeto que representa la terminación o el fracaso de una operación asíncrona.
 

Una promesa en JavaScript es similar a una promesa en la vida real. Cuando hacemos una promesa en la vida real, es una garantía de que vamos a hacer algo en el futuro. Porque las promesas solo se pueden hacer para el futuro. Una promesa tiene 2 posibles resultados: o se cumplirá cuando llegue el momento, o no se cumplirá. Esto también es lo mismo para las promesas en JavaScript. Cuando definimos una promesa en JavaScript, se resolverá cuando llegue el momento, o se rechazará.

Las promesas pueden tener 3 estados definidos:

- _pendiente (pending)_: estado inicial, no cumplida o rechazada.
- _cumplida (fulfilled)_: significa que la operación se completó satisfactoriamente.
- _rechazada (rejected)_: significa que la operación falló.

Por ejemplo, cuando solicitamos datos del servidor mediante una Promesa, estará en modo pendiente hasta que recibamos nuestros datos. Si conseguimos obtener la información del servidor, la Promesa se resolverá con éxito. Pero si no obtenemos la información, entonces la Promesa estará en estado rechazado.

¿Cuál es la diferencia entre Callbacks y Promises?

La principal diferencia entre las funciones de devolución de llamada y las promesas es que adjuntamos una devolución de llamada a una promesa en lugar de pasarla. Así que todavía usamos funciones de devolución de llamada con Promesas, pero de una manera diferente.


```javascript
const findPostById = (id) => {
    const post = posts.find((item) => item.id === id)

    // devolver la promesa
    return new Promise((resolve, reject) => {
        //resolve
        if (post) {
            resolve(post)
        } else {
            reject("No encontrado por id: " + id)
        }
    })
}

findPostById(1)
    .then((post) => console.log(post))
    .catch((err) => console.log(err))
    .finally(() => console.log("fin de la promesa"))
```

  

Ahorrando codigo:

```javascript
const findPostById = (id) =>
    new Promise((resolve, reject) => {
        const post = posts.find((item) => item.id === id)

        post ? resolve(post) : reject("No encontrado por id: " + id)
    })

findPostById(4)
    .then((post) => console.log(post))
    .catch((e) => console.log(e))
```

  

## Promises hell

```javascript
findPostById(1)
    .then((post) => {
        console.log(post.title)
        return findPostById(2)
    })
    .then((post) => {
        console.log(post.title)
        return findPostById(3)
    })
    .then((post) => {
        console.log(post.title)
        return findPostById(4)
    })
    .then((post) => console.log(post.title))
    .catch((e) => console.log(e))
```

  

## async await

- [async](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/async_function): La declaración de función async define una función asíncrona, la cual devuelve una AsyncFunction.

- [await](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/await): El operador await es usado para esperar a una Promise. Sólo puede ser usado dentro de una función async function.

  

```javascript
const findPostById = (id) =>
    new Promise((resolve, reject) => {
        setTimeout(() => {
            const post = posts.find((item) => item.id === id)
            post ? resolve(post) : reject("No encontrado por id: " + id)
        }, 2000);
    })

findPostById(1)
    .then((post) => console.log(post))
    .catch((e) => console.log(e))

console.log("Fin del programa")
```

  

```javascript
const findPostById = (id) =>
    new Promise((resolve, reject) => {
        setTimeout(() => {
            const post = posts.find((item) => item.id === id)
            post ? resolve(post) : reject("No encontrado por id: " + id)
        }, 2000)
    })

const buscar = async (id) => {
    const post = await findPostById(id)
    console.log(post)
}

buscar(3)

console.log("Fin del programa")
```

  

Con Try y Catch para que funcione el reject de la promesa

```javascript
const findPostById = (id) =>
    new Promise((resolve, reject) => {
        setTimeout(() => {
            const post = posts.find((item) => item.id === id)
            post ? resolve(post) : reject("No encontrado por id: " + id)
        }, 2000)
    })

const buscar = async (id) => {
// let loading = true
    try {
        const post = await findPostById(id)
        console.log(post)
    } catch (error) {
        console.log(error)
    } finally {
        console.log("se ejecuta siempre")
        // let loading = false
    }
}

buscar(4)

console.log("Fin del programa")
```

  

Multiple llamadas

```javascript
const buscar = async (
) => {
    try {
        const postUno = await findPostById(1)
        const postDos = await findPostById(2)
        console.log(postUno.title, postDos.title)
    } catch (error) {
        console.log(error)
    } finally {
        console.log("se ejecuta siempre")
    }
}

buscar()

console.log("Fin del programa")
```

  

Promise all

```javascript
const buscar = async (
) => {
    try {
        // solo en el caso que no dependan una de la otra
        const respuestaPosts = await Promise.all([findPostById(1), findPostById(2)])

        // console.log(rePosts);
        console.log(respuestaPosts[0].title, respuestaPosts[1].title)
    } catch (error) {
        console.log(error)
    }
}

buscar()

console.log("Fin del programa")
```

  

## Fetch

- **Fetch es una interfaz para hacer solicitudes AJAX en JavaScript.** Es usado generalmente para hacer una solicitud a un API.
- El método `fetch()` toma un argumento obligatorio, la ruta de acceso al recurso que desea recuperar.

  

## Ajax

- [ajax](https://developer.mozilla.org/es/docs/Web/Guide/AJAX)
- JavaScript Asíncrono + XML (ahora se utiliza JSON)
- AJAX no es una tecnología por sí misma, **es un término que describe un nuevo modo de utilizar conjuntamente varias tecnologías existentes.**
- Esto incluye: **HTML, CSS, JavaScript, DOM, JSON y lo más importante, el objeto XMLHttpRequest (XMLHttpRequest viejito ahora Fetch)**
- Cuando estas tecnologías se combinan en un modelo AJAX, es posible lograr aplicaciones web capaces de actualizarse continuamente sin tener que volver a cargar la página completa.
- Esto crea aplicaciones más rápidas y con mejor respuesta a las acciones del usuario.

## Métodos nativos para AJAX

- [XMLHttpRequest](https://developer.mozilla.org/es/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest)
- [fetch API](https://developer.mozilla.org/es/docs/Web/API/Fetch_API)

## Fetch API

- [Fetch api](https://developer.mozilla.org/es/docs/Web/API/Fetch_API/Using_Fetch): Proporciona una interfaz JavaScript para hacer peticiones HTTP así como sus respuestas.
- También provee un método para obtener recursos de forma asíncrona por la red.
- [fetch parámetros](https://developer.mozilla.org/en-US/docs/Web/API/fetch) inicia el proceso de obtener un recurso de la red, devolviendo una promesa que se cumple una vez que la respuesta está disponible.
- Este tipo de funcionalidad se conseguía previamente haciendo uso de **XMLHttpRequest**.


Conceptos Claves al momento de hacer una petición HTTP:

- [HTTP:](https://developer.mozilla.org/es/docs/Web/HTTP) Hypertext Transfer Protocol (HTTP) (o Protocolo de Transferencia de Hipertexto en español) es el nombre de un protocolo el cual nos permite realizar una petición de datos y recurso.
- **Ruta (PATH):** Es la dirección de donde queremos obtener los recursos.
- [Métodos Http:](https://developer.mozilla.org/es/docs/Web/HTTP/Methods) HTTP define un conjunto de métodos de petición para indicar la acción que se desea realizar para un recurso determinado. (GET, POST, PUT, PATCH, DELETE)
- **Cabeceras (headers):** Cabeceras HTTP opcionales, que pueden aportar información adicional a los servidores.
- **Códigos de respuestas (Response Codes):** Un código de estado, indicando si la petición ha sido exitosa, o no, y debido a que. [más info](https://developer.mozilla.org/es/docs/Web/HTTP/Status) [cat http](https://http.cat/)
- [JSON:](https://developer.mozilla.org/es/docs/Learn/JavaScript/Objects/JSON) JavaScript Object Notation, es un formato basado en texto estándar para representar datos estructurados en la sintaxis de objetos de JavaScript. Es comúnmente utilizado para transmitir datos en aplicaciones web.

  
```javascript
const url = "https://pokeapi.co/api/v2/pokemon/";

fetch(url)
    .then((res) => res.json())
    .then((data) => console.log(data));
```

- Aquí estamos recuperando un archivo JSON a través de red e imprimiendo en la consola.
- El uso de `fetch()` más simple toma un argumento (la ruta del recurso que quieres obtener) y **devuelve un objeto Promise conteniendo la respuesta**, un objeto Response.
- Esto es, por supuesto, una respuesta HTTP **sin el archivo JSON**.
- **Para extraer el contenido en el cuerpo del JSON** desde la respuesta, usamos el método `json()`, el cual está implementado por los objetos Request y Response

  

## Rick & Morty API

```html
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rick and Morty</title>
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32x32.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

</head>

<body class="bg-secondary">
    <div class="container my-5">
        <section class="d-flex align-items-center text-white" id="loading">
            <strong>Cargando...</strong>
            <div class="spinner-border ms-auto" role="status" aria-hidden="true"></div>
        </section>
        <div class="row" id="card-dinamica">
            <template id="template-card">
                <article class="col-md-6 col-lg-3 mb-3">
                    <div class="card text-center bg-dark shadow">
                        <img src="https://rickandmortyapi.com/api/character/avatar/3.jpeg" class="card-img-top" />
                        <div class="card-body">
                            <h5 class="card-title text-white lead">
                                SumSum
                            </h5>
                            <p class="lead text-secondary">Human</p>
                        </div>
                    </div>
                </article>
            </template>
        </div>
    </div>
    <script src="src/script.js"></script>
</body>

</html>
```

  

```javascript
document.addEventListener("DOMContentLoaded", () => {
    fetchData()
});

const cards = document.querySelector("#card-dinamica")
const templateCard = document.querySelector("#template-card").content

const fetchData = async () => {
    try {
        loadingData(true)

        const res = await fetch("https://rickandmortyapi.com/api/character")
        const data = await res.json()

        showData(data)
    } catch (error) {
        console.log(error)
    } finally {
        loadingData(false)
    }
}

const loadingData = (estado) => {
    const loading = document.querySelector("#loading")
    if (estado) {
        loading.classList.remove("d-none")
    } else {
        loading.classList.add("d-none")
    }
}

const showData = (data) => {
    const fragment = document.createDocumentFragment()

    cards.textContent = ""

    data.results.forEach((item) => {
        const clone = templateCard.cloneNode(true)
        clone.querySelector("h5").textContent = item.name
        clone.querySelector("p").textContent = item.species
        clone.querySelector("img").setAttribute("src", item.image)

        fragment.appendChild(clone)
    })
    cards.appendChild(fragment)
}
```