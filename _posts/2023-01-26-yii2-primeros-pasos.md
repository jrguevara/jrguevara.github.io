---
title: Yii2 Primeros pasos
date: 2023-01-26 03:00:00 -500
categories: [yii2]
tags: [yii2, frameworks, programacion, php]
---

## Yii2 Primeros pasos

![Yii2](/assets/images/yii3_full_for_dark.png)_Yii2_   

[https://www.yiiframework.com/](https://www.yiiframework.com/)  

## ¿Qué es Yii?

Yii es un framework de PHP de alto rendimiento, basado en componentes para desarrollar aplicaciones web modernas en poco tiempo. El nombre Yii significa "simple y evolutivo" en chino. También se puede considerar como el acrónimo de _**Yes It Is**_ (que en inglés significa _**Sí, lo es**_)!

## ¿En qué es mejor Yii?

Yii es un framework genérico de programación web, lo que significa que se puede utilizar para desarrollar todo tipo de aplicaciones web en PHP. Debido a su arquitectura basada en componentes y a su sofisticada compatibilidad de caché, es especialmente apropiado para el desarrollo de aplicaciones de gran envergadura, como páginas web, foros, sistemas de gestión de contenidos (CMS), proyectos de comercio electrónico, servicios web compatibles con la arquitectura REST y muchos más.

## ¿Cómo se compara Yii con otros frameworks?

Si estás ya familiarizado con otros framework, puedes apreciar como se compara Yii con ellos:

- Como la mayoría de los framework de PHP, Yii implementa el patrón de diseño MVC (Modelo-Vista-Controlador) y promueve la organización de código basada en este patrón.
- La filosofía de Yii consiste en escribir el código de manera simple y elegante, sin sobrediseñar nunca por el mero hecho de seguir un patrón de diseño determinado.
- Yii es un framework completo (full stack) que provee muchas características probadas y listas para usar, como los constructores de consultas y la clase ActiveRecord para las bases de datos relacionales y NoSQL, la compatibilidad con la arquitectura REST para desarrollar API, la compatibilidad de caché en varios niveles y muchas más.
- Yii es extremadamente extensible. Puedes personalizar o reemplazar prácticamente cualquier pieza de código de base, como se puede también aprovechar su sólida arquitectura de extensiones para utilizar o desarrollar extensiones distribuibles.
- El alto rendimiento es siempre la meta principal de Yii.

Yii no es un proyecto de un sola persona, detrás de Yii hay un [sólido equipo de desarrollo](https://www.yiiframework.com/team/), así como una gran comunidad en la que numerosos profesionales contribuyen constantemente a su desarrollo. El equipo de desarrollo de Yii se mantiene atento a las últimas tendencias de desarrollo web, así como a las mejores prácticas y características de otros frameworks y proyectos. Las buenas prácticas y características más relevantes de otros proyectos se incorporan regularmente a la base del framework y se exponen a través de interfaces simples y elegantes.

## Versiones de Yii

Actualmente existen dos versiones principales de Yii: la versión 1.1 y la versión 2.0. Para la versión 1.1, que es de la generación anterior, actualmente solo se ofrece mantenimiento. La versión 2.0 está completamente reescrita y adopta las últimas tecnologías y protocolos, incluidos Composer, PSR, namespaces, traits, etc. La versión 2.0 representa la actual generación del framework y su desarrollo recibirá el principal esfuerzo en los próximos años. Esta guía está basada principalmente en la versión 2.0. del framework.

## Requisitos y Prerequisitos

Yii 2.0 requiere PHP 5.4.0 o una versión posterior y corre de mejor manera en la última versión de PHP. Se pueden encontrar requisitos más detallados de características individuales ejecutando el script de comprobación incluido en cada lanzamiento de Yii.

Para utilizar Yii se requieren conocimientos básicos de programación orientada a objetos (POO), porque el framework Yii se basa íntegramente en esta tecnología. Yii 2.0 hace uso también de las últimas características de PHP, como [namespaces](https://www.php.net/manual/es/language.namespaces.php) y [traits](https://www.php.net/manual/es/language.oop5.traits.php). Comprender estos conceptos te ayudará a entender mejor Yii 2.0.

- Guía Definitiva de Yii 2.0: [https://www.yiiframework.com/doc/guide/2.0/es](https://www.yiiframework.com/doc/guide/2.0/es)
- Guía de instalación para plantilla basica: [https://www.yiiframework.com/doc/guide/2.0/es/start-installation](https://www.yiiframework.com/doc/guide/2.0/es/start-installation)
- Guía de instalación para plantilla avanzada: [https://www.yiiframework.com/extension/yiisoft/yii2-app-advanced/doc/guide/2.0/es/start-installation](https://www.yiiframework.com/extension/yiisoft/yii2-app-advanced/doc/guide/2.0/es/start-installation)
  

| Característica | Básica | Avanzada |
| --- | --- | --- |
| Estructura del proyecto | ✓   | ✓   |
| Controlador site | ✓   | ✓   |
| Usuario login/logout | ✓   | ✓   |
| Formularios | ✓   | ✓   |
| Conexión DB | ✓   | ✓   |
| Comandos de consola | ✓   | ✓   |
| Asset bundle | ✓   | ✓   |
| Tests con Codeception | ✓   | ✓   |
| Twitter Bootstrap | ✓   | ✓   |
| Front- y back-end apps |     | ✓   |
| Modelo User listo para usar |     | ✓   |
| Registro de usuarios y restablecimiento de contraseña |     | ✓   |

## Estructura de la aplicación

Los archivos y directorios más importantes en tu aplicación son (asumiendo que la raíz de la aplicación es `basic`):

```plaintext
basic/                  base path de la aplicación
    composer.json       archivo utilizado por Composer, describe información de sus paquetes y librerías
    config/             contiene la configuración de las aplicaciones (y otras)
        console.php     configuración de la aplicación de consola
        web.php         configuración de la aplicación web
    commands/           contiene las clases de comandos de consola
    controllers/        contiene las clases de los controladores
    models/             contienes las clases del modelo
    runtime/            contiene archivos generados por Yii en tiempo de ejecución, como archivos de log y cache
    vendor/             contiene los paquetes y librerías instalados por Composer, incluyendo el propio núcleo de Yii
    views/              contiene los archivos de vistas (templates)
    web/                raíz web de la aplicación, contiene los archivos accesibles vía Web
        assets/         contiene los assets publicados (javascript y css) por Yii
        index.php       el script de entrada (o bootstrap) de la aplicación
    yii                 el script de ejecución de los comandos de consola de Yii

```

En general, los archivos de la aplicación pueden ser divididos en dos: aquellos bajo `basic/web` y aquellos bajo otros directorios. Los primeros pueden accederse directo por HTTP (ej., en un navegador), mientras que los últimos no pueden ni deben ser accedidos así.

Yii implementa el patrón de diseño [modelo-vista-controlador (MVC)](https://wikipedia.org/wiki/Model-view-controller), que es reflejado en la estructura de directorios utilizada. El directorio `models` contiene todas las [clases del modelo](https://www.yiiframework.com/doc/guide/2.0/es/structure-models), el directorio `views` contiene todas las [vistas (templates)](https://www.yiiframework.com/doc/guide/2.0/es/structure-views), y el directorio `controllers` contiene todas las [clases de controladores](https://www.yiiframework.com/doc/guide/2.0/es/structure-controllers).

El siguiente diagrama muestra la estructura estática de una aplicación.  

![Yii2](/assets/images/yii-00.png)_Diagrama Yii2_ 

Cada aplicación tiene un script de entrada `web/index.php` que es el único script PHP accesible vía web. El script de entrada toma una petición (request) entrante y crea una instancia de una [aplicación](https://www.yiiframework.com/doc/guide/2.0/es/structure-applications) para manejarlo. La [aplicación](https://www.yiiframework.com/doc/guide/2.0/es/structure-applications) resuelve la petición (request) con la ayuda de sus [componentes](https://www.yiiframework.com/doc/guide/2.0/es/concept-components), y la envía al resto de los elementos MVC. Los [widgets](https://www.yiiframework.com/doc/guide/2.0/es/structure-widgets) son usados en las [vistas](https://www.yiiframework.com/doc/guide/2.0/es/structure-views) para ayudar a construir elementos de interfaz complejos y dinámicos.

## Ciclo de Vida de una Petición (Request)

El siguiente diagrama muestra cómo una aplicación maneja una petición.

![Yii2](/assets/images/yii-01.png)_Diagrama Yii2_ 

1. Un usuario realiza una petición al [script de entrada](https://www.yiiframework.com/doc/guide/2.0/es/structure-entry-scripts) `web/index.php`.
2. El script de entrada carga la [configuración](https://www.yiiframework.com/doc/guide/2.0/es/concept-configurations) de la aplicación y crea una instancia de la [aplicación](https://www.yiiframework.com/doc/guide/2.0/es/structure-applications) para manejar la consulta.
3. La aplicación resuelve la [ruta](https://www.yiiframework.com/doc/guide/2.0/es/runtime-routing) solicitada con la ayuda del componente [request](https://www.yiiframework.com/doc/guide/2.0/es/runtime-requests) de la aplicación.
4. La aplicación crea una instancia de un [controlador](https://www.yiiframework.com/doc/guide/2.0/es/structure-controllers) para manejar la petición.
5. El controlador crea una instancia de una [acción](https://www.yiiframework.com/doc/guide/2.0/es/structure-controllers) y ejecuta los filtros de dicha acción.
6. Si alguno de los filtros falla, la acción es cancelada.
7. Si todos los filtros pasan, la acción es ejecutada.
8. La acción carga datos del modelo, posiblemente de la base de datos.
9. La acción renderiza una vista, pasándole los datos del modelo cargado.
10. El resultado de la renderización es pasado al componente [response](https://www.yiiframework.com/doc/guide/2.0/es/runtime-responses) de la aplicación.
11. El componente response envía el resultado de la renderización al navegador del usuario.

  

## Hola Mundo!

- Crear archivo `Controllers/InicioController.php` 

```php
<?php

namespace app\controllers;

use app\models\InicioForm;
use Yii;
use yii\filters\AccessControl;
use yii\web\Response;
use yii\filters\VerbFilter;
use yii\web\Controller;

class InicioController extends Controller
{
    public function actionIndex(
)
    {
        echo "Hola Mundo"!
    }
}
```

  

## Controlador / Vista

- Crear archivo `views/inicio/index.php`

```php
<div class="site-index">
    <div class="jumbotron">
        <h1><?= $mensaje ?></h1>
        <h2><?= $h2 ?></h2>
        <h2><?= date_format($dateTime, 'Y-m-d H:i:s'); ?></h2>
    </div>
</div>
```

  

- Modificar archivo `Controllers/InicioController.php` 

```php
<?php

namespace app\controllers;

use app\models\InicioForm;
use Yii;
use yii\filters\AccessControl;
use yii\web\Response;
use yii\filters\VerbFilter;
use yii\web\Controller;

class InicioController extends Controller
{
    public function actionIndex(
)
    {
        $mensaje = 'Yes, it is';
        $h2 = 'UNIVO';
        $dateTime = new \DateTime();

        return $this->render(
            'index',
            [
                'mensaje' => $mensaje,
                'h2' => $h2,
                'dateTime' => $dateTime,
            ]
        );
    }
}
```

  

## Ejemplo de Resta

- Crear vista `views/inicio/resta.php`

```php
<div class="site-index">
    <div class="jumbotron">
        <h1><?= $resultado ?></h1>
    </div>
</div>
```

  

- Modificar archivo `Controllers/InicioController.php` 

```php
<?php

namespace app\controllers;

use app\models\InicioForm;
use Yii;
use yii\filters\AccessControl;
use yii\web\Response;
use yii\filters\VerbFilter;
use yii\web\Controller;

class InicioController extends Controller
{
    public function actionIndex(
)
    {
        $mensaje = 'Yes, it is';
        $h2 = 'UNIVO';
        $dateTime = new \DateTime();

        return $this->render(
            'index',
            [
                'mensaje' => $mensaje,
                'h2' => $h2,
                'dateTime' => $dateTime,
            ]
        );
    }

    public function actionResta(
)
    {
        $valor_a = 60;
        $valor_b = 8;
        $resultado = $valor_a - $valor_b;

        return $this->render('resta', ['resultado' => $resultado]);
    }
}
```

  

## Modelo / Vista / Controlador

- Crear archivo `models/inicioForm.php`

```php
<?php

namespace app\models;

use Yii;
use yii\base\Model;

class InicioForm extends Model
{
    public $valor_a;
    public $valor_b;

    public function rules(
)
    {
        return [
            [['valor_a', 'valor_b'], 'required'],
            [['valor_a', 'valor_b'], 'number'],
        ];
    }
}
```

  

- Crear vista `views/inicio/suma.php` 

```php
<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
?>

<?php
if (isset($respuesta)) {
    echo Html::tag('div', Html::encode($respuesta), ['class' => 'alert alert-warning']);
}
?>

<div class="row">
    <div class="container">
        <?php $formulario = ActiveForm::begin(); ?>

        <?= $formulario->field($model, 'valor_a') ?>
        <?= $formulario->field($model, 'valor_b') ?>

        <div class="form-group">
            <?= Html::submitButton('Aceptar', ['class' => 'btn btn-success']) ?>
        </div>

        <?php ActiveForm::end(); ?>
    </div>
</div>
```

  

- Modificar archivo `Controllers/InicioController.php` 

```php
<?php

namespace app\controllers;

use app\models\InicioForm;
use Yii;
use yii\filters\AccessControl;
use yii\web\Response;
use yii\filters\VerbFilter;
use yii\web\Controller;

class InicioController extends Controller
{
    public function actionIndex()
    {
        $mensaje = 'Yes, it is';
        $h2 = 'UNIVO';
        $dateTime = new \DateTime();

        return $this->render(
            'index',
            [
                'mensaje' => $mensaje,
                'h2' => $h2,
                'dateTime' => $dateTime,
            ]
        );
    }

    public function actionResta()
    {
        $valor_a = 60;
        $valor_b = 8;
        $resultado = $valor_a - $valor_b;

        return $this->render('resta', ['resultado' => $resultado]);
    }

    public function actionSuma()
    {
        $model = new InicioForm();

        if ($model->load(Yii::$app->request->post()) && $model->validate()) {

            $resultado = $model->valor_a + $model->valor_b;
            $respuesta = ("El resultado es: " . $resultado);

            return $this->render('suma', ['model' => $model, 'respuesta' => $respuesta]);
        }

        return $this->render('suma', ['model' => $model]);
    }
}
```