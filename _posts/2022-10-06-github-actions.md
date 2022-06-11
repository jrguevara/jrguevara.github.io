---
title: GitHub Actions
date: 2022-06-10 20:00:00 -500
categories: [despliegue, github, CI/CD]
tags: [github, CI/CD, calidad de software, programacion]
---

## Resumen

GitHub Actions es una plataforma de integración y despliegue continuos (IC/DC) que te permite automatizar tu mapa de compilación, pruebas y despliegue. Puedes crear flujos de trabajo y crear y probar cada solicitud de cambios en tu repositorio o desplegar solicitudes de cambios fusionadas a producción.

GitHub Actions va más allá de solo DevOps y te permite ejecutar flujos de trabajo cuando otros eventos suceden en tu repositorio. Por ejemplo, puedes ejecutar un flujo de trabajo para que agregue automáticamente las etiquetas adecuadas cada que alguien cree una propuesta nueva en tu repositorio.

GitHub proporciona máquinas virtuales Linux, Windows y macOS para que ejecutes tus flujos de trabajo o puedes hospedar tus propios ejecutores auto-hospedados en tu propio centro de datos o infraestructura en la nube.

## Los componentes de las GitHub Actions

Puedes configurar un flujo de trabajo de GitHub Actions para que se active cuando ocurre un evento en tu repositorio, tal como la apertura de una solicitud de cambios o la creación de una propuesta. Tu flujo de trabajo contiene uno o más jobs, los cuales pueden ejecutarse en orden secuencial o en paralelo. Cada job se ejecutará dentro del ejecutor de su propia máquina virtual o dentro de un contenedor y tendrá uno o más pasos que ya sea puedan ejecutar un script que definas o que ejecuten una acción, la cual es una extensión reutilizable que puede simplificar tu flujo de trabajo.

