# Publicar BuildZone en internet (Railway)

Esta guía deja BuildZone en línea con una dirección pública
(`https://algo.up.railway.app`), con su base de datos MySQL y con claves
propias. Tiempo aproximado: 20-30 minutos.

> **Antes de empezar:** corre `mvn test` en tu PC y sube los cambios a GitHub
> (`git push`). Railway construye la aplicación desde tu repositorio.

---

## 1. Qué protege la configuración de producción

Con el perfil `prod` (el `Dockerfile` ya lo activa):

| Protección | Qué hace |
|---|---|
| **Claves obligatorias** | Si falta `JWT_SECRET`, `ADMIN_PASSWORD` o la contraseña de la base, o si son las de ejemplo o débiles, la aplicación **no arranca** y dice qué corregir. |
| **Sin cuentas de prueba** | El script `03_cuentas_prueba.sql` (contraseña `Prueba1234`) **no** se carga. Solo existe el admin con tu contraseña. |
| **Fuerza bruta** | 5 intentos fallidos sobre una cuenta la bloquean 15 minutos. También hay límites por conexión para registro, contacto y "olvidé mi contraseña". |
| **HTTPS** | Railway da HTTPS; la cabecera HSTS obliga al navegador a usarlo siempre. |
| **Cabeceras de seguridad** | Content-Security-Policy, X-Frame-Options, Referrer-Policy, Permissions-Policy, X-Content-Type-Options. |
| **CORS cerrado** | Ningún otro sitio puede llamar a la API desde el navegador. |
| **Errores sin detalles** | Nunca se muestran trazas internas. |
| **Contenedor sin privilegios** | La aplicación corre con un usuario sin permisos de administrador. |

---

## 2. Crear el proyecto en Railway

1. Entra a <https://railway.com> e inicia sesión **con tu cuenta de GitHub**.
2. **New Project → Deploy from GitHub repo** y elige tu repositorio
   (`Proyecto-Final`). Railway detecta el `Dockerfile` y `railway.json`.
   El primer despliegue **va a fallar**: todavía no tiene base ni claves. Es normal.
3. En el mismo proyecto: **New → Database → MySQL**. Railway crea el servicio
   `MySQL` con sus variables (`MYSQLHOST`, `MYSQLPASSWORD`, ...).

## 3. Generar las claves

**Clave JWT** (firma las sesiones). En tu PC, una de estas dos:

```bash
# Git Bash
openssl rand -base64 48
```

```powershell
# PowerShell
$b = New-Object byte[] 48; [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($b); [Convert]::ToBase64String($b)
```

Copia el resultado (un texto de 64 caracteres). **No lo guardes en el proyecto.**

**Contraseña del administrador:** mínimo 12 caracteres, con mayúsculas,
minúsculas y números. Ejemplo de formato: `BuildZone-Admin-2026x` (inventa la tuya).

## 4. Variables de entorno

En Railway, abre el servicio de **la aplicación** (no el de MySQL) →
pestaña **Variables** → **Raw Editor**, y pega (cambiando los valores):

```
JWT_SECRET=pega-aqui-la-clave-generada
ADMIN_EMAIL=tu-correo@ejemplo.com
ADMIN_PASSWORD=TuContrasenaSegura2026
MYSQLHOST=${{MySQL.MYSQLHOST}}
MYSQLPORT=${{MySQL.MYSQLPORT}}
MYSQLDATABASE=${{MySQL.MYSQLDATABASE}}
MYSQLUSER=${{MySQL.MYSQLUSER}}
MYSQLPASSWORD=${{MySQL.MYSQLPASSWORD}}
```

Las líneas `${{MySQL....}}` son **referencias**: Railway pone los datos del
servicio MySQL automáticamente (si tu servicio de base tiene otro nombre,
cambia `MySQL` por ese nombre). Guarda: Railway vuelve a desplegar solo.

`.env.example` (en el repositorio) tiene la misma lista explicada.

## 5. Dirección pública

Servicio de la aplicación → **Settings → Networking → Generate Domain**.
Railway muestra la dirección (`https://...up.railway.app`).

## 6. Verificar

1. **Deployments → View logs**: debe aparecer
   `Configuracion de produccion revisada: claves propias definidas.` y luego
   `Started BuildzoneApiApplication`.
   El primer arranque tarda más: crea las tablas y carga los 84 productos.
2. Abre la dirección pública: deben verse los productos, el comparador y el blog.
3. Inicia sesión con `ADMIN_EMAIL` / `ADMIN_PASSWORD`.
4. Comprueba que **no** entra `laura.gomez@buildzone.com` / `Prueba1234`
   (las cuentas de prueba no existen en producción).
5. Opcional: en <https://securityheaders.com> escribe tu dirección; debe
   mostrar las cabeceras de seguridad.

---

## 7. Problemas comunes

| Mensaje en los logs | Solución |
|---|---|
| `BuildZone NO arranca en modo produccion... Corrige: ...` | Lee la lista: dice exactamente qué variable falta o es débil. Corrígela en **Variables**. |
| `Communications link failure` | La aplicación no llega a MySQL. Revisa las 5 variables `MYSQL...` y que el servicio MySQL esté encendido. Si sigue, usa la conexión pública: `DB_URL=jdbc:mysql://HOST:PUERTO/railway?sslMode=REQUIRED` con los datos de `MYSQL_PUBLIC_URL` (pestaña Variables del servicio MySQL), más `DB_USER` y `DB_PASSWORD`. |
| `Access denied for user` | La contraseña de la base no coincide: usa las referencias `${{MySQL.MYSQLPASSWORD}}`, no la copies a mano. |
| La página no carga y el despliegue dice *healthcheck failed* | El primer arranque puede tardar; si se repite, revisa los logs completos. |
| `OutOfMemoryError` | El plan tiene muy poca memoria. El Dockerfile ya ajusta Java a 512 MB - 1 GB; revisa el límite del plan. |
| Olvidaste la contraseña del admin | `ADMIN_PASSWORD` solo se usa la **primera** vez que se crea el admin. Para cambiarla, entra y usa Mi cuenta → Seguridad. |

---

## 8. Costos y reglas importantes

- **Costo:** Railway da una prueba gratuita de 30 días con un crédito único;
  después hay un plan gratuito muy limitado (los servicios se duermen) y uno
  pago de bajo costo. Revisa los precios actuales en <https://railway.com/pricing>.
- **Para la sustentación ten siempre la versión local de respaldo**
  (`iniciar.bat mysql`), por si el servicio está dormido o sin crédito.
- **Nunca** subas a GitHub un archivo con claves reales (`.env` ya está en
  `.gitignore`). Si una clave se publica por error, genera otra y cámbiala
  en Variables.
- Si cambias `JWT_SECRET`, todas las sesiones abiertas se cierran (es normal).

## 9. Probar el modo producción en tu PC (opcional)

Con XAMPP encendido y una base vacía `buildzone_prod`, en PowerShell:

```powershell
$env:SPRING_PROFILES_ACTIVE="prod"
$env:DB_URL="jdbc:mysql://localhost:3306/buildzone_prod?createDatabaseIfNotExist=true"
$env:DB_USER="root"; $env:DB_PASSWORD="tu-clave-de-mysql"
$env:JWT_SECRET="(clave generada en el paso 3)"
$env:ADMIN_PASSWORD="TuContrasenaSegura2026"
mvn spring-boot:run
```

(La contraseña de la base no puede estar vacía en modo producción.)
