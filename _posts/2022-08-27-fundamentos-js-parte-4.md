---
title: Fundamentos JavaScript - parte 4
date: 2022-08-27 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## Métodos avanzados Array

- **Estos métodos no mutan el array original**, sino que nos devuelven uno nuevo.

### map

- [map](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/map): El método map iterará sobre cada elemento de un arreglo y devuelve un nuevo arreglo que contiene los resultados de llamar a la **función callback** en cada elemento. Esto lo hace sin mutar el arreglo original.

> Una función de callback es una función que se pasa a otra función como un argumento, que luego se invoca dentro de la función externa para completar algún tipo de rutina o acción.
  
Cuando se utiliza la función callback, se pasan tres argumentos. El primer argumento es el elemento actual que se está procesando. El segundo es el índice de ese elemento y el tercero es el arreglo al que se llamó el método map.  

```javascript
const frutas = ["banana", "manzana", "pera"];

const nuevoArray = frutas.map((item) => {
    return item;
});

console.log(nuevoArray);
```

Reduciendo el código:

```javascript
const frutas = ["banana", "manzana", "pera"];
const nuevoArray = frutas.map((item) => item);
console.log(nuevoArray);
```

¿Pero no es lo mismo que esto?

```javascript
const frutas = ["banana", "manzana", "pera"];
// por referencia (revisar videos anteriores)
const arrayReferencia = frutas; 
frutas.push("sandia");
console.log(arrayReferencia);

// construye un nuevo array con los resultados
// esto lo hace sin mutar el arreglo original
const nuevoArray = frutas.map((item) => item);
frutas.push("sandia");
console.log(nuevoArray);
```

Devolver solo el name en un nuevo array

```javascript
const users = [
    { name: "Juan", age: 34 },
    { name: "Amy", age: 20 },
    { name: "James", age: 10 },
];

const names = users.map((user) => user.name);
console.log(names);
```

Devolver nuevo array con numeros \* 2

```javascript
const numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const numerosPorDos = numeros.map((item) => item * 2);

console.log(numerosPorDos);
```
### filter

- [filter](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/filter): El método `filter()` crea un nuevo array con todos los elementos que cumplan la condición implementada por la función dada.

```javascript
const users = [
    { uid: 1, name: "John", age: 34 },
    { uid: 2, name: "Amy", age: 20 },
    { uid: 3, name: "camperCat", age: 10 },
];

const mayor = users.filter((user) => user.age > 30);
console.log(mayor);
```

Eliminar un usuario por uid

```javascript
const users = [
    { uid: 1, name: "John", age: 34 },
    { uid: 2, name: "Amy", age: 20 },
    { uid: 3, name: "camperCat", age: 10 },
];

const userFiltrado = users.filter((user) => user.uid !== 2);

console.log(userFiltrado);
```

### find

- [find](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/find): El método `find()` devuelve el valor del primer elemento del array que cumple la función de prueba proporcionada.

Buscar usuario por uid:

```javascript
const users = [
    { uid: 1, name: "John", age: 34 },
    { uid: 2, name: "Amy", age: 20 },
    { uid: 3, name: "camperCat", age: 10 },
];

const amy = users.find((user) => user.uid === 2);
console.log(amy);
```

Utilizando [desestructuración](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment)

```javascript
const { age } = users.find((user) => user.uid === 2);
console.log(age);
```

### some

- [some](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/some): El método `some()` comprueba si al menos un elemento del array cumple con la condición implementada por la función proporcionada.

```javascript
const users = [
    { uid: 1, name: "John", age: 34 },
    { uid: 2, name: "Amy", age: 20 },
    { uid: 3, name: "camperCat", age: 10 },
];

const existe = users.some((user) => user.uid === 2);
console.log(existe);
```

### findIndex

- [findIndex](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex): El método `findIndex()` devuelve el índice del primer elemento de un array que cumpla con la función de prueba proporcionada. En caso contrario devuelve -1.

```javascript
const users = [
    { uid: 1, name: "John", age: 34 },
    { uid: 2, name: "Amy", age: 20 },
    { uid: 3, name: "camperCat", age: 10 },
];

const existe = users.findIndex((user) => user.uid === 4);
console.log(existe);
```

### slice

- [slice](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/slice): El método `slice()` devuelve una copia de una parte del array dentro de un nuevo array empezando por inicio hasta fin **(fin no incluido)**. El array original no se modificará.

