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
