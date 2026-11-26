#!/usr/bin/env bash
# preflight.sh -> corrélo en la raíz del proyecto ANTES de hacer push a Amplify
# Uso: bash preflight.sh
# No usamos "set -e" a propósito: queremos ver TODOS los chequeos, no que pare en el primero que falle.

FAILED=0
ok()   { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAILED=1; }
warn() { echo "  ⚠️  $1"; }

echo "🔍 1. Archivos necesarios"
for f in package.json package-lock.json amplify.yml .env.example README.md; do
  # package-lock es clave: amplify.yml usa "npm ci", que SOLO funciona con lockfile sincronizado
  [ -f "$f" ] && ok "$f existe" || fail "Falta $f"
done

echo "🔍 2. Node (Next 16 necesita >= 20.9)"
NODE_V=$(node -v 2>/dev/null | sed 's/v//')
NODE_MAJOR=${NODE_V%%.*}
if [ -z "$NODE_V" ]; then fail "Node no está instalado"
elif [ "$NODE_MAJOR" -ge 20 ]; then ok "Node $NODE_V"
else fail "Node $NODE_V es muy viejo (necesitás 20.9+)"; fi

echo "🔍 3. Secretos"
# git check-ignore devuelve 0 si el archivo está ignorado
if git check-ignore -q .env.local 2>/dev/null; then ok ".env.local está en .gitignore"; else fail ".env.local NO está ignorado"; fi
# Si algún .env real está trackeado hay que sacarlo del repo (git rm --cached <archivo>)
if git ls-files --error-unmatch .env .env.local .env.production >/dev/null 2>&1; then
  fail "Hay un .env real trackeado en git"
else
  ok "Ningún .env real está trackeado"
fi

echo "🔍 4. Variables de entorno documentadas"
# Buscamos todo process.env.ALGO en src/ y revisamos que esté en .env.example
for v in $(grep -rhoE 'process\.env\.[A-Z_]+' src 2>/dev/null | sed 's/process\.env\.//' | sort -u); do
  grep -q "^$v=" .env.example && ok "$v documentada en .env.example" || fail "$v se usa en el código pero NO está en .env.example"
done

echo "🔍 5. Lockfile sincronizado (lo que usará Amplify)"
# npm ci --dry-run falla si package.json y package-lock.json no coinciden
if npm ci --dry-run >/dev/null 2>&1; then ok "npm ci --dry-run OK"; else fail "package-lock desincronizado: corré 'npm install' y commiteá el lock"; fi

echo "🔍 6. Lint y build local (tarda un poquito)"
if npm run lint >/tmp/lint.log 2>&1; then ok "npm run lint OK"; else warn "lint con problemas (revisá /tmp/lint.log); no bloquea el build"; fi
if npm run build >/tmp/build.log 2>&1; then ok "npm run build compiló bien"; else fail "npm run build FALLÓ"; tail -n 20 /tmp/build.log; fi

echo "🔍 7. Git"
[ -z "$(git status --porcelain)" ] && ok "Working tree limpio" || warn "Hay cambios sin commitear (hacé commit y push antes de desplegar)"
[ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" = "main" ] && ok "Estás en la rama main" || fail "No estás en la rama main"

echo
if [ $FAILED -eq 0 ]; then echo "🚀 Todo listo para desplegar en Amplify"; else echo "🛑 Arreglá los ❌ antes de desplegar"; fi
exit $FAILED
