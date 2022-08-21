---
title: Fundamentos JavaScript - parte 3
date: 2022-08-19 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## Plantillas literales

Las plantillas literales son cadenas literales que habilitan el uso de expresiones incrustadas. Con ellas, es posible utilizar cadenas de caracteres de más de una línea, y funcionalidades de interpolación de cadenas de caracteres.

En ediciones anteriores de la especificación ES2015, solían llamarse "plantillas de cadenas de caracteres".

```javascript
console.log('línea 1 de cadena de texto\n' +
'línea 2 de cadena de texto');

console.log(`línea 1 de la cadena de texto
línea 2 de la cadena de texto`);
```

### Interpolación de expresiones

Para insertar expresiones dentro de cadenas de caracteres normales, se utilizaría la siguiente sintaxis:

```javascript
let nombreUsuario = "James";
console.log("\nBienvenido: \n" + nombreUsuario);

```

Ahora, con las plantillas literales, se pueden utilizar sus nuevas capacidades (es decir, insertar expresiones con `${ }` e incluir caracteres de fin de linea literales dentro de la cadena) para simplificar la sintaxis:  

```javascript
let nombreUsuario = "James";
console.log(`
Bienvenido: 
${ nombreUsuario }
`);

//operaciones matematicas
let a = 23;
let b = 55;
console.log(`Resultado de a + b: ${ a + b }`)

//uso de metodos
console.log(`Bienvenido: ${ nombreUsuario.toUpperCase() }`)

// ternario
let nombreUsuario = "james"
let estado = false
console.log(`${ estado ? 'online!' : 'offline' } ${ nombreUsuario }`);
```

## var vs let vs const

### var

Uno de los mayores problemas al declarar variables con `var`, es que puede sobrescribir las declaraciones de variables sin errores.

```javascript
var estado = true;
var estado = false;
console.log(estado);
```

En una aplicación pequeña, es posible que no se encuentre con este tipo de problema, pero cuando su código se agrande, **puede sobrescribir accidentalmente una variable que no tenía la intención de sobrescribir.**

### let

Debido a que este comportamiento no arroja un error, la búsqueda y corrección de errores se vuelve más difícil. Se introdujo `let` una nueva palabra clave llamada en ES6 para resolver este problema potencial con `var`. 

- Con `let`: Una variable con el mismo nombre solo se puede declarar una vez.

```javascript
let estado = true;
let estado = false;
console.log(estado);
```

- Pero si se puede cambiar su valor:

```javascript
let estado = true;
estado = false;
console.log(estado);
```

### Scope

En simples palabras el "scope de una variable" hace referencia al lugar donde esta va a residir o donde podrá ser accesible. Cuando declaras una variable con `var`, **se declara globalmente o localmente** si se declara dentro de una función.

```javascript
var estado = true
if (estado) {
    var estado = false
}
console.log(estado)
```

`let` se comporta de manera similar, pero con algunas características adicionales. Cuando declaras una variable con `let` dentro de un bloque, declaración o expresión, **su alcance se limita a ese bloque**, declaración o expresión.

```javascript
let estado = true
if (estado) {
    let estado = false
    console.log(estado)
}
console.log(estado)

for (let i = 0; i < 10; i++) {
    console.log(i)
}
console.log(i)
```
### const

`const` tiene todas las características de `let`, con la ventaja adicional de que las variables declaradas usando `const` **son de solo lectura**. Son un valor constante, **lo que significa que una vez que se asigna una variable `const`, no se puede reasignar.**

```javascript
//error 
const estado = true
estado = false

//error
for (const i = 0; i < 10; i++) {
    console.log(i)
}

//valido
const estado = true
if (estado) {
    const estado = false
    console.log(estado)
}
console.log(estado)
```

Algunos desarrolladores prefieren asignar todas sus variables usando `const` de forma predeterminada, a menos que sepan que necesitarán reasignar el valor. Solo en ese caso, usan `let`.

## Array vs const

Es importante comprender que los objetos **(incluidos los arreglos y las funciones)** asignados a una variable mediante el uso `const` **siguen siendo mutables**. El uso de `const` solo evita la reasignación del identificador de variable.
  
Error:

```javascript
const miArray = []
miArray = ["nuevoElemento"]
```

Válido:

``` javascript
const miArray = []
miArray[0] = ["nuevoElemento"]
console.log(miArray)
```

## Métodos basicos Array (push, pop, shift, unshift)

