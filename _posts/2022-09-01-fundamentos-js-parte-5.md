---
title: Fundamentos JavaScript - parte 5
date: 2022-09-01 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## DOM

- El modelo de objeto de documento [DOM](https://developer.mozilla.org/es/docs/Web/API/Document_Object_Model/Introduction) es una interfaz de programación para los documentos HTML.

- Facilita una representación estructurada del documento y define de qué manera los programas pueden acceder, al fin de modificar, tanto su estructura, estilo y contenido.

- **Una página web es un documento**. Éste documento puede exhibirse en la ventana de un navegador o también como código fuente HTML.

  

## document

- [document](https://developer.mozilla.org/es/docs/Web/API/Document) La interfaz Document representa cualquer página web cargada en el navegador y sirve como punto de entrada al contenido de la página (El árbol DOM).

```javascript
console.log(document)
```

[Propiedades:](https://developer.mozilla.org/es/docs/Web/API/Document#properties)

```javascript
console.log(document.head)
console.log(document.title)
console.log(document.body)
console.log(document.domain)
```

[Métodos:](https://developer.mozilla.org/es/docs/Web/API/Document#methods)

- Document.getElementsByClassName(String className)
- Document.getElementsByTagName(String tagName)
- Document.getElementById(String id)
- Document.querySelector(String selector)
- Document.querySelectorAll(String selector)
- Document.createDocumentFragment()
- Document.createElement(String name)

## getElementById

- [getElementById](https://developer.mozilla.org/es/docs/Web/API/Document/getElementById): Devuelve una referencia al elemento por su ID.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1 id="tituloWeb">Lorem, ipsum dolor.</h1>
    <script src="app.js"></script>
</body>
</html>
```

```javascript
console.log(document.getElementById("tituloWeb"))
console.log(document.getElementById("tituloWeb").textContent)
console.log(document.getElementById("tituloWeb").innerHTML)
```

```html
<!DOCTYPE html>
<html lang="en">
</html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <script src="app.js"></script> <!-- Qué sucedera?? -->
</head>
<body>
    <h1 id="tituloWeb">Lorem, ipsum dolor.</h1>
</body>
</html>
```


## DOMContentLoaded y defer

- [DOMContentLoaded](https://es.javascript.info/onload-ondomcontentloaded) el navegador HTML está completamente cargado y el árbol DOM está construido, pero es posible que los recursos externos como `<img>` y hojas de estilo aún no se hayan cargado.


```javascript
document.addEventListener("DOMContentLoaded", () => {
    console.log(document.getElementById("tituloWeb"))
    console.log(document.getElementById("tituloWeb").textContent)
});
```

- [defer](https://es.javascript.info/script-async-defer) El atributo defer indica al navegador que no espere por el script. En lugar de ello, debe seguir procesando el HTML, construir el DOM. El script carga “en segundo plano” y se ejecuta cuando el DOM esta completo.

- Los scripts con defer siempre se ejecutan **cuando el DOM esta listo** (pero antes del evento DOMContentLoaded).
- defer no funciona igual en todos los navegadores.


```html
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <script src="app.js" defer></script>
</head>
```

## querySelector

- [querySelector](https://developer.mozilla.org/es/docs/Web/API/Document/querySelector): Devuelve el primer elemento del documento que coincida con el grupo especificado de selectores.

```html
<h1 class="text-primary" id="tituloWeb">Lorem, ipsum dolor.</h1>
```

  

```javascript
console.log(document.querySelector("h1"));
console.log(document.querySelector(".text-primary"));
console.log(document.querySelector("#tituloWeb"));
```

  

```html
<div class="container">
    <p class="text-danger">Lorem, ipsum dolor 1.</p>
    <p class="text-danger">Lorem, ipsum dolor 2.</p>
    <p class="text-danger">Lorem, ipsum dolor 3.</p>
</div>

<p class="text-danger">parrafo</p>
```

  

```javascript
// El primer elemento que encuentre
console.log(document.querySelector(".text-danger"));

// Todos
console.log(document.querySelectorAll(".text-danger"));

// Todo lo que esté en "container"
console.log(document.querySelectorAll(".container .text-danger"));
```

  

## querySelector vs getElementById

- El método querySelector le permite recuperar un elemento mediante una consulta de selector de CSS
- El método getElementById recupera un elemento por su ID DOM.
- Ambos métodos tienen una amplia compatibilidad con los navegadores. Debe optar por usar el método querySelector si necesita seleccionar elementos usando reglas más complejas que se representan fácilmente usando un selector CSS. Si desea seleccionar un elemento por su ID, usar getElementById es una buena opción.

- A menudo necesitará realizar selecciones más complejas en su HTML, y ahí es donde querySelector puede ser más útil; usarlo de manera constante también puede hacer que su código sea más fácil de leer para otros codificadores.

- En otras palabras, el principal beneficio de usar querySelector o querySelectorAll es que podemos seleccionar elementos usando selectores CSS, lo que nos da **una forma uniforme de manejar la selección de elementos**, y eso lo convierte en una forma preferida de seleccionar elementos para muchos desarrolladores.

- Si usa una herramienta como Babel para admitir navegadores más antiguos, entonces puede ser irrelevante, ya que las funciones más nuevas se pueden convertir a código compatible con versiones anteriores cuando compila su script.

  

## element

- [element](https://developer.mozilla.org/es/docs/Web/API/Element): eventos disponibles para los elementos HTML

  

Algunas propiedades:

```javascript
const h1 = document.querySelector("#tituloWeb");

console.log(h1.className);
console.log(h1.id);
console.log(h1.style);
console.log(h1.tagName);
console.log(h1.textContent);

h1.textContent = "nuevo texto";
h1.style.backgroundColor = "red";
h1.style.color = "white";
```

[Métodos:](https://developer.mozilla.org/es/docs/Web/API/Element#m.c3.a9todos)

- addEventListener: Registra un controlador de evento para un tipo de evento específico en un elemento.
- appendChild: Inserta un nodo así como el último nodo hijo de este elemento.
- hasAttributes: Verifica si el elemento tiene o no algún atributo.

## Eventos

En JavaScript, la interacción con el usuario se consigue mediante la captura de los eventos que éste produce. Un evento es una acción del usuario ante la cual puede realizarse algún proceso (por ejemplo, el cambio del valor de un formulario, o la pulsación de un enlace).

## addEventListener

- [addEventListener](https://developer.mozilla.org/es/docs/Web/API/EventTarget/addEventListener): Registra un evento a un objeto en específico.

- **El Objeto especifico puede ser un simple elemento** en un archivo, el mismo documento , una ventana o un XMLHttpRequest.

- [Eventos estándar](https://developer.mozilla.org/es/docs/Web/Events#eventos_est%C3%A1ndar)


```javascript
elemento.addEventListener(tipo, listener);
```

  

- tipo: tipo de evento a escuchar.
- listener: El objeto que recibe una notificación cuando un evento de el tipo especificado ocurre. Debe ser un objeto implementando la interfaz EventListener o **solo una function en JavaScript**.

## click

```html
<button id="boton">Cambiar texto</button>
<p id="parrafo">Lorem, ipsum dolor.</p>
```

```javascript
const boton = document.querySelector("#boton")
const parrafo = document.querySelector("#parrafo")

boton.addEventListener("click", () => {
    console.log("Haz hecho click")
    parrafo.textContent = "Nuevo texto desde evento"
    parrafo.style.backgroundColor = "red"
});
```
## createElement

- [createElement](https://developer.mozilla.org/es/docs/Web/API/Document/createElement): El método `document.createElement()` crea un elemento HTML especificado por su tagName.

  

Crear un `<li>` 

```javascript
const li = document.createElement("li")
li.textContent = "item desde javascript"
console.log(li)
```

  

## appendChild

- [appendChild](https://developer.mozilla.org/es/docs/Web/API/Node/appendChild): Agrega un nuevo nodo al final de la lista de un elemento hijo de un elemento padre especificado.

  

```html
<ul id="listaDinamica">
    <li>Elemento estático</li>
</ul>
```

  

```javascript
// elemento donde vamos a incorporar los <li>
const listaDinamica = document.querySelector("#listaDinamica")

// Creamos el <li>
const li = document.createElement("li")

// Agregamos texto al <li>
li.textContent = "item desde javascript"

// Finalmente incorporamos al <ul>
listaDinamica.appendChild(li)
listaDinamica.appendChild(li)
```

  

CONSIDERACIONES:

- Si el **child hace una referencia a un nodo existente en el documento**, el método appendChild se mueve de su posición actual a su nueva posición.
- Ésto significa que el nodo no puede estar en dos puntos del documento de manera simultánea.
- Así que si el nodo ya contiene un padre, primero es eliminado, y después se añade a la nueva posición.
- Se puede usar [Node.cloneNode](https://developer.mozilla.org/es/docs/Web/API/Node/cloneNode) para hacer una copia del nodo antes de añadirlo debajo de su nuevo elemento padre.

  

No recomendado:

```javascript
const listaDinamica = document.querySelector("#listaDinamica")

const arrayHeroes = ["Spiderman", "IronMan", "BlackWidow"]

arrayHeroes.forEach((heroe) => {
    const li = document.createElement("li")
    li.textContent = heroe
    listaDinamica.appendChild(li)
})
```

  

Reflow  

Aquí se genera [Reflow:](https://developer.mozilla.org/en-US/docs/Glossary/reflow) Ocurre cuando un navegador debe procesar y renderizar parte o la totalidad de una página web nuevamente, como después de una actualización en un sitio interactivo.

  

## Fragment

- [new DocumentFragment()](https://developer.mozilla.org/es/docs/Web/API/DocumentFragment)
- [createDocumentFragment()](https://developer.mozilla.org/es/docs/Web/API/Document/createDocumentFragment)
- La interfaz DocumentFragment representa un objeto de documento mínimo que no tiene padre.
- Se utiliza como una versión ligera de Document que almacena un segmento de una estructura de documento compuesta de nodos como un documento estándar.
- La gran diferencia se debe al hecho de que **el fragmento de documento no forma parte de la estructura de árbol del documento activo.**
- Los cambios realizados en el fragmento no afectan el documento (incluso en reflow) ni inciden en el rendimiento cuando se realizan cambios.

  

```javascript
const listaDinamica = document.querySelector("#listaDinamica")

const arrayHeroes = ["Spiderman", "IronMan", "BlackWidow"]

const fragment = document.createDocumentFragment()

arrayHeroes.forEach((heroe) => {
    const li = document.createElement("li")
    li.textContent = heroe
    fragment.appendChild(li)
})

listaDinamica.appendChild(fragment)
```

  

##  insertBefore

- [firstChild](https://developer.mozilla.org/en-US/docs/Web/API/Node/firstChild)
- [insertBefore](https://developer.mozilla.org/es/docs/Web/API/Node/insertBefore)

  

```
parentNode.insertBefore(newNode, referenceNode);
```

  

```javascript
arrayHeroes.forEach((heroe) => {
    const newNode = document.createElement("li")
    newNode.textContent = heroe

    // Nos devuelve el primer elemento
    const referenceNode = fragment.firstChild

    // En caso de que no exista un nodo hijo mostrara null
    console.log("primer newNode", referenceNode)

    // Si "referenceNode" es null, el newNode se insertará al final de la lista.
    fragment.insertBefore(newNode, referenceNode)
})
```

  

## Ejemplo createElement

Supongamos que necesitamos incorporar de forma dinámica este elemento:

  

```html
<li class="list">
  <b>Heroe: </b> <span class="text-primary">aquí va el heroe</span>
</li>
```

  

```javascript
const listaDinamica = document.querySelector("#listaDinamica")

const arrayHeroes = ["Spiderman", "IronMan", "BlackWidow"]

const fragment = new DocumentFragment()

arrayEHeroes.forEach((heroe) => {
    const li = document.createElement("li")
    li.className = "list"

    const bold = document.createElement("b")
    bold.textContent = "Heroe: "

    const span = document.createElement("span")
    span.className = "text-primary"
    span.textContent = heroe

    li.appendChild(bold)
    li.appendChild(span)
    fragment.appendChild(li)
})

listaDinamica.appendChild(fragment)
```

  

## template

- [template](https://developer.mozilla.org/es/docs/Web/HTML/Element/template): es un mecanismo para mantener el contenido HTML del lado del cliente que no se renderiza cuando se carga una página, pero que posteriormente puede ser instanciado durante el tiempo de ejecución empleando JavaScript.
- Piensa en la plantilla como un fragmento de contenido que está siendo almacenado para un uso posterior en el documento.
- El analizador procesa el contenido del elemento `<template>` durante la carga de la página, pero sólo lo hace para asegurar que esos contenidos son válidos; sin embargo, estos contenidos del elemento no se renderizan.
- los elementos `<template>` contienen un **DocumentFragment** en su propiedad **HTMLTemplateElement.content**.
    

```html
<ul id="listaDinamica"></ul>

    <template id="template">
        <li class="list">
            <b>Heroe: </b> <span class="text-primary">aquí va el heroe</span>
        </li>
    </template>

<script src="app.js"></script>
```

  

```javascript
const listaDinamica = document.querySelector("#listaDinamica")

const template = document.querySelector("#template")
// es aconsejable clonar
const clone = template.content.cloneNode(true)

//console.log(clone)

clone.querySelector("span").textContent = "Spiderman"

listaDinamica.appendChild(clone)
```

  

### Fragment + Template

```javascript
const listaDinamica = document.querySelector("#listaDinamica")
const fragment = document.createDocumentFragment()
const template = document.querySelector("#template")

const arrayHeroes = ["Spiderman", "IronMan", "BlackWidow"]

arrayHeroes.forEach((heroe) => {
    const clone = template.content.cloneNode(true)
    clone.querySelector("span").textContent = heroe
    fragment.appendChild(clone)
});

listaDinamica.appendChild(fragment)
```

  

> **OJO**  
> HTMLTemplateElement tiene una propiedad **content**, que es de **solo lectura** y DocumentFragment contiene el subárbol DOM que representa la plantilla. **Tener en cuenta que el uso directo del valor de content** podría provocar un comportamiento inesperado; consulte la sección [Evitar el error de DocumentFragment](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/template#avoiding_documentfragment_pitfall).

  

```javascript
const listaDinamica = document.querySelector("#listaDinamica")
const arrayHeroes = ["Spiderman", "IronMan", "BlackWidow"]
const fragment = document.createDocumentFragment()
const template = document.querySelector("#template")

const clickHeroe = (e) => console.log("Evento click: ", e.target)

arrayHeroes.forEach((heroe) => {
    const clone = template.content.firstElementChild.cloneNode(true) // se añade firstElementChild
    clone.querySelector("span").textContent = heroe
    clone.addEventListener("click", clickHeroe)
    fragment.appendChild(clone)
});

listaDinamica.appendChild(fragment)
```


## Carrito con objeto

  
```html
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito con Objetos</title>
    <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon-32x32.png">
    <link rel="stylesheet" href="assets/css/style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-iYQeCzEYFbKjA/T2uDLTpkwGzCiq6soy8tYaI1GyVh/UjpbCx/TYkiZhlZB6+fzT" crossorigin="anonymous">
</head>

<body>
    <div class="row">
        <div class="col-lg-12">
            <img src="assets/img/logo.png" style="max-width:20%;" class="img-responsive center-block d-block mx-auto" alt="Sample Image">
        </div>
    </div>

    <main class="container mt-5">
        <div class="row text-center">
            <article class="col-sm-4 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Cóctel 🍸</h5>
                        <button class="btn btn-primary" data-id="1" data-bebida="Cóctel 🍸">Agregar</button>
                    </div>
                </div>
            </article>
            <article class="col-sm-4 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Cerveza 🍺</h5>
                        <button class="btn btn-primary" data-id="2" data-bebida="Cerveza 🍺">Agregar</button>
                    </div>
                </div>
            </article>
            <article class="col-sm-4 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Vino 🍷</h5>
                        <button class="btn btn-primary" data-id="3" data-bebida="Vino 🍷">Agregar</button>
                    </div>
                </div>
            </article>
        </div>
    </main>

    <section class="container mt-3">
        <ul class="list-group" id="carrito">
            <!--li class="list-group-item d-flex justify-content-between align-items-center">
                <span class="lead">items</span>
                <span class="badge bg-primary rounded-pill">14</span>
            </li-->
        </ul>
    </section>

    <template id="template">
        <li class="list-group-item d-flex justify-content-between align-items-center">
            <span class="lead">items</span>
            <span class="badge bg-primary rounded-pill">0</span>
        </li>
    </template>

    <script src="src/script.js"></script>
</body>

</html>
```


```javascript
const carrito = document.querySelector("#carrito")
const template = document.querySelector("#template")
const fragment = document.createDocumentFragment()
const agregar = document.querySelectorAll(".card button")

const carritoObjeto = {}

const agregarCarrito = (e) => {

    const producto = {
        titulo: e.target.dataset.bebida,
        id: e.target.dataset.id,
        cantidad: 1,
    }

    if (carritoObjeto.hasOwnProperty(producto.id)) {
        producto.cantidad = carritoObjeto[producto.id].cantidad + 1
    }

    carritoObjeto[producto.id] = producto

    mostrarCarrito()
}

agregar.forEach((boton) => boton.addEventListener("click", agregarCarrito))

const mostrarCarrito = () => {
    carrito.textContent = ""

    Object.values(carritoObjeto).forEach((item) => {
        const clone = template.content.cloneNode(true)
        clone.querySelector(".lead").textContent = item.titulo
        clone.querySelector(".rounded-pill").textContent = item.cantidad
        fragment.appendChild(clone)
    });
    carrito.appendChild(fragment)
}
```