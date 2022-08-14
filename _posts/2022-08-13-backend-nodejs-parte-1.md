---
title: BackEnd con NodeJS - parte 1
date: 2022-08-13 00:00:00 -500
categories: [nodeJS]
tags: [javascript, backend, nodeJS, express, JWT, programacion]
published: true
hidden: false
---

## Stack de tecnologías

- Node.js
- Express
- MongoDB

## Configuración inicial


``` powershell
npm init -y

```

  

- Este comando genera el archivo `package.json`

  

```json
{
  "name": "backend-todo-univo",
  "version": "1.0.0",
  "description": "Proyecto BackEnd TODO UNIVO",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["Rest", "UNIVO"],
  "author": "Jaime Guevara",
  "license": "ISC"
}

```

  

- Instalación de dependencias

  

``` powershell
npm i bcryptjs cookie-parser cors dotenv express express-validator jsonwebtoken mongoose
npm i -D nodemon
```

  

- Modificar archivo `package.json`

```json
{
  "name": "apirest-univo",
  "version": "1.0.0",
  "type": "module",
  "description": "Proyecto API TODO UNIVO",
  "main": "index.js",
  "scripts": {
    "dev": "nodemon index.js",
    "start": "node index.js"
  },
  "keywords": [
    "Rest",
    "UNIVO"
  ],
  "author": "Jaime Guevara",
  "license": "ISC",
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "cookie-parser": "^1.4.6",
    "cors": "^2.8.5",
    "dotenv": "^16.0.1",
    "express": "^4.18.1",
    "express-validator": "^6.14.2",
    "jsonwebtoken": "^8.5.1",
    "mongoose": "^6.5.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.19"
  }
}

```

  

- Crear archivo `.gitignore`

```text
node_modules
.env

```

  

- Archivo `index.js`

```javascript
import express from "express"

const app = express()

app.listen(3000, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:3000"))

```

  

- Ejecutar servidor con: `⁠npm run dev`
- Crear/verificar la siguiente estructura de archivos y directorios

![Estructura](/assets/images/backend-01.png)_Estructura de archivos_

## Base de datos MongoDB

