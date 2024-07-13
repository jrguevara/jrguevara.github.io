---
title: Ubuntu LEMP Stack
date: 2024-04-04 00:00:00 -500
categories: [aws]
tags: [LEMP, nube, aws, Ubuntu]
published: true
hidden: false
---

## ¿Qué es LEMP?

LEMP es una variación de la omnipresente pila LAMP utilizada para desarrollar e implementar aplicaciones web.  Tradicionalmente, LAMP consta de Linux, Apache, MySQL y PHP.  Debido a su naturaleza modular, los componentes se pueden intercambiar fácilmente.  Con LEMP, Apache se reemplaza con el Nginx ligero pero potente.

### ¿Por qué LEMP en lugar de LNMP?

Elegimos LEMP debido a la pronunciación de Nginx: Engine-X (en-juhn-ecks).  Piense en cómo en inglés, el artículo an se usa en lugar de a por hora a pesar de que comienza con una consonante.  La importancia es el sonido de la primera letra más que su representación escrita.  Además, LEMP es en realidad pronunciable y no suena como recitar el alfabeto.

![LEMP](https://lemp.io/wp-content/uploads/2021/03/lemp-stack-components-300x177-1.png)

### LINUX

Un sistema operativo similar a Unix de código abierto proporciona la base para los componentes de la pila.  Muchas distribuciones incluyen sistemas de gestión de paquetes que facilitan la instalación de las aplicaciones deseadas.  Sin embargo, estas versiones del repositorio generalmente no serán las más actuales.  Dos de las distribuciones de Linux más utilizadas en pilas LEMP son Debian y Ubuntu.

### Nginx

Nginx es un servidor proxy inverso de código abierto para los protocolos HTTP, HTTPS, SMTP, POP3 e IMAP.  También funciona como equilibrador de carga, caché HTTP y servidor web (servidor de origen).  Tiene un fuerte enfoque en alta concurrencia, alto rendimiento y bajo uso de memoria.  El proyecto HTML5 Boilerplate tiene archivos de configuración de servidor de muestra para mejorar el rendimiento y la seguridad.

### MYSQL

MySQL es el segundo sistema de gestión de bases de datos relacionales de código abierto más utilizado.  Una bifurcación desarrollada por la comunidad, MariaDB, está dirigida por los desarrolladores originales.  Su objetivo es ser un reemplazo directo.

### PHP

PHP es un lenguaje de secuencias de comandos del lado del servidor diseñado para el desarrollo web.  La función de secuencias de comandos también se puede cumplir con Python o Perl.  Los servidores como Gunicorn o uWSGI se pueden usar junto con Nginx para servir estas aplicaciones.

- Verificar actualizaciones

```powershell
sudo apt update
sudo apt upgrade
sudo reboot
```


## Personalizar Terminal

- el comando `echo $SHELL` muestra la shell que actualmente se esta utilizando
- Instalar Shel ZSH

```powershell
sudo apt install zsh
```


- Cambiar shell con el comando:

```powershell
sudo chsh -s /bin/zsh ubuntu
```


- Alternativamente ejecutar `nano /etc/passwd`  y editar el usuario ubuntu cambiando `/bin/bash` a `/bin/zsh` 
- verificar existencia del archivo `.zshrc` con el comando `ls -a`

- Instalar Oh My ZSH [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

```powershell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```


- Instalar autosugerencias para ZSH [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

```powershell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```


- Instalar Syntax Highlinghting para ZSH [https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

```powershell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```


- Editar archivo `.zshrc` 

```powershell
nano .zshrc

```


- Editar linea en el archivo `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)` 
- Instalar font awesome 

```powershell
sudo apt install -y fonts-font-awesome
```

- Instalar Powerlevel10k [https://github.com/romkatv/powerlevel10k#oh-my-zsh](https://github.com/romkatv/powerlevel10k#oh-my-zsh)


```powershell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```


- Editar archivo `.zshrc` modificar la linea `ZSH_THEME="powerlevel10k/powerlevel10k"` 
- Al reiniciar la terminal se nos mostrara la configuración paso a paso, en caso de no aparecer escribir el comando `p10k configure`


## NGINX/PHP/PHP-FPM/MYSQL

```powershell
sudo apt install nginx
nginx -v
sudo apt install php-fpm php-mysql
php -v
php-fpm8.1 -v
sudo apt install mysql-server
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'JR_w3b51t35';
exit
sudo mysql_secure_installation
```


## Sitio Web


Crear directorio para sitio web con: sudo 

```powershell
mkdir /var/www/site1.dev

```


Cambiar el propietario de la carpeta con:

```powershell
sudo chown -R www-data:www-data /var/www/html/site1.dev
sudo chown -R $USER:$USER /var/www/site1.dev

```


Crear archivo de configuración de virtual host;

```powershell
sudo nano /etc/nginx/sites-available/site1.dev

```


Contenido del archivo:

```plaintext
server {
    listen 80;
    server_name site2.dev www.site2.dev;
    root /var/www/site2.dev;

    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
     }
    location ~ /\.ht {
        deny all;
    }
}
```


Deshabilitar el virtual host por defecto:

```powershell
sudo unlink /etc/nginx/sites-enabled/default

```


Habilitar el virtual host:  

```powershell
sudo ln -s /etc/nginx/sites-available/site1.dev /etc/nginx/sites-enabled/
```


Comprobar que la configuración de nginx esta correcta y recargar nginx

```powershell
sudo nginx -t
sudo systemctl reload nginx
```


Crear archivo `index.html` en la carpeta del sitio

```powershell
sudo nano /var/www/site1.dev/index.html
```


Contenido de `index.html`

```html
<html>
  <head>
    <title>Sitio Web</title>
  </head>
  <body>
    <h1>Hello World!</h1>
    <p>Esta es la pagina de inicio <strong>Sitio Web</strong>.</p>
  </body>
</html>
```


- Crear archivo `info.php` en la carpeta del sitio

```powershell
sudo nano /var/www/site1.dev/info.php
```


Contenido de `info.php`

```php
<?php
phpinfo();
```

## Instalación de otras versiones de php

Primero instalar `software-properties-common`, el cual permite gestion de diferentes repositorios de software

```powershell
sudo apt install software-properties-common

```


Instalar el repositorio `ppa:ondrej/php`, el cual dará acceso a las diferentes versiones de php

```powershell
sudo add-apt-repository ppa:ondrej/php

```

Actualizar `apt-get` para poder ver los nuevos paquetes:

```powershell
sudo apt-get update

```


Instalar las extenciones que se necesite de PHP

```powershell
sudo apt-get install php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php7.4-pspell  php7.4-intl  php7.4-xmlrpc php7.4-ldap php7.4-soap php7.4-fpm
``` 

- `php7.4-cli` \- command interpreter, useful for testing PHP scripts from a shell or performing general shell scripting tasks
- `php7.4-json` \- for working with JSON data
- `php7.4-common` \- documentation, examples, and common modules for PHP
- `php7.4-mysql` \- for working with MySQL databases
- `php7.4-zip` \- for working with compressed files
- `php7.4-gd` \- for working with images
- `php7.4-mbstring` \- used to manage non-ASCII strings
- `php7.4-curl` \- lets you make HTTP requests in PHP
- `php7.4-xml` \- for working with XML data
- `php7.4-bcmath` \- used when working with precision floats



## Habilitar e instalar certificado SSL

```powershell
sudo apt-get install python3-certbot-nginx
sudo certbot --nginx -d site1.dev -d www.site1.dev
```

## Habilitar SSH

```powershell
sudo apt-get install python3-certbot-nginx
sudo certbot --nginx -d site1.dev -d www.site1.dev
```

  

## Instalar phpmyadmin

- Actualizar de ser necesario `sudo apt update`
- Instalar libreria

```
sudo apt-get install php8.1-mbstring
```

  

- Desabilitar componente de validacion de password

```powershell
mysql -u root -p
mysql> UNINSTALL COMPONENT "file://component_validate_password";
mysql> exit
```

  

- instalar phpmyadmin `sudo apt install phpmyadmin` 
- 

Durante el proceso de instalación, se le pedirá que elija un servidor web (ya sea Apache o Lighttpd) para configurar. phpMyAdmin puede realizar automáticamente una serie de cambios de configuración para garantizar que funcione correctamente con cualquiera de estos servidores web durante la instalación. Sin embargo, debido a que está utilizando Nginx como servidor web, no debe elegir ninguna de estas opciones. En su lugar, presione TAB para resaltar <Ok> y luego presione ENTER para continuar con el proceso de instalación. A continuación, se le preguntará si desea utilizar dbconfig-common para configurar la base de datos de la aplicación. Seleccione <Sí>. Esto configurará la base de datos interna y el usuario administrativo de phpMyAdmin. Se le pedirá que defina una nueva contraseña para el usuario MySQL de phpmyadmin, pero como no es una contraseña que necesita recordar, puede dejarla en blanco y dejar que phpMyAdmin cree una contraseña aleatoriamente.

  

- Una vez que se complete el comando apt install, phpMyAdmin estará completamente instalado. Sin embargo, para que el servidor web Nginx encuentre y proporcione los archivos phpMyAdmin correctamente, deberá crear un enlace simbólico desde los archivos de instalación al directorio raíz de documentos de Nginx. 

`sudo ln -s /usr/share/phpmyadmin /var/www/site1.dev/phpmyadmin` 

- Crear usuario admin con todos los privilegios
    
```powershell
mysql -u root -p
mysql> CREATE USER 'admin'@'localhost' IDENTIFIED BY 'JR_d4t4b453';
mysql> GRANT ALL PRIVILEGES ON * . * TO 'admin'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> exit
```  

- Para restaurar la verificacion de password en mysql utilizar:

```powershell
mysql -u root -p
mysql> INSTALL COMPONENT "file://component_validate_password";
mysql> exit
```
- Acceder a phpmyadmin desde: [https://site1.dev/phpmyadmin](https://server_domain_or_IP/phpmyadmin)



## Instalar Node Version Manager

- Instalar NVM siguiendo instrucciones de la pagina oficial
[https://github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)

```powershell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

source ~/.zshrc
```
- Instalaa la version de node que se necesite, en este caso la mas reciente

```powershell
nvm install node
node -v
npm -v
```

## Instalar PM2

- Instalar PM2 globalmente

```powershell
npm install pm2 -g
```

- Iniciar PM2

```powershell
pm2 start app.js
```

-- Iniciar aplicacion con nombre

```powershell
pm2 start app.js --name="app_name"
```

- Listar aplicaciones en PM2

```powershell
pm2 list
pm2 status
```

- Detener aplicacion en PM2

```powershell 
pm2 stop app_name_or_id
```

- Eliminar aplicacion de PM2

```powershell
pm2 delete app_name_or_id
```

- Reiniciar aplicacion en PM2

```powershell
pm2 restart app_name_or_id
```


- Habilitar PM2 para iniciar en el arranque

```powershell
pm2 startup
pm2 save
```

## Configurar Nginx para proxy con PM2

- Crear archivo de configuracion en `/etc/nginx/sites-available/app_name`

```powershell
sudo nano /etc/nginx/sites-available/app_name
```

- Contenido del archivo

```plaintext
server {
        listen 80;
        server_name app_name.dev www.app_name.dev;
        location / {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
    }
}
```

- Habilitar el virtual host

```powershell
sudo ln -s /etc/nginx/sites-available/app_name /etc/nginx/sites-enabled/
``` 

- Comprobar que la configuración de nginx esta correcta y recargar nginx

```powershell
sudo nginx -t
sudo systemctl reload nginx
```

## Configurar PhpMyAdmin para conectarse a servidor AWS RDS

- Editar archivo de configuracion de phpmyadmin

```powershell
sudo nano /etc/phpmyadmin/config.inc.php
```

- Agregar las siguientes lineas al archivo

```php
$i++;
$cfg['Servers'][$i]['host'] = 'RDS Hostname';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['user'] = 'RDS Username';
$cfg['Servers'][$i]['password'] = 'RDS Password';
$cfg['Servers'][$i]['socket'] = '';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
```