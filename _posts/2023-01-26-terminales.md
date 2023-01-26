---
title: Personalización de Terminales
date: 2023-01-23 00:00:00 -500
categories: [GCS]
tags: [windows, linux, shell, gestion de calidad de software]
published: true
hidden: false
---

# Terminal

## Windows Terminal vs. PowerShell: ¿Qué los hace diferentes? 

Se ven similares, pero bajo el capó, Windows Terminal y PowerShell actúan de manera muy diferente.  

Si usa Windows 10 u 11, encontrará PowerShell y Windows Terminal preinstalados en su sistema. En esencia, son esencialmente herramientas de línea de comandos para ingresar instrucciones (comandos) que le permiten realizar una variedad de tareas en su PC con Windows. Estas tareas incluyen la resolución de problemas, la automatización de tareas, la gestión de sistemas, la ejecución de diagnósticos y la administración de redes.  

  

## PowerShell es una mejora sobre el símbolo del sistema

Microsoft introdujo PowerShell en 2006 y hace todo lo que hace el símbolo del sistema (cmd) y algo más. Dado que Microsoft creó PowerShell sobre .NET Framework, puede usar lenguajes .NET, además de comandos basados ​​en texto, en la aplicación para interactuar con su sistema operativo. El lenguaje más popular para PowerShell es C# y le permite desbloquear las funciones avanzadas de la herramienta y aumentar su productividad.

Además de los comandos estándar, PowerShell tiene más de 200 cmdlets, un tipo especial de clase de C# que Microsoft define como "comandos ligeros". Cuando PowerShell los ejecuta, devuelven un objeto .NET que puede manipular.

Esto, por ejemplo, le permite no solo interactuar con programas en su computadora que funcionan con .Net Core, sino también procesar su entrada sin tener que escribir ningún código especial o complicado.

Además, si bien PowerShell puede ejecutar archivos por lotes como cmd, también permite una mayor automatización al permitirle programar cuándo se ejecutan las tareas. De esa manera, puede alinear tareas por adelantado y hacer otras cosas mientras deja que PowerShell haga lo suyo.

Estas son solo algunas de las formas en que PowerShell es mucho más poderoso que el símbolo del sistema. Entonces, mientras que Microsoft nos trajo PowerShell para llevar CommandPrompt al siguiente nivel, ¿cuál es el propósito de Windows Terminal?

## Terminal de Windows trajo BASH a Windows

 Microsoft presentó Windows Terminal en 2019 con Windows 10, y es un operador de terminal que admite casi cualquier shell de línea de comandos. La aplicación es más notable por traer una herramienta de línea de comandos a Windows que la comunidad ha envidiado durante mucho tiempo sobre Linux: BASH (Bourne Again Shell).

Además, otra gran característica de Windows Terminal es el cambio a una interfaz con pestañas más moderna que le permite ejecutar varias utilidades de línea de comandos. Por ejemplo, puede tener varias instancias de Símbolo del sistema ejecutándose o abrir cmd, PowerShell, BASH y Azure a la vez.  

Además, puedes usar emojis y caracteres especiales de otros idiomas en Windows Terminal gracias a su compatibilidad con Unicode y UTF. Y con su nuevo motor de renderizado de texto de GPU acelerado, puede mostrarlos sin saltarse nada. También puede personalizar la interfaz de la aplicación dándole diferentes esquemas de color, imágenes de fondo (también admite GIF) y configuraciones.  

Windows Terminal es un proyecto de código abierto y la comunidad de línea de comandos de Windows lo está desarrollando activamente. Esta es una comunidad apasionada por el proyecto y apoyará continuamente la aplicación, mejorará su rendimiento y agregará más funciones (los contribuyentes priorizarán las más solicitadas, por supuesto).

  

## NerdFonts