```javascript
const arr = ["Cat", "Dog", "Tiger", "Zebra"];
//             0     [1      2]        3
const newArray = arr.slice(1, 3);

console.log(newArray);
```

### concat

- [concat](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/concat): El método `concat()` se usa para unir dos o más arrays. Este método no cambia los arrays existentes, sino que devuelve un nuevo array.

```javascript
const array1 = ["a", "b", "c"];
const array2 = ["d", "e", "f"];
const array3 = array1.concat(array2);

console.log(array3);
```

- [Spread syntax](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/Spread_syntax): **permite a un elemento iterable** tal como un arreglo o cadena **ser expandido** en lugares donde son esperados.

```javascript
const array1 = ["a", "b", "c"];
const array2 = ["d", "e", "f"];
const array3 = [...array1, ...array2];

console.log(array3);
```

### reduce

- [reduce](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce): El método reduce() ejecuta una función reductora sobre cada elemento de un array, devolviendo como resultado un único valor.

Sumar todos los números:

```javascript
const numeros = [1, 2, 3, 4, 5];

const sumaTodos = numeros.reduce((acc, valorActual) => acc + valorActual);

console.log(sumaTodos);
```

Aplanar matrices anidadas #01:

```javascript
const arrayNumeros = [
    [0, 1],
    [2, 3],
    [4, 5],
];

const soloNumeros = arrayNumeros.reduce(
    (acc, current) => acc.concat(current)
);

console.log(soloNumeros);
```

Aplanar matrices anidadas #02:

```javascript
const flatSingle = [].concat(...arrayNumeros);
console.log(flatSingle);
```

Aplanar matrices anidadas #03: [flat()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/flat)

```javascript
const flatSingle = arrayNumeros.flat();
console.log(flatSingle);
```
 
```javascript
const arrayNumeros = [1, 2, [3, 4, [5, 6]]];

const arrayPlano = arrayNumeros.flat(2);
console.log(arrayPlano);
```

### split

- [split](https://bluuweb.github.io/desarrollo-web-bluuweb/11-06-js-paradigma/#imperativa-vs-declarativa): El método `split()` divide un objeto de tipo String en un array, mediante un separador.

```javascript
const cadenaMeses = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";

const arrayMeses = cadenaMeses.split(",");
console.log(arrayMeses);
```
### join

- [join](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Array/join): el método `join()` une todos los elementos de una matriz (o un objeto similar a una matriz) en una cadena y devuelve esta cadena.

```javascript
const cadenaMeses = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";

const arrayMeses = cadenaMeses.split(",");
console.log(arrayMeses);

const nuevamenteString = arrayMeses.join(",");
console.log(nuevamenteString);
```

Separador: Es una cadena usada para separar cada uno de los elementos del arreglo. El separador es convertido a una cadena si es necesario. **Si este se omite, los elementos del arreglo son separados con una coma (",")**.


## Objetos

- JavaScript está diseñado en un paradigma simple basado en [objetos](https://developer.mozilla.org/es/docs/Web/JavaScript/Guide/Working_with_Objects)
- Un objeto es una colección de propiedades, y una propiedad es una asociación entre un nombre (o clave) y un valor.
- **El valor de una propiedad puede ser una función**, en cuyo caso la propiedad es conocida como un método.
- Además de los objetos que están predefinidos en el navegador, puedes definir tus propios objetos.
- Los objetos son similares a los arreglos (arrays), **excepto que en lugar de usar índices** para acceder y modificar sus datos, **accedes a los datos en objetos a través de propiedades** (properties).

  

## Objeto literal

- Se denomina objeto literal al objeto cuyas propiedades están declaradas textualmente en el código.

```javascript
const gato = {
    nombre: 'Michi',
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"]
}
```

## Acceder a los valores

Notación de punto:  

```javascript
console.log(gato.nombre)
console.log(gato.duerme)
console.log(gato.enemigos[0]);
```

Notación de corchetes (nos servirá para recorrerlo):

```javascript
console.log(gato['nombre'])
console.log(gato['edad'])
console.log(gato["enemigos"][0]);
```

## CRUD (propiedades)

Crear (create)  

```javascript
gato.color = 'Blanco'
```

Leer (read)

```javascript
console.log(gato)
```

Actualizar (update)

```javascript
gato.edad = 11
```

Eliminar (delete)

```javascript
delete gato.duerme
```

## hasOwnProperty

A veces es útil comprobar si existe o no la propiedad de un objeto dado. Podemos utilizar el método `.hasOwnProperty(propname)` para determinar si un objeto tiene una propiedad con ese nombre. `.hasOwnProperty()` devuelve `true` o `false` si se encuentra la propiedad o no.

```javascript
const gato = {
    nombre: 'Michi',
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"]
}

console.log(gato.hasOwnProperty("nombre"))
console.log(gato.hasOwnProperty("salud"))
```

## Objetos anidados

```javascript
const gato = {
    nombre: 'Michi',
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    otros: {
        amigos: ["Pelusa", "Bombi", "Milo"],
        favoritos: {
            comida: {
                fria: "salmón",
                caliente: "pollo"
            }
        }
    }
}
```

Acceder:

```javascript
console.log(gato.otros.amigos[0])
console.log(gato.otros.favoritos.comida.fria)
```

## Encadenamiento opcional

- [Optional chaining](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/Optional_chaining): El operador de encadenamiento opcional `?.` permite leer el valor de una propiedad ubicada dentro de una cadena de objetos conectados sin tener que validar expresamente que cada referencia en la cadena sea válida.

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
};
console.log(gato.otros.favoritos);
```
Encadenamiento opcional: resultado undefined.

```javascript
console.log(gato.otros?.favoritos);
```
## Propiedad

Propiedades:

```javascript
const frutas = ["sandía", "pera", "melon"];
console.log(frutas.length);
```

Métodos:

```javascript
const frutas = ["sandía", "pera", "melon"];
frutas.push("banana");
console.log(frutas);
```

## Métodos

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer: function (
) {
        console.log("Ahora está comiendo");
    },
};

gato.comer();
```

Reducido:
```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(
) {
        console.log("Ahora está comiendo");
    },
};

gato.comer();
```
  
Con parámetros:
```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return "Ahora está comiendo: " + comida;
    },
};

console.log(gato.comer("atun"));
```

¿Qué pasará con esto?

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${nombre} está comiendo ${comida}`;
    },
};

console.log(gato.comer("atun"));
```

  

Lo está buscando en el **objeto global**

```javascript
const nombre = "Milo";

const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${nombre} está comiendo ${comida}`;
    },
};

