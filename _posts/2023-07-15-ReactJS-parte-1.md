---
title: ReactJS
date: 2023-07-15 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, programacion]
published: true
hidden: false
---

## ¿Qué es ReactJS?

![ReactJS](/assets/images/react.png)_ReactJS_  

## Recursos

- [es.reactjs.org](https://es.reactjs.org/)
- [beta.reactjs](https://beta.reactjs.org/learn)
- [vitejs](https://vitejs.dev/)
- [getting-started](https://es.reactjs.org/docs/getting-started.html)
- [tutorial](https://es.reactjs.org/tutorial/tutorial.html)
- [create-react-app](https://create-react-app.dev/)
- [getting-started-with-react](https://www.taniarascia.com/getting-started-with-react/)
- [es7 react js snippets](https://marketplace.visualstudio.com/items?itemName=dsznajder.es7-react-js-snippets)

  

## ¿Qué es React?

- React es una biblioteca Javascript para crear interfaces de usuario.
- React no es un framework (a diferencia de Angular o Vue, que tienen más opiniones).
- React es un proyecto de código abierto creado por Facebook.
- Está basado en componentes.

### Componentes

Uno de los aspectos más importantes de React es el hecho de que puede crear componentes, que son como elementos HTML personalizados y reutilizables, para construir interfaces de usuario de manera rápida y eficiente. React también agiliza la forma en que se almacenan y manejan los datos, utilizando el estado y los accesorios.

  

## Requisitos

- [node js](https://nodejs.org/es/): es un entorno en tiempo de ejecución multiplataforma, de código abierto, para la capa del servidor (pero no limitándose a ello) basado en el lenguaje de programación JavaScript.
- [npm](https://www.npmjs.com/): NPM (Node Package Manager) es un gestor de paquetes desarrollado en su totalidad bajo el lenguaje JavaScript por Isaac Schlueter, a través del cual podemos obtener cualquier librería con tan solo una sencilla línea de código, lo cual nos permitirá agregar dependencias de forma simple, distribuir paquetes y administrar eficazmente tanto los módulos como el proyecto a desarrollar en general.

## ¿Qué es un módulo?

- Un módulo no es nada más que una unidad de código organizado en archivos o directorios, la cual puede ser exportada con facilidad para poder reutilizarse en otras partes de la aplicación.
- External modules: Son, en esencia, los paquetes de terceros distribuidos a través de npm (aunque pueden provenir de otros repositorios). Estos paquetes se instalan como dependencias y, aunque aportan funcionalidad a la aplicación, no deben incluirse en el repositorio ya que no son parte de la misma.

  

## Instalación

- Vite.js
- CRA create react app

## Vite

- [Vite web oficial](https://vitejs.dev/): Vite se define como una herramienta de frontend que te ayudará a crear proyectos (sin atarte a ningún framework concreto) y que su desarrollo y construcción final sea lo más sencilla posible.
- Está desarrollada por Evan You, el creador de Vue.
- Actualmente, Vite soporta tanto proyectos vanilla (sin utilizar frameworks), como proyectos utilizando Vue, React, Preact o Lit-element (tanto en versión Javascript, como Typescript). [Fuente](https://lenguajejs.com/automatizadores/vite/guia-tutorial-inicial-de-vite/)
- [Templates](https://github.com/vitejs/awesome-vite#templates)
- [Comunidad DEV](https://dev.to/t/vite)

  

```powershell
npm create vite@latest
```

  

## CRA - create-react-app

- [create-react-app](https://create-react-app.dev/) Afortunadamente, Facebook ha creado la aplicación Create React App, un entorno que viene preconfigurado con todo lo necesario para crear una aplicación React.
- Creará un servidor de desarrollo en vivo.
- No es necesario instalar ni configurar herramientas como webpack o Babel. Están preconfigurados y ocultos para que pueda concentrarse en el código.
- Ventaja: enfocarse en el código, no en las herramientas de compilación.

```powershell
npx create-react-app my-app
cd my-app
npm start

```

  

> npx
> 
> - Npx es una herramienta de cli que nos permite ejecutar paquetes de npm, los busca en su servidor y lo ejecuta en nuestra máquina.
> 
> - Si usas npx no tienes que instalar paquetes de forma global.
> 
> - Busca siempre la última versión.
{: .prompt-tip }
  

> Advertencia:  
> Si ha instalado previamente `create-react-app globalmente` a través de: `npm install -g create-react-app`, le recomendamos que desinstale el paquete usando `npm uninstall -g create-react-app` o `yarn global remove create-react-app` para asegurarse de que `npx` siempre usa la última versión.
{: .prompt-warning }
  

## CRA vs Vite

- Vite y CRA no son tan diferentes como podría pensar. Básicamente, hacen más o menos lo mismo, que es servir a un servidor de desarrollo local y agrupar códigos para la producción.
- La principal diferencia que notará es cómo se sirve el código en el desarrollo y qué módulos son compatibles.
- Vite no necesita agrupar la aplicación completa o transpilar los módulos y el código antes de iniciar un servidor de desarrollo; la transpilación se realiza bajo demanda, lo que la hace significativamente más rápida que CRA.

  

## Creación de componente principal

Los componentes no son mas que funciones que son exportadas

```jsx
const App = () => {
    return <h1>Hola desde React.js</h1>
}
```

  

Exportaciones por Defecto solo permiten exportar una función del archivo en cuestión.

```jsx
const App = () => {
    return <h1>Hola desde React.js</h1>
}

export default App

```

  

Exportaciones nombradas permiten exportar varias funciones de un mismo archivo.  

```jsx
export const App = () => {
    return <h1>Hola desde React.js</h1>
}

```

  

El Componente App es exportado al archivo `main.jsx`  

```jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx' //Exportacion defecto
//import { App } from './App.jsx' //Exportacion nombrada
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

  

## JSX: JavaScript + XML

- Como ha visto, hemos estado usando lo que parece HTML en nuestro código React, pero no es HTML del todo. Esto es JSX , que significa JavaScript XML.
- El uso de JSX no es obligatorio para escribir React.
- Debajo del capó, se está ejecutando `createElement`, lo que toma la etiqueta, las propiedades y los elementos secundarios del componente y muestra la misma información.
- JSX está más cerca de JavaScript, no de HTML, por lo que hay algunas diferencias clave a tener en cuenta al escribirlo.
    - `className` se usa en lugar de `class` para agregar clases CSS, ya que `class` es una palabra clave reservada en JavaScript.
    - Las propiedades y métodos en JSX son camelCase.
    - Las etiquetas de cierre automático deben terminar en una barra inclinada,Ej. `<img />`
    - Su componente tampoco puede devolver varias etiquetas JSX. Tienes que envolverlos en un padre compartido, como un envoltorio `<div>...</div>` vacío o: `<>...</>`

Las expresiones de JavaScript también se pueden incrustar dentro de JSX usando llaves, incluidas variables, funciones y propiedades.

  

> La carpeta pública contiene archivos estáticos como index. html, archivos de biblioteca de javascript, imágenes y otros activos, etc. que no desea que webpack procese. Los archivos de esta carpeta se copian y pegan tal como están directamente en la carpeta de compilación.

  

```jsx
const App = () => {
    const titulo = "Mi primer proyecto con React.js";
    const imagen = "https://picsum.photos/200/300";
    return (
        <div className="container">
            <h1 className="text-primary">{titulo.ToUpperCase}</h1>
            <img src={imagen} alt={`imagen-${titulo}`} />
        </div>
    );
};

export default App;
```

  

```jsx
const App = () => {
  const titulo = "Mi primer proyecto con React.js";
  const classColors = {
    primary: "text-primary",
    info: "text-info",
  };
  return (
    <div className="container">
      <h1 className={classColors.primary}>{titulo}</h1>
      <p className={classColors.info}>Lorem ipsum dolor sit.</p>
    </div>
  );
};

export default App;

```

  

## Componentes

- Las aplicaciones React están hechas de componentes .
- Un componente es una parte de la IU (interfaz de usuario) que tiene su propia lógica y apariencia.
- Un componente puede ser tan pequeño como un botón o tan grande como una página entera.
- Los componentes de React son funciones de JavaScript:

  

```jsx
const MyButton = () => {
  return <button>Boton</button>;
};

const App = () => {
  const titulo = "Mi primer proyecto con React.js";
  return (
    <div className="container">
      <h1 className="text-primary">{titulo}</h1>
      <MyButton />
    </div>
  );
};

export default App;

```

> Componentes siempre en Mayúsculas  
> Fíjate que `<MyButton />` empieza con mayúscula. **Así es como sabes que es un componente React.** Los nombres de los componentes de React siempre deben comenzar con una letra mayúscula, mientras que las etiquetas HTML deben estar en minúsculas.
{: .prompt-info }

## Renderizado condicional

- [condicional](https://es.reactjs.org/docs/conditional-rendering.html): En React, puedes crear distintos componentes que encapsulan el comportamiento que necesitas. Entonces, puedes renderizar solamente algunos de ellos, dependiendo del estado de tu aplicación.

  

```jsx
const MyButton = () => {
    return <button>Boton</button>;
};

const UserMessage = () => {
    return <h2>Bienvenido usuario</h2>;
};

const App = () => {
    const titulo = "Mi primer proyecto con React.js";
    const user = true;
    return (
        <div className="container">
            <h1 className="text-primary">{titulo}</h1>
            <MyButton />
            {user ? <UserMessage /> : "Offline"}
        </div>
    );
};

export default App;
```