- Instalar Nerd Font preferentemente con soporte con ligaturas por ejemplo FiraCode [https://www.nerdfonts.com/](https://www.nerdfonts.com/)

## Windows Terminal

- Descargar e instalar Terminal para Windows / PowerShell
![Terminal](/assets/images/terminal-000.png)_Terminal_

- Abrir Terminal en windows y cambiar el perfil por defecto, inicialmente es Command Prompt. Seleccionar una de las opciones decargadas en el paso anterior

![Terminal](/assets/images/terminal-00.png)_Terminal_ 

  

- Configurar preferencias por terminal por ejemplo imagen de fondo, transparencia de la ventana, tipo de fuente (NerdFont), etc.

![Terminal](/assets/images/terminal-01.png)_Terminal_

## Oh My Posh

- Instalar Oh My Posh [https://ohmyposh.dev/docs/installation/windows](https://ohmyposh.dev/docs/installation/windows)
- Instalacion global

```bash
winget install JanDeDobbeleer.OhMyPosh -s winget
```

  

- Instalacion por Usuario 

```bash
Install-Module oh-my-posh -Scope CurrentUser
```

  

- Para utilizar Oh My Posh ([https://ohmyposh.dev/docs/installation/prompt](https://ohmyposh.dev/docs/installation/prompt)) se necesita crear/editar el archivo `$PROFILE` 

```bash
notepad $PROFILE
```

![Terminal](/assets/images/terminal-02.png)_Terminal_

- Agregrar la siguiente linea al archivo de perfil

```bash
oh-my-posh init pwsh | Invoke-Expression
```

- Terminal hasta este momento deberia lucir asi:

![Terminal](/assets/images/terminal-03.png)_Terminal_

  

## Temas de Oh My Posh

- Para obtener e instalar los temas disponibles ([https://ohmyposh.dev/docs/themes](https://ohmyposh.dev/docs/themes)) ejecutamos el comando

  

```bash
Get-PoshThemes
```

  

- Editar el archivo de perfil, donde colocamos el nombre del tema a utilizar, en este ejemplo powerlevel10k Rainbow

```bash
oh-my-posh --init --shell pwsh --config ~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression
```

  

## PSReadLine

- Este modulo permite autocompletar los comandos en la terminal y mostrar si se desea una lista de comandos usados con anterioridad
- Repositorio: [https://github.com/PowerShell/PSReadLine](https://github.com/PowerShell/PSReadLine)

```bash
Install-Module PSReadLine
```

- Editar el archivo de perfil:

```bash
oh-my-posh --init --shell pwsh --config ~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
```

  

## Iconos de Terminal

- Permite ver los archivos en las carpetas con sus iconos conrrespondientes
- Repositorio: [https://github.com/devblackops/Terminal-Icons](https://github.com/devblackops/Terminal-Icons)

```bash
Install-Module -Name Terminal-Icons -Repository PSGallery
```

- Editar el archivo de perfil:

```bash
oh-my-posh --init --shell pwsh --config ~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
Import-Module -Name Terminal-Icons
#Get-ChildItem | Format-List
#Get-ChildItem | Format-Wide
```

  

## WinFetch

- Muestra informacion del sistema al iniciar la terminal
- Repositorio: [https://github.com/lptstr/winfetch](https://github.com/lptstr/winfetch)

```bash
Install-Script winfetch
```

- Editar el archivo de perfil:

```bash
oh-my-posh --init --shell pwsh --config ~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
Import-Module -Name Terminal-Icons
#Get-ChildItem | Format-List
#Get-ChildItem | Format-Wide
winfetch
```

  

- Para personalizar la informacion que se muestra editar adecuadamente el archivo `~\.config\winfetch\config.ps1` 

## Resultado Final

![Terminal](/assets/images/terminal-04.png)_Terminal_ 

 

## Personalizar consola de Ubuntu

  

## BASH Shell

- Verificar actualizaciones con el comando `sudo apt update`  
    
- Instalar neofetch muestra informacion del sistema

```bash
sudo apt install neofetch
```

  

- Instalar git y curl

```bash
sudo apt install git
sudo apt install curl
```

  

- Comando `ls` muestra lista de archivos en una carpeta, `ls -la` muestra los ocultos
- Instalar Oh My Bash [https://github.com/ohmybash/oh-my-bash](https://github.com/ohmybash/oh-my-bash)  
    

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

  

- Listado de temas [https://github.com/ohmybash/oh-my-bash/tree/master/themes](https://github.com/ohmybash/oh-my-bash/tree/master/themes)
- Instalar fuentes e iconos [https://github.com/powerline/fonts](https://github.com/powerline/fonts)

```bash
sudo apt-get install fonts-powerline
```

  

- editar el archivo `.bashrc`

```bash
nano .bashrc
```

  

- Editar linea del tema: `OSH_THEME="powerline-multiline"`
- Agregar al final del archivo `neofetch`

  

## ZSH Shell

- el comando `echo $SHELL` muestra la shell que actualmente se esta utilizando
- Instalar Shel ZSH

```bash
sudo apt install zsh
```

  

- Cambiar shell con el comando `chsh`

```bash
/bin/zsh
```

  

- Crear archivo de configuracion con opcion 0
- Verificar archivo creado con `cat ~/.zshrc`
- Instalar Oh My ZSH [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

  

- Instalar autosugerencias para ZSH [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

  

- Instalar Syntax Highlinghting para ZSH [https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

  

- Editar archivo `.zshrc` 

```bash
nano .zshrc
```

  

- Editar linea en el archivo `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)` 
- Instalar font awesome 
    
```bash
sudo apt install -y fonts-font-awesome
```
    
      
    
- Instalar Powerlevel10k [https://github.com/romkatv/powerlevel10k#oh-my-zsh](https://github.com/romkatv/powerlevel10k#oh-my-zsh)

  

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

  

- Editar archivo `.zshrc` modificar la linea `ZSH_THEME="powerlevel10k/powerlevel10k"` 
- Al reiniciar la terminal se nos mostrara la configuracion paso a paso, en caso de no aparecer escribir el comando `p10k configure`
- Para agregar NeoFetch agragamos las siguientes lineas al archivo `.zshrc`

```bash
neofetch
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
```

  

## Resultado final:

![Terminal](/assets/images/terminal-05.png)_Terminal_