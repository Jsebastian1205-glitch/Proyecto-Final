# BuildZone: comparador de componentes de PC

Proyecto formativo SENA (Análisis y Desarrollo de Software). Es una aplicación web para
consultar y comparar componentes de PC (procesadores, tarjetas gráficas, memorias RAM...),
con cuentas de usuario, planes de suscripción y panel de administración.

## Estructura del repositorio

Todo el proyecto es **una sola aplicación Spring Boot**: el mismo servidor entrega la
página web y la API REST, en `http://localhost:8080`.

```
Proyecto Sena 1/
├── pom.xml                      Proyecto Maven (abrir esta carpeta en NetBeans/IntelliJ)
├── iniciar.bat                  Arranca todo con un clic (perfil dev, sin XAMPP)
├── src/main/java/com/buildzone/api/   Back-end: API REST (seguridad, catálogo, usuarios, planes)
├── src/main/resources/
│   ├── application.properties         Configuración (puerto, MySQL, JWT, admin inicial)
│   ├── application-dev.properties     Perfil dev: H2 en memoria
│   ├── application-default.properties Perfil MySQL: carga automática de tablas y datos
│   ├── datos-dev.sql                  Los 84 productos para el perfil dev
│   └── static/                        Front-end (lo sirve Spring Boot tal cual)
│       ├── index.html
│       ├── css/Style.css
│       └── js/  ui.js · api.js · auth.js · planes.js · cuenta.js · admin.js · catalogo.js · script.js
├── database/mysql/              Scripts SQL (00 y 01 tablas, 02 datos); la API los ejecuta al arrancar
├── docs/API.md                  Detalle de la API: paquetes, seguridad, endpoints
└── backend-java/                Módulo de consola JDBC (etapa anterior, independiente)
```

| Archivo del front-end | Para qué |
|---|---|
| `js/ui.js` | Utilidades de interfaz: toasts, formato de moneda, `escaparHtml` (anti-XSS) |
| `js/api.js` | Capa de acceso al backend: fetch + JWT + manejo de errores HTTP |
| `js/auth.js` | Login, registro, cierre de sesión y menú de usuario |
| `js/planes.js` | Página pública de planes y suscripción |
| `js/cuenta.js` | Mi cuenta: perfil, contraseña, suscripción e historial |
| `js/admin.js` | Panel admin: usuarios, planes y suscripciones |
| `js/catalogo.js` | Catálogo desde la API + pestaña Catálogo del panel admin |
| `js/script.js` | Navegación entre páginas, productos, comparador, blog, contacto |

## Arquitectura

```
 Navegador ── http://localhost:8080
        │  GET /  ·  /css/**  ·  /js/**      → front-end (src/main/resources/static)
        │  /api/**  HTTP/JSON  ·  Authorization: Bearer <JWT>
        ▼
 BuildZone (Spring Boot, puerto 8080, mismo origen: sin CORS)
   ├─ Seguridad ........ Spring Security + filtro JWT (transversal)
   ├─ Presentación ..... controller/   (REST, validación de DTOs)
   ├─ Negocio .......... service/impl/ (reglas, transacciones)
   └─ Datos ............ repository/   (Spring Data JPA / Hibernate)
        │  JDBC
        ▼
 MySQL/MariaDB "buildzone" (XAMPP)   ·   H2 en memoria (dev)
        ▲
 backend-java (consola JDBC) ── usa las mismas tablas producto, marca, categoria
```

El detalle de paquetes, patrones de diseño, seguridad y endpoints está en
[`docs/API.md`](docs/API.md).

### Librerías y frameworks por capa

| Capa | Front-end | Back-end |
|---|---|---|
| Presentación | HTML5, CSS3, JavaScript (ES2020), Fetch API | Spring Web, Jackson |
| Seguridad | JWT guardado en `localStorage`, escape de HTML | Spring Security 6, JJWT, BCrypt |
| Negocio | Módulos JS por página | Spring (servicios, `@Transactional`), Bean Validation |
| Datos | — | Spring Data JPA, Hibernate, MySQL Connector/J, H2 |

## Mapa de navegación

