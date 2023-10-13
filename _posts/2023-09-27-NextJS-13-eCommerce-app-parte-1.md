---
title: NextJS 13 - eCommerce App - parte 1
date: 2023-09-27 00:00:00 -500
categories: [react]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Configuración inicial
  
[https://ui.shadcn.com/](https://ui.shadcn.com/)  

[https://ui.shadcn.com/docs/installation/next](https://ui.shadcn.com/docs/installation/next)  

- Crear app de NextJS `npx create-next-app@latest my-app --typescript --tailwind --eslint`

![NextJS](/assets/images/next1.png)_NextJS_  

- CLI de shadcn-ui `npx shadcn-ui@latest init`

![NextJS](/assets/images/next2.png)_NextJS_  

- Ejecutar proyecto con `npm run dev`
- Editar `app/page.tsx` y probar tailwind.css ([https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss))

```tsx
export default function Home() {
  return (
    <div>
      <p className="text-3xl font-medium text-sky-700">Hello World</p>
    </div>
  );
}

```

  

## Componentes de shadcn-ui

[https://ui.shadcn.com/docs/components](https://ui.shadcn.com/docs/components/button)  

- Instalación de componente botón `npx shadcn-ui@latest add button`
- Agregar boton a `app/page.tsx`

```tsx
import { Button } from "@/components/ui/button";

export default function Home() {
  return (
    <div>
      <p className="text-3xl font-medium text-sky-700">Hello World</p>
      <Button>
        Click
      </Button>
    </div>
  );
}

```

  

Variantes de botón
- [https://tailwindcss.com/docs/customizing-colors](https://tailwindcss.com/docs/customizing-colors)
- [https://tailwindcss.com/docs/text-color](https://tailwindcss.com/docs/text-color)

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
        warning:
        "bg-yellow-500 text-black hover:bg-yellow-700",
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
```

  

- Agregar a `app/globals.css`

```css
html,
body,
:root {
  height: 100%;
}

```

  

## Estructura de carpetas, grupos, rutas y paginas

- Instalar [https://marketplace.visualstudio.com/items?itemName=burkeholland.simple-react-snippets](https://marketplace.visualstudio.com/items?itemName=burkeholland.simple-react-snippets)
- Instalar [https://marketplace.visualstudio.com/items?itemName=NextNav.NextNav](https://marketplace.visualstudio.com/items?itemName=NextNav.NextNav)
- Crear pagina de ejemplo `app/test/page.tsx`

```tsx
const TestPage = () => {
    return (
        <div>Pagina de prueba</div>
    );
};

export default TestPage;

```

  

- Crear ruta `app/api/test/route.ts`

```ts
import { NextResponse } from "next/server";

export async function GET() {
    return NextResponse.json({ test: "Hello World APIv1" });
}

```

  

- Crear `app/(group)/ruta_a/page.tsx`

```tsx
const RutaA = () => {
    return (
        <div>
            Esta es la ruta A dentro de una carpeta grupal
        </div>
    );
}

export default RutaA;

```

  

- Crear `app/(group)/ruta_b/page.tsx`

```tsx
const RutaB = () => {
    return (
        <div>
            Esta es la ruta B dentro de una carpeta grupal
        </div>
    );
}

export default RutaB;

```

  

- Crear `app/(group)/layout.tsx`

```tsx
const GroupLayout = ({ children }: { children: React.ReactNode }) => {
    return (
        <div className="h-full bg-slate-600 text-white">
            {children}
        </div>
    );
}

export default GroupLayout;

```

  

- Borrar los archivos y carpetas de esta sección
- Crear `app/(dashboard)/(routes)` y mover dentro `app/page.tsx`

  

## Autenticación

- Crear cuenta en [https://clerk.com/](https://clerk.com/)
- Crear aplicación, seleccionar NextJS y copiar llaves

- Añadir .env al archivo .gitignore
- Crear archivo .env en la raiz del proyecto y pegar las llaves
- [https://clerk.com/docs/quickstarts/nextjs](https://clerk.com/docs/quickstarts/nextjs)
- instalar el paquete de clerk `npm install @clerk/nextjs`
- Editar `app/layout.tsx`
```tsx
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { ClerkProvider } from '@clerk/nextjs'

const inter = Inter({ subsets: ['latin'] })

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
      <html lang="en">
        <body className={inter.className}>{children}</body>
      </html>
    </ClerkProvider>
  )
}
```
- Crear en raíz del proyecto `middleware.ts`

```typescript
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({});

export const config = {
    matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};

```

  

- Crear `app/(auth)/(routes)/sign-up/[[...sign-up]]page.tsx`

```tsx
import { SignUp } from "@clerk/nextjs";

export default function Page() {
    return <SignUp />;
}

```

  

- Crear `app/(auth)/(routes)/sign-in/[[...sign-in]]page.tsx`

```tsx
import { SignIn } from "@clerk/nextjs";

export default function Page() {
    return <SignIn />;
}

```

  

- Actualizar variables de entorno

```
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/

```

  

- Editar `app/(dashboard)/routes/page.tsx`

```tsx
import { UserButton } from "@clerk/nextjs";

export default function Home() {
  return (
    <div>
      <UserButton
        afterSignOutUrl="/"
      />
    </div>
  );
}

```

  

- Crear `app/(auth)/layout.tsx`

```tsx
const AuthLayout = ({ children }: { children: React.ReactNode }) => {
    return (
        <div className="h-full flex items-center justify-center">
            {children}
        </div>
    );
}

export default AuthLayout;

```

  

- Para rutas publicas, crear `app/test/page.tsx`

```tsx
const TestPage = () => {
    return (
        <div>
            <h1>Test Page: sin protección</h1>
        </div>
    );
}

export default TestPage;

```

  

- Editar `middleware.ts` para agregar rutas sin protección

```tsx
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
    publicRoutes: ["/test"]
});

export const config = {
    matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};

```