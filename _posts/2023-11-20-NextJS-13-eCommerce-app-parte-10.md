---
title: NextJS 13 - eCommerce App - parte 10
date: 2023-11-20 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Listado de Categorías

  

- Instalar `npm i react-icons`  y  `npm i query-string`
- [https://react-icons.github.io/react-icons/icons/fc/](https://react-icons.github.io/react-icons/icons/fc/)
- Crear `app/(dashboard)/(routes)/search/_components/Categories.tsx` 

```tsx
"use client";

import { tbl_categorias } from "@prisma/client";
import {
    FcDepartment,
    FcMultipleDevices,
    FcMusic,
    FcCalculator,
} from "react-icons/fc";
import { IconType } from "react-icons";
import { CategoryItem } from "./Category-item";

interface CategoriesProps {
    items: tbl_categorias[];
}

const iconMap: Record<tbl_categorias["nombre"], IconType> = {
    "Artes y musica": FcMusic,
    "Matematicas y Fisica": FcCalculator,
    "Programacion y TI": FcMultipleDevices,
    "Arquitectura y diseño": FcDepartment,
};

export const Categories = ({
    items,
}: CategoriesProps) => {
    return (
        <div className="flex items-center gap-x-2 overflow-x-auto pb-2 content-between justify-center">
            {items.map((item) => (
                <CategoryItem
                    key={item.uuid}
                    label={item.nombre}
                    icon={iconMap[item.nombre]}
                    value={item.uuid}
                />
            ))}
        </div>
    )
}

```

- Crear `app/(dashboard)/(routes)/search/_components/Category-item.tsx` 

```tsx
"use client";

import qs from "query-string";
import { IconType } from "react-icons";
import {
    usePathname,
    useRouter,
    useSearchParams
} from "next/navigation";

import { cn } from "@/lib/utils";

interface CategoryItemProps {
    label: string;
    value?: string;
    icon?: IconType;
};

export const CategoryItem = ({
    label,
    value,
    icon: Icon,
}: CategoryItemProps) => {
    const pathname = usePathname();
    const router = useRouter();
    const searchParams = useSearchParams();

    const currentCategoryId = searchParams.get("category"); 
    const currentTitle = searchParams.get("title");

    const isSelected = currentCategoryId === value;

    const onClick = () => {
        const url = qs.stringifyUrl({
            url: pathname,
            query: {
                title: currentTitle,
                category: isSelected ? null : value,
            }
        }, { skipNull: true, skipEmptyString: true });

        router.push(url);
    };

    return (
        <button
            onClick={onClick}
            className={cn(
                "py-2 px-3 text-sm border border-slate-200 rounded-full flex items-center gap-x-1 hover:border-sky-500 transition",
                isSelected && "border-sky-600 bg-teal-600 text-white dark:bg-yellow-500 dark:text-black dark:border-red-900"
            )}
            type="button"
        >
            {Icon && <Icon size={20} />}
            <div className="truncate">
                {label}
            </div>
        </button>
    )
}

```

  

- Editar `app/(dashboard)/(routes)/search/page.tsx`

```tsx
import { db } from "@/lib/db";
import { Categories } from "./_components/Categories";

interface SearchPageProps {
    searchParams: {
        title: string;
        categoryId: string;
    }
};

const SearchPage = async () => {
    const categories = await db.tbl_categorias.findMany({
        orderBy: {
            nombre: "asc"
        }
    });

    return (
        <>
            <div className="p-6 space-y-4">
                <Categories
                    items={categories}
                />
            </div>
        </>
    );
}

export default SearchPage;

```

  

## Búsqueda

- Crear `hooks/use-debounce.ts`

```ts
import { useEffect, useState } from "react";

export function useDebounce<T>(value: T, delay?: number): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value);

    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedValue(value)
        }, delay || 500);

        return () => {
            clearTimeout(timer);
        }
    }, [value, delay]);

    return debouncedValue;
};

```

  

- Crear `components/SearchInput.tsx`

```tsx
"use client";

import qs from "query-string";
import { Search } from "lucide-react";
import { useEffect, useState } from "react";
import { useSearchParams, useRouter, usePathname } from "next/navigation";

import { Input } from "@/components/ui/input";
import { useDebounce } from "@/hooks/use-debounce";

export const SearchInput = () => {
    const [value, setValue] = useState("")
    const debouncedValue = useDebounce(value);

    const searchParams = useSearchParams();
    const router = useRouter();
    const pathname = usePathname();

    const currentCategoryId = searchParams.get("categoryId");

    useEffect(() => {
        const url = qs.stringifyUrl({
            url: pathname,
            query: {
                categoryId: currentCategoryId,
                title: debouncedValue,
            }
        }, { skipEmptyString: true, skipNull: true });

        router.push(url);
    }, [debouncedValue, currentCategoryId, router, pathname])

    return (
        <div className="relative">
            <Search
                className="h-4 w-4 absolute top-3 left-3 text-slate-600"
            />
            <Input
                onChange={(e) => setValue(e.target.value)}
                value={value}
                className="w-full md:w-[300px] pl-9 rounded-full"
                placeholder="Buscar cursos..."
            />
        </div>
    )
}

```

- Editar `components/NavbarRoutes.tsx`

```tsx
"use client";

import { UserButton } from "@clerk/nextjs";
import { ModeToggle } from "@/components/mode-toggle";
import { Button } from "@/components/ui/button";
import { LogOut, Search } from "lucide-react";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { SearchInput } from "@/components/SearchInput";

export const NavbarRoutes = () => {
    const pathname = usePathname();

    const isTeacherPage = pathname?.startsWith("/teacher");
    const isPlayerPage = pathname?.includes("/chapter");
    const isSearchPage = pathname === "/search";

    return (
        <>
            {isSearchPage && (
                <div className="hidden md:block">
                    <SearchInput />
                </div>
            )}
            <div className="flex gap-x-8 ml-auto">
                {isTeacherPage || isPlayerPage ? (
                    <Link href="/">
                        <Button size="sm" variant='customghost'>
                            <LogOut className="h-4 w-4 mr-2" />
                            Salir
                        </Button>
                    </Link>
                ) : (
                    <Link href="/teacher/courses">
                        <Button size="sm" variant='customghost'>
                            Modo Profesor
                        </Button>
                    </Link>
                )}
                <UserButton
                    afterSignOutUrl="/"
                />
                <ModeToggle />
            </div>
        </>
    );
}

```

  

- Editar `app/(dashboard)/(routes)/search/page.tsx` para mostrar en vista movíl

```tsx
import { db } from "@/lib/db";
import { Categories } from "./_components/Categories";
import { SearchInput } from "@/components/SearchInput";

interface SearchPageProps {
    searchParams: {
        title: string;
        categoryId: string;
    }
};

const SearchPage = async () => {
    const categories = await db.tbl_categorias.findMany({
        orderBy: {
            nombre: "asc"
        }
    });

    return (
        <>
        <div className="px-6 pt-6 md:hidden md:mb-0 block">
            <SearchInput />
        </div>
            <div className="p-6 space-y-4">
                <Categories
                    items={categories}
                />
            </div>
        </>
    );
}

export default SearchPage;

```

  

## Listado de Cursos

- Modificar `prisma/schema.prisma`

```ts
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["fullTextSearch", "fullTextIndex"]
}

datasource db {
  provider     = "mysql"
  url          = env("DATABASE_URL")
  relationMode = "foreignKeys"
}

model tbl_cursos {
  id_curso    Int     @id @default(autoincrement())
  uuid        String  @default(uuid())
  id_usuario  String
  titulo      String  @db.Text
  descripcion String? @db.Text
  imagen_url  String? @db.Text
  precio      Float?
  publicado   Boolean @default(false)

  id_categoria Int?
  categoria    tbl_categorias? @relation(fields: [id_categoria], references: [id_categoria])

  adjuntos tbl_adjuntos[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([id_categoria])
  @@fulltext([titulo])
}

model tbl_categorias {
  id_categoria Int          @id @default(autoincrement())
  uuid         String       @default(uuid())
  nombre       String       @unique
  courses      tbl_cursos[]
}

model tbl_adjuntos {
  id_adjunto Int    @id @default(autoincrement())
  uuid       String @default(uuid())
  nombre     String
  url        String @db.Text

  id_curso Int
  curso    tbl_cursos @relation(fields: [id_curso], references: [id_curso], onDelete: Cascade)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([id_curso])
}


```

  

- Ejecutar `npx prisma generate`
- Ejecutar `npx prisma db push`
- Crear `actions/get-courses.tsx`

```tsx
import { tbl_categorias, tbl_cursos } from "@prisma/client";

import { db } from "@/lib/db";

type CourseWithCategory = tbl_cursos & {
    categoria: tbl_categorias | null;
};

type GetCourses = {
    userId: string;
    title?: string;
    category?: string;
};

export const getCourses = async ({
    userId,
    title,
    category
}: GetCourses): Promise<CourseWithCategory[]> => {
    try {
        const categoria = await db.tbl_categorias.findFirst({
            where: {
                uuid: category,
            },
        });

        const courses = await db.tbl_cursos.findMany({
            where: {
                publicado: true,
                titulo: {
                    contains: title,
                },
                id_categoria: category ? categoria?.id_categoria : undefined,
            },
            include: {
                categoria: true,
            },
            orderBy: {
                createdAt: "desc",
            }
        });

        const coursesList: CourseWithCategory[] = await Promise.all(
            courses.map(async course => {
                return {
                    ...course
                }
            })
        );
        return coursesList;

    } catch (error) {
        console.log("[GET_COURSES]", error);
        return [];
    }
}

```

  

- Crear `components/CourseCard.tsx`

```tsx
import Image from "next/image";
import Link from "next/link";
import { formatPrice } from "@/lib/format";

interface CourseCardProps {
    id: string;
    title: string;
    imageUrl: string;
    price: number;
    category: string;
};

export const CourseCard = ({
    id,
    title,
    imageUrl,
    price,
    category
}: CourseCardProps) => {
    return (
        <Link href={`/courses/${id}`}>
            <div className="group hover:shadow-sm transition overflow-hidden border rounded-lg p-3 h-full bg-white dark:bg-black">
                <div className="relative w-full aspect-video rounded-md overflow-hidden">
                    <Image
                        fill
                        className="object-cover"
                        alt={title}
                        src={imageUrl}
                    />
                </div>
                <div className="flex flex-col pt-2">
                    <div className="text-lg md:text-base font-medium group-hover:text-sky-700 dark:group-hover:text-yellow-500 transition line-clamp-2">
                        {title}
                    </div>
                    <p className="text-xs text-muted-foreground">
                        {category}
                    </p>
                    <p className="text-md md:text-sm font-medium text-slate-700">
                        {formatPrice(price)}
                    </p>

                </div>
            </div>
        </Link>
    )
}

```

  

- Crear `components/CoursesList.tsx`

```tsx
import { tbl_categorias, tbl_cursos } from "@prisma/client";
import { CourseCard } from "./CourseCard";

type CourseWithCategory = tbl_cursos & {
    categoria: tbl_categorias | null;
};

interface CoursesListProps {
    items: CourseWithCategory[];
}

export const CoursesList = ({
    items
}: CoursesListProps) => {
    return (
        <div>
            <div className="grid sm:grid-cols-2 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-4 gap-4">
                {items.map((item) => (
                    <CourseCard
                        key={item.uuid}
                        id={item.uuid}
                        title={item.titulo!}
                        imageUrl={item.imagen_url!}
                        price={item.precio!}
                        category={item?.categoria?.nombre!}
                    />
                ))}
            </div>
            {items.length === 0 && (
                <div className="text-center text-sm text-muted-foreground mt-10">
                    No courses found
                </div>
            )}
        </div>
    )
}

```

  

- Modificar `app/(dashboard)/(routes)/search/page.tsx`

```tsx
import { db } from "@/lib/db";
import { Categories } from "./_components/Categories";
import { SearchInput } from "@/components/SearchInput";
import { getCourses } from "@/actions/get-courses";
import { auth } from "@clerk/nextjs";
import { redirect } from "next/navigation";
import { CoursesList } from "@/components/CoursesList";

interface SearchPageProps {
    searchParams: {
        title: string;
        categoryId: string;
    }
};

const SearchPage = async ({
    searchParams
}: SearchPageProps) => {
    const { userId } = auth();

    if (!userId) {
        return redirect("/");
    }


    const categories = await db.tbl_categorias.findMany({
        orderBy: {
            nombre: "asc"
        }
    });

    const courses = await getCourses({
        userId,
        ...searchParams,
    });

    return (
        <>
            <div className="px-6 pt-6 md:hidden md:mb-0 block">
                <SearchInput />
            </div>
            <div className="p-6 space-y-4">
                <Categories
                    items={categories}
                />
                <CoursesList items={courses} />
            </div>
        </>
    );
}

export default SearchPage;

```