---
title: Fundamentos JavaScript - parte 2
date: 2022-07-31 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## Estructuras de control

En lenguajes de programación, las estructuras de control permiten modificar el flujo de ejecución de las instrucciones de un programa.

### Condicionales

- if/else (Si ocurre algo, haz esto, sino, haz lo otro...)
- ?: operador ternario (Operador ternario: Equivalente a If/else , método abreviado.)
- switch (Estructura para casos específicos: Similar a varios If/else anidados.)

### Repetitivas o iterativas

- while
- do... while
- for

## if... else

Ejecuta una sentencia si una condición especificada es evaluada como verdadera. Si la condición es evaluada como falsa, otra sentencia puede ser ejecutada.  

```javascript
if (condicion) {
    // bloque verdadero
} else {
    // bloque falso
}
```

```javascript
let textJavascript = prompt("Escriba 'javascript'")

if (textJavascript === "javascript") {
    console.log("Lo escribiste bien")
} else {
    console.log("Lo escribiste mal")
}
```

```javascript
let numUsuario = prompt("Ingrese numero del 1 al 10")

console.log(numUsuario + " Es: " + typeof numUsuario)
console.log(parseInt(numUsuario))

if (parseInt(numUsuario) <= 10) {
    // Sentencia true
    console.log("Numero dentro del rango 1 a 10")
} else {
    // Sentencia false
    console.log("Numero fuera de rango")
}
```

```javascript
//condicion ? exprVerdadero : exprFalso
const edad = 26
const bebida = edad >= 21 ? "Cerveza 🍺 " : "Juice 🧃"
console.log(bebida)

function getCobro(esVIP) {
  return (esVIP ? '$2.00' : '$10.00')
}

console.log(getCobro(true))
console.log(getCobro(false))
console.log(getCobro(null))
```

## Switch

La **declaración** `**switch**` evalúa una expresión, comparando el valor de esa expresión con una instancia `**case**`, y ejecuta declaraciones asociadas a ese `case`, así como las declaraciones en los `case` que siguen.  

```javascript
let fruta = prompt("Escriba una fruta")

switch (fruta) {
  case 'Naranjas':
    console.log('El kilogramo de naranjas cuesta $0.59.')
    break
  case 'Manzanas':
    console.log('El kilogramo de manzanas cuesta $0.32.')
    break
  case 'Platanos':
    console.log('El kilogramo de platanos cuesta $0.48.')
    break;
  case 'Cerezas':
    console.log('El kilogramo de cerezas cuesta $3.00.')
    break
  case 'Mangos':
  case 'Papayas':
    console.log('El kilogramo de mangos y papayas cuesta $2.79.')
    break
  default:
    console.log('Lo lamentamos, por el momento no disponemos de ' + expr + '.')
}
```

## while

Crea un bucle que ejecuta una sentencia especificada mientras cierta condición se evalúe como verdadera. Dicha condición es evaluada antes de ejecutar la sentencia.
 

```javascript
let numero = 0
while (numero <= 10) {
    console.log(numero)
    numero++ //numero = numero + 1;
}
console.log("FIN: " + numero)
```

## do... while

La sentencia (hacer mientras) crea un bucle que ejecuta una sentencia especificada, hasta que la condición de comprobación se evalúa como falsa. La condición se evalúa después de ejecutar la sentencia, dando como resultado que la sentencia especificada se ejecute al menos una vez.

```javascript
let resultado = ''
let i = 0

do {
  i = i + 1
  resultado = resultado + i
} while (i < 5)

console.log(result)
```

## for

Crea un bucle que consiste en tres expresiones opcionales, encerradas en paréntesis y separadas por puntos y comas, seguidas de una sentencia ejecutada en un bucle.

```javascript
for (let i = 0; i < 5; i++) {
  console.log("El numero es " + i)
}
```

## Array

Los arrays son objetos similares a una lista cuyo prototipo proporciona métodos para efectuar operaciones de recorrido y de mutación. Tanto la longitud como el tipo de los elementos de un array son variables.  

```javascript
let frutas = ["manzana", "platano", "pera"]
console.log(frutas)
console.log(frutas.length)
console.log(frutas[0])
console.log(frutas[1])
console.log(frutas[2])
console.log(frutas[3])

console.log(typeof frutas)

for (let i = 0; i < frutas.length; i++) {
    console.log(frutas[i])
}
```

## for of

La sentencia for...of ejecuta un bloque de código para cada elemento de un objeto iterable, como lo son: String, Array, objetos similares a array (por ejemplo, arguments or NodeList), TypedArray, Map, Set e iterables definidos por el usuario.  

```javascript
for (let fruta of frutas) {
    console.log(fruta);
}
```

## for in

El bucle for...in iterará sobre todas las propiedades de un objeto. Más tecnicamente, iterará sobre cualquier propiedad en el objeto que haya sido internamente definida con su propiedad \[\[Enumerable\]\] configurada como true.  


```javascript
for (let fruta in frutas) {
    console.log(fruta);
}
```

## function

Las funciones son uno de los bloques de construcción fundamentales en JavaScript. Una función en JavaScript es similar a un procedimiento — un **conjunto de instrucciones** que realiza una tarea o calcula un valor, pero para que un procedimiento califique como función, debe tomar alguna entrada y devolver una salida donde hay alguna relación obvia entre la entrada y la salida.

### Características:

- El nombre de la función.
- Una lista de parámetros de la función, entre paréntesis y separados por comas.
- Las declaraciones de JavaScript que definen la función, encerradas entre llaves, `{ ... }`.

```javascript
function saludar(
) {
    console.log("Bienvenido!");
}

saludar();
```

```javascript
saludar();

function saludar(
) {
    console.log("Bienvenido!");
}
```

- [Hoisting](https://developer.mozilla.org/es/docs/Glossary/Hoisting) una estricta definición de hoisting sugiere que las declaraciones de variables y funciones son físicamente movidas al comienzo del código, pero esto no es lo que ocurre en realidad. Lo que sucede es que las declaraciones de variables y funciones son asignadas en memoria durante la fase de compilación, pero quedan exactamente en dónde las has escrito en el código.

### Funciones con argumentos/parámetros:  

```javascript
function saludar(nombreUsuario) {
    console.log("Bienvenido! " + nombreUsuario);
}
saludar("Ignacio");
```

### Funciones con retorno:

```javascript
function saludar(nombreUsuario) {
    return "Bienvenido " + nombreUsuario;
}

console.log(saludar("Ignacio"));
```

### Ejemplo sumar:

```javascript
function sumar(n1, n2) {
    return parseInt(n1) + parseInt(n2);
}

let numeroUno = prompt("Ingrese primer número");
let numeroDos = prompt("Ingrese segundo número");

let resultado = sumar(numeroUno, numeroDos);

console.log("El total es: " + resultado);
```

### Reutilizables
Una característica fundamental de las funciones es que se pueden reutilizar.

```javascript
function sumar(n1, n2) {
    return n1 + n2;
}

let resultadoUno = sumar(10, 20);
let resultadoDos = sumar(50, 60);
let resultadoTres = sumar(100, 30);

console.log("El total uno es: " + resultadoUno);
console.log("El total dos es: " + resultadoDos);
console.log("El total tres es: " + resultadoTres);
```