console.log(gato.comer("atun"));
```

Objeto `this`:

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        console.log(this);
    },
};

gato.comer("atun");
```

## this

- [this](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/this): Hace referencia al objeto **contexto** de JavaScript **en el cual se está ejecutando el código actual**  
    

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${this.nombre} está comiendo ${comida}`;
    },
};

console.log(gato.comer("atun"));
```

  

### this con arrow function

¿Error?

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer: (comida) => {
        return `${this.nombre} está comiendo ${comida}`;
    },
};

console.log(gato.comer("pez"));
```

Arrow Functions

- **No tiene this** o super y **no se debe usarla como métodos.**
- Pero si puedo utilizarla en su interior:

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${this.nombre} está comiendo ${comida}`;
    },
    mostrarEnemigos(
) {
        return this.enemigos.forEach((item) => console.log(item));
    },
};

gato.mostrarEnemigos();
```

## Recorrer un objeto

### for...in

- [for in](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/for...in): La instrucción for-in itera sobre todas las propiedades enumerables de un objeto que está codificado por cadenas

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
};

for (const propiedad in gato) {
    console.log(gato[propiedad]);
}
```

### ¿Por qué usar for...in?

- Dado que for...in está construido para **iterar propiedades de objeto**, no se recomienda su uso con arreglos y opciones como Array.prototype.forEach() y existe for...of, ¿cuál podría ser el uso de for...in?
- Es posible que **se utilice de forma más práctica con fines de depuración**, ya que es una forma fácil de comprobar las propiedades de un objeto (mediante la salida a la consola o de otro modo)
- Aunque los arreglos suelen ser más prácticos para almacenar datos, en situaciones en las que se prefiere un par clave-valor para trabajar con datos (con propiedades que actúan como la "clave"), puede haber casos en los que desees comprobar si alguna de esas claves cumple un valor particular.

### Object.values()

- [Object.values()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Object/values): devuelve un array con los valores correspondientes a las propiedades enumerables de un objeto.

```javascript
console.log(Object.values(gato));
```

Con forEach()

```javascript
Object.values(gato).forEach((item) => console.log(item));
```

Existen más métodos como:

- [Object.entries()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Object/entries)
- [Object.key()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Object/keys)
- [Object.getOwnPropertyNames()](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyNames)

## Desestructuración de Objectos

