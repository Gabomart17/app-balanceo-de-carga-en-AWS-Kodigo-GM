# Guía de despliegue: ClickZone en AWS Amplify

ClickZone no usa base de datos ni claves secretas: solo tiene **una variable opcional**,
`NEXT_PUBLIC_SITE_URL`. Por eso el despliegue es corto.

## 0. Antes de empezar
```bash
bash preflight.sh        # revisa lockfile, variables, secretos, lint y build
```

## 1. Subir cambios a GitHub
```bash
git add .
git commit -m "chore: agregar configuración de despliegue para AWS Amplify"
git push origin main
```

## 2. Crear la app en Amplify
1. Consola AWS -> región (us-east-1 o us-east-2) -> buscar **AWS Amplify**.
2. **Create new app** -> **GitHub** -> Next.
3. Autorizar GitHub y elegir el repo y la rama `main`.
4. Amplify detecta Next.js y usa `amplify.yml`. Si pide rol de servicio: **Create and use a new service role**.
5. **Save and deploy**.

## 3. Versión de Node (si el build se queja)
Next 16 necesita Node 20.9+. Amplify solo soporta Node 16, 18, 20 y 22.
`amplify.yml` ya pide Node 22. Si aun así falla por la versión:
**Amplify -> Hosting -> Build settings -> Build image settings -> Edit -> Live package updates -> Node.js = 22**.

## 4. Variable de entorno (segundo deploy)
La URL pública solo se conoce DESPUÉS del primer deploy:
1. Copiá la URL `https://main.xxxxxxxx.amplifyapp.com`.
2. **Hosting -> Environment variables -> Manage variables** -> agregar
   `NEXT_PUBLIC_SITE_URL` = esa URL.
3. **Redeploy this version** (las `NEXT_PUBLIC_*` se hornean en el build).

Es opcional: sin ella la app funciona igual (solo cambia `metadataBase` para Open Graph).

## 5. Verificación
- [ ] La URL carga
- [ ] `/` , `/productos`, `/productos/1`, `/comparar`, `/favoritos` funcionan
- [ ] Filtros y búsqueda del catálogo traen datos (consume `/api/productos`)
- [ ] `/api/productos` y `/api/productos/1` responden JSON
- [ ] Una ruta inexistente muestra el 404 personalizado
- [ ] Favoritos y comparador funcionan (usan localStorage)
- [ ] Se ve bien en celular

## 6. Capturas para entregar
1. Panel de Amplify con el build en **Deployed**.
2. La app en el navegador con la URL pública visible.

## 7. Entregables
- [ ] URL pública activa
- [ ] Repo público de GitHub
- [ ] README.md con la URL del deploy + instrucciones (pegá la URL real en la línea "Despliegue")
- [ ] 2 capturas

## Troubleshooting
| Síntoma | Causa probable | Solución |
|---|---|---|
| `Unsupported NodeJS version` | Amplify usa/pide Node no soportado | Fijar Node 22 en Live package updates |
| Falla en `npm ci` | package-lock desincronizado | `npm install` local y commitear el lock |
| Falla en TypeScript | Error de tipos | Corregirlo (corré `npm run build` local) |
| "Module not found" | Mayúsculas/minúsculas en imports (Linux distingue) | Igualar el nombre exacto del archivo |
| La app cargó pero un `NEXT_PUBLIC_*` sale vacío | Variable agregada después del build | Redeploy |
| 404 en todo | Salida mal configurada | `baseDirectory: .next` en amplify.yml |
| Build falla al bajar la fuente Geist | Sin internet en el build (raro) | Reintentar el build |
