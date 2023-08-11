---
title: ReactJS - parte 2
date: 2023-08-10 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, programacion]
published: true
hidden: false
---

## Manejando eventos

- [eventos](https://es.reactjs.org/docs/handling-events.html)
- Los eventos de React se nombran usando camelCase, en vez de minúsculas.
- Con JSX pasas una función como el manejador del evento, en vez de un string

```jsx
const MiBoton = ({ text, className }) => {
  const handleClick = (text) => {
    console.log("Haz dado click al " + text );
  };

  return (
    <button onClick={() => handleClick(text)} className={className}>
      {text}
    </button>
  );
};

MiBoton.propTypes = {
  text: PropTypes.string.isRequired,
  className: PropTypes.string.isRequired,
};
```

## Componentes (modularizar)

- [components](https://es.reactjs.org/docs/components-and-props.html)
- Los componentes permiten separar la interfaz de usuario en piezas independientes, reutilizables y pensar en cada pieza de forma aislada.

Crear en carpeta `src` una carpeta llamada `components` donde se colocaran todos los componentes

`components/MiBoton.jsx`

```jsx
import PropTypes from "prop-types";

const MiBoton = ({ text, className }) => {
    const handleClick = (text) => {
        console.log("Haz dado click al " + text);
    };

    return (
        <button onClick={() => handleClick(text)} className={className}>
            {text}
        </button>
    );
};

MiBoton.propTypes = {
    text: PropTypes.string.isRequired,
    className: PropTypes.string.isRequired,
};

export default MiBoton;

```

  

`components/MensajeOnline.jsx`

```jsx
const MensajeOnline = () => {
    return <h3>Bienvenido usuario</h3>;
};

export default MensajeOnline;

```

  

`components/MensajeOffline.jsx`

```jsx
const MensajeOffline = () => {
    return <h3>Usuario desconectado</h3>;
};

export default MensajeOffline;

```

  

`components/UserMensaje.jsx`

```jsx
import PropTypes from 'prop-types';
import MensajeOnline from './MensajeOnline';
import MensajeOffline from './MensajeOffline';

const UserMensaje = ({ usuario }) => {
    return usuario ? <MensajeOnline /> : <MensajeOffline />;
    //return <h3> { usuario ? ( "Bienvenido usuario" ) : ( "Usuario desconectado" ) } </h3>
};

UserMensaje.propTypes = {
    usuario: PropTypes.bool.isRequired,
};

export default UserMensaje;

```

  

`components/ListaFrutas.jsx`

```jsx
import PropTypes from 'prop-types';

const ListaFrutas = ({ frutas }) => {
    //const frutas = ["🍉", "🍌", "🍎"];

    return (
        <ul>
            {frutas.map((fruta, index) => {
                return (
                    <li key={index}>
                        {" "}
                        {index} - {fruta}
                    </li>
                );
            })}
        </ul>
    );
}

ListaFrutas.propTypes = {
    frutas: PropTypes.array.isRequired,
};

export default ListaFrutas;

```

  

  

`App.jsx`

```jsx
import MiBoton from "./components/MiBoton";
import UserMensaje from "./components/UserMensaje";
import ListaFrutas from "./components/ListaFrutas";

const App = () => {
  const titulo = "Mi primer proyecto con React.JS";
  const subtitulo = "Lorem ipsum dolor sit amet consectetur adipisicing elit";
  const imagen = "https://picsum.photos/600/400";
  const logo = "./src/assets/react.svg";
  const clases = {
    titulo: "text-info text-center",
    subtitulo: "text-info text-center",
    imagenCenter: "rounded d-block mx-auto",
  };
  const user = true;

  const frutas = ["🍉", "🍌", "🍎"];
  const frutas2 = ["🍐", "🍑", "🍓"];

  return (
    <div className="container">
      <h1 className={clases.titulo}>{titulo}</h1>
      <p className={clases.subtitulo}>{subtitulo}</p>
      <img className={clases.imagenCenter} src={logo} />
      <hr></hr>
      <img
        className={clases.imagenCenter}
        src={imagen}
        alt={`imagen-${titulo}`}
      />
      <hr></hr>
      <UserMensaje usuario={user} />
      <hr></hr>
      <MiBoton text="Boton 1" className="btn btn-light m-3" />
      <MiBoton text="Boton 2" className="btn btn-danger m-3" />
      <MiBoton text="Boton 3" className="btn btn-warning m-3" />
      <MiBoton text="Boton 4" className="btn btn-success m-3" />
      <hr></hr>
      <ListaFrutas frutas={frutas}/>
      <ListaFrutas frutas={frutas2}/>
    </div>
  );
};

export default App;

```

> Fragmentos:  
> [fragment](https://es.reactjs.org/docs/fragments.html): Un patrón común en React es que un componente devuelva múltiples elementos. Los Fragmentos te permiten agrupar una lista de hijos sin agregar nodos extra al DOM.
{: .prompt-tip } 

`App.jsx`

```jsx
import MiBoton from "./components/MiBoton";
import UserMensaje from "./components/UserMensaje";
import ListaFrutas from "./components/ListaFrutas";
import React from "react";

const App = () => {
  const titulo = "Mi primer proyecto con React.JS";
  const subtitulo = "Lorem ipsum dolor sit amet consectetur adipisicing elit";
  const imagen = "https://picsum.photos/600/400";
  const logo = "./src/assets/react.svg";
  const clases = {
    titulo: "text-info text-center",
    subtitulo: "text-info text-center",
    imagenCenter: "rounded d-block mx-auto",
  };
  const user = true;

  const frutas = ["🍉", "🍌", "🍎"];
  const frutas2 = ["🍐", "🍑", "🍓"];

  return (
    <React.Fragment>
      <h1 className={clases.titulo}>{titulo}</h1>
      <p className={clases.subtitulo}>{subtitulo}</p>
      <img className={clases.imagenCenter} src={logo} />
      <hr></hr>
      <img
        className={clases.imagenCenter}
        src={imagen}
        alt={`imagen-${titulo}`}
      />
      <hr></hr>
      <UserMensaje usuario={user} />
      <hr></hr>
      <MiBoton text="Boton 1" className="btn btn-light m-3" />
      <MiBoton text="Boton 2" className="btn btn-danger m-3" />
      <MiBoton text="Boton 3" className="btn btn-warning m-3" />
      <MiBoton text="Boton 4" className="btn btn-success m-3" />
      <hr></hr>
      <ListaFrutas frutas={frutas}/>
      <ListaFrutas frutas={frutas2}/>
    </React.Fragment>
  );
};

export default App;

```

  

## Estado

- El estado le permite a los componentes de React cambiar su salida a lo largo del tiempo en respuesta a acciones del usuario, respuestas de red y cualquier otra cosa.
- [state](https://es.reactjs.org/docs/state-and-lifecycle.html)
- Nada le indica a React que tenemos que volver a renderizar para pintar nuevamente button.
- Para hacer cambios vamos a utilizar un hook.

  

`components/BotonState.jsx`

```jsx
const BotonState = () => {
    let contador = 0;

    const handleClick = () => {
        contador = contador + 1;
        console.log("Contador: " + contador);
    };

    return (
        <div className="text-center">
            <button onClick={handleClick} className="btn btn-info">Contador: {contador}</button>
        </div>
    );
};

export default BotonState;

```

  

## Hooks

- [hooks](https://es.reactjs.org/docs/hooks-overview.html)
- Los Hooks son funciones que te permiten “enganchar” el estado de React y el ciclo de vida desde componentes de función.
- Los hooks no funcionan dentro de las clases — te permiten usar React sin clases.
- React proporciona algunos Hooks incorporados como useState.
- También puedes crear tus propios Hooks para reutilizar el comportamiento con estado entre diferentes componentes.

  

## useState

- [useState](https://es.reactjs.org/docs/hooks-state.html)

### ¿Qué hace la llamada a useState?

- Declara una “variable de estado”.
- useState es una nueva forma de usar exactamente las mismas funciones que `this.state` nos da en una clase.
- Normalmente, las variables “desaparecen” cuando se sale de la función, pero las variables de estado son conservadas por React.

### ¿Qué pasamos a useState como argumento?

- El único argumento para el Hook useState() es el estado inicial.

### ¿Qué devuelve useState?

- Devuelve una pareja de valores (array): el estado actual y una función que lo actualiza.

  

`components/BotonState.jsx`

```jsx
import { useState } from "react";

const BotonState = () => {
    const [contador, setContador] = useState(0);

    const handleClick = () => {
        setContador(contador + 1);
        console.log("Contador: " + contador);
    };

    return (
        <div className="text-center">
            <button onClick={handleClick} className="btn btn-info">Contador: {contador}</button>
        </div>
    );
};

export default BotonState;

```

  

### Resumen:

- Declaramos una variable de estado llamada contador y le asignamos a 0.
- React recordará su valor actual entre re-renderizados, y devolverá el valor más reciente a nuestra función.
- Si se quiere actualizar el valor de contador actual, podemos llamar a setContador.
- Cuando el usuario hace click, llamamos a setContador con un nuevo valor. React actualizará entonces el componente Contador pasándole el nuevo valor de contador.
- Nota los corchetes son intaxis de Javascript, se llama “desestructuración de arrays”.