---
title: NextJS 13 - eCommerce App - parte 8
date: 2023-11-09 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Acciones

- Ejecutar el comando `npx shadcn-ui@latest add alert-dialog` 
- Ejecutar `npm i zustand`  
- Instalar `npm i react-confetti` 
- Crear `hooks/use-confetti-store.ts`

```typescript
import { create } from "zustand";

type ConfettiStore = {
    isOpen: boolean;
    onOpen: () => void;
    onClose: () => void;
};

export const useConfettiStore = create<ConfettiStore>((set) => ({
    isOpen: false,
    onOpen: () => set({ isOpen: true }),
    onClose: () => set({ isOpen: false }),
}));

```

- Crear `components/providers/confetti-provider.tsx`

```tsx
"use client";

import ReactConfetti from "react-confetti";

import { useConfettiStore } from "@/hooks/use-confetti-store";

export const ConfettiProvider = () => {
  const confetti = useConfettiStore();

  if (!confetti.isOpen) return null;

  return (
    <ReactConfetti
      className="pointer-events-none z-[100]"
      numberOfPieces={500}
      recycle={false}
      onConfettiComplete={() => {
        confetti.onClose();
      }}
    />
  )
}

```

  

- Crear  `components/Banner.tsx`

```tsx
import { AlertTriangle, CheckCircleIcon } from "lucide-react"
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const bannerVariants = cva(
    "border text-center p-4 text-sm flex items-center w-full",
    {
        variants: {
            variant: {
                warning: "bg-yellow-200/80 dark:bg-yellow-500 dark:text-black border-yellow",
                success: "bg-emerald-700 border-emerald-800 text-secondary",
            }
        },
        defaultVariants: {
            variant: "warning",
        }
    }
);

interface BannerProps extends VariantProps<typeof bannerVariants> {
    label: string;
};

const iconMap = {
    warning: AlertTriangle,
    success: CheckCircleIcon,
};

export const Banner = ({
    label,
    variant,
}: BannerProps) => {
    const Icon = iconMap[variant || "warning"];

    return (
        <div className={cn(bannerVariants({ variant }))}>
            <Icon className="h-4 w-4 mr-2" />
            {label}
        </div>
    );
};

```

  

- Crear `components/confirm-modal.tsx`

```tsx
"use client";

import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

interface ConfirmModalProps {
    children: React.ReactNode;
    onConfirm: () => void;
};

export const ConfirmModal = ({
    children,
    onConfirm
}: ConfirmModalProps) => {
    return (
        <AlertDialog>
            <AlertDialogTrigger asChild>
                {children}
            </AlertDialogTrigger>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>Esta seguro?</AlertDialogTitle>
                    <AlertDialogDescription>
                        Esta acción no se puede deshacer.
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel>Cancelar</AlertDialogCancel>
                    <AlertDialogAction onClick={onConfirm}>
                        Continuar
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    );
};

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
import { Banner } from "@/components/Banner";
import { Actions } from "./_components/Actions";

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

    const isComplete = requiredFields.every(Boolean);

    return (
        <>
            {!course.publicado && (
                <Banner
                    label="Este curso no esta publicado. No sera visible para los estudiantes."
                />
            )}
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
                    <Actions
                        disabled={!isComplete}
                        id_curso={course.id_curso}
                        isPublished={course.publicado}
                    />
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
        </>
    );
}

export default CourseUuidPage;

```

  

- Crear `app/(dashboard)/(routes)/teacher/courses/[uuid]/_components/Actions.tsx`

```tsx
"use client";

import axios from "axios";
import { Trash } from "lucide-react";
import { useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";

import { Button } from "@/components/ui/button";
import { ConfirmModal } from "@/components/confirm-modal";
import { useConfettiStore } from "@/hooks/use-confetti-store";

interface ActionsProps {
    disabled: boolean;
    id_curso: number;
    isPublished: boolean;
};

export const Actions = ({
    disabled,
    id_curso,
    isPublished
}: ActionsProps) => {
    const router = useRouter();
    const confetti = useConfettiStore();
    const [isLoading, setIsLoading] = useState(false);

    const onClick = async () => {
        try {
            setIsLoading(true);

            if (isPublished) {
                await axios.patch(`/api/courses/${id_curso}/unpublish`);
                toast.success("Curso despublicado");
            } else {
                await axios.patch(`/api/courses/${id_curso}/publish`);
                toast.success("Curso publicado");
                confetti.onOpen();
            }

            router.refresh();
        } catch {
            toast.error("Sucedió un error al actualizar el curso");

        } finally {
            setIsLoading(false);
        }
    }

    const onDelete = async () => {
        try {
            setIsLoading(true);

            await axios.delete(`/api/courses/${id_curso}`);

            toast.success("Curso eliminado");
            router.refresh();
            router.push(`/teacher/courses`);
        } catch {
            toast.error("Something went wrong");
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <div className="flex items-center gap-x-2">
            <Button
                onClick={onClick}
                disabled={disabled || isLoading}
                variant="customghost"
                size="sm"
            >
                {isPublished ? "Despublicar" : "Publicar"}
            </Button>
            <ConfirmModal onConfirm={onDelete}>
                <Button size="sm" disabled={isLoading} variant={"destructive"}>
                    <Trash className="h-4 w-4" />
                </Button>
            </ConfirmModal>
        </div>
    )
}

```
  
  

- Editar `app/api/[id_curso]/route.ts`

```typescript
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";
import { db } from "@/lib/db";

export async function DELETE(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const { userId } = auth();

        if (!userId) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            },
        });

        if (!course) {
            return new NextResponse("Curso No encontrado", { status: 404 });
        }

        const deletedCourse = await db.tbl_cursos.delete({
            where: {
                id_curso: parseInt(params.id_curso),
            },
        });

        return NextResponse.json(deletedCourse);
    } catch (error) {
        console.log("[COURSE_ID_DELETE]", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}

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
        return new NextResponse("Error Interno", { status: 500 });
    }
}

```

  

  

- Crear `app/api/[id_curso]/publish/route.ts`

```typescript
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";

import { db } from "@/lib/db";

export async function PATCH(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const { userId } = auth();

        if (!userId) {
            return new NextResponse("No autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            },
        });

        if (!course) {
            return new NextResponse("Not found", { status: 404 });
        }

        if (!course.titulo || !course.descripcion || !course.imagen_url || !course.id_categoria) {
            return new NextResponse("Faltan campos requeridos", { status: 401 });
        }

        const publishedCourse = await db.tbl_cursos.update({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            },
            data: {
                publicado: true,
            }
        });

        return NextResponse.json(publishedCourse);
    } catch (error) {
        console.log("[COURSE_ID_PUBLISH]", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}

```

  

- Crear `app/api/[id_curso]/unpublish/route.ts`

```typescript
import { auth } from "@clerk/nextjs";
import { NextResponse } from "next/server";

import { db } from "@/lib/db";

export async function PATCH(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const { userId } = auth();

        if (!userId) {
            return new NextResponse("No Autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            },
        });

        if (!course) {
            return new NextResponse("Curso No encontrado", { status: 404 });
        }

        const unpublishedCourse = await db.tbl_cursos.update({
            where: {
                id_curso: parseInt(params.id_curso),
                id_usuario: userId,
            },
            data: {
                publicado: false,
            }
        });

        return NextResponse.json(unpublishedCourse);
    } catch (error) {
        console.log("[COURSE_ID_UNPUBLISH]", error);
        return new NextResponse("Error Interno", { status: 500 });
    }
}

```