```
Inicio ─┬─ Productos (filtro por categoría + buscador)
        ├─ Comparador (duelo entre 2 productos de la misma categoría)
        ├─ Blog (modal de artículo)
        ├─ Planes ── Suscribirme (requiere sesión)
        ├─ Contacto
        ├─ [👤] Iniciar sesión ⇄ Registrarse
        └─ (con sesión) Menú de usuario
              ├─ Mi cuenta: Perfil · Seguridad (contraseña) · Suscripción (actual + historial)
              ├─ Panel admin (solo ADMIN): Usuarios · Planes · Suscripciones · Catálogo
              └─ Cerrar sesión
```

## Ambientes

| | Desarrollo rápido | Desarrollo con XAMPP |
|---|---|---|
| Perfil Spring | `dev` | *(por defecto)* |
| Base de datos | H2 en memoria | MySQL/MariaDB `buildzone` |
| Esquema y datos | Hibernate + `datos-dev.sql` (84 productos) | Scripts de `database/mysql`, ejecutados solos al arrancar |
| Datos iniciales | Admin + planes + catálogo de ejemplo | Admin + planes (el catálogo es el real) |
| Comando | `iniciar.bat` o `mvn spring-boot:run -Dspring-boot.run.profiles=dev` | `iniciar.bat mysql` o `mvn spring-boot:run` |

### Requisitos del equipo de desarrollo

| Herramienta | Versión | Para qué |
|---|---|---|
| JDK | 21 o más nuevo | Compilar y ejecutar la aplicación y `backend-java` |
| Maven | 3.9+ (o el que trae NetBeans/IntelliJ) | Dependencias y build |
| XAMPP (MariaDB 10.4+) o MySQL 8 | — | Base de datos `buildzone` (opcional si se usa el perfil `dev`) |
| Navegador moderno | Chrome, Edge o Firefox | Front-end |
| Git | 2.x | Control de versiones |

### Servidores y puertos

| Servicio | Puerto | Configuración |
|---|---|---|
| BuildZone: página + API (Tomcat embebido) | 8080 | `server.port` en `application.properties` |
| MySQL/MariaDB (XAMPP) | 3306 | `spring.datasource.url` |

## Cómo ejecutar todo

Un solo comando levanta la página y la API juntas:

```bash
# Windows: doble clic en iniciar.bat   (o desde una terminal en esta carpeta)
iniciar.bat              # perfil dev: H2 en memoria, no necesita XAMPP
iniciar.bat mysql        # con XAMPP encendido: crea las tablas y carga los datos sola

# Equivalente con Maven, en cualquier sistema:
mvn spring-boot:run -Dspring-boot.run.profiles=dev
mvn spring-boot:run
```

Cuando la consola muestre `Started BuildzoneApiApplication`, abra **http://localhost:8080**.
Ingrese con `admin@buildzone.com` / `Admin1234` para ver el panel de administración,
o cree una cuenta nueva desde "Regístrate".

En NetBeans o IntelliJ: abra la carpeta `Proyecto Sena 1` (se reconoce el `pom.xml`) y
ejecute `BuildzoneApiApplication` (para el perfil dev agregue `-Dspring.profiles.active=dev`).

Para entregar o desplegar, `mvn package` genera un único archivo
`target/buildzone-api-1.0.0.jar` que contiene el front-end y la API:
`java -jar target/buildzone-api-1.0.0.jar --spring.profiles.active=dev`.

`js/api.js` llama a la API con la ruta relativa `/api`, así que funciona en cualquier
puerto o servidor. Si se abre `index.html` con doble clic o con Live Server, usa como
respaldo `http://localhost:8080/api`. Si el backend está apagado, Productos y Comparador
siguen funcionando con los datos locales de `js/script.js`, y las funciones de cuenta
muestran un aviso de conexión.

## Control de versiones

Repositorio Git único con commits pequeños por módulo, con prefijo según el tipo de cambio:
`feat:` funcionalidad, `fix:` corrección, `docs:` documentación,
`refactor:` reorganización sin cambio de comportamiento. Ver `git log --oneline`.
