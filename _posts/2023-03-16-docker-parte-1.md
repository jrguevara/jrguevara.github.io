---
title: Docker - parte 1
date: 2023-03-15 00:00:00 -500
categories: [docker]
tags: [docker, contenedores, imagenes]
published: true
hidden: false
---

## ¿Qué es Docker?

![DOCKER](https://geekflare.com/wp-content/uploads/2020/03/docker-security.jpg)

Docker es una plataforma de software que le permite crear, probar e implementar aplicaciones rápidamente. Docker empaqueta el software en unidades estandarizadas llamadas contenedores que tienen todo lo que el software necesita para ejecutarse, incluidas bibliotecas, herramientas del sistema, código y tiempo de ejecución. Con Docker, puede implementar y escalar rápidamente aplicaciones en cualquier entorno y saber que su código se ejecutará.

### ¿Como funciona docker?

En Docker tenemos imágenes que se pueden descargar automáticamente o de la página web oficial. Al ejecutar una instancia, ésta crea un Contanier, el cual vamos a aprender a utilizar.
Para poder usar estos contenedores necesitamos de unos comandos que nos permiten usarlos y utilizarlos de la manera más conveniente.
Esos comandos se desarrollan en una terminal, los cuales son necesarios para dar el uso adecuado a Docker.
Lo primero que tenemos que entender es que las imágenes son previas, creadas por un usuario y los contenedores o containers son aplicaciones asiladas que contienen una o más imágenes.
Estos contenedores contienen todo lo necesario para ejecutar una aplicación.

Docker funciona proporcionando una forma estándar de ejecutar su código. Docker es un sistema operativo para contenedores. De manera similar a cómo una máquina virtual virtualiza (elimina la necesidad de administrar directamente) el hardware del servidor, los contenedores virtualizan el sistema operativo de un servidor. Docker está instalado en cada servidor y proporciona comandos simples que puede usar para crear, iniciar o detener contenedores.

![Docker](https://www.disenowebwordpress.com/wp-content/uploads/2018/12/Diferencias-Vm-y-containers.png)

## ¿Qué son las imágenes en Docker?

Las imágenes son como unas plantillas ya creadas, ya sea por nosotros o por otros, sirviéndonos para crear nuestro contenedores.

Podemos almacenarlo de manera local o en un repositorio público.


## Ciclo de vida de las imágenes

Las imágenes en Docker tienen un ciclo de vida útil. Este puede ser avanzado y básico.

**Ciclo de vida básico**

- En este ciclo de vida se crea el contenedor a partir de una imagen.
- Se ejecuta el proceso determinado en el contenedor
- El proceso de finaliza y el contenedor se detiene
- Se destruye el contenedor

**Ciclo de vida avanzado**

- Se crea un contenedor a partir de una imagen
- Se ejecuta un proceso en el contenedor
- Realiza acciones dentro del contenedor
- Detener el contenedor
- Lanzar el contenedor nuevamente

## Comandos Docker

![Docker](https://www.disenowebwordpress.com/wp-content/uploads/2018/12/Infograf%C3%ADa-docker-737x1024.png)

## Creación de una imagen personalizada en Docker

- Crear aplicación NodeJS con `⁠npm init -y` 
- instalar express `npm install express`  
- Crear `index.js`   

 

```javascript
const express = require("express")

const app = express()

app.get("/", (req, res) => {
    res.send("<h1>Hola Mundo</h1>")
})

const port = process.env.PORT || 3000

app.listen(port, () => console.log(`Escuchando en el puerto ${port} 😎`))
```

  

- Ejecutar con `⁠node index.js` y escribir en el navegador [http://localhost:3000/](http://localhost:3000/)
- Detener el servidor con `Ctrl+C`
- Crear cuenta en [https://hub.docker.com/](https://hub.docker.com/)
- Abrir [https://hub.docker.com/\_/node](https://hub.docker.com/_/node)

## DockerFile

- Crear `dockerfile`   

```javascript
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . ./
EXPOSE 3000
CMD [ "node", "index.js" ]
```

  

- Crear imagen con `docker build .`
- Ver lista de imágenes con `docker image ls`
- Borrar imagen con `docker image rm ID_IMAGEN`
- Crear imagen con nombre `docker build -t docker-node-image .` 
- Ver lista de imágenes con `docker image ls` 

## Ejecutar Contenedor

- Ejecutar la imagen en un contenedor `docker run -d --name node-app docker-node-image`
- Ver lista de contenedores con `docker ps`
- Escribir en el navegador [http://localhost:3000/](http://localhost:3000/) la aplicación no funcionara ya que no se ha especificado puerto
- Eliminar contenedor con `docker rm node-app -f` 
- Ejecutar la imagen con puerto con `docker run -p 3000:3000 -d --name node-app docker-node-image` 
- 3000:3000 el numero de la izquierda representa el puerto desde el cual hay trafico de entrada, el de la derecha el puerto donde docker o la aplicación esta escuchando
- Para ver el sistema de archivos del contenedor entramos en modo interactivo con `docker exec -it node-app bash`
- Listar los archivos con `ls`  salir con `exit`
- Eliminar contenedor

## DockerIgnore

- Crear archivo `.dockerignore`

```
node_modules
dockerfile
.dockerignore
.git
.gitignore
```

- Reconstruir imagen `docker build -t docker-node-image .` 
- Ejecutar contenedor `docker run -p 3000:3000 -d --name node-app docker-node-image` 
- Revisar contendor y verificar archivos

  

## Integración de imagen para desarrollo

- Realizar cambios a etiqueta H1 en `index.js` 
- Verificar que no hay cambios en la imagen con `docker exec -it node-app bash` y luego con `cat index.js` 

  
Un montaje de enlace (**_mount bind_**) es otro tipo de montaje, que le permite compartir un directorio desde el sistema de archivos del host en el contenedor. Al trabajar en una aplicación, puede usar un montaje de vinculación para montar el código fuente en el contenedor. El contenedor ve los cambios que realiza en el código inmediatamente, tan pronto como guarda un archivo. Esto significa que puede ejecutar procesos en el contenedor que observen cambios en el sistema de archivos y respondan a ellos.

  

- Usando un Mount Bind para sincronizar los archivos al contendor `docker run -v ${pwd}:/app -p 3000:3000 -d --name node-app docker-node-image` en powershell
- CMD  `docker run -v %cd%:/app -p 3000:3000 -d --name node-app docker-node-image` 
- Linux y MacOS `docker run -v $(pwd):/app -p 3000:3000 -d --name node-app docker-node-image`
- Modificar `index.js` y verificar que el contenido se actualiza dentro el contenedor
- Instalar nodemon  como dependencia dev `npm install nodemon --save-dev`
- Modificar `package.json`

```json
{
  "name": "docker-node",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon -L index.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.21"
  }
}
```

  

- Modificar Dockerfile

```javascript
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000 
CMD [ "npm", "run", "dev" ]
```
## Logs de contenedores

- Borrar carpeta `node_modules` 
- Utilizar `docker ps -a` para mostrar los contendores ejecutados
- Usar `docker logs NOMBRE_CONTENEDOR` para ver logs del contenedor
- Evitar que el bind mount sobreescriba la carpeta `node_modules` del contenedor con `docker run -v ${pwd}:/app -v /app/node_modules -p 3000:3000 -d --name node-app docker-node-image` 
- Entrar al contenedor con `docker exec -it node-app bash`
- Crear archivo dentro dl contenedor con `touch nombre_archivo`
- Para que el directorio del contenedor sea solo de lectura `docker run -v ${pwd}:/app:ro -v /app/node_modules -p 3000:3000 -d --name node-app docker-node-image`

## Variables de entorno

- Modificar Dockerfile

```javascript
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
ENV PORT 3000
EXPOSE $PORT
CMD [ "npm", "run", "dev" ]
```

  

- Reconstruir imagen `docker build -t docker-node-image .` 
- Ejecutar contenedor con `docker run -v ${pwd}:/app:ro -v /app/node_modules --env PORT=4000 -p 3000:4000 -d --name node-app docker-node-image` 
- Entrar al contenedor con `docker exec -it node-app bash`
- Imprimir variables de entorno con `printenv` 
- Crear archivo `.env` 

```bash
PORT=4000
```

- Eliminar contenedor con `docker rm node-app -f` 
- Eliminar imagen `docker image rm docker-node-image` 
- Reconstruir imagen `docker build -t docker-node-image .` 
- Ejecutar contenedor con `docker run -v ${pwd}:/app:ro -v /app/node_modules --env-file ./.env PORT=4000 -p 3000:4000 -d --name node-app docker-node-image` 

  

## Borrar Volúmenes

- Verificar volúmenes con `docker volumen ls` 
- Eliminar con `docker volume ID_VOLUMEN` o `docker volume prune` 
- Eliminar contenedor y volumen con `docker rm node-app -fv` 

  

## Docker compose

- Crear archivo `docker-compose.yml` 

```yaml
version: '3.8'
services:
  node-app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./:/app:ro
      - /app/node_modules
    environment:
      - PORT=3000
    #env_file:
      #- ./.env
```

- Ejecutar `docker-compose up -d`
- Para detener `docker-compose down -v`
- Comando para forzar la reconstrucción de imagen al usar compose  `docker-compose up -d --build` 

  

## Multiple Compose

- Modificar `Dockerfile`

```javascript
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
ENV PORT 3000
EXPOSE $PORT 
CMD [ "node", "index.js" ]
```

  

- Modificar `docker-compose.yml` 

```yaml
version: '3.8'
services:
  node-app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
```

  

- Crear `docker-compose-dev.yml` 

```yaml
version: '3.8'
services:
  node-app:
    build: .
    volumes:
      - ./:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm run dev
```

  

- Crear `docker-compose-prod.yml` 

```yaml
version: '3.8'
services:
  node-app:
    environment:
      - NODE_ENV=production
    command: node index.js
```

  

- Ejecutar dev mode con `docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build` 
- Para detener `docker-compose down -v` 
- Ejecutar prod mode con `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build` 
- Para detener `docker-compose -f docker-compose.yml -f docker-compose.prod.yml down -v` 
- Actualizar `.dockerignore` 

```
node_modules
Dockerfile
.git
.gitignore
docker-compose*
```