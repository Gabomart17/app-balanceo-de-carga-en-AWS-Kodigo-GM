# ClickZone

Catálogo de periféricos gaming (mouse, teclados, headsets y monitores) con filtros, búsqueda, comparador de hasta 3 productos y favoritos.

Proyecto de la actividad evaluada **"Implementación de Aplicación Next.js mediante Vibe Coding: Flujo de Desarrollo Guiado por IA"**, construido con Claude como copiloto. El registro del proceso está en [`VIBE_CODING.md`](./VIBE_CODING.md).

🔗 **Despliegue (AWS Amplify):** _pendiente: pegar aquí la URL pública, ej. https://main.xxxxxxxx.amplifyapp.com_

## Stack

- Next.js 16 (App Router, Turbopack, Cache Components)
- React 19 + TypeScript
- Tailwind CSS 4
- Route Handlers como API interna
- Despliegue en AWS Amplify (`amplify.yml`)

## Requisitos

- Node.js 20.9 o superior
- npm

## Instalación y uso

```bash
# 1. Instalar dependencias
npm install

# 2. Variables de entorno
cp .env.example .env.local      # en Windows: copy .env.example .env.local

# 3. Servidor de desarrollo -> http://localhost:3000
npm run dev
```

Otros scripts:

```bash
npm run build   # compilación de producción (revisa TODAS las rutas)
npm run start   # sirve el build de producción
npm run lint    # ESLint
```

## Rutas

| Ruta | Tipo | Descripción |
| --- | --- | --- |
| `/` | Server | Landing con productos destacados |
| `/productos` | Server + Client | Catálogo con filtros y búsqueda (consume `/api/productos`) |
| `/productos/[id]` | Server + Client | Detalle y especificaciones; botones de favorito y comparar |
| `/comparar` | Client | Comparador de hasta 3 productos |
| `/favoritos` | Client | Lista de favoritos (guardada en `localStorage`) |
| `/api/productos` | Route Handler | Lista; admite `?categoria=mouse` y `?q=texto` |
| `/api/productos/[id]` | Route Handler | Detalle; responde 404 si no existe |

## Requisitos de la actividad

- **App Router, 4+ rutas:** ver tabla de rutas.
- **API:** Route Handlers en `src/app/api/productos`.
- **Server y Client Components:** páginas de lectura en servidor; catálogo, comparador, favoritos y navbar en cliente.
- **`useState` / `useEffect`:** `Catalogo.tsx` (filtros, debounce y fetch).
- **Responsive:** diseño mobile-first con Tailwind (menú hamburguesa en móvil).
- **Loading y error UI:** `src/app/productos/loading.tsx`, `src/app/error.tsx`, `src/app/not-found.tsx` y estados de carga/error dentro del catálogo.
- **Variables de entorno:** `.env.example` documentado.

## Estructura

```
src/
├── app/
│   ├── api/productos/         # Route Handlers
│   ├── productos/             # catálogo, detalle y loading
│   ├── comparar/  favoritos/
│   ├── error.tsx  not-found.tsx  layout.tsx  page.tsx
├── components/                # Navbar, ProductCard, Catalogo, Comparador...
├── data/productos.ts          # datos de ejemplo tipados
├── lib/                       # listas persistentes en localStorage
└── types/producto.ts
```

## Despliegue en AWS Amplify

La app corre en **AWS Amplify Hosting** (SSR), conectada a la rama `main` de GitHub. Cada `git push` a `main` redespliega solo.

1. Repo público en GitHub con la rama `main` actualizada.
2. AWS Console -> **AWS Amplify** -> **Create new app** -> **GitHub** -> elegir el repo y la rama `main`.
3. Amplify detecta Next.js y usa el archivo [`amplify.yml`](./amplify.yml) (build: `npm run build`).
4. En **Hosting -> Environment variables** agregar `NEXT_PUBLIC_SITE_URL` con la URL pública de Amplify (opcional; ver `.env.example`).
5. **Save and deploy** y esperar el estado **Deployed**.

Más detalle y solución de errores comunes en [`docs/GUIA_DESPLIEGUE.md`](./docs/GUIA_DESPLIEGUE.md).

Antes de subir cambios podés correr `bash preflight.sh` para validar el proyecto.
