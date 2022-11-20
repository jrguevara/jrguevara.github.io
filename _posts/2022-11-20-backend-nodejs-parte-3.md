---
title: BackEnd con NodeJS - parte 3
date: 2022-11-20 00:00:00 -500
categories: [nodeJS]
tags: [javascript, backend, nodeJS, express, JWT, programacion]
published: true
hidden: false
---

## Refresh Token

Como se mencionó, por motivos de seguridad, los tokens de acceso pueden ser válidos por un corto período de tiempo. Una vez que caducan, las aplicaciones cliente pueden usar un token de actualización para "actualizar" el token de acceso. Es decir, un token de actualización es un artefacto de credencial que permite que una aplicación cliente obtenga nuevos tokens de acceso sin tener que pedirle al usuario que inicie sesión nuevamente. La aplicación cliente puede obtener un nuevo token de acceso siempre que el token de actualización sea válido y no haya caducado.

  

Un token de acceso de corta duración ayuda a mejorar la seguridad de nuestras aplicaciones, pero tiene un costo: cuando caduca, el usuario debe iniciar sesión nuevamente para obtener uno nuevo. La reautenticación frecuente puede disminuir la experiencia de usuario percibida de su aplicación. Incluso si lo hace para proteger sus datos, los usuarios pueden encontrar su servicio frustrante o difícil de usar.

  

 Un token de actualización puede ayudarlo a equilibrar la seguridad con la usabilidad. Dado que los tokens de actualización suelen tener una vida más larga, puede usarlos para solicitar nuevos tokens de acceso después de que caduquen los tokens de acceso más cortos.

  

- Modificar `protected.html` para cambiar el tipo de verificación del token, incluyendo la cookie en el método request con la propiedad credentials

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
                //const token = localStorage.getItem('token')
                const res = await fetch("/api/v1/auth/protected", {
                    method: 'GET',
                    headers: {
                        //"Authorization": "Bearer " + token,
                        "Content-Type": "application/json",
                    },
                    credentials: "include"
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

  

- Añadir una nueva variable de entorno: JWT\_REFRESH
- Modificamos `tokenManager.js` para poder generar el refresh token

```javascript
import jwt from "jsonwebtoken"

export const generateToken = (uid) => {

    const expiresIn = 60 * 15  // 15 min 
    try {
        const token = jwt.sign({ uid }, process.env.JWT_SECRET, { expiresIn })
        return { token, expiresIn }
    } catch (error) {
        console.log(error)
    }
}

export const generateRefreshToken = (uid, res) => {
    const expiresIn = 60 * 60 * 24 * 30 // 30 dias
    try {
        const refreshToken = jwt.sign({ uid }, process.env.JWT_REFRESH, { expiresIn })
        res.cookie("refreshToken", refreshToken, {
            httpOnly: true, //evitar document.cookie en consola
            secure: !(process.env.MODE === "dev"), //https
            sameSite: true,
            expires: new Date(Date.now() + expiresIn * 1000)
        })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}
```

  

- Modificamos la acción de login en `auth_controller.js` 

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
        generateRefreshToken(usuario._id, res)
        
        return res.json({ token, expiresIn })

        //return res.status(201).json({ ok: "inicio de sesion exitoso" })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}
```

- Probar en navegador que el refreshToken se ha creado

## Uso del Refresh Token

- Crear middleware para generación de refresh token `middlewares/requireRefreshToken.js`

```javascript
import jwt from 'jsonwebtoken'
import { errorTokens } from "../utils/errorsToken.js"

export const requireRefreshToken = (req, res, next) => {
    try {
        const refreshTokenCookie = req.cookies?.refreshToken
        if(!refreshTokenCookie) throw new Error("No existe el refreshToken")

        const { uid } = jwt.verify(refreshTokenCookie, process.env.JWT_REFRESH)

        req.uid = uid
        next()    
    } catch(error) {
        console.log(error);
        const data = errorTokens(error);
        return res.status(401).json({ error: data });
    }
}
```
 

- Modificamos  `auth_controller.js` 

```javascript
import { User } from "../models/User.js"
import { generateRefreshToken, generateToken } from "../utils/tokenManager.js"
import jwt from "jsonwebtoken"

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
        generateRefreshToken(usuario._id, res)

        return res.json( { token, expiresIn } )

        //return res.status(201).json({ ok: "inicio de sesion exitoso" })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}

export const infoUser = async (req, res) => {
    try {
        const user = await User.findById(req.uid)
        //return res.json({ user })
        return res.json({ email: user.email, uid: user.id })
    } catch (error) {
        return res.status(500).json({ error: "error de servidor" })
    }
}

export const refreshToken = (req, res) => {
    try {
        const { token, expiresIn} = generateToken(req.uid)
        
        return res.json({token, expiresIn})
    } catch (error) {
        console.log(error)
        return res.status(500).json({ error: "error de servidor....." })
    }
}
```

  

- Agregar nueva ruta para generación del refreshToken en `auth.route.js` 

```javascript
import express from "express"
import { infoUser, login, refreshToken, register } from "../controllers/auth_controller.js"
import { validatorExpress } from "../middlewares/validatorExpress.js"
import { body } from "express-validator"
import { requireToken } from "../middlewares/requireToken.js"
import { requireRefreshToken } from "../middlewares/requireRefreshToken.js"

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
router.get("/refresh", requireRefreshToken, refreshToken)

export default router
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
                const resToken = await fetch("/api/v1/auth/refresh", {
                    method: 'GET',
                    credentials: "include"
                })
                //console.log(resToken.ok, resToken.status);
                const { token } = await resToken.json()

                //const token = localStorage.getItem('token')
                const res = await fetch("/api/v1/auth/protected", {
                    method: 'GET',
                    headers: {
                        "Authorization": "Bearer " + token,
                        "Content-Type": "application/json",
                    },
                    //credentials: "include"
                })
                //console.log(res.ok, res.status)
                const data = await res.json()
                //console.log(data)

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

  

## Cerrar sesión

- Modificamos  `auth_controller.js` 

```javascript
export const logout = (req, res) => {
    res.clearCookie("refreshToken")
    return res.json({ ok: true })
}
```

- Agregamos ruta a `auth_route.js`

```javascript
router.get("/logout", logout)
```

- Modificamos `protected.html`

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
                const resToken = await fetch("/api/v1/auth/refresh", {
                    method: 'GET',
                    credentials: "include"
                })
                //console.log(resToken.ok, resToken.status);
                const { token } = await resToken.json()

                //const token = localStorage.getItem('token')
                const res = await fetch("/api/v1/auth/protected", {
                    method: 'GET',
                    headers: {
                        "Authorization": "Bearer " + token,
                        "Content-Type": "application/json",
                    },
                    //credentials: "include"
                })
                //console.log(res.ok, res.status)
                const data = await res.json()
                //console.log(data)

                app.innerHTML = `
                        <h2>Email: ${data.email}</h2>
                        <h3>UID: ${data.uid}</h3>
                    `;
            } catch (error) {
                console.log(error)
            }

            const logout = document.querySelector("#logout");
            logout.addEventListener("click", async () => {
                const res = await fetch("/api/v1/auth/logout");
                console.log(res.ok, res.status);
                if (res.ok) {
                    window.location.href = "/";
                }
            })
        })
    </script>
</body>

</html>
```