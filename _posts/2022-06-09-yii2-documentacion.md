---
title: Documentación en Yii2
date: 2022-06-09 03:00:00 -500
categories: [yii2]
tags: [documentacion, yii2, calidad de software, programacion]
---

## Documentación de Software

La documentación es uno de los aspectos más importantes y subestimados de cualquier biblioteca o proyecto de código abierto. Si está escribiendo código que será utilizado por alguien que no sea usted mismo, debe documentarse.

## Los diferentes componentes de la documentación

Cada componente tiene un papel único que desempeñar y se requiere en diferentes etapas del uso diario de la biblioteca. En esta guia nos cenraremos en la Documentación de API.

![Componentes de Documentacion](/assets/images/doc-summary.png)
_Componentes de documentación de software_

## Documentación API

La documentación de la API contiene la descripción de las funciones, métodos y componentes individuales de su biblioteca. Es la fuente final de verdad cuando se trata de descifrar cómo funciona su biblioteca.

Si bien los tutoriales y ejemplos bien escritos cubren la mayoría de los casos de uso, realmente no puede cubrir todas las situaciones para las que las personas usarán su biblioteca. Luego, sus usuarios consultarán la documentación de su API para ayudarlos a resolverlo.

Aquí hay algunas reglas a seguir al escribir la documentación de la API:

1. Si una función, clase o variable se expone públicamente, debe documentarse.
2. La documentación debe contener una breve descripción del componente y mencionar cualquier caso límite que pueda ocurrir.

### Video: Documentación en Programación

{% include youtubePlayer.html id="zoq1Yoqmbe4" %}

### Video: Software Planning and Technical Documentation

{% include youtubePlayer.html id="2qlcY9LkFik" %}

# Documentación Técnica en Yii2

* Instalar [yii2-apidoc](https://github.com/yiisoft/yii2-apidoc) via Terminal

```terminal
composer require --prefer-dist yiisoft/yii2-apidoc --with-all-dependencies
./vendor/bin/apidoc api "controllers, models, modules" documentation
```

* Colocar un bloque de comentarios en la parte superior de cada archivo que contenga un modelo o controlador:

```php
/**
 * @link http://jrcoding.net
 * @copyright Copyright (c) 2022 jrCoding
 * @license https://www.yiiframework.com/license/
 */
```

* Colocar un bloque de comentarios sobre cada controlador o definición de modelo:

```php
/**
 * PacientesController implementa las operaciones CRUD para el modelo TblPacientes.
 * @author Jaime Guevara <jr.guevara@outlook.com>
 * @since 0.1
 */
class PacientesController extends Controller
{

```

* Bloque de comentario para acciones

```php
/**
* Lista todos los paciente en el modelo TblPacientes.
* @return string que renderiza vista index
*/
 public function actionIndex()
{
    $searchModel = new PacientesSearch();
    $dataProvider = $searchModel->search($this->request->queryParams);

    return $this->render('index', [
        'searchModel' => $searchModel,
        'dataProvider' => $dataProvider,
    ]);
}
```

* Comentarios para funciones especificas

```php
/**
* Genera Codigo para ser utilizado en registro de Representantes actionCreate
* @return string
*/
function CreateCode()
{
    $paciente = TblPacientes::find()->orderBy(['id_paciente' => SORT_DESC])->one();
    if (empty($paciente->cod_paciente)) $codigo = 0;
    else $codigo = $paciente->cod_paciente;

    $int = intval(preg_replace('/[^0-9]+/', '', $codigo), 10);
    $id = $int + 1;

    $numero = $id;
    $tmp = "";
    if ($id < 10) {
        $tmp .= "000";
        $tmp .= $id;
    } elseif ($id >= 10 && $id < 100) {
        $tmp .= "00";
        $tmp .= $id;
    } elseif ($id >= 100 && $id < 1000) {
        $tmp .= "0";
        $tmp .= $id;
    } else {
        $tmp .= $id;
    }
    $result = str_replace($id, $tmp, $numero);
    return "PA-" . $result;
}
```

```php
/**
* Getter para recuperar data de un solo paciente
*
* @param int $id_paciente captura id de paciente
* @return object $paciente con la informacion del paciente
* @throws Exception not yet implemented
*/
public static function getPaciente($id_paciente)
{
    $paciente = TblPacientes::find()->where(['id_paciente' => $id_paciente])->one();
    return $paciente;
}
```

* Utilizar en terminal el siguiente codigo para generar documentacion (crear previamente carpeta documentation en la raiz del proyecto)

```terminal
./vendor/bin/apidoc api "controllers, models, modules" documentation
```

* Abrir carpeta documentation y abrir archivo index en el navegador

![Documentacion API en Yii2](/assets/images/yii2-doc-example.jpg)
_Documentacion API Yii2_

Como se puede apreciar, esto es extremadamente útil para compartir una API con programadores de terceros en tiempo real mientras entrega el código. El gran beneficio es que elimina la necesidad de mantener manualmente la documentación de la API por separado.

# Vinculos

[Yii2 Code Style](https://github.com/yiisoft/yii2/blob/master/docs/internals/core-code-style.md)

[PHPDoc Basic Syntax](https://docs.phpdoc.org/guide/references/phpdoc/basic-syntax.html)