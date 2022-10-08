---
title: LEMP Stack en EC2 Amazon Linux 2
date: 2022-10-07 00:00:00 -500
categories: [aws]
tags: [LEMP, nube, AWS, Linux]
published: true
hidden: false
---


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