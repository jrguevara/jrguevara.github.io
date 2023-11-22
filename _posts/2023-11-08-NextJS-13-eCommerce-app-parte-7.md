---
title: NextJS 13 - eCommerce App - parte 7
date: 2023-11-08 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Formulario de Adjuntos

- Modificar `components/FileUpload.tsx`

```tsx
"use client";

import toast from "react-hot-toast";
import { UploadDropzone } from "@/lib/uploadthing";
import { ourFileRouter } from "@/app/api/uploadthing/core";

interface FileUploadProps {
    onChange: (url?: string, name?:string) => void;
    endpoint: keyof typeof ourFileRouter;
};

export const FileUpload = ({
    onChange,
    endpoint
}: FileUploadProps) => {
    return (
        <UploadDropzone
            endpoint={endpoint}
            onClientUploadComplete={(res) => {
                onChange(res?.[0].url, res?.[0].name);
            }}
            onUploadError={(error: Error) => {
                toast.error(`${error?.message}`);
            }}
        />
    )
}

```

  

- Editar `app/(dashboard)/(routes)/teacher/courses/[uuid]/page.tsx`

```tsx
import { auth } from "@clerk/nextjs";
import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { CircleDollarSign, File, LayoutDashboard } from "lucide-react";
import { TitleForm } from "./_components/TitleForm";
import { DescriptionForm } from "./_components/DescriptionForm";
import { ImageForm } from "./_components/ImageForm";
import { CategoriesForm } from "./_components/CategoriesForm";
import { PriceForm } from "./_components/PriceForm";
import { Prisma } from "@prisma/client";
import { AttachmentsForm } from "./_components/AttachmensForm";

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
            id_usuario: userId
        },
        include: {
            categoria: true,
            adjuntos: true
        },
    });

    const categories = await db.tbl_categorias.findMany({
        orderBy: {
            nombre: "asc"
        }
    });

    if (!course) {
        return redirect("/");
    }

    const requiredFields = [
        course.titulo,
        course.descripcion,
        course.imagen_url,
        course.precio,
        course.id_categoria];

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
                    <DescriptionForm
                        initialData={course}
                        id_curso={course.id_curso}
                    />
                    <CategoriesForm
                        initialData={course}
                        id_curso={course.id_curso}
                        options={categories.map((category) => ({
                            label: category.nombre,
                            value: category.id_categoria,
                        }))}
                    />
                    <ImageForm
                        initialData={course}
                        id_curso={course.id_curso}
                    />
                </div>
                <div className="space-y-6">
                    <div className="flex items-center gap-x-2">
                        <div className="rounded-full flex items-center justify-center bg-sky-100 dark:bg-[#1f1f1f] p-2">
                            <CircleDollarSign className="h-8 w-8 text-teal-700 dark:text-yellow-500" />
                        </div>
                        <h2 className="text-xl">
                            Pon precio a tu curso
                        </h2>
                    </div>
                    <PriceForm
                        initialData={course}
                        id_curso={course.id_curso}
                    />
                    <div className="flex items-center gap-x-2">
                        <div className="rounded-full flex items-center justify-center bg-sky-100 dark:bg-[#1f1f1f] p-2">
                            <File className="h-8 w-8 text-teal-700 dark:text-yellow-500" />
                        </div>
                        <h2 className="text-xl">
                            Recursos y Adjuntos (Opcional)
                        </h2>
                    </div>
                    <AttachmentsForm
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

  

- Crear `app/(dashboard)/(routes)/teacher/courses/[uuid]/_components/AttachmentsForm.tsx`

```tsx
"use client";

