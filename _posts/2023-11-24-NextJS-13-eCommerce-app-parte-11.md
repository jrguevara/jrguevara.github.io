---
title: NextJS 13 - eCommerce App - parte 11
date: 2023-11-25 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Landing Page

- Ejecutar `npm i react-type-animation`
- Modificar archivo `.env`

```bash
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/student
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/student

```

  

- Modificar `middleware.ts`

```typescript
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
    publicRoutes: ['/'],
});

export const config = {
    matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};

```

  

- Crear `app/(dashboard)/(routes)/student/page.tsx`

```tsx
import {auth, currentUser } from "@clerk/nextjs";

const StudentPage = async () => {
    const user = await currentUser();
    return (
        <div>
            <h1>Bienvenido, { user?.firstName + ' ' + user?.lastName}</h1>
        </div>
    );
}

export default StudentPage;

```

  

- Editar `app/(dashboard)/_components/SidebarRoutes.tsx` 

```tsx
"use client";
import { Layout, Compass, List, BarChart } from "lucide-react";
import { SidebarItem } from "./SidebarItem";
import { usePathname } from "next/navigation";

const guestRoutes = [
    {
        icon: Layout,
        label: "Dashboard",
        href: "/student",
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

  

- Eliminar `app/(dashboard)/(routes)/page.tsx`
- Crear `components/Logo.tsx`

```tsx
import Link from "next/link";
import Image from "next/image";
import localFont from "next/font/local";

import { cn } from "@/lib/utils";

const headingFont = localFont({
    src: "../public/fonts/font.woff2",
});

export const Logo = () => {
    return (
        <Link href="/">
            <div className="hover:opacity-75 transition items-center gap-x-2 hidden md:flex">
                <Image
                    src="/logo.png"
                    alt="Logo"
                    height={30}
                    width={30}
                />
                <p className={cn(
                    "text-lg text-neutral-700 dark:text-white pb-1",
                    headingFont.className,
                )}>
                    Academia
                </p>
            </div>
        </Link>
    );
};

```

  

- Crear `app/(landing)/_components/Navbar.tsx`

```tsx
import Link from "next/link";
import { Logo } from "@/components/Logo";
import { Button } from "@/components/ui/button";
import { ModeToggle } from "@/components/mode-toggle";

export const Navbar = () => {
    return (
        <div className="fixed top-0 w-full h-14 px-4 border-b shadow-sm  bg-[#ededed] dark:bg-[#1f1f1f] flex items-center">
            <div className="md:max-w-screen-2xl mx-auto flex items-center w-full justify-between">
                <Logo />
                <div className="flex gap-x-8 ml-auto">
                    <Button size="sm" variant="customghost" asChild>
                        <Link href="/sign-in">
                            Iniciar sesión
                        </Link>
                    </Button>
                    <Button size="sm" asChild>
                        <Link href="/sign-up">
                            Registrate gratis
                        </Link>
                    </Button>
                    <ModeToggle />
                </div>
            </div>
        </div>
    );
};

```

  

- Crear `app/(landing)/_components/Footer.tsx`

```tsx
import { Logo } from "@/components/Logo";
import { Button } from "@/components/ui/button";

export const Footer = () => {
    return (
        <div className="fixed bottom-0 w-full p-4 border-t  bg-[#ededed] dark:bg-[#1f1f1f]">
            <div className="md:max-w-screen-2xl mx-auto flex items-center w-full justify-between">
                <Logo />
                <div className="space-x-4 md:block md:w-auto flex items-center justify-between w-full">
                    <Button size="sm" variant="ghost">
                        Politica de privacidad
                    </Button>
                    <Button size="sm" variant="ghost">
                        Terminos de servicio
                    </Button>
                </div>
            </div>
        </div>
    );
};

```

  

- Crear `app/(landing)/layout.tsx`

```tsx
import { Footer } from "./_components/Footer";
import { Navbar } from "./_components/Navbar";

const HomeLayout = ({
    children
}: {
    children: React.ReactNode;
}) => {
    return (
        <div className="h-full bg-[#eae5e5] dark:bg-[#313138]">
            <Navbar />
            <main className="pt-40 pb-20">
                {children}
            </main>
            <Footer />
        </div>
    );
};

export default HomeLayout;

