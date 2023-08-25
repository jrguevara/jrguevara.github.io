---
title: ReactJS - parte 4
date: 2023-08-24 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, programacion]
published: true
hidden: false
---
## useEffect

[useEffect](https://es.reactjs.org/docs/hooks-effect.html): El Hook de efecto te permite llevar a cabo efectos secundarios en componentes funcionales.

**¿Qué hace `useEffect`?** Al usar este _Hook_, le estamos indicando a React que el componente tiene que hacer algo después de renderizarse. React recordará la función que le hemos pasado (nos referiremos a ella como nuestro “efecto”), y la llamará más tarde después de actualizar el DOM. En este efecto, actualizamos el título del documento, pero también podríamos hacer peticiones de datos o invocar alguna API imperativa.

**¿Por qué se llama a `useEffect` dentro del componente?** Poner `useEffect` dentro del componente nos permite acceder a la variable de estado `count` (o a cualquier prop) directamente desde el efecto. No necesitamos una API especial para acceder a ella, ya que se encuentra en el ámbito de la función. Los _Hooks_ aprovechan los closures de JavaScript y evitan introducir APIs específicas de React donde JavaScript ya proporciona una solución.

**¿Se ejecuta `useEffect` después de cada renderizado?** ¡Sí! Por defecto se ejecuta después del primer renderizado _y_ después de cada actualización. Más tarde explicaremos [cómo modificar este comportamiento](about:reader?url=https%3A%2F%2Fes.legacy.reactjs.org%2Fdocs%2Fhooks-effect.html#tip-optimizing-performance-by-skipping-effects). En vez de pensar en términos de “montar” y “actualizar”, puede resultarte más fácil pensar en efectos que ocurren “después del renderizado”. React se asegura de que el DOM se ha actualizado antes de llevar a cabo el efecto.

  

`App.jsx`

```jsx
import Header from "./components/Header";
import { useState } from "react";

const App = () => {
  const [contador, setContador] = useState(0);

  return (
    <div className="container">
      <Header />
      <div className="text-center">
        <button className="btn btn-info" onClick={() => setContador(contador + 1)}>
          Contador: {contador} </button>
      </div>
    </div>
  );
};

export default App;
```

  

Agregando `UseEffect`, el cual toma una función de callback como primer argumento y un array de dependencia como segundo.

> ¿Por qué veo dos logs?  
> Si ves que se repiten tus logs, es porque está activado strict mode en React. En producción no deberías verlo.  
> [más info stric mode](https://es.reactjs.org/docs/strict-mode.html)  
> 
> ```jsx
> //import React from 'react'
> import ReactDOM from 'react-dom/client'
> import App from './App.jsx'
> import './index.css'
> 
> ReactDOM.createRoot(document.getElementById('root')).render(
>   //<React.StrictMode>
>     <App />
>   //</React.StrictMode>,
> )
> ```
{: .prompt-info }    

  

**¿Cómo podemos hacer que `useEffect` se ejecute solo una vez?** Le pasamos un array vacío como segundo argumento.

```jsx
useEffect(() => {
  console.log("useEffect");
}, []);
```

  

¿como podemos hacer que `useEffect` este pendiente de algo?

```jsx
  useEffect(() => {
    console.log("useEffect");
  }, [contador]);
```

  
## fetch

Una de las funciones más importantes de useEffect es la de hacer peticiones a una API.

  

```jsx
import Header from "./components/Header";
import { useEffect, useState } from "react";

const App = () => {
  const [contador, setContador] = useState(0);
  const [data, setData] = useState([]);
  console.log("App");

  useEffect(() => {
    console.log("useEffect");
    fetch("https://jsonplaceholder.typicode.com/users")
      .then((response) => response.json())
      .then((data) => setData(data));
  }, []);

  if (!data) return <p>Cargando datos...</p>; 

  return (
    <div className="container">
      <Header />
      <div className="text-center">
        <button className="btn btn-info" onClick={() => setContador(contador + 1)}>
          Contador: {contador} </button>
      </div>
      <hr></hr>
      <ul>
        {data.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
};

export default App;
```

  

## async await

También podemos usar async await para hacer peticiones a una API. Pero para ello necesitamos una función async.

  

El problema:

```jsx
  useEffect(async () => {
    console.log("useEffect");
    const response = await fetch("https://jsonplaceholder.typicode.com/users");

    const data = await response.json();
    setData(data);
  }, []);
```

  

> DANGER
> 
> Parece que escribiste useEffect(async () => ...) o devolviste una Promesa. En su lugar, escribe la función asíncrona dentro de tu efecto y llámala inmediatamente.
> 
> useEffect debe devolver una función de limpieza o nada.
> 
> El problema aquí es que se supone que el primer argumento de useEffect es una función que no devuelve nada (undefined) o una función (para limpiar los efectos secundarios). ¡**Pero una función asíncrona devuelve una Promesa**, que no se puede llamar como una función! Simplemente no es lo que el useEffect espera para su primer argumento.
> 
> [más info](https://devtrium.com/posts/async-functions-useeffect)
> 
{: .prompt-danger } 

  

Solución:

```jsx
  useEffect(() => {
    console.log("useEffect");
    const fetchData = async () => {
        const response = await fetch(
          "https://jsonplaceholder.typicode.com/users"
        );
        const data = await response.json();
        setData(data);
    };
    fetchData();
  }, []);
```

  

  

Solución con try y catch:

```jsx
  useEffect(() => {
    console.log("useEffect");
    const fetchData = async () => {
      try {
        const response = await fetch(
          "https://jsonplaceholder.typicode.com/users"
        );
        if (!response.ok) {
          throw "Error al conectar la API";
        }
        const data = await response.json();
        setData(data);
      } catch (error) {
        console.log(error);
        setData([]);
      }
    };
    fetchData();
  }, []);
```

  

## Extraer función

```jsx
import Header from "./components/Header";
import { useEffect, useState } from "react";

const App = () => {
  const [contador, setContador] = useState(0);
  const [data, setData] = useState([]);
  console.log("App");

  const fetchData = async () => {
    try {
      const response = await fetch("https://jsonplaceholder.typicode.com/users");
      if (!response.ok) {
        throw "Error al conectar la API";
      }
      const data = await response.json();
      setData(data);
    } catch (error) {
      console.log(error);
      setData([]);
    }
  };

  useEffect(() => {
    console.log("useEffect");
    fetchData();
  }, []);

  if (!data) return <p>Cargando datos...</p>;

  return (
    <div className="container">
      <Header />
      <div className="text-center">
        <button className="btn btn-info" onClick={() => setContador(contador + 1)}>
          Contador: {contador} </button>
      </div>
      <hr></hr>
      <ul>
        {data.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
};

export default App;
```

  

> WARNING  
> Nuevamente una advertencia: Cada vez que el componente se renderize se creará la función fetchData. Si no queremos que se cree cada vez, podemos usar useCallback.
{: .prompt-warning } 
  

## useCallBack

useCallback es un hook que nos permite memorizar una función. Esto quiere decir que si la función que le pasamos como argumento no ha cambiado, useCallback no la volverá a crear.

Necesitas pasar dos cosas a useCallback:

- Una definición de función que desea almacenar en caché entre renderizaciones.
- Una lista de dependencias que incluye cada valor dentro de su componente que se usa dentro de su función.

> ¡No es necesario useCallback!  
> Estos ejemplos son para explicar el concepto, **pero no es necesario usar useCallback en este caso.**, ya que no tiene un gran impacto en el rendimiento. Pero es bueno saberlo para cuando lo necesites.  
> [Más info aquí](https://beta.reactjs.org/reference/react/useCallback)
{: .prompt-tip } 
  

```jsx
import Header from "./components/Header";
import { useEffect, useState, useCallback } from "react";

const App = () => {
  const [contador, setContador] = useState(0);
  const [data, setData] = useState([]);
  console.log("App");

  const fetchData = useCallback (async () => {
    try {
      const response = await fetch("https://jsonplaceholder.typicode.com/users");
      if (!response.ok) {
        throw "Error al conectar la API";
      }
      const data = await response.json();
      setData(data);
    } catch (error) {
      console.log(error);
      setData([]);
    }
  }, []);

  useEffect(() => {
    console.log("useEffect");
    fetchData();
  }, [fetchData]);

```