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

## Edición de curso

- Editar `app/(dashboard)/(routes)/teacher/courses/[uuid]/page.tsx`

```tsx
import { auth } from "@clerk/nextjs";
import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { IconBadge } from "@/components/IconBadge";
import { LayoutDashboard } from "lucide-react";
import { TitleForm } from "@/app/(dashboard)/_components/TitleForm";

const CourseUuidPage = async ({
    params
}: {
    params: { uuid: string }
}) => {

    const { userId } = auth();

    if (!userId) {
        return redirect("/");
    }

    const course = await db.tbl_cursos.findFirst({
        where: {
            uuid: params.uuid,
        }
    });

    if (!course) {
        return redirect("/");
    }

    const requiredFields = [
        course?.titulo,
        course?.descripcion,
        course?.imagen_url,
        course?.precio,
        course?.id_categoria];

    const totalFields = requiredFields.length;
    const completedFields = requiredFields.filter(Boolean).length;

    const completionText = `(${completedFields}/${totalFields})`;

    return (
        <div className="p-6">
            <div className="flex items-center justify-between">
                <div className="flex flex-col gap-y-2">
                    <h1 className="text-2xl font-medium">
                        Configuracion del curso
                    </h1>
                    <span className="text-sm text-slate-700 dark:text-white">
                        Completar todos los campos {completionText}
                    </span>
                </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-16">
                <div>
                    <div className="flex items-center gap-x-2">
                        <div className="rounded-full flex items-center justify-center bg-sky-100 dark:bg-[#1f1f1f] p-2">
                            <LayoutDashboard className="h-8 w-8 text-teal-700 dark:text-yellow-500" />
                        </div>
                        <h2 className="text-xl">
                            Personaliza tu curso
                        </h2>
                    </div>
                    <TitleForm
                        initialData={course}
                        id_curso={course.id_curso}
                    />
                </div>
            </div>
        </div>
    );
}

export default CourseUuidPage;

```

  

- Crear app/(dashboard)/\_components/TitleForm.tsx

```tsx
"use client";

import * as z from "zod";
import axios from "axios";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { Pencil } from "lucide-react";
import { useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";

import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

interface TitleFormProps {
    initialData: {
        titulo: string;
    };
    id_curso: number;
};

const formSchema = z.object({
    titulo: z.string().min(5, {
        message: "El titulo es requerido",
    }),
});

export const TitleForm = ({
    initialData,
    id_curso
}: TitleFormProps) => {
    const [isEditing, setIsEditing] = useState(false);

    const toggleEdit = () => setIsEditing((current) => !current);

    const router = useRouter();

    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: initialData,
    });

    const { isSubmitting, isValid } = form.formState;

    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        try {
            await axios.patch(`/api/courses/${id_curso}`, values);
            toast.success("Curso Actualizado");
            toggleEdit();
            router.refresh();
        } catch {
            toast.error("Sucedio un error");
        }
    }

    return (
        <div className="mt-6 border bg-[#cfcfcf] dark:bg-[#1f1f1f] rounded-md p-4">
            <div className="font-medium flex items-center justify-between">
                Titulo del curso
                <Button onClick={toggleEdit} variant="customghost">
                    {isEditing ? (
                        <>Cancelar</>
                    ) : (
                        <>
                            <Pencil className="h-4 w-4 mr-2" />
                            Editar titulo
                        </>
                    )}
                </Button>
            </div>
            {!isEditing && (
                <p className="text-xl mt-2">
                    {initialData.titulo}
                </p>
            )}
            {isEditing && (
                <Form {...form}>
                    <form
                        onSubmit={form.handleSubmit(onSubmit)}
                        className="space-y-4 mt-4"
                    >
                        <FormField
                            control={form.control}
                            name="titulo"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <Input
                                            disabled={isSubmitting}
                                            placeholder="ej. 'Desarrollo web con NextJS'"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <div className="flex items-center gap-x-2">
                            <Button
                                disabled={!isValid || isSubmitting}
                                type="submit"
                                variant="success"
                            >
                                Guardar
                            </Button>
                        </div>
                    </form>
                </Form>
            )}
        </div>
    )
}

```

## Actualizar Curso API

- Crear app/courses/\[id\_curso\]/route.ts

```ts
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function PATCH(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const { userId } = auth();
        const { id_curso } = params;
        const values = await req.json();

        if (!userId) {
            return new NextResponse("No autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.update({
            where: {
                id_curso: parseInt(id_curso),
                id_usuario: userId
            },
            data: {
                ...values,
            }
        });

        return NextResponse.json(course);
    } catch (error) {
        console.log("[COURSE_ID]", error);
        return new NextResponse("Internal Error", { status: 500 });
    }
}

```