---
title: NextJS 13 - eCommerce App - parte 12
date: 2023-12-02 00:00:00 -500
categories: [NextJS]
tags: [javascript, reactjs, nextjs, ecommerce, programacion]
published: true
hidden: false
---

## Finalizando Esquema en Prisma

- Instalar `npx shadcn-ui@latest add separator`
- Modificar `prisma/schema.prisma`

```typescript
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
  compras tbl_compras[]

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

model tbl_compras {
  id_compra  String @id @default(uuid())
  userId String

  id_curso   Int
  curso      tbl_cursos @relation(fields: [id_curso], references: [id_curso], onDelete: Cascade)
  curso_uuid String
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt()

  @@unique([userId, curso_uuid])
  @@index([id_curso])
}

model tbl_stripe_clientes {
  id               String @id @default(uuid())
  userId           String @unique
  stripeCustomerId String @unique

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

```

  

## Detalle de curso

- Ejecutar `npx prisma generate`
- Ejecutar `npx prisma db push`
- Crear `app/(dashboard)/(routes)/courses/[uuid]/page.tsx`

```tsx
import { Separator } from "@/components/ui/separator";
import { db } from "@/lib/db";
import Image from "next/image";
import { redirect } from "next/navigation";
import { auth } from "@clerk/nextjs";
import { CourseEnrollButton } from "../_components/CourseEnrollButton";
import { File } from "lucide-react";
import { Button } from "@/components/ui/button";

const CourseIdPage = async ({
    params
}: {
    params: { uuid: string; }
}) => {
    const course = await db.tbl_cursos.findFirst({
        where: {
            uuid: params.uuid,
        },
        include: {
            adjuntos: true
        }
    });

    if (!course) {
        return redirect("/");
    }

    const purchase = await db.tbl_compras.findUnique({
        where: {
            userId_curso_uuid: {
                userId: auth().userId!,
                curso_uuid: course.uuid,
            }
        }
    });

    return (
        <div>
            <div className="flex flex-col max-w-4xl mx-auto pb-20 m-2">
                <div className="relative aspect-video pb-2">
                    <Image
                        alt="Cover"
                        fill
                        className="object-cover rounded-md"
                        src={course.imagen_url!}
                    />
                </div>
                <div>
                    <div className="p-4 flex flex-col md:flex-row items-center justify-between">
                        <h2 className="text-2xl font-semibold mb-2">
                            {course.titulo}
                        </h2>
                        {purchase ? (
                            <Button
                                disabled={true}
                                size="sm"
                                className="w-full md:w-auto"
                            >
                                Inscrito
                            </Button>
                        ) : (
                            <CourseEnrollButton
                                id_curso={course.id_curso}
                                price={course.precio!}
                            />
                        )}
                    </div>
                    <Separator />
                    <div className="p-6">
                        <p>{course.descripcion!}</p>
                    </div>
                </div>
                {purchase && (
                    <>
                        {!!course.adjuntos.length && (
                            <>
                                <Separator />
                                <div className="p-4 md:flex-row">
                                    <h2 className="text-xl font-semibold mb-2">
                                        Material extra para el curso
                                    </h2>
                                    <div className="p-4">
                                        {course.adjuntos.map((adjunto) => (
                                            <a
                                                href={adjunto.url}
                                                target="_blank"
                                                key={adjunto.id_adjunto}
                                                className="flex items-center p-3 w-full bg-sky-100 dark:bg-[#313138] border-sky-200 dark:border-white border dark:text-teal-400 text-sky-700 rounded-md mt-2"
                                            >
                                                <File className="h-4 w-4 mr-2 flex-shrink-0" />
                                                <p className="text-sm line-clamp-1">
                                                    {adjunto.nombre}
                                                </p>
                                            </a>
                                        ))}
                                    </div>
                                </div>
                            </>
                        )}

                    </>
                )}

            </div>
        </div>
    );
}

export default CourseIdPage;

```

  

- Crear `app/(dashboard)/(routes)/courses/_components/CourseEnrollButton.tsx`

```javascript
"use client";

import axios from "axios";
import { useState } from "react";
import toast from "react-hot-toast";

import { Button } from "@/components/ui/button";
import { formatPrice } from "@/lib/format";

interface CourseEnrollButtonProps {
    price: number;
    id_curso: number;
}

export const CourseEnrollButton = ({
    price,
    id_curso,
}: CourseEnrollButtonProps) => {
    const [isLoading, setIsLoading] = useState(false);

    const onClick = async () => {
        try {
            setIsLoading(true);

            const response = await axios.post(`/api/courses/${id_curso}/checkout`)

            window.location.assign(response.data.url);
        } catch {
            toast.error("Sucedio un error al procesar el pago");
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <Button
            onClick={onClick}
            disabled={isLoading}
            size="sm"
            className="w-full md:w-auto"
        >
            Inscribete por {formatPrice(price)}
        </Button>
    )
}

```

  

## Integración con Stripe

