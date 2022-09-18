---
title: Fundamentos JavaScript - parte 6
date: 2022-09-17 00:00:00 -500
categories: [javascript]
tags: [javascript, fundamentos, programacion]
published: true
hidden: false
---

## Callbacks

- [Callback](https://developer.mozilla.org/es/docs/Glossary/Callback_function): Una función de callback es una función que se pasa a otra función como un argumento, que luego se invoca dentro de la función externa para completar algún tipo de rutina o acción.

- Cada vez se ocupan menos.
- Pasar una función como argumento.


```javascript
const posts = [
    {
        userId: 1,
        id: 1,
        title:
            "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    },
    {
        userId: 1,
        id: 2,
        title: "qui est esse",
    },
    {
        userId: 1,
        id: 3,
        title: "ea molestias quasi exercitationem repellat qui ipsa sit aut",
    },
];
```

  

```javascript
const findPostById = (id, callback) => {
    const post = posts.find((item) => item.id === id)

    callback(post)
};

findPostById(1, (post) => {
    console.log(post)
})
```

  

### Errores

```javascript
const findPostById = (id, callback) => {
    const post = posts.find((item) => item.id === id)

    if (post) {
        // mandamos el null ya que no existen errores
        callback(null, post)
    } else {
        // en caso de que no exista el post
        callback("No encontrado por id: " + id)
    }
}

// ser recibe el err como primer argumento
findPostById(4, (err, post) => {
    if (err) {
        return console.log(err)
    }
    console.log(post)
})
```

  

### Callback Hell

```javascript
findPostById(1, (err, post) => {
    if (err) {
        return console.log(err)
    }
    console.log(post.id)

    findPostById(2, (err, post2) => {
        if (err) {
            return console.log(err)
        }
        console.log(post.id, post2.id)

        findPostById(3, (err, post3) => {
            if (err) {
                return console.log(err)
            }
            console.log(post.id, post2.id, post3.id)

            findPostById(4, (err, post4) => {
                if (err) {
                    return console.log(err)
                }
                console.log(post.id, post2.id, post3.id, post4.id)
            })
        })
    })
})
```  

## Promesas

- [promise](https://developer.mozilla.org/es/docs/Web/JavaScript/Guide/Using_promises): Una Promisa es un objeto que representa la terminación o el fracaso de una operación asíncrona.

  

```javascript
const findPostById = (id) => {
    const post = posts.find((item) => item.id === id);

    // devolver la promesa
    return new Promise((resolve, reject) => {
        //resolve
        if (post) {
            resolve(post)
        } else {
            reject("No encontrado por id: " + id)
        }
    });
};

findPostById(1)
    .then((post) => console.log(post))
    .catch((err) => console.log(err))
    .finally(() => console.log("fin de la promesa"))
```


```javascript
const findPostById = (id) =>
    new Promise((resolve, reject) => {
        const post = posts.find((item) => item.id === id)

        post ? resolve(post) : reject("No encontrado por id: " + id)
    });

findPostById(4)
    .then((post) => console.log(post))
    .catch((e) => console.log(e))
```

  

## Promises hell

```javascript
findPostById(1)
    .then((post) => {
        console.log(post.title)
        return findPostById(2)
    })
    .then((post) => {
        console.log(post.title)
        return findPostById(3)
    })
    .then((post) => {
        console.log(post.title)
        return findPostById(4)
    })
    .then((post) => console.log(post.title))
    .catch((e) => console.log(e))
```