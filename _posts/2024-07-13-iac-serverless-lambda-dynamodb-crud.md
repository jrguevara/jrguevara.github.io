---
title: CRUD con Serverless, Lambda y DynamoDB como IaC
date: 2024-07-13 00:00:00 -500
categories: [aws]
tags: [javascript, aws, serverless, lambda, iac, dynamodb]
published: true
hidden: false
---

## IaC serverless v4

  

- Ejecutar en terminal `serverless` y seleccionar plantilla ❯ AWS / Node.js / HTTP API
- `npm init`

  

`serverless.yml`

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}

functions:
  hello:
    handler: handler.hello
    events:
      - httpApi:
          path: /
          method: get
```

  

- `sls deploy --verbose`
- probar endpoint
- `sls remove --verbose`

  

## Cambiar la ubicación de la función inicial

`src/handlers/postProduct.mjs`

```js
exports.handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Lambda Post Product!",
    }),
  };
};
```

  

`serverless.yml`

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: GET
```

  

- `sls deploy --verbose`
- probar endpoint

  

## DynamoDB

  

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /producto
          method: POST
```

  

- `sls deploy --verbose`
- verificar que la tabla fue creada

  

## Crear producto

- `npm i uuid` 
- `npm install @aws-sdk/client-dynamodb`
- `npm install @aws-sdk/lib-dynamodb`
- Modificar `src/handlers/postProduct.mjs` 

```javascript
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { v4 as uuid } from "uuid";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event, context) => {
    try {
        const product = JSON.parse(event.body);

        const newProduct = {
            ...product,
            id: uuid(),
            created_at: new Date().toLocaleString('es-SV'),
        };

        const headers = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        };

        await dynamo.send(new PutCommand({
            TableName: "inventory",
            Item: newProduct,
        }));

        return {
            statusCode: 201,
            headers: headers,
            body: JSON.stringify(newProduct),
        };
    }
    catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }
};
```

  

- Modificar `serverless.yml`

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/inventory"

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: POST
```

- `sls deploy --verbose`
- probar endpoint en postman e ingresar los datos:

```json
{
    "name" :"PS5",
    "brand" : "SONY",
    "price" : 699.99,
    "comments" : "Consola de videojuegos",
    "stock" : 45
}
```

  

## Listar Productos

- Crear `src/handlers/getProducts.mjs` 

```javascript
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event, context) => {
    try {
        let products;

        const result = await dynamo.send(new ScanCommand({
            TableName: "inventory",
        }));

        products = result.Items;

        const headers = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        };

        return {
            statusCode: 200,
            headers: headers,
            body: JSON.stringify(products),
        };
    }
    catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }
};
```

  

- Modificar `serverless.yml`

```yaml
⁠⁠org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
        - dynamodb:Scan
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/inventory"

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: POST
  getProducts:
    handler: src/handlers/getProducts.handler
    events:
      - httpApi:
          path: /products
          method: GET
```

  

- `sls deploy --verbose`
- Probar endpoint en Postman

  

## Obtener Producto

- Crear `src/handlers/getProduct.mjs` 

```javascript
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event, context) => {

    let product;
    const { id } = event.pathParameters;
    
    const headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    };
    
    try {
        const result = await dynamo.send(new GetCommand({
            TableName: "inventory",
            Key: { id }
        }));

        product = result.Item;
    }
    catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }

    if (!product) {
        return {
            statusCode: 404,
            headers: headers,
            body: JSON.stringify({ message: "Producto no encontrado" }),
        };
    }

    return {
        statusCode: 200,
        headers: headers,
        body: JSON.stringify(product),
    };
};
```

  

- Modificar `serverless.yml`

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
        - dynamodb:Scan
        - dynamodb:GetItem
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/inventory"

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: POST
  getProducts:
    handler: src/handlers/getProducts.handler
    events:
      - httpApi:
          path: /products
          method: GET
  getProduct:
    handler: src/handlers/getProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: GET
```

- `sls deploy --verbose`
- Probar endpoint en Postman

  

## Modificar Producto

- Crear `src/handlers/putProduct.mjs` 

```javascript
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event, context) => {
    try {
        const id = event.pathParameters?.id;
        const { name, brand, price, comments, stock } = JSON.parse(event.body);

        // Verificar si el registro existe antes de actualizarlo
        const result = await dynamo.send(new GetCommand({
            TableName: "inventory",
            Key: { id: id },
        }));

        if (!result.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Registro no encontrado" }),
            };
        }

        const headers = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        };

        // Actualizar el registro existente
        await dynamo.send(new UpdateCommand({
            TableName: "inventory",
            Key: { id: id },
            UpdateExpression: "SET  #name = :name, brand = :brand, price = :price, comments = :comments, stock = :stock",
            ExpressionAttributeNames: {
                "#name": "name",
            },
            ExpressionAttributeValues: {
                ":name": name,
                ":brand": brand,
                ":price": price,
                ":comments": comments,
                ":stock": stock,
            },
            ReturnValues: "ALL_NEW",
        }));
    }

    catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Registro actualizado exitosamente" }),
    };
};
```

  

- Modificar `serverless.yml`

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:UpdateItem
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/inventory"

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: POST
  getProducts:
    handler: src/handlers/getProducts.handler
    events:
      - httpApi:
          path: /products
          method: GET
  getProduct:
    handler: src/handlers/getProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: GET
  putProduct:
    handler: src/handlers/putProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: PUT
```

- `sls deploy --verbose`
- Probar endpoint en Postman

  

## Elmininar Producto

- Crear `src/handlers/deleteProduct.mjs` 

```javascript
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, DeleteCommand, GetCommand } from "@aws-sdk/lib-dynamodb";

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event) => {
    try {
        const id = event.pathParameters?.id;

        // Verificar si el registro existe antes de eliminarlo
        const result = await dynamo.send(new GetCommand({
            TableName: "inventory",
            Key: { id: id },
        }));

        if (!result.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: "Registro no encontrado" }),
            };
        }

        const headers = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        };

        // Eliminar el registro si existe
        await dynamo.send(new DeleteCommand({
            TableName: "inventory",
            Key: { id: id },
        }));

        return {
            statusCode: 200,
            headers: headers,
            body: JSON.stringify({ message: "Registro eliminado exitosamente" }),
        };
    } catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }
};
```

  

- Modificar `serverless.yml` 

```yaml
org: jrcoding
service: iac-serverless

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  memorySize: 128
  stage: ${opt:stage, 'dev'}
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:PutItem
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:${self:provider.region}:*:table/inventory"

resources:
  Resources:
    InventoryTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: inventory
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST

functions:
  postProduct:
    handler: src/handlers/postProduct.handler
    events:
      - httpApi:
          path: /product
          method: POST
  getProducts:
    handler: src/handlers/getProducts.handler
    events:
      - httpApi:
          path: /products
          method: GET
  getProduct:
    handler: src/handlers/getProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: GET
  putProduct:
    handler: src/handlers/putProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: PUT
  deleteProduct:
    handler: src/handlers/deleteProduct.handler
    events:
      - httpApi:
          path: /product/{id}
          method: DELETE
```

  

- `sls deploy --verbose`
- Probar endpoint en Postman
- Remover stack de aws con `sls remove --verbose`