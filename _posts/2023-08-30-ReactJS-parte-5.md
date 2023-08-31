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

## Custom Hook useGif

- Instalar axios `npm i axios`
- Generar API\_KEY de [https://developers.giphy.com](https://developers.giphy.com/)

- `⁠components/Header.jsx`

```jsx
const logo = "./src/assets/react.svg";

const Header = () => {
    return (
        <>
            <h1 className="text-info text-center">Hook personalizado en React</h1>
            <img className="rounded d-block mx-auto" src={logo} />
            <hr></hr>
        </>
    );
}

export default Header;
```

  

- `components/Random_v1.jsx`

```jsx
import { useState, useEffect } from 'react';
import axios from 'axios';

const API_KEY = 'szInMDHl8WSrGGDZjbNSbUNYX5DmC8Fq';

const Random = () => {
    const [gif, setGif] = useState('');

    const fetchGif = async () => {
        const url = `https://api.giphy.com/v1/gifs/random?api_key=${API_KEY}`;
        const { data } = await axios.get(url);
        const imageSrc = data.data.images.downsized_large.url;
        setGif(imageSrc);
    }

    useEffect(() => {
        fetchGif();
    }, []);

    const handleClick = () => {
        fetchGif();
    }

    return (
        <div className="col-sm-6 text-center">
            <h2 className="text-info">Random Gif v1</h2>
            <img width="500" src={gif} alt="Random Gif" />
            <br /><br />
            <button className='btn btn-info' onClick={handleClick}>Cargar nuevo Gif</button>
        </div>
    );
}

export default Random;
```

  

- `components/Tag_v1.jsx`

```jsx
import { useState, useEffect } from 'react';
import axios from 'axios';

const API_KEY = 'szInMDHl8WSrGGDZjbNSbUNYX5DmC8Fq';

const Tag = () => {
    const [tag, setTag] = useState('cats');
    const [gif, setGif] = useState('');

    const fetchGif = async (tag) => {
        const url = `https://api.giphy.com/v1/gifs/random?api_key=${API_KEY}&tag=${tag}`;
        const { data } = await axios.get(url);
        const imageSrc = data.data.images.downsized_large.url;
        setGif(imageSrc);
    }

    useEffect(() => {
        fetchGif(tag);
    }, [tag]);

    const handleClick = () => {
        fetchGif(tag);
    }

    return (
        <div className="col-sm-6 text-center">
            <h2 className="text-info">Random Gif de { tag } v1</h2>
            <img width="500" src={gif} alt="Tag Gif" />
            <br /><br />    
            <input className="form-control mb-2" value={tag} onChange={(e) => setTag(e.target.value)} />
            <button className='btn btn-info' onClick={handleClick}>Buscar Gif</button>
        </div>
    );
}

export default Tag;
```

  

- `App.jsx`

```jsx
import Header from "./components/Header";
import Random from "./components/Random_v1";
import Tag from "./components/Tag_v1";

const App = () => {

  return (
    <div className="container">
      <Header />
      <div className="row">
        <Random />
        <Tag />
      </div>
    </div>
  );
};

export default App;
```

  

- Crear custom hook `hooks/useGif.jsx`

```jsx
import { useState, useEffect } from 'react';
import axios from 'axios';

const API_KEY = 'szInMDHl8WSrGGDZjbNSbUNYX5DmC8Fq';

const url = `https://api.giphy.com/v1/gifs/random?api_key=${API_KEY}`;

const useGif = (tag) => {
    const [gif, setGif] = useState('');

    const fetchGif = async (tag) => {
        const { data } = await axios.get(tag ? `${url}&tag=${tag}` : url);
        const imageSrc = data.data.images.downsized_large.url;
        setGif(imageSrc);
    }

    useEffect(() => {
        fetchGif(tag);
    }, [tag]);

    return { gif, fetchGif }
}

export default useGif;
```

  

- `components/Random_v2.jsx`

```jsx
import useGif from '../hooks/useGif';

const Tag = () => {
    const {gif, fetchGif} = useGif();

    return (
        <div className="col-sm-6 text-center">
            <h2 className="text-info">Random Gif v2</h2>
            <img width="500" src={gif} alt="Random Gif" />
            <br /><br />
            <button className='btn btn-info' onClick={fetchGif}>Vargar nuevo Gif</button>
        </div>
    );
}

export default Tag;
```

  

- `components/Tag_v2.jsx`

```jsx
import { useState } from 'react';
import useGif from '../hooks/useGif';

const Tag = () => {
    const [tag, setTag] = useState('cats');
    const {gif, fetchGif} = useGif(tag);

    return (
        <div className="col-sm-6 text-center">
            <h2 className="text-info">Random Gif de { tag } v2</h2>
            <img width="500" src={gif} alt="Random Gif" />
            <br /><br />
            <input className="form-control mb-2" value={tag} onChange={(e) => setTag(e.target.value)} />
            <button className='btn btn-info' onClick={() => fetchGif(tag)}>Buscar Gif</button>
        </div>
    );
}

export default Tag;
```

  

- `⁠App.jsx`  

```jsx
import Header from "./components/Header";
import Random from "./components/Random_v2";
import Tag from "./components/Tag_v2";

const App = () => {

  return (
    <div className="container">
      <Header />
      <div className="row">
        <Random />
        <Tag />
      </div>
    </div>
  );
};

export default App;
```