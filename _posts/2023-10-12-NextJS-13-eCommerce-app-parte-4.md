---
title: NextJS 13 - eCommerce App - parte 4
date: 2023-10-11 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Esquema de base de datos

[https://www.prisma.io/](https://www.prisma.io/)  

- instalar Prisma `npm i -D prisma`
- Ejecutar `npx prisma init` esto creara la carpeta `prisma` y el archivo `schema.prisma`, ademas de modificar el archivo `.env` con el url a la base de datos
- Instalar `npm i @prisma/client`

- Editar `.env` asegurandose de que el url a la base de datos sea la correcta

```bash
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/

//DATABASE_URL="mysql://usuario:password@localhost:8889/base_datos?schema=public"
DATABASE_URL="mysql://root:root@localhost:8889/next13_ecommerce?socket=/Applications/MAMP/tmp/mysql/mysql.sock"

```

- Crear `lib/db.ts`

```ts
import { PrismaClient } from '@prisma/client';

declare global {
    var prisma: PrismaClient | undefined;
};

export const db = globalThis.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalThis.prisma = db;

//!Dara problemas en develpment por el hot reload ya que se crea una nueva instancia de prisma cada vez que se hace un cambio
//export const db = new PrismaClient(); 

```

  

- Editar `prisma/schema.prisma`

```ts
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
  relationMode = "foreignKeys"
}

model tbl_cursos {
  id_curso Int @id @default(autoincrement())
  uuid String @default(uuid())
  id_usuario String
  titulo String @db.Text
  descripcion String? @db.Text
  imagen_url String? @db.Text
  precio Float?
  publicado Boolean @default(false)

  id_categoria Int?
  categoria tbl_categorias? @relation(fields: [id_categoria], references: [id_categoria])

  adjuntos tbl_adjuntos[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([id_categoria])
}

model tbl_categorias {
  id_categoria Int @id @default(autoincrement())
  uuid String @default(uuid())
  nombre String @unique
  courses tbl_cursos[]
}

model tbl_adjuntos {
  id_adjunto Int @id @default(autoincrement())
  uuid String @default(uuid())
  nombre String
  url String @db.Text

  id_curso Int
  curso tbl_cursos @relation(fields: [id_curso], references: [id_curso], onDelete: Cascade)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([id_curso])
}

```

  

- Crear una base de datos en mysql con el nombre `next13_ecommerce`
- Ejecutar `npx prisma generate`
- Ejecutar `npx prisma db push`
- Script SQL

```sql
CREATE DATABASE next13_ecommerce;

USE next13_ecommerce;

--
-- Table structure for table `tbl_adjuntos`
--

CREATE TABLE `tbl_adjuntos` (
  `id_adjunto` int(11) NOT NULL,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_curso` int(11) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updatedAt` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_categorias`
--

CREATE TABLE `tbl_categorias` (
  `id_categoria` int(11) NOT NULL,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_cursos`
--

CREATE TABLE `tbl_cursos` (
  `id_curso` int(11) NOT NULL,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_usuario` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `titulo` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `imagen_url` text COLLATE utf8mb4_unicode_ci,
  `precio` double DEFAULT NULL,
  `publicado` tinyint(1) NOT NULL DEFAULT '0',
  `id_categoria` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updatedAt` datetime(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_adjuntos`
--
ALTER TABLE `tbl_adjuntos`
  ADD PRIMARY KEY (`id_adjunto`),
  ADD KEY `tbl_adjuntos_id_curso_idx` (`id_curso`);

--
-- Indexes for table `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `tbl_categorias_nombre_key` (`nombre`);

--
-- Indexes for table `tbl_cursos`
--
ALTER TABLE `tbl_cursos`
  ADD PRIMARY KEY (`id_curso`),
  ADD KEY `tbl_cursos_id_categoria_idx` (`id_categoria`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_adjuntos`
--
ALTER TABLE `tbl_adjuntos`
  MODIFY `id_adjunto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_cursos`
--
ALTER TABLE `tbl_cursos`
  MODIFY `id_curso` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_adjuntos`
--
ALTER TABLE `tbl_adjuntos`
  ADD CONSTRAINT `tbl_adjuntos_id_curso_fkey` FOREIGN KEY (`id_curso`) REFERENCES `tbl_cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_cursos`
--
ALTER TABLE `tbl_cursos`
  ADD CONSTRAINT `tbl_cursos_id_categoria_fkey` FOREIGN KEY (`id_categoria`) REFERENCES `tbl_categorias` (`id_categoria`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

```

  

## API - Crear Curso

- Crear `app/api/courses/route.ts`

```ts
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";

import { db } from "@/lib/db";

export async function POST(
    req: Request,
) {
    try {
        const { userId } = auth();
        const { titulo } = await req.json();

        if (!userId) {
            return new NextResponse("No autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.create({
            data: {
                id_usuario: userId,
                titulo,
            }
        });

        return NextResponse.json(course);
    } catch (error) {
        console.log("[CURSOS]", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}

```


- Modificar función onSubmit en `app/(dashboard)/(routes)/teacher/create/page.tsx`

```tsx
    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        try {
            const response = await axios.post("/api/courses", values);
            router.push(`/teacher/courses/${response.data.uuid}`);
            toast.success("Curso creado");
        } catch (error) {
            //console.log("ha ocurrido un error");
            toast.error("Ha ocurrido un error");
        }
    }

```

- Crear un curso utilizando la interfaz de Creación de curso
- Crear `app/(dashboard)/(routes)/teacher/courses/[uuid]/page.tsx`

```tsx
const CourseUuidPage = ({
    params
}: {
    params: { uuid: string }
}) => {
    return (
        <div>
            UUID del curso: {params.uuid}
        </div>
    );
}

export default CourseUuidPage;

```