- Crear cuenta en [https://stripe.com/](https://stripe.com/)
- Crear nueva cuenta o Tienda en dashboard de Stripe
- Acceder a API KEYS FOR DEVELOPERS [https://dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys)
- Editar archivo `.env` y pegar Secret api key

```bash
STRIPE_API_KEY=sk_test_51OJI1ELlyOAqRjT0cpeFtui2gzhXmi4iSFXo1oemkI0MEpY5MUfwXutYvr38OAEew5146MceIc9qwq00rCfXiO1h
NEXT_PUBLIC_APP_URL=http://localhost:3000

```

- Ejecutar `npm i stripe`
- Crear `lib/stripe.ts`

```typescript
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_API_KEY!, {
    apiVersion: "2023-10-16",
    typescript: true,
});

```

- Crear ruta de cobro en `app/api/courses/[courseUuid]/checkout/route.ts`

```typescript
import Stripe from "stripe";
import { currentUser } from "@clerk/nextjs";
import { NextResponse } from "next/server";

import { db } from "@/lib/db";
import { stripe } from "@/lib/stripe";

export async function POST(
    req: Request,
    { params }: { params: { id_curso: string } }
) {
    try {
        const user = await currentUser();

        if (!user || !user.id || !user.emailAddresses?.[0]?.emailAddress) {
            return new NextResponse("No autorizado", { status: 401 });
        }

        const course = await db.tbl_cursos.findUnique({
            where: {
                id_curso: parseInt(params.id_curso),
                publicado: true,
            }
        });

        const purchase = await db.tbl_compras.findUnique({
            where: {
                userId_curso_uuid: {
                    userId: user.id,
                    curso_uuid: course?.uuid!,
                }
            }
        });

        if (purchase) {
            return new NextResponse("Curso adquirido anteriormente", { status: 400 });
        }

        if (!course) {
            return new NextResponse("No fue encontrado", { status: 404 });
        }

        const line_items: Stripe.Checkout.SessionCreateParams.LineItem[] = [
            {
                quantity: 1,
                price_data: {
                    currency: "USD",
                    product_data: {
                        name: course.titulo,
                        description: course.descripcion!,
                    },
                    unit_amount: Math.round(course.precio! * 100),
                }
            }
        ];

        let stripeCustomer = await db.tbl_stripe_clientes.findUnique({
            where: {
                userId: user.id,
            },
            select: {
                stripeCustomerId: true,
            }
        });

        if (!stripeCustomer) {
            const customer = await stripe.customers.create({
                email: user.emailAddresses[0].emailAddress,
            });

            stripeCustomer = await db.tbl_stripe_clientes.create({
                data: {
                    userId: user.id,
                    stripeCustomerId: customer.id,
                }
            });
        }

        const session = await stripe.checkout.sessions.create({
            customer: stripeCustomer.stripeCustomerId,
            line_items,
            mode: 'payment',
            success_url: `${process.env.NEXT_PUBLIC_APP_URL}/courses/${course.uuid}?success=1`,
            cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/courses/${course.uuid}?canceled=1`,
            metadata: {
                courseId: course.id_curso,
                courseUuid: course.uuid,
                userId: user.id,
            }
        });

        return NextResponse.json({ url: session.url });
    } catch (error) {
        console.log("[COURSE_ID_CHECKOUT]", error);
        return new NextResponse("Error Interno", { status: 500 })
    }
}

```

  

## Stripe Weebhook

- Habilitar Stripe WeebHook [https://dashboard.stripe.com/test/webhooks/create?endpoint\_location=local](https://dashboard.stripe.com/test/webhooks/create?endpoint_location=local)
- Descargar e instalar CLI [https://stripe.com/docs/stripe-cli](https://stripe.com/docs/stripe-cli)
- Iniciar sesión por medio de la cli con `stripe login`
- Ejecutar `stripe listen --forward-to localhost:3000/api/webhook`   
- Copiar codigo secreto generado y colocarlo en archivo `.env`

```bash
STRIPE_WEBHOOK_SECRET=whsec_9132392357e5e69d9a80a65f187d89448c5efcbe60aa2c9b51e

```

- Crear `app/api/webhook/route.ts` 

```typescript
import Stripe from "stripe";
import { headers } from "next/headers";
import { NextResponse } from "next/server";

import { stripe } from "@/lib/stripe";
import { db } from "@/lib/db";

export async function POST(req: Request) {
    const body = await req.text();
    const signature = headers().get("Stripe-Signature") as string;

    let event: Stripe.Event;

    try {
        event = stripe.webhooks.constructEvent(
            body,
            signature,
            process.env.STRIPE_WEBHOOK_SECRET!
        )
    } catch (error: any) {
        return new NextResponse(`Webhook Error: ${error.message}`, { status: 400 })
    }

    const session = event.data.object as Stripe.Checkout.Session;
    const userId = session?.metadata?.userId;
    const courseId = session?.metadata?.courseId;
    const courseUuid = session?.metadata?.courseUuid;

    if (event.type === "checkout.session.completed") {
        if (!userId || !courseId || !courseUuid ) {
            return new NextResponse(`Webhook Error: Missing metadata`, { status: 400 });
        }

        await db.tbl_compras.create({
            data: {
                id_curso: parseInt(courseId),
                curso_uuid: courseUuid,
                userId: userId,
            }
        });
    } else {
        return new NextResponse(`Webhook Error: Unhandled event type ${event.type}`, { status: 200 })
    }

    return new NextResponse(null, { status: 200 });
}

```

  

- Editar `middleware.ts`

```typescript
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
    publicRoutes: ['/','/api/webhook'],
});

export const config = {
    matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};
```