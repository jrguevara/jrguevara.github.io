---
title: BackEnd con NodeJS - parte 2
date: 2022-11-05 00:00:00 -500
categories: [nodeJS]
tags: [javascript, backend, nodeJS, express, JWT, programacion]
published: true
hidden: false
---

## Generación y Autorización de JWT

- Transferir la generación del token a un archivo diferente `utils/tokenManager.js` 

```javascript
import jwt  from "jsonwebtoken"

export const generateToken = (uid) => {

    const expiresIn = 60 * 15  // 15 min 
    try {
        const token = jwt.sign({uid}, process.env.JWT_SECRET, { expiresIn })
        return {token, expiresIn}
    } catch (error) {
        console.log(error)
    }
}
```

  

- Modificar `auth_controller.js` 

```javascript
import { User } from "../models/User.js"
import { generateToken } from "../utils/tokenManager.js"

export const register = async (req, res) => {
    const { email, password } = req.body

    try {
        let usuario = new User({ email, password })
        await usuario.save()

        return res.status(201).json({ ok: "dato almacenado" })
    } catch (error) {
        console.log(error)
        return res.status(400).json({ error: error.message })
    }
}

export const login = async (req, res) => {
    try {
        const { email, password } = req.body

        let usuario = await User.findOne({ email })
        if (!usuario)
            return res.status(403).json({ error: "No existe este usuario" })

        const respuestaPassword = await usuario.comparePassword(password)
        if (!respuestaPassword)
            return res.status(403).json({ error: "Contraseña incorrecta" })
        
        // Generacion de JWT
        const { token, expiresIn } = generateToken(usuario._id)
        return res.json({ token, expiresIn })

        //return res.status(201).json({ ok: "inicio de sesion exitoso" })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}
```

  

- Procedemos a crear un middleware que solicite un token antes de poder mostrar alguna ruta protegida, `middlewares/requireToken.js`

```javascript
import jwt from "jsonwebtoken"

export const requireToken = (req, res, next) => {
    try {
        let token = req.headers.authorization
        console.log(token)
        if (!token)
            throw new Error("No existe el token en el header. Metodo Bearer")

        token = token.split(" ")[1];
        const payload = jwt.verify(token, process.env.JWT_SECRET)
        console.log(payload)

        next()
    } catch (error) {
        console.log(error.message)
        return res.status(401).json({ error: error.message })
    }
}
```

  

- Se actualiza `auth_controller.js` con la información protegida

```javascript
export const infoUser = async (req, res) => {
    res.json({ info: "informacion del usuario"})
}
```

  

- Se define una nueva ruta protegida en `auth_router.js` para probar el JWT 

```javascript
import express from "express"
import { infoUser, login, register } from "../controllers/auth_controller.js"
import { validatorExpress } from "../middlewares/validatorExpress.js"
import { body } from "express-validator"
import { requireToken } from "../middlewares/requireToken.js"

const router = express.Router()

router.post("/register",
    [
        body("email", "Ingrese un email válido")
            .trim()
            .isEmail()
            .normalizeEmail(),
        body("password", "Contraseña mínimo 6 carácteres")
            .trim()
            .isLength({ min: 6 })
            .custom((value, { req }) => {
                if (value !== req.body.reEnterPassword) {
                    throw new Error("No coinciden las contraseñas")
                }
                return value;
            }),
    ],
    validatorExpress,
    register)

router.post("/login",
    [
        body("email", "Ingrese un email válido")
            .trim()
            .isEmail()
            .normalizeEmail(),
        body("password", "Contraseña mínimo 6 carácteres")
            .trim()
            .isLength({ min: 6 }),
    ],
    validatorExpress,
    login
)

router.get("/protected", requireToken, infoUser)

export default router
```

  

- Probar con postman configurando el uso de Bearer en la parte de autorización, copiando el jwt generado.

![PostMan](/assets/images/jwt_00.png)_PostMan_  

- Modificar `requireToken.js` para extraer el uid del payload y que este este disponible al controlador

```javascript
import jwt from "jsonwebtoken"

export const requireToken = (req, res, next) => {
    try {
        let token = req.headers.authorization
        console.log(token)
        if (!token)
            throw new Error("No existe el token en el header. Metodo Bearer")

        token = token.split(" ")[1];
        const { uid } = jwt.verify(token, process.env.JWT_SECRET)
        console.log("uid: " + uid)

        req.uid = uid

        next()
    } catch (error) {
        console.log(error.message)
        return res.status(401).json({ error: error.message })
    }
}
```

  

- Se actualiza `auth_controller.js` para mostrar la información del usuario

```javascript
export const infoUser = async (req, res) => {
    try {
        const user = await User.findById(req.uid)
        //return res.json({ user })
        return res.json({ email: user.email, uid: user.id })
    } catch (error) {
        return res.status(500).json({ error: "error de servidor" })
    }
}
```

  

- Crear utilidad para el manejo de errores del JWT `utils/errorsToken.js` 

```javascript
export const errorTokens = (message) => {
    switch (message) {
        case "jwt malformed":
            return "Formato no válido";
        case "invalid token":
            return "Token no válido";
        case "jwt expired":
            return "Token expirado";
        case "invalid signature":
            return "Firma invalida";
        case "No Bearer":
            return "Utiliza formato Bearer"
        default:
            return message;
    }
}
```

  

- Modificar `requireToken.js` para que use la utils de errores

```javascript
import jwt from "jsonwebtoken"
import { errorTokens } from "../utils/errorsToken.js"

export const requireToken = (req, res, next) => {
    try {
        let token = req.headers.authorization
        console.log(token)
        if (!token)
            throw new Error("No existe el token en el header. Metodo Bearer")

        token = token.split(" ")[1];
        const { uid } = jwt.verify(token, process.env.JWT_SECRET)
        console.log("uid: " + uid)

        req.uid = uid

        next()
    } catch (error) {
        console.log(error.message)
        return res.status(401).json({ error: errorTokens(error.message) })
    }
}
```

  

