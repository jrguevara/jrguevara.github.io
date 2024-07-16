---
title: Extensión para Visual Studio Code
date: 2023-07-19 00:00:00 -500
categories: [javascript]
tags: [javascript, vs-code, programacion]
published: true
hidden: false
---


# ¿Qué es una extensión de VS Code?

Las extensiones nos permiten agregar funcionalidad a Visual Studio Code de forma [modular y aislada](https://github.com/Microsoft/vscode-docs/blob/master/docs/extensions/our-approach.md), son una excelente manera de personalizar nuestra experiencia con la herramienta.

## Prerequisitos

Visual Studio Code es un editor **multiplataforma**, por lo que, las herramientas que necesitamos para la creación de extensiones pueden conseguirse en Mac, Linux y obviamente, Windows.

- Visual Studio Code ([instalador multiplataforma](http://code.visualstudio.com/))
- NodeJS ([sitio oficial](https://nodejs.org/es))
- [Yeoman](http://yeoman.io/) (instalable desde NodeJS/NPM)
- Cuenta de [Visual Studio Team Services](https://www.visualstudio.com/en-us/products/visual-studio-team-services-vs.aspx) (gratuita) si queremos publicar nuestra extensión en el Marketplace.


## Creación de una extensión en VS Code

> Referencia: [https://code.visualstudio.com/api/get-started/your-first-extension](https://code.visualstudio.com/api/get-started/your-first-extension) 
{: .prompt-tip }

- Asegúrese de tener Node.js y Git instalados, luego instale Yeoman y VS Code Extension Generator con:

```powershell
npm install -g yo generator-code
```

  

- El generador construye un proyecto de TypeScript o JavaScript listo para el desarrollo. Ejecute el generador y complete algunos campos para un proyecto de TypeScript:

```powershell
yo code
```


![Generador de Extensiones para VS Code](/assets/images/vscode-yo.png)_VSCodeextensiongen_   


- Luego, dentro del editor, presiona F5. Esto compilará y ejecutará la extensión en una nueva ventana del host de desarrollo de extensiones.

- Ejecutar el comando Hello World desde la paleta de comandos (Ctrl+Shift+P) en la nueva ventana.

  

- `package.json`

```json
{
  "name": "buscar-google",
  "displayName": "Buscar Google",
  "description": "Extension sencilla para buscar en google.com",
  "author": "Jaime Guevara",
  "version": "0.0.1",
  "engines": {
    "vscode": "^1.80.0"
  },
  "categories": [
    "Other"
  ],
  "activationEvents": [],
  "main": "./extension.js",
  "contributes": {
    "commands": [{
      "command": "buscar-google.buscarGoogle",
      "title": "Buscar en Google..."
    }]
  },
  "scripts": {
    "lint": "eslint .",
    "pretest": "npm run lint",
    "test": "node ./test/runTest.js"
  },
  "devDependencies": {
    "@types/vscode": "^1.80.0",
    "@types/glob": "^8.1.0",
    "@types/mocha": "^10.0.1",
    "@types/node": "20.2.5",
    "eslint": "^8.41.0",
    "glob": "^8.1.0",
    "mocha": "^10.2.0",
    "typescript": "^5.1.3",
    "@vscode/test-electron": "^2.3.2"
  }
}
```

  

`extension.js`

```javascript
const vscode = require('vscode');

function activate(context) {
	let disposable = vscode.commands.registerCommand('buscar-google.buscarGoogle', async function () {
		const busqueda = await vscode.window.showInputBox({
			value: '',
			title: 'Buscar en Google',
			placeHolder: 'Que necesitas buscar?',
			validateInput: (value) => {
				if (value === '') return 'Busqueda vacia'
			}
		})

		if (!busqueda) return

		vscode.env.openExternal(
			vscode.Uri.parse(`https://www.google.com/search?q=${busqueda}`)
		)
	});

	context.subscriptions.push(disposable);
}

function deactivate() { }

module.exports = {
	activate,
	deactivate
}
```