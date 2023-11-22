---
title: NextJS 13 - eCommerce App - parte 3
date: 2023-10-05 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Layout dinamico


- Modificar `app/components/NavbarRoutes.tsx` para agregar los hooks necesarios para navegación dinámica

```tsx
"use client";

import { UserButton } from "@clerk/nextjs";
import { ModeToggle } from "@/components/mode-toggle";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react";
import { usePathname } from "next/navigation";
import Link from "next/link";

export const NavbarRoutes = () => {
    const pathname = usePathname();
    const isTeacherPage = pathname?.startsWith("/teacher");
    const isPlayerPage = pathname?.includes("/chapter");

    return (
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
    );
}

```

  

- Crear `app/(dashboard)/(routes)/teacher/courses/page.tsx`

```tsx
const CoursesPage = () => {
    return (
        <div>
            Pagina para cursos
        </div>
    );
}

export default CoursesPage;

```

  

- Agregar rutas para modo profesor editando `app/(dashboard)/_components/SidebarRoutes.tsx` 

```tsx
"use client";
import { Layout, Compass, List, BarChart } from "lucide-react";
import { SidebarItem } from "./SidebarItem";
import { usePathname } from "next/navigation";

const guestRoutes = [
    {
        icon: Layout,
        label: "Dashboard",
        href: "/",
    },
    {
        icon: Compass,
        label: "Navegar",
        href: "/search",
    }
];

const teacherRoutes = [
    {
        icon: List,
        label: "Cursos",
        href: "/teacher/courses",
    },
    {
        icon: BarChart,
        label: "Estadisticas",
        href: "/teacher/stadistics",
    }
];

export const SidebarRoutes = () => {
    const pathname = usePathname(); 
    const isTeacherPage = pathname?.includes("/teacher");
    const routes = isTeacherPage ? teacherRoutes : guestRoutes;

    return (
        <div className="flex flex-col w-full">
            {routes.map((route) => (
                <SidebarItem 
                key={route.href}
                icon={route.icon}
                label={route.label}
                href={route.href}
            />
            ))}
        </div>
    )
};


```

  

- Crear `app/(dashboard)/(routes)/teacher/stadistics/page.tsx`

```tsx
const StadisticPage = () => {
    return (
        <div>
            Pagina para estadisticas
        </div>
    );
}

export default StadisticPage;

```

  

- Editar `app/(dashboard)/layout.tsx` para empujar el contenido verticalmente

```tsx
import Navbar from "./_components/Navbar";
import Sidebar from "./_components/Sidebar";

const DashboardLayout = ({ children }: { children: React.ReactNode }) => {
    return (
        <div className="h-full">
            <div className="h-[80px] md:pl-56 fixed inset-y-0 w-full z-50">
                <Navbar />
            </div>
            <div className="hidden md:flex h-full w-56 flex-col fixed inset-y-0 z-50">
                <Sidebar />
            </div>
            <main className="md:pl-56 pt-[80px] h-full">
                {children}
            </main>
        </div>
    );
}

export default DashboardLayout;

```

  

- Limpiar el contenido de la pagina inicial. Editar `app/(dashboard)/(toutes)page.tsx`

```tsx
export default function Home() {
  return (
    <div>
      Pagina de inicio
    </div>
  );
}

```

  

## IU Crear Curso

 

- `npx shadcn-ui@latest add form` 
- `npx shadcn-ui@latest add input` 
- `npm install axios` 
- `npm install react-hot-toast`
- Editar `app/(dashboard)/(routes)/teacher/courses/page.tsx`

```tsx
import { Button } from "@/components/ui/button";
import Link from "next/link";

const CoursesPage = () => {
    return (
        <div className="p-6">
            <Link href="/teacher/create">
                <Button> Crear curso </Button>
            </Link>
        </div>
    );
}

export default CoursesPage;

```

  

- Agregar variante de botón `success` a `components/ui/button.tsx`

```tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
        customghost: "hover:bg-teal-600 hover:text-white hover:dark:bg-yellow-500 hover:dark:text-black",
        success: "bg-green-500 text-white hover:bg-green-600",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }

```

  

  

- Crear `app/(dashboard)/(routes)/teacher/create/page.tsx`