## Persistencia del JWT

- Modificar `index.js` para permitir por medio de middleware el acceso al contenido estático en la carpeta public

```javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"
import authRoutes from "./routes/auth_route.js"

const app = express()

app.use(express.json())
app.use('/api/v1/auth', authRoutes)
app.use(express.static("public"))
const PORT = process.env.PORT || 3000 

app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))
```

  

- Crear carpeta public y archivo `index.html` 
- [Fetch & JSON](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio</title>
</head>

<body>
    <form id="formLogin">
        <input type="email" value="jrg.correo@correo.com" id="email" />
        <input type="password" value="123456" id="password" />
        <button type="submit">Acceder</button>
    </form>

    <script>
        const formLogin = document.querySelector("#formLogin")
        const email = document.querySelector("#email")
        const password = document.querySelector("#password")

        formLogin.addEventListener("submit", async (e) => {
            e.preventDefault()
            try {
                // console.log(password.value)
                // console.log(email.value)
                const res = await fetch("/api/v1/auth/login", {
                    method: "post",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({
                        email: email.value,
                        password: password.value,
                    }),
                });
                // console.log(res)
                console.log(res.ok, res.status)

                // const data = await res.json()
                // console.log(data)

                const { token } = await res.json()
                console.log(token)

                //window.location.href = "/protected.html"
            } catch (error) {
                console.log(error)
            }
        });
    </script>
</body>

</html>
```

  

- Crear en public archivo `protected.html`

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ruta protegida</title>
</head>

<body>
    <h1>Ruta protegida</h1>
    <div id="app">
        <h2>Email</h2>
        <h3>UID</h3>
    </div>
    <button id="logout">Logout</button>

    <script>
        document.addEventListener("DOMContentLoaded", async (e) => {
            const app = document.getElementById("app")
            try {
                const token = "???"
                const res = await fetch("/api/v1/auth/protected", {
                    method: 'GET',
                    headers: {
                        "Authorization": "Bearer " + token,
                        "Content-Type": "application/json",
                    },
                })
                console.log(res.ok, res.status)
                const data = await res.json()
                console.log(data)
            } catch (error) {
                console.log(error)
            }
        })
    </script>
</body>

</html>
```

  

  

## JWT en Local Storage

- Modificar `index.html` 

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio</title>
</head>

<body>
    <form id="formLogin">
        <input type="email" value="jrg.correo@correo.com" id="email" />
        <input type="password" value="123456" id="password" />
        <button type="submit">Acceder</button>
    </form>

    <script>
        const formLogin = document.getElementById("formLogin")
        const email = document.getElementById("email")
        const password = document.getElementById("password")

        formLogin.addEventListener("submit", async (e) => {
            e.preventDefault()
            try {
                // console.log(password.value)
                // console.log(email.value)
                const res = await fetch("/api/v1/auth/login", {
                    method: "post",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({
                        email: email.value,
                        password: password.value,
                    }),
                });
                // console.log(res)
                console.log(res.ok, res.status)

                // const data = await res.json()
                // console.log(data)

                const { token } = await res.json()
                console.log(token)

                localStorage.setItem("token", token)

                window.location.href = "/protected.html"
            } catch (error) {
                console.log(error)
            }
        });
    </script>
</body>

</html>
```

  

- Modificar `protected.html` 

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ruta protegida</title>
</head>

<body>
    <h1>Ruta protegida</h1>
    <div id="app">
        <h2>Email</h2>
        <h3>UID</h3>
    </div>
    <button id="logout">Logout</button>

    <script>
        document.addEventListener("DOMContentLoaded", async (e) => {
            const app = document.getElementById("app")
            try {
                const token = localStorage.getItem('token')
                const res = await fetch("/api/v1/auth/protected", {
                    method: 'GET',
                    headers: {
                        "Authorization": "Bearer " + token,
                        "Content-Type": "application/json",
                    },
                })
                console.log(res.ok, res.status)
                const data = await res.json()
                console.log(data)

                app.innerHTML = `
                        <h2>Email: ${data.email}</h2>
                        <h3>UID: ${data.uid}</h3>
                    `;
            } catch (error) {
                console.log(error)
            }
        })
    </script>
</body>

</html>
```


## JWT en Cookie 🍪

- Modificar `index.js` para el uso de cookieParser

```javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"
import authRoutes from "./routes/auth_route.js"
import cookieParser from 'cookie-parser'

const app = express()

app.use(express.json())
app.use('/api/v1/auth', authRoutes)
app.use(express.static("public"))
app.use(cookieParser())
const PORT = process.env.PORT || 3000 

app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))
```

  

- Modificar `auth_controller.js` para generar cookie en el login
- [Manejo de cookies](https://expressjs.com/en/api.html#res.cookie)

```javascript
export const login = async (req, res) => {
    try {
        const { email, password } = req.body

        let usuario = await User.findOne({ email })
        if (!usuario)
            return res.status(403).json({ error: "No existe este usuario" })

        const respuestaPassword = await usuario.comparePassword(password)
        if (!respuestaPassword)
            return res.status(403).json({ error: "Contraseña incorrecta" })

        // Generacion de JWT
        const { token, expiresIn } = generateToken(usuario._id)
        res.cookie("token", token, {
            httpOnly: true, //evitar document.cookie en consola
            secure: !(process.env.MODE === "dev"), //https
            sameSite: true
        })
        return res.json({ token, expiresIn })

        //return res.status(201).json({ ok: "inicio de sesion exitoso" })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}
```