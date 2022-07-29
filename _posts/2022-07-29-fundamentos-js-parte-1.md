---
title: Fundamentos JavaScript - parte 1
date: 2022-07-29 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## JavaScript

**JavaScript** (**J****S**) es un lenguaje de programación ligero, interpretado, o compilado [justo-a-tiempo](https://es.wikipedia.org/wiki/Compilaci%C3%B3n_en_tiempo_de_ejecuci%C3%B3n) (just-in-time) con [funciones de primera clase](https://developer.mozilla.org/es/docs/Glossary/First-class_Function). Si bien es más conocido como un lenguaje de scripting (secuencias de comandos) para páginas web, y es usado en [muchos entornos fuera del navegador](https://es.wikipedia.org/wiki/JavaScript), tal como [Node.js](https://developer.mozilla.org/es/docs/Glossary/Node.js), [Apache CouchDB](https://couchdb.apache.org/) y [Adobe Acrobat](https://www.adobe.com/devnet/acrobat/javascript.html) JavaScript es un lenguaje de [programación basada en prototipos](https://developer.mozilla.org/es/docs/Glossary/Prototype-based_programming), multiparadigma, de un solo hilo, dinámico, con soporte para programación orientada a objetos, imperativa y declarativa (por ejemplo programación funcional).

El estándar para JavaScript es [ECMAScript](https://developer.mozilla.org/es/docs/conflicting/Web/JavaScript/JavaScript_technologies_overview) (ECMA-262) y [la especificación de la API para la Internacionalización de ECMAScript](https://tc39.es/ecma402/) (ECMA-402). No confundas JavaScript con el [lenguaje de programación Java](https://es.wikipedia.org/wiki/Java_(lenguaje_de_programaci%C3%B3n)). Ambos "Java" y "JavaScript" son marcas o marcas registradas de Oracle en los Estados Unidos y otros países, Sin embargo, los dos lenguajes de programación tienen sintaxis, semántica y usos muy diferentes.

JavaScript fue desarrollado originalmente por Brendan Eich de Netscape  con el nombre de Mocha, el cual fue renombrado posteriormente a LiveScript, para finalmente quedar como JavaScript.

- **HTML**: es el lenguaje de marcado que usamos para estructurar y dar significado a nuestro contenido web, por ejemplo, definiendo párrafos, encabezados y tablas de datos, o insertando imágenes y videos en la página.
- **CSS**: es un lenguaje de reglas de estilo que usamos para aplicar estilo a nuestro contenido HTML, por ejemplo, establecer colores de fondo y tipos de letra, y distribuir nuestro contenido en múltiples columnas.
- **JS**: es un lenguaje de secuencias de comandos que te permite crear contenido de actualización dinámica, controlar multimedia, animar imágenes y prácticamente todo lo demás. (Está bien, no todo, pero es sorprendente lo que puedes lograr con unas pocas líneas de código JavaScript).

![HTML+CSS+JS](/assets/images/robot.gif)_HTML+CSS+JS_

## Agregando JavaScript

1 - En el head o cabecera de un archivo html con las etiquetas _**<script>**_  

``` html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JS Basic</title>
    <script>
        alert("Alerta con JavaScript 🎉 🎆 🎊");
    </script>
</head>
<body>
    <h1>Fundamentos de JS</h1>    
</body>
</html>

```

2 - Mezclado con html lo cual es una mala practica por lo que hay que evitarlo. 🚫🚫🚫

``` html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JS Basic</title>
</head>
<body>
    <h1>Fundamentos de JS</h1>
    <button onclick="alerta()">Click me!</button>
    <script>
        function alerta() {
            alert("Alerta con JavaScript 🎉 🎆 🎊");
        }
    </script>
</body>
</html>

```

3 - En un archivo externo

***index.html***

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JS Basic</title>
</head>
<body>
    <h1>Fundamentos de JS</h1>
    <script src="src/script.js"></script>
</body>
</html>

```

***script.js***

```javascript
alert("Alerta con JavaScript 🎉 🎆 🎊")
```

## Comentarios

``` javascript
// soy un comentario de una linea

/*
  Yo también soy
  un comentario en bloque 
  o varias lineas
*/
```

## Palabras reservadas

### Palabras clave reservadas a partir de ECMAScript 2015

- [`break`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/break)
- [`case`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/switch)
- [`catch`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/try...catch)
- [`class`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/class)
- [`const`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/const)
- [`continue`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/continue)
- [`debugger`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/debugger)
- [`default`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch "Currently only available in English (US)")
- [`delete`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/delete)
- [`do`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/do...while)
- [`else`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/if...else)
- [`export`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/export)
- [`extends`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/class)
- [`finally`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/try...catch)
- [`for`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/for)
- [`function`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/function)
- [`if`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/if...else)
- [`import`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/import)
- [`in`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/in)
- [`instanceof`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/instanceof)
- [`new`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/new)
- [`return`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/return)
- [`super`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/super)
- [`switch`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/switch)
- [`this`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/this)
- [`throw`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/throw)
- [`try`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/try...catch)
- [`typeof`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/typeof)
- [`var`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/var)
- [`void`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/void)
- [`while`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/while)
- [`with`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/with "Currently only available in English (US)")
- [`yield`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/yield)

### Futuras palabras clave reservadas

Las siguientes están reservadas como palabras clave futuras por la especificación ECMAScript. No tienen ninguna funcionalidad especial en la actualidad, pero es posible que lo hagan en el futuro, por lo que no se pueden utilizar como identificadores.

Estas siempre están reservadas:

- `enum`

Las siguientes solo están reservadas cuando se encuentran en código de modo estricto:

- `implements`
- `interface`
- [`let`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/let)
- `package`
- `private`
- `protected`
- `public`
- `static`
- [`yield`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/yield)

Las siguientes solo están reservadas cuando se encuentran en código de módulo:

- `await`

### Futuras palabras clave reservadas en estándares más antiguos

Las siguientes están reservadas como palabras clave futuras según las especificaciones de ECMAScript anteriores (ECMAScript 1 a 3).  

- `abstract`
- `boolean`
- `byte`
- `char`
- `double`
- `final`
- `float`
- `goto`
- `int`
- `long`
- `native`
- `short`
- `synchronized`
- `throws`
- `transient`
- `volatile`

Además, los literales `null`, `true` y `false` no se pueden utilizar como identificadores en ECMAScript.

## Orden de ejecución

Cuando el navegador encuentra un bloque de JavaScript, generalmente lo ejecuta en orden, de arriba a abajo. Esto significa que debes tener cuidado con el orden en el que colocas las cosas.  

```javascript
alert("primero")
alert("segundo")
alert("tercero")
```
> **⚠ CUIDADO!!!!**
> JavaScript distingue entre mayúsculas y minúsculas y es muy exigente, por lo que debes ingresar la sintaxis exactamente como se muestra; de lo contrario, es posible que no funcione.

## Consola

Si abrimos el inspector de elementos, podrás ver una pestaña de consola. La consola del navegador es una herramienta que nos ayuda a depurar nuestras páginas, facilitando nuestro trabajo diario.

```javascript
console.log("Saludos desde la consola 👌")
```

## Tipos de datos

El último estándar ECMAScript define nueve tipos:

- Seis **tipos de datos** [primitivos](https://developer.mozilla.org/es/docs/Glossary/Primitive), controlados por el [`operador typeof`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/typeof)
    - [Undefined](https://developer.mozilla.org/es/docs/Glossary/undefined): `typeof instance === "undefined"`
    - [Boolean](https://developer.mozilla.org/es/docs/Glossary/Boolean): `typeof instance === "boolean"`
    - [Number](https://developer.mozilla.org/es/docs/Glossary/Number): `typeof instance === "number"`
    - [String](https://developer.mozilla.org/es/docs/Glossary/String): `typeof instance === "string"`
    - [BigInt](https://developer.mozilla.org/es/docs/Glossary/BigInt): `typeof instance === "bigint"`
    - [Symbol](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Symbol): `typeof instance === "symbol"`
- [Null](https://developer.mozilla.org/es/docs/Glossary/Null): `typeof instance === "object"`. Tipo [primitivo](https://developer.mozilla.org/es/docs/Glossary/Primitive) especial que tiene un uso adicional para su valor: si el objeto no se hereda, se muestra `null`;
- [Object](https://developer.mozilla.org/es/docs/Glossary/Object): `typeof instance === "object"`. Tipo estructural especial que no es de datos pero para cualquier instancia de objeto [construido](https://developer.mozilla.org/es/docs/Learn/JavaScript/Objects#the_constructor) que también se utiliza como estructuras de datos: new [`Object`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Object), new [`Array`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array), new `Map`, new [`Set`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Set), new [`WeakMap`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/WeakMap), new [`WeakSet`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/WeakSet), new [`Date`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date) y casi todo lo hecho con la [palabra clave `new`](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/new);
- [Function](https://developer.mozilla.org/es/docs/Glossary/Function): una estructura sin datos, aunque también responde al operador `typeof`: `typeof instance === "function"`. Esta simplemente es una forma abreviada para funciones, aunque cada constructor de funciones se deriva del constructor `Object`.

### Tipos de datos más basicos

- String: se utiliza para representar datos textuales. 
- Number: valores numéricos. 
- Boolean: representa una entidad lógica y puede tener dos valores: `true` y `false`.  

```javascript
console.log("un valor de tipo texto o string")
console.log(20)
console.log("20")
console.log(1.2)
console.log(1, 62) //funcion recibiendo parametros
console.log(1 + 1)
console.log(true)
console.log(false)
```

## Variables

Una variable es un espacio de memoria el cual nos servirá para almacenar un tipo de dato con un valor correspondiente.  

JavaScript tiene tres tipos de declaraciones de variables.

- `var` Declara una variable, opcionalmente la inicia a un valor. 
- `let` Declara una variable local con ámbito de bloque, opcionalmente la inicia a un valor. 
- `const` Declara un nombre de constante de solo lectura y ámbito de bloque. 

## Asignación

- En JS el signo **`=`** se conoce como **Operador de asignación simple** (permite almacenar un valor a una variable).
- Se evalúa la expresión de la derecha y luego se le asigna el resultado a la variable de la izquierda.
- A esto se le llama **declarar la variable** con un valor inicial.  
    
```javascript
let x = 10
let y = false
let z = x
let n = "Carlitos"
let a = 10
let b = 20
let resultado = a * b

console.log(resultado)
```

Reglas para el nombre de variables:

- No utilizar espacios, en su lugar reemplazar con `_` o [camelCase](https://es.wikipedia.org/wiki/Camel_case) 🐫
- Utilizar lengua inglesa, sin ñ ni tildes (en teoría se puede pero es una mala práctica)
- Evitar signos extraños como `@ # [ ] + { } -` etc.
- El primer carácter no puede ser un número `var 2res = 'valor'`
- Se puede utilizar el signo `$` ej: `var $anio = 2022;`

## Concatenación

Concatenación es el **proceso de anexar una cadena al final de otra cadena**. Las cadenas se concatenan con el operador `+`
  
``` javascript
var a = "Hola, "
var b = "como estas?"
var union = a + b
console.log(union)
//variantes
console.log(a + b)
console.log("Hola, " + "como estas?")

var nombreUsuario = "James"
var edadUsuario = "40"
console.log("Mi nombre es: " + nombreUsuario + " y mi edad es: " + edadUsuario)

var num1 = 100
var num2 = 200
console.log(num1 + num2)
```

## Prompt()

Genera un dialogo para el ingreso de data

```javascript
let numeroUno = prompt("Ingresa el primero número")
let numeroDos = prompt("Ingresa el segundo número")
let resultado = numeroUno + numeroDos
console.log(resultado)
```

- [typeof](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/typeof) El operador typeof devuelve una cadena que indica el tipo del operando sin evaluarlo
- [parseInt](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/parseInt) Convierte (parsea) un argumento de tipo cadena y devuelve un entero de la base especificada.

```javascript
let numeroUno = prompt("Ingresa el primero número")
let numeroDos = prompt("Ingresa el segundo número")

console.log(typeof numeroUno)

let resultado = parseInt(numeroUno) + parseInt(numeroDos)
console.log(resultado)
```

## Operadores Aritméticos

En programación y matemáticas, los operadores aritméticos son aquellos que manipulan los datos de tipo numérico, es decir, permiten la realización de operaciones matemáticas (sumas, restas, multiplicaciones, etc.).  

Adición: Suma dos números juntos.

```javascript
let resultado = 1 + 1
console.log(resultado)
```

Resta: Resta el numero de la derecha del de la izquierda.

```javascript
let resultado = 2 - 1
console.log(resultado)
```

Multiplicación: Multiplica dos números juntos.

```javascript
let resultado = 5 * 20
console.log(resultado)
``` 

División: Divide el número de la izquierda por el de la derecha.

```javascript
let resultado = 20 / 5
console.log(resultado)
```

Sobrante (también llamado módulo): Retorna el restante después de dividir el número de la izquierda en porciones enteras del de la derecha.


```javascript
let resultado = 8 % 3
console.log(resultado)
```

```javascript
let resultado = 2 * (100 / 5) + 10
console.log(resultado)
```

## Operadores Relacionales

Los operadores relacionales definidos por JavaScript son idénticos a los que definen las matemáticas: mayor que `>`, menor que `<`, mayor o igual `>=`, menor o igual `<=`, igual que `===` y distinto de `!==`.

Mientras que al `==` se le considera igualdad débil o abstracta, al `===` se le conoce como igualdad estricta, fuerte o también se le llama identidad.

La diferencia es que mientras que con el `==` antes de hacer la comparación se convierten ambos datos a un tipo común.

Con `===` ninguno de estos valores se convierte de manera implícita antes de ser comparado. Por eso aunque el valor del dato sea igual, si el tipo de dato no coincide el operador responde que no son iguales.

``` javascript
let resultado = 20 > 10
console.log(resultado)
```

``` javascript
let resultado = 20 < 10
console.log(resultado)
```

``` javascript
let resultado = 20 === 10
console.log(resultado)
```

``` javascript
let resultado = 20 == "20"
console.log(resultado)
```

``` javascript
let resultado = 20 !== 10
console.log(resultado)
```

``` javascript
let resultado = 10 != "10"
console.log(resultado)
```

## Operadores lógicos

Los operadores lógicos se usan para combinar dos valores Booleanos y devolver un resultado verdadero, falso o nulo. Los operadores lógicos también se denominan operadores Booleanos.

- `&&` : Si los dos son verdaderos devuelve verdadero.
- `||` : Con que uno sea verdadero devolverá verdadero.
- `!`  : Negación

``` javascript
let resultado = true && true
console.log(resultado)
```

``` javascript
let resultado = 20 > 10 && 10 < 20
console.log(resultado)
```

``` javascript
let resultado = true && true && false
console.log(resultado)
```

``` javascript
let resultado = true || false
console.log(resultado)
```

``` javascript
let resultado = true || false || false
console.log(resultado)
```

``` javascript
let resultado = !false
console.log(resultado)
```