```tsx
"use client";

import * as z from "zod";
import axios from "axios";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Form, FormControl, FormDescription, FormField, FormLabel, FormMessage, FormItem } from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const formSchema = z.object({
    titulo: z.string().min(1, {
        message: "El título es requerido",
    }),
});

const CreatePage = () => {
    const router = useRouter();
    // hook para el formulario
    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            titulo: "",
        },
    });

    //Extraccion de estados del formulario
    const { isSubmitting, isValid } = form.formState;

    const onSubmit = (values: z.infer<typeof formSchema>) => {
        console.log(values);
    };

    return (
        <div className="max-w-5xl mx-auto flex md:items-center md:justify-center h-full p-6">
            <div className="bg-[#cfcfcf] dark:bg-[#1f1f1f] p-6">
                <h1 className="text-2xl">Nombra tu curso</h1>
                <p className="text-sm text-slate-600 dark:text-gray-500">
                    ¿Como te gustaría nombrar tu curso? No te preocupes, puedes cambiar esto después.
                </p>
                <Form {...form}>
                    <form
                        onSubmit={form.handleSubmit(onSubmit)}
                        className="space-y-8 mt-8"
                    >
                        <FormField
                            control={form.control}
                            name="titulo"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>
                                        Titulo del curso
                                    </FormLabel>
                                    <FormControl>
                                        <Input
                                            disabled={isSubmitting}
                                            placeholder="ej. 'Desarrollo web con Next.js'"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormDescription>
                                        ¿Que vas a enseñar en este curso?
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <div className="flex items-center gap-x-2">
                            <Link href="/">
                                <Button
                                    type="button"
                                    variant="destructive"
                                >
                                    Cancelar
                                </Button>
                            </Link>
                            <Button
                                type="submit"
                                variant="success"
                                disabled={!isValid || isSubmitting}
                            >
                                Aceptar
                            </Button>
                        </div>
                    </form>
                </Form>
            </div>
        </div>
    );
}

export default CreatePage;

```

- Crear `app/components/providers/toastter-provider.tsx`

```tsx
"use client";
import { Toaster } from "react-hot-toast";

export const ToasterProvider = () => {
    return <Toaster />
}

```

  

- Editar `app/layout.tsx`

```tsx
import './globals.css'
import type { Metadata } from 'next'
import { Open_Sans } from 'next/font/google'
import { ClerkProvider } from '@clerk/nextjs'
import { ThemeProvider } from '@/components/providers/theme-provider'
import { cn } from '@/lib/utils'
import { ToasterProvider } from '@/components/providers/toaster-provider'

const font = Open_Sans({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Create Next App',
  description: 'Generated by create next app',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ClerkProvider>
      <html lang="en" suppressHydrationWarning>
        <body className={cn(
          font.className,
          "bg-[#dddddd] dark:bg-[#313138]")}>
          <ThemeProvider
            attribute='class'
            defaultTheme='dark'
            enableSystem={true}
            storageKey='theme-lms'
          >
            <ToasterProvider />
            {children}
          </ThemeProvider>
        </body>
      </html>
    </ClerkProvider>
  )
}


```

  

- Modificar `app/(dashboard)/(routes)/teacher/create/page.tsx`

```tsx
"use client";

import * as z from "zod";
import axios from "axios";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Form, FormControl, FormDescription, FormField, FormLabel, FormMessage, FormItem } from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import toast from "react-hot-toast";

const formSchema = z.object({
    titulo: z.string().min(1, {
        message: "El título es requerido",
    }),
});

const CreatePage = () => {
    const router = useRouter();
    // hook para el formulario
    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            titulo: "",
        },
    });

    //Extraccion de estados del formulario
    const { isSubmitting, isValid } = form.formState;

    /*const onSubmit = (values: z.infer<typeof formSchema>) => {
        console.log(values);
    };*/

    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        try {
            const response = await axios.post("/api/courses", values);
            router.push(`/teacher/courses/${response.data.id}`);
        } catch (error) {
            //console.log("ha ocurrido un error");
            toast.error("Ha ocurrido un error");
        }
    }

    return (
        <div className="max-w-5xl mx-auto flex md:items-center md:justify-center h-full p-6">
            <div className="bg-[#cfcfcf] dark:bg-[#1f1f1f] p-6">
                <h1 className="text-2xl">Nombra tu curso</h1>
                <p className="text-sm text-slate-600 dark:text-gray-500">
                    ¿Como te gustaría nombrar tu curso? No te preocupes, puedes cambiar esto después.
                </p>
                <Form {...form}>
                    <form
                        onSubmit={form.handleSubmit(onSubmit)}
                        className="space-y-8 mt-8"
                    >
                        <FormField
                            control={form.control}
                            name="titulo"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>
                                        Titulo del curso
                                    </FormLabel>
                                    <FormControl>
                                        <Input
                                            disabled={isSubmitting}
                                            placeholder="ej. 'Desarrollo web con Next.js'"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormDescription>
                                        ¿Que vas a enseñar en este curso?
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <div className="flex items-center gap-x-2">
                            <Link href="/">
                                <Button
                                    type="button"
                                    variant="destructive"
                                >
                                    Cancelar
                                </Button>
                            </Link>
                            <Button
                                type="submit"
                                variant="success"
                                disabled={!isValid || isSubmitting}
                            >
                                Aceptar
                            </Button>
                        </div>
                    </form>
                </Form>
            </div>
        </div>
    );
}

export default CreatePage;

```