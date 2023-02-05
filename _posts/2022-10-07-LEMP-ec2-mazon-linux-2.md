---
title: LEMP Stack en EC2 Amazon Linux 2
date: 2022-10-07 00:00:00 -500
categories: [aws]
tags: [LEMP, nube, AWS]
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

## Actualizar el servidor Amazon Linux AMI 2

- Verificar actualizaciones

```powershell
sudo su
yum check-update
sudo yum update -y
```

  

- Verificar paquetes instalados

```powershell
yum list installed
yum repolist all
sudo amazon-linux-extras list | grep epel
sudo amazon-linux-extras enable epel
sudo yum install epel-release
```

  

- De existir una actualización de kernel reiniciar el servidor  
    

```powershell
sudo reboot
```

  

## Instalar Nginx web server

- Buscar paquete de instalación

```powershell
sudo yum list nginx*
sudo yum info nginx
sudo yum install nginx
sudo amazon-linux-extras install nginx1
```

  

- Verificar status del servicio

```powershell
sudo service nginx status
sudo service nginx start
sudo chkconfig nginx on
```

  

- Comandos básicos

```powershell
sudo systemctl stop nginx
sudo systemctl start nginx
sudo systemctl reload nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl disable nginx
```

  

## Instalar PHP  

```powershell
sudo amazon-linux-extras install php8.0
sudo service php-fpm start
sudo chkconfig php-fpm on
```

  

- Añadir `ec2-user` al grupo `nginx`

```powershell
sudo usermod -a -G nginx ec2-user
exit
groups
```

  

- Cambie la propiedad de grupo de `/usr/share/nginx` y su contenido al grupo `nginx`

```powershell
sudo chown -R ec2-user:nginx /usr/share/nginx
```

  

- Para agregar permisos de escritura de grupo y establecer el ID de grupo en futuros subdirectorios, cambie los permisos del directorio `/usr/share/nginx` y sus subdirectorios.

```powershell
sudo chmod 2775 /usr/share/nginx
find /usr/share/nginx -type d -exec sudo chmod 2775 {} \;
```

  

- Para agregar permisos de escritura de grupo, cambie recursivamente los permisos de archivo de `/usr/share/nginx` y sus subdirectorios

```powershell
find /usr/share/nginx -type f -exec sudo chmod 0664 {} \;
```

  

- Crear archivo `phpinfo.php` en la carpeta inicial de nginx

```powershell
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/phpinfo.php
```

  

- Remover archivo `phpinfo.php`

```powershell
rm /usr/share/nginx/html/phpinfo.php
```

  

## Instalar MariaDB

```powershell
sudo amazon-linux-extras install mariadb10.5
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
sudo systemctl stop mariadb

sudo yum makecache
sudo mysql_upgrade

mysql -u root -p
```

  

## Instalar phpMyAdmin

- Instalar dependencias

```powershell
sudo yum install php-mbstring php-xml
sudo service nginx restart
sudo service php-fpm restart
```

  

- Navegar a folder 

```powershell
cd /usr/share/nginx/html
```

  

- Descargar una version de phpMyAdmin

```powershell
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
```

  

- Crear folder phpMyAdmin y extraer contenido del archivo que se descargo

```powershell
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
```

  

- Borrar archivo

```powershell
rm phpMyAdmin-latest-all-languages.tar.gz
```

  

- Iniciar servicio de MariaDB

```powershell
sudo systemctl start mariadb
```

  

- Crear configuración para phpMyAdmin
```powershell
cp -a config.sample.inc.php config.inc.php
nano config.inc.php
mkdir tmp
chmod 777 tmp
```

- Configuración de PHP-FPM

  

```powershell
sudo nano /etc/php-fpm.d/www.conf
```

  

```bash
user = nginx
group = nginx
listen = /var/run/php-fpm/www.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
;listen.acl_users = apache,nginx

```

  

```powershell
 sudo nano /etc/nginx/nginx.conf

```

  

```bash
server {
        listen       80;
        listen       [::]:80;
        server_name  localhost;
        root         /usr/share/nginx/html;
	  index	index.html index.htm index.php;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }

	location ~ \.php$ {
		try_files $uri =404;
		include fastcgi_params;
		fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_index index.php;
		# fastcgi_intercept_errors on;
		# fastcgi_keep_conn on;
		# fastcgi_read_timeout 300;
	
	        # fastcgi_pass   127.0.0.1:9000;
		fastcgi_pass  unix:/var/run/php-fpm/www.sock;
		#for ubuntu unix:/var/run/php/php8.0-fpm.sock;

                # FastCGI cache config
	        # fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=WORDPRESS:10m max_size=1000m inactive=60m;
		# fastcgi_cache_key $scheme$host$request_uri$request_method;
		# fastcgi_cache_use_stale updating error timeout invalid_header http_500;        
                fastcgi_cache_valid any 30m;
	}
}

```

  

```powershell
sudo service nginx restart
sudo service php-fpm restart
sudo service nginx restart
sudo service php-fpm status

ls -al /var/run/php-fpm/www.sock
netstat -al --protocol=unix |egrep "Proto|fpm"
chmod -R 777 /var/lib/php/session
```