El método `push()` añade uno o más elementos al final de un array y devuelve la nueva longitud del array.

```javascript
const frutas = ["Banana"]
frutas.push("Sandía")
console.log(frutas)
```

El método `unshift()` agrega uno o más elementos al inicio del array, y devuelve la nueva longitud del array.

```javascript
const frutas = ["Banana"]
frutas.unshift("Sandía")
console.log(frutas)
```

El método `pop()` elimina el último elemento de un array y lo devuelve. Este método cambia la longitud del array.

```javascript
const frutas = ["manzana", "pera"]

frutas.unshift("uva")

const frutaEliminada = frutas.pop()

console.log(frutas)
console.log(frutaEliminada)
```

El método shift() elimina el primer elemento del array y lo retorna. Este método modifica la longitud del array.

```javascript
const frutas = ["manzana", "pera"]

frutas.unshift("uva")

const frutaEliminada = frutas.shift()

console.log(frutas)
console.log(frutaEliminada)
```

## Funciones anónimas

En JavaScript, usualmente no necesitas nombrar tus funciones, especialmente cuando se pasa una función como argumento a otra función. En su lugar, creamos funciones inline (en línea). No necesitamos nombrar estas funciones porque no las reutilizamos en otro lugar.

- Función declarativa:

```javascript
// declaro la función
function numAleatorioRango(min, max) {
    return Math.floor(Math.random() * (max - min)) + min
}

// invoco la función
console.log(numAleatorioRango(1, 11))
```

- Función expresada:

Anónima (expresada en una variable):

```javascript
const miNumero = function (min, max) {
    return Math.floor(Math.random() * (max - min)) + min
}
console.log(miNumero(1, 11))
```

Diferencia declarativa vs Expresada:

```javascript
console.log(miNumero(1, 11))
const miNumero = function (min, max) {
    return Math.floor(Math.random() * (max - min)) + min
}
```
> La forma correcta de definir una función varía según el comportamiento que esperemos de la misma: **con las funciones declaradas, tenemos la seguridad de que siempre estarán disponibles en tiempo de ejecución**. Con las funciones expresadas, tendremos que éstas no son evaluadas hasta que el intérprete no alcance su posición en el código, lo cual puede generar errores en arquitecturas muy anidadas.  
> El hecho de que las funciones declarativas se evalúen antes que las expresiones, pueden producir comportamientos no deseados cuando forman parte de condicionales. Para estos casos, **el uso de las funciones expresadas garantiza que éstas formarán parte del flujo general del programa**, lo cual puede evitarnos sorpresa en determinados entornos.

## Arrow functions

- [Arrow functions](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Functions/Arrow_functions): Una expresión de función flecha es una alternativa compacta a una expresión de función tradicional

```javascript
const miNumeroFlecha = (max) => {
    return Math.floor(Math.random() * (max - 1)) + 1
}

console.log(miNumeroFlecha(11))
```

Reducción:

```javascript
const miNumeroFlecha = max => Math.floor(Math.random() * (max - 1)) + 1
        
console.log(miNumeroFlecha(11))
```

Reducción con paréntesis:

```javascript
const miNumeroFlecha = max => (Math.floor(Math.random() * (max - 1)) + 1)
        
console.log(miNumeroFlecha(11))
```

Más parámetros:

```javascript
const miNumeroFlecha = (min, max) => Math.floor(Math.random() * (max - min)) + min

console.log(miNumeroFlecha(1, 11))
```

Parámetros opcionales (también se puede hacer con function):

```javascript
const miNumeroFlecha = (min = 1, max = 10) => Math.floor(Math.random() * (max - min)) + min

console.log(miNumeroFlecha())
```

> Limitantes:
> - No tiene sus propios enlaces a this o super y no se debe usar como métodos.
> - No tiene argumentos o palabras clave new.target.
> - No apta para los métodos call, apply y bind, que generalmente se basan en establecer un ámbito o alcance
> - No se puede utilizar como constructor.

## Arrow & forEach()

- [forEach()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach): El método `forEach()` ejecuta la función indicada una vez por cada elemento del array.

```javascript
let frutas = ["manzana", "sandía", "pera"]
frutas.forEach(fruta => console.log(fruta))
```

```javascript
let frutas = ["manzana", "sandía", "pera"]
frutas.forEach((fruta, index, array) => {
    console.log(index)
    console.log(fruta)
    console.log(array)
})
```