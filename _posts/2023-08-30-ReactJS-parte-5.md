---
title: ReactJS - parte 5
date: 2023-08-29 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, programacion]
published: true
hidden: false
---

## Custom Hook  

Los hooks personalizados son muy útiles para limpiar su código. Puedes usar hooks de React dentro de tus hooks personalizados (después de todo, todas son funciones! 👍). Puede encapsular mucha lógica repetitiva y luego devolver lo que necesita desde el hook personalizado.

`components(Header.jsx`

```jsx
const logo = "./src/assets/react.svg";

const Header = () => {
    return (
        <>
            <h1 className="text-info text-center">Hooks en React</h1>
            <img className="rounded d-block mx-auto" src={logo} />
            <hr></hr>
        </>
    );
}

export default Header;
```

  

`App.jsx`

```jsx
import { useCallback, useEffect, useState } from "react";
import Header from "./components/Header";

const App = () => {
  const [data, setData] = useState([]);
  const [url, setUrl] = useState("");

  //https://jsonplaceholder.typicode.com/users

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log(url)
  };

  const fetchData = useCallback(async () => {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw "Error al conectar la API";
      }
      const data = await response.json();
      setData(data);
    } catch (error) {
      console.log(error);
      setData([]);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);


  if (!data) return <p>Cargando datos...</p>

  return (
    <div className="container">
      <Header />
      <form
        onSubmit={handleSubmit}
      >
          <input
            className="form-control mb-2"
            type="text"
            placeholder="Ingrese un URL"
            name="url"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
          />
      </form>
      <hr></hr>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};

export default App;
```

  

`components/Form.jsx`

```jsx
import { useState } from "react";
import { useFetch } from "../hooks/useFetch";

const Form = () => {
    const [url, setUrl] = useState("");
    const { data } = useFetch(url);

    //https://jsonplaceholder.typicode.com/users

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log(url)
    };

    return (
        <>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un URL"
                    name="url"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                />
            </form>
            <h3 className="text-center">Resultados</h3>
            <hr></hr>
            <pre>{JSON.stringify(data, null, 2)}</pre>
        </>
    );
};

export default Form;
```

  

`hooks/useFetch.jsx`

```jsx
import { useCallback, useEffect, useState } from "react";

export const useFetch = (url) => {
    const [data, setData] = useState([]);

    const fetchData = useCallback(async () => {
        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw "Error al conectar la API";
            }
            const data = await response.json();
            setData(data);
        } catch (error) {
            console.log(error);
            setData([]);
        }
    }, [url]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    return { data };
}
```

  

`App.jsx`

```jsx
import Header from "./components/Header";
import Form from "./components/Form";

const App = () => {

  //const { data } = useFetch("https://jsonplaceholder.typicode.com/albums");

  return (
    <div className="container">
      <Header />
      <Form />
    </div>
  );
};

export default App;
```

  

## Manejo de errores  

`useFetch.jsx`

```jsx
import { useCallback, useEffect, useState } from "react";

export const useFetch = (url) => {
    const [data, setData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    const fetchData = useCallback(async () => {
        setLoading(true);
        try {
            if (!url) {
                throw Error("No se ha especificado una URL");
            } else {
                const response = await fetch(url);
                if (!response.ok) {
                    throw Error("Error al conectar la API");
                }
                const data = await response.json();
                setData(data);
                setError("")
            }
        } catch (error) {
            console.log(error.message);
            setError(error.message);
            setData([]);
        } finally {
            setLoading(false);
        }
    }, [url]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    return { data, loading, error };
}
```

  

`Form.jsx`

```jsx
import { useState } from "react";
import { useFetch } from "../hooks/useFetch";

const Form = () => {
    const [url, setUrl] = useState('');
    const { data, loading, error } = useFetch(url);

    //https://jsonplaceholder.typicode.com/users

    const handleSubmit = (e) => {
        setUrl(e.target.url.value);
        e.preventDefault();
        console.log(url)
    };
    if (loading) return <p>Cargando...</p>
    return (
        <>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un URL"
                    name="url"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                />
            </form>
            <hr></hr>
            { ( error ) ? <p className="badge rounded-pill bg-warning text-dark">{error} </p> :
                <pre>{JSON.stringify(data, null, 2)}</pre>
            }
        </>
    );
};

export default Form;
```

  

## Syntax Highlighter

- [https://github.com/react-syntax-highlighter/react-syntax-highlighter](https://github.com/react-syntax-highlighter/react-syntax-highlighter)
- `npm install react-syntax-highlighter --save ⁠`

  

`Form.jsx`

```jsx
import { useState } from "react";
import { useFetch } from "../hooks/useFetch";
import SyntaxHighlighter from 'react-syntax-highlighter';
import { monokaiSublime } from 'react-syntax-highlighter/dist/esm/styles/hljs';

const Form = () => {
    const [url, setUrl] = useState('');
    const { data, loading, error } = useFetch(url);

    //https://jsonplaceholder.typicode.com/users

    const handleSubmit = (e) => {
        setUrl(e.target.url.value);
        e.preventDefault();
        console.log(url)
    };
    if (loading) return <p>Cargando...</p>
    return (
        <>
            <form
                onSubmit={handleSubmit}
            >
                <input
                    className="form-control mb-2"
                    type="text"
                    placeholder="Ingrese un URL"
                    name="url"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                />
            </form>
            <hr></hr>
            {(error) ? <p className="badge rounded-pill bg-warning text-dark"> {error} </p> :

                <SyntaxHighlighter language="json" style={monokaiSublime} showLineNumbers={true}>
                    {JSON.stringify(data, null, 2)}
                </SyntaxHighlighter>


            }
        </>
    );
};

export default Form;
```