![GitHub Secrets](https://docs.github.com/assets/cb-25535/images/help/images/overview-actions-simple.png)
_Componentes de GituHub Actions_

## Flujos de trabajo

Un flujo de trabajo es un proceso automatizado configurable que ejecutará uno o más jobs. Los flujos de trabajo se definen mediante un archivo de YAML que se verifica en tu repositorio y se ejecutará cuando lo active un evento dentro de este o puede activarse manualmente o en una programación definida.

Los flujos de trabajo se definen en el directorio .github/workflows en un repositorio, y un repositorio puede tener varios flujos de trabajo, cada uno de los cuales puede realizar un conjunto diferente de tareas. Por ejemplo, puedes tener un flujo de trabajo para crear y probar las solicitudes de cambio, otro para desplegar tu aplicación cada que se cree un lanzamiento y todavía otro más que añadir una etiqueta cada que alguien abra una propuesta nueva.

## Eventos

Un evento es una actividad específica en un repositorio, la cual activa una ejecución de flujo de trabajo. Por ejemplo, la actividad puede originarse desde GitHub cuando alguien crea una solicitud de cambios, abre una propuesta o sube una confirmación a un repositorio. También puedes activar una ejecución de flujo de trabajo de acuerdo con una programación si la publicas en una API de REST o si lo haces manualmente.

Para encontrar una lista de eventos completa que puede utilizarse para activar flujos de trabajo, consulta los Eventos que activan flujos de trabajo.

## Jobs

Un job es un conjunto de pasos en un flujo de trabajo, los cuales se ejecutan en el mismo ejecutor. Cada paso es ya sea un script de shell o una acción que se ejecutarán. Los pasos se ejecutarán en orden y serán dependientes uno del otro. Ya que cada paso se ejecuta en el mismo ejecutor, puedes compartir datos de un paso a otro. Por ejemplo, puedes tener un paso que compile tu aplicación, seguido de otro que pruebe la aplicación que se compiló.

Puedes configurar las dependencias de un job con otros jobs; predeterminadamente, los jobs no tienen dependencias y se ejecutan en paralelo entre ellos. Cuando un job lleva una dependencia a otro job, este esperará a que el job dependiente se complete antes de que pueda ejecutarse. Por ejemplo, puedes tener jobs de compilación múltiple para arquitecturas diferentes que no tengan dependencias y un job de empaquetado que sea dependiente de estos jobs. Los jobs de compilación se ejecutarán en paralelo y, cuando se hayan completado con éxito, se ejecutará el job de empaquetado.

## Actions

Una acción es una aplicación personalizada para la plataforma de GitHub Actions que realiza una tarea compleja pero que se repite frecuentemente. Utiliza una acción para ayudarte a reducir la cantidad de código repetitivo que escribes en tus archivos de flujo de trabajo. Una acción puede extraer tu repositorio de git desde GitHub, configurar la cadena de herramientas correcta para tu ambiente de compilación o configurar la autenticación en tu proveedor de servicios en la nube.

Puedes escribir tus propias acciones o puedes encontrar acciones para utilizar en tus flujos de trabajo dentro de GitHub Marketplace.

*Fuente:* [*Entender las GitHub Actions*](https://docs.github.com/es/actions/learn-github-actions/understanding-github-actions)

# Uso practico de Github Actions

A continuacion utilizaremos Githubs Action para crea un flujo de despligue de archivos a un servidor compartido. Para esto sera necesario contar con una cuenta ftp a dicho servidor.

* Acceder a [FTP Deploy](https://github.com/marketplace/actions/ftp-deploy)

* Crear una estructura de archivos como la imagen

 ![GitHub Secrets](/assets/images/actions-1.png)
_Estructura de archivos_

* index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Actions</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>
```

* master.yaml

 ```yaml
 on: 
  push:
    branches:
      - master
name: 🚀 Desplegar on push master
jobs:
  web-deploy:
    name: 🎉 Deploy
    runs-on: ubuntu-latest
    steps:
    - name: 🚚 Obtener ultimas actualizaciones de codigo
      uses: actions/checkout@v2
    
    - name: 📂 Sincronizar archivos
      uses: SamKirkland/FTP-Deploy-Action@4.3.0
      with:
        server: ${{ secrets.ftp_server }}
        username: ${{ secrets.ftp_username }}
        password: ${{ secrets.ftp_password }}
        protocol: ftps
        server-dir: /public_html/
```

 * pruebas.yaml

 ```yaml
 on: 
  push:
    branches:
      - pruebas
name: 🚀 Desplegar on push pruebas
jobs:
  web-deploy:
    name: 🎉 Deploy
    runs-on: ubuntu-latest
    steps:
    - name: 🚚 Obtener ultimas actualizaciones de codigo
      uses: actions/checkout@v2
    
    - name: 📂 Sincronizar archivos
      uses: SamKirkland/FTP-Deploy-Action@4.3.0
      with:
        server: ${{ secrets.ftp_server }}
        username: ${{ secrets.ftp_username }}
        password: ${{ secrets.ftp_password }}
        protocol: ftps
        server-dir: /public_html/pruebas.jrcoding.net/
```

* Crear un repositorio en GitHub y despues configurarlo para replicar el proyecto local

``` powershell
git init
git add .
git commit -m "primer commit"
git remote add origin https://github.com/jrguevara/site.git
git push origin master
 ```

* Verificar actions en Github

![GitHub Secrets](/assets/images/actions.png)
_Actions GitHub_

* Ingresar Secrets en el repositorio de github

![GitHub Secrets](/assets/images/secret-1.png)
_Secrets GitHub_

* FTP_SERVER: ftp.sitio.com
* FTP_USERNAME: username
* FTP_PASSWORD: password

*Volver a actions y Re-run Jobs
* Proseguir con la creacion de ramas en github

``` powershell
git branch pruebas
checkout master
git branch actualizaciones
checkout actualizaciones
```

* Modificar parte del index.html mientras se esta en la rama **actualizaciones**
* Proseguir a añadir los cambios y hacer commit y push de la rama **actualizaciones**

``` powershell
git add .
git commit -m "nueva actualizacion"
git push origin actualizaciones
```

* Verificar que las acciones no se ejecutan ya que solo funcionan para **master** y **pruebas**
* Cambiar a rama **pruebas**, fusionar con **actualizaciones** y push la rama **pruebas**

``` powershell
git checkout pruebas
git merge actualizaciones
git push origin pruebas
```

* Verificar que la accion para despliegue en pruebas funciona correctamente
* Finalmente cambiar a la rama **master**, fusionar con **pruebas** y push la rama **master**

``` powershell
git checkout master
git merge pruebas
git push origin master
```