- Crear base de datos en mongo.db creando cuenta en [https://www.mongodb.com/](https://www.mongodb.com/) donde se crea un usuario y se conecta a la base de datos con la opción Connect your application

![MongoDB](/assets/images/backend-02.png)_MongoDB_

- Copiar la URI, después se modificara con el usuario y password generado

![MongoDB](/assets/images/backend-03.png)_MongoDB_


## Variables de entorno y Moongoose

- Modificar archivo `⁠.env`  sustituyendo sus credenciales

``` text
DB_URI=mongodb+srv://<usuario>:<password>@cluster0.3kuar1l.mongodb.net/todo_v1

```

  

- Crear archivo `⁠database/connect.js` 

```javascript
import mongoose from "mongoose"

try {
    await mongoose.connect(process.env.DB_URI)
    console.log("Conectado a la base de datos 😎")
} catch (error) {
    console.log("Error de conexion a mongoDB" + error)
}

```

  

- Modificar `⁠index.js`

```javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"

const app = express()

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))

```

  

## Schema & Models

1. Schema: Con Mongoose, todo se deriva de un esquema.
2. Cada esquema se asigna a una colección MongoDB y define la forma de los documentos dentro de esa colección.
3. Para usar nuestra definición de esquema, necesitamos convertirla a un modelo con el que podamos trabajar

  

- Crear archivo `⁠models/user.js` 

```javascript
import mongoose from "mongoose"

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        trim: true,
        unique: true,
        lowercase: true,
        index: { unique: true },
    },
    password: {
        type: String,
        required: true,
    },
});

export const User = mongoose.model("User", userSchema);

```

  

## Routes

- Crear archivo `routes/auth_route.js` 

```javascript
import express from 'express'

const router = express.Router()

router.get("/login", (req, res) => {
    res.json({ok:"login"})
})

router.post("/register", (req, res) => {
    res.json({ok:true})
})

export default router

```

  

- Modificar `⁠index.js`

```javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"
import authRoutes from "./routes/auth_route.js"

const app = express()

app.use('/', authRoutes)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))

```

  

- Los navegadores solo permiten realizar peticiones GET, para realizar peticiones POST es necesario un programa como [POSTMAN](https://www.postman.com/downloads/) o [INSOMNIA](https://insomnia.rest/)

  

![PostMan](/assets/images/backend-04.png)_PostMan_ 

  

- Agregamos version a nuestra api modificando archivo ⁠`index.js`

```javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"
import authRoutes from "./routes/auth_route.js"

const app = express()

app.use('/api/v1/auth', authRoutes)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))

```

  

## Controllers

- Utilizamos controladores para manejar la lógica de respuesta de las rutas, crear archivo `⁠controllers/auth_controller.js` 

```javascript
export const register = async (req, res) => {
    res.json({ok:true})
};

export const login = async (req, res) => {
    res.json({ok:true})
};

```

  

- Modificar archivo `routes/auth_route.js` 

```javascript
import express from 'express'
import { login, register } from '../controllers/auth_controller.js'

const router = express.Router()

router.get("/login", login)

router.post("/register", register)

export default router

```

  

## Verificar envió de datos JSON

- Modificar `⁠controllers/auth_controller.js` 

```javascript
export const register = async (req, res) => {
    console.log(req.body)
    res.json({ok:true})
};

export const login = async (req, res) => {
    res.json({ok:true})
};
```

  

- Probar envió de datos formato JSON con POSTMAN

![PostMan](/assets/images/backend-05.png)_PostMan_ 

- En la consola aparecerá undefined, eso es debido a que express no esta configurado para recibir peticiones en JSON, para habilitar esta lectura es necesario agregar un middleware al archivo `⁠index.js`  

``` javascript
import 'dotenv/config'
import './database/connect.js'
import express from "express"
import authRoutes from "./routes/auth_route.js"

const app = express()
app.use(express.json())
app.use('/api/v1', authRoutes)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("🔥🔥🔥 servidor disponible en: http://localhost:" + PORT))

```

- Vista en consola

``` powershell
[nodemon] restarting due to changes...
[nodemon] starting `node index.js`
Conectado a la base de datos 😎
🔥🔥🔥 servidor disponible en: http://localhost:3000
{ email: 'jr.correo@correo.com', password: '123456' }

```

  

## Validaciones

- Agregamos validaciones con ExpressValidator, modificamos `routes/auth_route.js` ya que hay que interceptar la respuesta antes de que llegue al controlador.

```javascript
import express from 'express'
import { login, register } from '../controllers/auth_controller.js'
import { validatorExpress } from "../middlewares/validatorExpress.js";
import { body } from "express-validator";

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
    register
)

router.post(
    "/login",
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

export default router

```

  

- Crear archivo `middlewares/validatorExpress.js`
    

```javascript
import { validationResult } from "express-validator"
export const validatorExpress = (req, res, next) => {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
        return res.status(400).json({ error: errors.array() })
    }
    next()
}

```

  

- Probar validaciones con Postman

![PostMan](/assets/images/backend-06.png)_PostMan_ 

  

## Encriptación al password y comparación

- Modificar archivo `  models/User.js  ⁠`  

  

```javascript
import mongoose from "mongoose"
import bcrypt from "bcryptjs"

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        trim: true,
        unique: true,
        lowercase: true,
        index: { unique: true },
    },
    password: {
        type: String,
        required: true,
    },
});

userSchema.pre("save", async function (next) {
    const user = this

    if (!user.isModified("password")) return next()

    try {
        const salt = await bcrypt.genSalt(10)
        user.password = await bcrypt.hash(user.password, salt)
        next()
    } catch (error) {
        console.log(error)
        throw new Error("Error al codificar la contraseña")
    }
});

userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password)
}

export const User = mongoose.model("User", userSchema)

```

  

## Register y Login

- Modificar `⁠controllers/auth_controller.js` 

  

```javascript
import { User } from "../models/User.js"

export const register = async (req, res) => {
    const { email, password } = req.body

    try {
        let usuario = new User({ email, password })
        await usuario.save()

        return res.status(201).json({ ok: true })
    } catch (error) {
        console.log(error)
        return res.status(400).json({ error: error.message })
    }
}

export const login = async (req, res) => {
    try {
        const { email, password } = req.body

        let usuario = await User.findOne({ email });
        if (!usuario)
            return res.status(403).json({ error: "No existe este usuario" });

        const respuestaPassword = await usuario.comparePassword(password);
        if (!respuestaPassword)
            return res.status(403).json({ error: "Contraseña incorrecta" });

        return res.status(201).json({ ok: true })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}

```
  
## JWT

- [Introducción a JWT](https://jwt.io/introduction)

- Generar JWT para el login y register, modificar archivo  `.env` 

``` text
DB_URI=mongodb+srv://<usuario>:<password>@cluster0.3kuar1l.mongodb.net/todo_v1
JWT_SECRET=SflKkkRJSMeKKF2QT4fwpMeJf36POk6yJV_a3dAA5c

```

- Modificar `⁠controllers/auth_controller.js` 

```javascript
import { User } from "../models/User.js"
import jwt  from "jsonwebtoken"

export const register = async (req, res) => {
    const { email, password } = req.body

    try {
        let usuario = new User({ email, password })
        await usuario.save()

        return res.status(201).json({ ok: true })
    } catch (error) {
        console.log(error)
        return res.status(400).json({ error: error.message })
    }
}

export const login = async (req, res) => {
    try {
        const { email, password } = req.body

        let user = await User.findOne({ email })
        if (!user)
            return res.status(403).json({ error: "No existe este usuario" })

        const respuestaPassword = await user.comparePassword(password)
        if (!respuestaPassword)
            return res.status(403).json({ error: "Contraseña incorrecta" })

        // JWT
        const token = jwt.sign({uid: user._id}, process.env.JWT_SECRET)
        return res.json({ token })
        return res.status(201).json({ ok: true })
    } catch (error) {
        console.log(error)
        return res.status(403).json({ error: error.message })
    }
}

```