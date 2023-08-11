---
title: ReactJS - parte 3
date: 2023-08-11 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, programacion]
published: true
hidden: false
---
## Recursos

- [form react](https://es.reactjs.org/docs/forms.html)
- [uncontrolled components](https://es.reactjs.org/docs/uncontrolled-components.html)
- [useRef](https://es.reactjs.org/docs/hooks-reference.html#useref)
- [formData form react](https://mattboldt.com/2020/05/02/formdata-with-react-hooks-and-fetch/)
- [Referencias](https://es.reactjs.org/docs/refs-and-the-dom.html)

## Componentes no controlados

- [uncontrolled](https://es.reactjs.org/docs/uncontrolled-components.html): En la mayoría de los casos, te recomendamos usar Componentes controlados para implementar formularios.
- En un componente controlado, los datos del formulario son manejados por un componente React.
- La alternativa son los componentes no controlados, donde los datos del formulario son manejados por el propio DOM.
- Para escribir un componente no controlado, puedes usar una referencia para que obtengas los valores del formulario desde el DOM.

  

> Referencias y el DOM
> 
> - [refs](https://es.reactjs.org/docs/refs-and-the-dom.html): Las referencias proporcionan una forma de acceder a los nodos del DOM o a elementos React creados en el método de renderizado.
> 
> - [useRef](https://es.reactjs.org/docs/hooks-reference.html#useref): useRef devuelve un objeto ref mutable cuya propiedad `.current` se inicializa con el argumento pasado (initialValue). El objeto devuelto se mantendrá persistente durante la vida completa del componente.
{: .prompt-tip } 
  

`⁠components/Header.jsx`

```jsx
const logo = "./src/assets/react.svg";

const Header = () => {
    return (
        <>
            <h1 className="text-info text-center">Formularios en React</h1>
            <img className="rounded d-block mx-auto" src={logo} />
            <hr></hr>
        </>
    );
}

export default Header;

```

  

`components/NoControlado.jsx`

```jsx
const NoControlado = () => {
  // Formulario no controlado
  const handleSubmit = () => {
    console.log("Formulario enviado");
  };

  return (
    <div className="container mt-2">
      <form
        onSubmit={handleSubmit}
      >
        <input
          className="form-control mb-2"
          type="text"
          placeholder="Ingrese un TODO"
          name="todoNombre"
          defaultValue="Tarea #01"
        />
        <textarea
          className="form-control mb-2"
          type="text"
          placeholder="Ingrese un TODO"
          name="todoDescripcion"
          defaultValue="Descripción tarea #01"
        />
        <select
          className="form-control mb-2"
          name="todoEstado"
          defaultValue="completado"
        >
          <option value="pendiente">Pendiente</option>
          <option value="completado">Completado</option>
        </select>
        <button
          className="btn btn-primary"
          type="submit"
        >
          Agregar
        </button>
      </form>
    </div>
  );
};

export default NoControlado;


```

  

`⁠App.jsx`  

```jsx
import NoControlado from "./components/FormularioNoControlado";
import Header from "./components/Header";

const App = () => {
  return (
    <div className="container">
      <Header/>
      <div className="row">
      <NoControlado/>
      </div>
    </div>
  );
};

export default App;

```

  

- Prevent Default modificar `NoControlado.jsx`

```jsx
const NoControlado = () => {
    // Formulario no controlado
    const handleSubmit = (e) => {
        console.log("Formulario enviado");
        console.log(formulario.current);
        e.preventDefault();
    };

    /* document.addEventListener("submit", (evento) => {
        evento.preventDefault();
    }); */

    return (
        <div className="col-sm-6">
            <form
                onSubmit={handleSubmit}
                /*onSubmit={(e) => handleSubmit(e)}*/
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                    defaultValue="Tarea #01"
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                    defaultValue="Descripción tarea #01"
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                    defaultValue="pendiente"
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
            </form>
        </div>
    );
};

export default NoControlado;


```

  

- Usualmente para capturar los datos de un formulario se debe de usar un id al mismo. sin embargo esto daria problemas con el DOM virtual de React. Por lo que usamos un hook llamado useRef

```jsx
import { useRef } from "react";

const NoControlado = () => {
    const formulario = useRef(null);

    // Formulario no controlado
    const handleSubmit = (e) => {
        console.log("Formulario enviado");
        console.log(formulario.current);
        e.preventDefault();
    };

    /* document.addEventListener("submit", (evento) => {
        evento.preventDefault();
    }); */

    return (
        <div className="col-sm-6">
            <form
                onSubmit={handleSubmit}
                ref={formulario}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                    defaultValue="Tarea #01"
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                    defaultValue="Descripción tarea #01"
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                    defaultValue="pendiente"
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
            </form>
        </div>
    );
};

export default NoControlado;

```

  

## FormData

- modificar `NoControlado.jsx`

```jsx
import { useRef, useState } from "react";

const NoControlado = () => {
    const formulario = useRef(null);
    const [error, setError] = useState(null);

    // Formulario no controlado
    const handleSubmit = (e) => {
        console.log("Formulario enviado");
        //console.log(formulario.current);
        e.preventDefault();
        setError(null);

        //?Capturar datos del formulario
        // El método FormData() crea un objeto FormData que representa un conjunto de pares clave/valor.
        const datos = new FormData(formulario.current);

        // spread operator: permite a un elemento iterable ser expandido
        // copia cada uno de sus elementos
        console.log([...datos.entries()]);

        // El método Object.fromEntries() transforma una lista de pares con [clave-valor] en un objeto.
        const objetoDatos = Object.fromEntries([...datos.entries()]);
        console.log(objetoDatos);

        //?Validaciones
        if (!objetoDatos.todoNombre.trim()) {
            return console.log("Campo vacío");
        }

        if (!objetoDatos.todoNombre.trim() || !objetoDatos.todoDescripcion.trim() || !objetoDatos.todoEstado.trim()) {
            return setError("* Llena todos los campos");
        }

        console.log("Pasó las validaciones!");
        formulario.current.reset();
    };

    /* document.addEventListener("submit", (evento) => {
        evento.preventDefault();
    }); */

    return (
        <div className="col-sm-6">
            <h2 className="text-info">Formulario No Controlado</h2>
            <form
                onSubmit={handleSubmit}
                //onSubmit={(e) => handleSubmit(e)}
                ref={formulario}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                    defaultValue="Tarea #01"
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                    defaultValue="Descripción tarea #01"
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                    defaultValue="pendiente"
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
                {error !== "" &&
                    <>
                        <hr></hr>
                        <span className="text-warning">{error}</span>
                    </>
                }
            </form>
        </div>
    );
};

export default NoControlado;

```

  

## Componentes controlados

- [controlled](https://es.reactjs.org/docs/forms.html#controlled-components)
- Los componentes React que renderizan un formulario también controlan lo que pasa en ese formulario con las subsecuentes entradas del usuario.
- Ahora vamos a poder detectar los campos input en tiempo real.

  

`components/Controlado.jsx`

```jsx
const Controlado = () => {

    // Formulario controlado
    const handleSubmit = (e) => {
        e.preventDefault();
    };


    return (
        <div className="col-sm-6">
            <h2 className="text-info">Formulario Controlado</h2>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
            </form>
        </div>
    );
};

export default Controlado;

```

  

- modificando con useState

```jsx
import { useState } from "react";

const Controlado = () => {
    const [todoNombre, setTodoNombre] = useState("Tarea #1");
    const [todoDescripcion, setTodoDescripcion] = useState("Descripción tarea #01");
    const [todoEstado, setTodoEstado] = useState("pendiente");


    // Formulario controlado
    const handleSubmit = (e) => {
        e.preventDefault();
        console.log(todoNombre, todoDescripcion, todoEstado)      
    };

    return (
        <div className="col-sm-6">
            <h2 className="text-info">Formulario Controlado</h2>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                    value={todoNombre}
                    onChange={(e) => setTodoNombre(e.target.value)}
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                    value={todoDescripcion}
                    onChange={(e) => setTodoDescripcion(e.target.value)}
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                    value={todoEstado}
                    onChange={(e) => setTodoEstado(e.target.value)}
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
            </form>
        </div>
    );
};

export default Controlado;


```

  

- Variante con `useState` como objeto y funcion para manejar el `OnChange` 

```jsx
import { useState } from "react";

const Controlado = () => {
    const [todo, setTodo] = useState({
        todoNombre: "Tarea #01",
        todoDescripcion: "Descripción tarea #01",
        todoEstado: "pendiente",
    });

    // Formulario controlado
    const handleSubmit = (e) => {
        e.preventDefault();
        console.log(todo)
    };

    const handleOnChange = (e) => {
        // console.log(e.target.name);
        // console.log(e.target.value);
        // setTodo({ ...todo, [e.target.name]: e.target.value });
        // utilizando el callback
        setTodo((todo) => ({
            ...todo,
            [e.target.name]: e.target.value,
        }));
    };

    return (
        <div className="col-sm-6">
            <h2 className="text-info">Formulario Controlado</h2>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoNombre"
                    value={todo.todoNombre}
                    onChange={handleOnChange}
                />
                <textarea
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un TODO"
                    name="todoDescripcion"
                    value={todo.todoDescripcion}
                    onChange={handleOnChange}
                />
                <select
                    className="form-select mb-2"
                    name="todoEstado"
                    value={todo.todoEstado}
                    onChange={handleOnChange}
                >
                    <option value="pendiente">Pendiente</option>
                    <option value="completado">Completado</option>
                </select>
                <button
                    className="btn btn-info"
                    type="submit"
                >
                    Agregar
                </button>
            </form>
        </div>
    );
};

export default Controlado;


```