import * as z from "zod";
import axios from "axios";
import { Pencil, PlusCircle, ImageIcon, File, Loader2, X } from "lucide-react";
import { useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";
import { tbl_adjuntos, tbl_categorias, tbl_cursos } from "@prisma/client";
import Image from "next/image";

import { Button } from "@/components/ui/button";
import { FileUpload } from "@/components/FileUpload";

interface AttachmentFormProps {
    initialData: tbl_cursos & { categoria: tbl_categorias | null, adjuntos: tbl_adjuntos[] };
    id_curso: number;
};

const formSchema = z.object({
    url: z.string().min(1),
    nombre: z.string().min(1)
});

export const AttachmentsForm = ({
    initialData,
    id_curso
}: AttachmentFormProps) => {
    const [isEditing, setIsEditing] = useState(false);
    const [deletingId, setDeletingId] = useState<number | null>(null);

    const toggleEdit = () => setIsEditing((current) => !current);

    const router = useRouter();

    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        try {
            await axios.post(`/api/courses/${id_curso}/attachments`, values);
            toast.success("Curso Actualizado");
            toggleEdit();
            router.refresh();
        } catch {
            toast.error("Sucedio un error al agregar el adjunto");
        }
    };

    const onDelete = async (id_adjunto: number) => {
        try {
            setDeletingId(id_adjunto);
            await axios.delete(`/api/courses/${id_curso}/attachments/${id_adjunto}`);
            toast.success("Adjunto eliminado");
            router.refresh();
        } catch {
            toast.error("Sucedio un error al eliminar el adjunto");
        } finally {
            setDeletingId(null);
        }
    }

    return (
        <div className="mt-6 border bg-[#cfcfcf] dark:bg-[#1f1f1f] rounded-md p-4">
            <div className="font-medium flex items-center justify-between">
                Adjuntos del curso
                <Button onClick={toggleEdit} variant="customghost">
                    {isEditing && (
                        <>Cancelar</>
                    )}
                    {!isEditing && (
                        <>
                            <PlusCircle className="h-4 w-4 mr-2" />
                            Agregar un archivo
                        </>
                    )}
                </Button>
            </div>
            {!isEditing && (
                <>
                    {initialData.adjuntos.length === 0 && (
                        <p className="text-sm mt-2 text-slate-500 italic">
                            *Aun no se han agregado adjuntos*
                        </p>
                    )}
                    {initialData.adjuntos.length > 0 && (
                        <div className="space-y-2">
                            {initialData.adjuntos.map((adjunto) => (
                                <div
                                    key={adjunto.id_adjunto}
                                    className="flex items-center p-3 w-full bg-sky-100 dark:bg-[#313138] border-sky-200 dark:border-white border dark:text-teal-400 text-sky-700 rounded-md mt-2"
                                >
                                    <File className="h-4 w-4 mr-2 flex-shrink-0" />
                                    <p className="text-sm line-clamp-1">
                                        {adjunto.nombre}
                                    </p>
                                    {deletingId === adjunto.id_adjunto && (
                                        <div>
                                            <Loader2 className="h-4 w-4 animate-spin" />
                                        </div>
                                    )}
                                    {deletingId !== adjunto.id_adjunto && (
                                        <button
                                            onClick={() => onDelete(adjunto.id_adjunto)}
                                            className="ml-auto hover:opacity-75 transition bg-red-700 text-white rounded-full p-1"
                                        >
                                            <X className="h-4 w-4" />
                                        </button>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </>
            )}
            {isEditing && (
                <div>
                    <FileUpload
                        endpoint="courseAttachment"
                        onChange={(url, nombre) => {
                            if (url && nombre) {
                                onSubmit({ url: url, nombre: nombre });
                            }
                        }}
                    />
                    <div className="text-xs text-muted-foreground mt-4">
                        Agrega cualquier cosa que tus estudiantes puedan necesitar para completar el curso.
                    </div>
                </div>
            )}
        </div>
    )
}

```

  

- Crear `app/api/courses/[id_curso]/attachments/route.ts`

```typescript
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";

import { db } from "@/lib/db";

export async function POST(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const { userId } = auth();
        const { url, nombre } = await req.json();

        if (!userId) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const courseOwner = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            }
        });

        if (!courseOwner) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const attachment = await db.tbl_adjuntos.create({

            data: {
                url: url,
                nombre: nombre,
                id_curso: parseInt(params.id_curso),
            }
        });

        return NextResponse.json(attachment);
    } catch (error) {
        console.log("COURSE_ID_ATTACHMENTS", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}

```

  

- Crear `app/api/courses/[id_curso]/attachments/[id_adjunto]/route.ts`

```typescript
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function DELETE(
    req: Request,
    { params }: { params: { id_curso: string, id_adjunto: string } }
) {
    try {
        const { userId } = auth();

        if (!userId) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const courseOwner = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId
            }
        });

        if (!courseOwner) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const attachment = await db.tbl_adjuntos.delete({
            where: {
                id_curso: parseInt(params.id_curso),
                id_adjunto: parseInt(params.id_adjunto),
            }
        });

        return NextResponse.json(attachment);
    } catch (error) {
        console.log("ATTACHMENT_ID", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}


```