- [desestructuración](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment): La sintaxis de desestructuración es una expresión de JavaScript que permite desempacar valores de arreglos o propiedades de objetos en distintas variables.

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    otros: {
        amigos: ["Pelusa", "Bombi", "Milo"],
        favoritos: {
            comida: {
                fria: "salmón",
                caliente: "pollo",
            },
        },
    },
};

const nombreGato = gato.nombre;
console.log(nombreGato);
```

Desestructura de objetos:

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    otros: {
        amigos: ["Pelusa", "Bombi", "Milo"],
        favoritos: {
            comida: {
                fria: "salmón",
                caliente: "pollo",
            },
        },
    },
};

const { nombre, duerme, edad, enemigos } = gato;
console.log(nombre);
console.log(duerme);
console.log(edad);
console.log(enemigos);
```

Alias:

```javascript
const { nombre: nombreGato } = gato;
console.log(nombreGato);
```

Por defecto:

```javascript
const gato = {
    // nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    otros: {
        amigos: ["Pelusa", "Bombi", "Milo"],
        favoritos: {
            comida: {
                fria: "salmón",
                caliente: "pollo",
            },
        },
    },
};

const { nombre: nombreGato = "Sin nombre" } = gato;
console.log(nombreGato);
```

Anidados:

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    otros: {
        amigos: ["Pelusa", "Bombi", "Milo"],
        favoritos: {
            comida: {
                fria: "salmón",
                caliente: "pollo",
            },
        },
    },
};

const {
    otros: { amigos },
} = gato;
console.log(amigos);
```

Con Array: La desestructuración también sirve para Array, solo reemplazar por `[]`

```javascript
const enemigos = ["agua", "perros"]
const [agua, perro] = enemigos;
console.log(agua);
console.log(perro);

```

Métodos:

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${this.nombre} está comiendo ${comida}`;
    },
    mostrarEnemigos(
) {
        return this.enemigos.forEach((item) => console.log(item));
    },
};

const { comer } = gato;
console.log(comer("pescado"));

// undefined está comiendo pescado
```

## Getters y Setters

- [infdrmacion de setters y getters](https://developer.mozilla.org/es/docs/Web/JavaScript/Guide/Working_with_Objects#definici%C3%B3n_de_captadores_getters_y_establecedores_setters)
- [get](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Functions/get): Enlaza la propiedad de un objeto con una función que será llamada cuando la propiedad es buscada.
- [set](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Functions/set): La sintaxis set asocia la propiedad de un objeto a una función que será llamada cuando haya un intento de asignar valor a esa propiedad.

GET: Tomar en cuenta lo siguiente al trabajar con la sintaxis get:

- Debe tener exactamente cero parámetros.
- No debe haber múltiples getters para una misma propiedad.

SET: Tomaren cuenta lo siguiente al trabajar con setters:

- Debe tener exactamente un parámetro

```javascript
const gato = {
    nombre: "Michi",
    duerme: true,
    edad: 10,
    enemigos: ["agua", "perros"],
    comer(comida) {
        return `${this.nombre} está comiendo ${comida}`;
    },
    get nombreMayuscula() {
        return this.nombre.toUpperCase();
    },
    set nuevoEnemigo(nuevo) {
        this.enemigos.push(nuevo);
    },
};

// GET
console.log(gato.nombreMayuscula);

// SET
gato.nuevoEnemigo = "batman";
console.log(gato.enemigos);
```

## por valor vs por referencia

- [Referencia](https://medium.com/laboratoria-developers/por-valor-vs-por-referencia-en-javascript-de3daf53a8b9)

- **por valor:** Cuando asignamos valores primitivos (Boolean, Null, Undefined, Number, String y Symbol), el valor asignado es una copia del valor que estamos asignando.
- **por referencia:** Pero cuando asignamos valores NO primitivos o complejos (Object, Array y Function), JavaScript copia “la referencia”, lo que implica que no se copia el valor en sí, si no una referencia a través de la cual accedemos al valor original.

Primitivos: (por valor)

```javascript
let a = "hola";
let b = a;
console.log(b);
```

Si cambiamos el valor de a, b sigue siendo "hola"

```javascript
a = "chao";
console.log(b);
```
No primitivos: (por referencia)

```javascript
let a = ["hola"];
let b = a;
console.log(b);
```

```javascript
let a = ["hola"];
let b = a;

a.push("chao");

console.log(b);
```

Lo mismo pasa con los objetos:

```javascript
const a = {
    nombre: "hola",
};

const b = a;

a.nombre = "chao";

console.log(b);
```