```

  

- Crear `public/fonts` descargar en carpeta archivo `font.woff2` desde [https://github.com/jrguevara/lms-jrcoding-dev/blob/main/public/fonts/font.woff2](https://github.com/jrguevara/lms-jrcoding-dev/blob/main/public/fonts/font.woff2) 
- Crear `app/(landing)/page.tsx`

```tsx
"use client"
import Link from "next/link";
import localFont from "next/font/local";
import { Poppins } from "next/font/google";
import { Medal } from "lucide-react";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import Image from "next/image";

const headingFont = localFont({
    src: "../../public/fonts/font.woff2"
});
import { TypeAnimation } from "react-type-animation";
import { motion } from "framer-motion";
import { Client } from "@clerk/nextjs/server";
import { Logo } from "@/components/Logo";

const textFont = Poppins({
    subsets: ["latin"],
    weight: [
        "100",
        "200",
        "300",
        "400",
        "500",
        "600",
        "700",
        "800",
        "900"
    ],
});

const HomePage = () => {
    return (
        <div className="flex items-center justify-center flex-col">
            <div className={cn(
                "flex items-center justify-center flex-col",
                headingFont.className,
            )}>
                <div className="flex items-center justify-center p-10">
                    <Image
                        src="/logo.png"
                        alt="Logo"
                        height={100}
                        width={100}
                    />

                    <p className={cn(
                        "text-6xl text-neutral-700 dark:text-white pb-1",
                        headingFont.className,
                    )}>
                        Academia
                    </p>
                </div>
                <div className="mb-10 flex items-center border shadow-sm p-4 bg-teal-500 text-sky-700 rounded-full">
                    <Medal className="h-6 w-6 mr-2" />
                    La plataforma de aprendizaje # 1
                </div>
                <h1 className="text-3xl md:text-6xl text-center text-neutral-800 dark:text-white mb-6">
                    Hoy quiero aprender a...
                </h1>
                <motion.div
                    initial={{ opacity: 0, scale: 0.5 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ duration: 0.5 }}
                    className="col-span-8 place-self-center text-center sm:text-left justify-self-start"
                >
                    <h1 className="text-teal-800 dark:text-yellow-500 mb-4 text-4xl sm:text-5xl lg:text-8xl lg:leading-normal font-extrabold">
                        <TypeAnimation
                            sequence={[
                                "Programar la web",
                                1000,
                                "Crear diseños asombrosos",
                                1000,
                                "Tocar la guitarra",
                                1000,
                                "Aplicar matematicas",
                                1000,
                            ]}
                            wrapper="span"
                            speed={50}
                            repeat={Infinity}
                        />
                    </h1>
                </motion.div>
            </div>
            <div className={cn(
                "text-sm md:text-xl text-neutral-600 dark:text-neutral-400 mt-4 max-w-xs md:max-w-2xl text-center mx-auto",
                textFont.className,
            )}>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
            </div>
            <Button className="mt-6" size="lg" asChild>
                <Link href="/sign-up">
                    Registrarse
                </Link>
            </Button>
        </div>
    );
};

export default HomePage;

```

  

- Modificar `app/(landing)/_components/Navbar.tsx`

```tsx
import Link from "next/link";
import { Logo } from "@/components/Logo";
import { Button } from "@/components/ui/button";
import { ModeToggle } from "@/components/mode-toggle";
import { auth, UserButton } from "@clerk/nextjs";

export const Navbar = () => {
    const { userId } = auth();
    return (
        <div className="fixed top-0 w-full h-14 px-4 border-b shadow-sm  bg-[#ededed] dark:bg-[#1f1f1f] flex items-center">
            <div className="md:max-w-screen-2xl mx-auto flex items-center w-full justify-between">
                <Logo />
                <div className="flex gap-x-8 ml-auto">
                    {!userId && (
                        <>
                            <Button size="sm" variant="customghost" asChild>
                                <Link href="/sign-in">
                                    Iniciar sesión
                                </Link>
                            </Button>
                            <Button size="sm" asChild>
                                <Link href="/sign-up">
                                    Registrate gratis
                                </Link>
                            </Button>
                        </>
                    )}
                    {userId && (
                        <Button size="sm" variant="customghost" asChild>
                            <Link href="/student">
                                Dashboard
                            </Link>
                        </Button>
                    )}
                    <UserButton
                        afterSignOutUrl="/"
                    />
                    <ModeToggle />
                </div>
            </div>
        </div>
    );
};

```