# BuildZone — API REST

API REST de **BuildZone**, construida con Spring Boot. Es el backend que consume el
front-end (`src/main/resources/static/index.html` + `js/api.js`), que se sirve desde esta misma
aplicación, y reúne tres módulos:

| Módulo | Qué hace | Endpoints |
|---|---|---|
| **Catálogo** | CRUD de Producto, Marca y Categoría sobre las tablas que ya existen en la base `buildzone` (las mismas que usa `backend-java`) | `/api/productos`, `/api/marcas`, `/api/categorias` |
| **Seguridad y usuarios** | Registro, inicio de sesión con JWT, perfil propio, cambio de contraseña y administración de usuarios por rol | `/api/auth`, `/api/usuarios` |
| **Planes y suscripciones** | Planes de pago y suscripción de cada usuario (alta, cancelación, vencimiento, historial) | `/api/planes`, `/api/suscripciones` |

`backend-java` (consola JDBC) sigue existiendo y no se modificó: las dos aplicaciones
trabajan sobre la misma base de datos.

## Tecnologías por capa

| Capa | Tecnología / librería |
|---|---|
| Lenguaje y build | Java 21, Maven, Spring Boot 3.3.4 |
| Presentación (API REST) | Spring Web (`@RestController`), Jackson (JSON), Bean Validation |
| Seguridad (transversal) | Spring Security 6, JJWT 0.12.6 (tokens JWT HS256), BCrypt |
| Lógica de negocio | Servicios Spring (`@Service`) con transacciones (`@Transactional`) |
| Acceso a datos | Spring Data JPA, Hibernate 6 |
| Base de datos | MySQL/MariaDB (XAMPP) en el perfil por defecto; H2 en memoria en `dev` |
| Control de versiones | Git |

## Arquitectura y paquetes

La API sigue una arquitectura **en capas**. Cada petición recorre
`controller → service → repository → base de datos`, y ninguna capa se salta a la siguiente.

```
src/main/java/com/buildzone/api/
├── BuildzoneApiApplication.java  Punto de entrada
├── controller/     Capa de presentación: recibe HTTP, valida DTOs y delega
│   ├── AuthController, UsuarioController
│   ├── PlanController, SuscripcionController
│   └── ProductoController, MarcaController, CategoriaController
├── service/        Capa de negocio: interfaces (contratos de casos de uso)
│   └── impl/       Implementaciones con las reglas de negocio
├── repository/     Capa de datos: interfaces Spring Data JPA
├── model/          Entidades JPA (Usuario, PlanSuscripcion, Suscripcion, Producto, Marca, Categoria)
│   └── enums/      Rol, EstadoUsuario, EstadoSuscripcion
├── dto/            Objetos de entrada/salida (la entidad nunca sale al cliente)
├── security/       JwtService, JwtAuthenticationFilter, UsuarioAutenticado, RespuestaErrorSeguridad
├── config/         SecurityConfig, AppConfig (Clock), DatosInicialesConfig, CatalogoDemoConfig
└── exception/      GlobalExceptionHandler, ErrorResponse y excepciones de negocio
```

### Patrones de diseño aplicados

| Patrón | Dónde |
|---|---|
| **MVC / arquitectura en capas** | `controller` → `service` → `repository` |
| **Repository** | Interfaces `*Repository` de Spring Data: la persistencia queda aislada del negocio |
| **DTO** | `*Request` / `*Response`: validan la entrada y ocultan datos sensibles (el hash de la contraseña nunca sale) |
| **Inyección de dependencias** | Todas las dependencias entran por constructor y se programa contra interfaces (`AuthService`, no `AuthServiceImpl`) |
| **Chain of Responsibility** | `JwtAuthenticationFilter` dentro de la cadena de filtros de Spring Security |
| **Static Factory Method** | `UsuarioResponse.desde(...)`, `PlanResponse.desde(...)`, `ErrorResponse.de(...)` |
| **Controller Advice** (manejo centralizado de errores) | `GlobalExceptionHandler` convierte cada excepción en un `ErrorResponse` uniforme |
| **Strategy (reloj inyectable)** | `Clock` se inyecta en `SuscripcionServiceImpl` (zona horaria de Colombia) |

## Mecanismos de seguridad

- **Autenticación sin estado con JWT**: `POST /api/auth/login` devuelve un token firmado
  con HMAC-SHA256 que vence en 8 horas. El cliente lo envía en `Authorization: Bearer <token>`.
- **Contraseñas con BCrypt**: nunca se guardan ni se devuelven en texto plano.
- **Autorización por rol** (`USUARIO` / `ADMIN`) en `SecurityConfig`, por ruta y verbo HTTP.
- **Revalidación en cada petición**: el filtro vuelve a leer el usuario en la base, así que
  desactivar una cuenta o quitarle el rol ADMIN tiene efecto inmediato aunque su token siga vigente.
- **Reglas de negocio de seguridad**: un ADMIN no puede quitarse su propio rol ni desactivarse;
  un usuario solo puede cancelar sus propias suscripciones; el perfil `/me` siempre usa el id del
  token, nunca uno enviado por el cliente.
- **Mensajes de login que no filtran información**: el mismo error para "usuario no existe" y
  "contraseña incorrecta".
- **Validación de entrada** con Bean Validation en todos los DTO.
- **Errores sin trazas internas**: `GlobalExceptionHandler` y `server.error.include-stacktrace=never`.
- **CORS** configurable (`buildzone.cors.origenes-permitidos`) y CSRF deshabilitado (no hay cookies de sesión).
- **Secretos por variables de entorno**: `JWT_SECRET`, `DB_USER`, `DB_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`.
- En el front-end, todo dato del usuario se escapa con `escaparHtml` antes de insertarlo en el HTML (anti-XSS).

### Matriz de permisos

| Ruta | Público | USUARIO | ADMIN |
|---|:-:|:-:|:-:|
| `POST /api/auth/registro`, `POST /api/auth/login` | ✅ | ✅ | ✅ |
| `GET /api/productos`, `/api/marcas`, `/api/categorias` (y `/{id}`) | ✅ | ✅ | ✅ |
| `POST/PUT/DELETE` de productos, marcas y categorías | ❌ 401 | ❌ 403 | ✅ |
| `GET /api/noticias` (y `/{id}`) | ✅ | ✅ | ✅ |
| `GET /api/noticias/mias` | ❌ 401 | ✅ | ✅ |
| `POST /api/noticias` | ❌ 401 | ✅ (con plan de pago activo, mensual o anual; Gratuito o sin plan 403) | ✅ |
| `PUT/DELETE /api/noticias/{id}` | ❌ 401 | ✅ (solo las propias) | ✅ |
| `GET /api/comparaciones/mias`, `POST /api/comparaciones`, `DELETE /api/comparaciones/{id}` | ❌ 401 | ✅ (con plan de pago activo, mensual o anual; Gratuito o sin plan 403; borrar solo las propias) | ✅ |
| `POST /api/contacto` | ✅ | ✅ | ✅ |
| `GET /api/contacto`, `PATCH /api/contacto/{id}/estado`, `DELETE /api/contacto/{id}` | ❌ 401 | ❌ 403 | ✅ |
| `GET /api/planes` | ✅ | ✅ | ✅ |
| `GET /api/planes/todos`, `POST/PUT/DELETE /api/planes` | ❌ 401 | ❌ 403 | ✅ |
| `GET/PUT /api/usuarios/me`, `PUT /api/usuarios/me/password` | ❌ 401 | ✅ | ✅ |
| `GET /api/usuarios`, `PATCH /api/usuarios/{id}/rol`, `PATCH /api/usuarios/{id}/estado`, `POST /api/usuarios/{id}/restablecer-password` | ❌ 401 | ❌ 403 | ✅ |
| `POST /api/auth/recuperar` | ✅ | ✅ | ✅ |
| `POST /api/suscripciones`, `GET /api/suscripciones/me`, `GET /api/suscripciones/me/activa` | ❌ 401 | ✅ | ✅ |
| `DELETE /api/suscripciones/{id}` | ❌ 401 | ✅ (solo las propias) | ✅ |
| `GET /api/suscripciones` | ❌ 401 | ❌ 403 | ✅ |

## Endpoints

Base URL local: `http://localhost:8080`

### Autenticación — `/api/auth`

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| POST | `/api/auth/registro` | `{"nombre","apellido","username","email","password"}` | 201 `{token, tipo:"Bearer", usuario}` · 400 · 409 |
| POST | `/api/auth/login` | `{"identificador": "correo o username", "password"}` | 200 `{token, tipo, usuario}` · 401 · 403 (cuenta inactiva) |
| POST | `/api/auth/recuperar` | `{"email"}` | 202 `{mensaje}`: siempre el mismo, exista o no la cuenta |

#### Recuperar contraseña

No hay servidor de correo (SMTP), así que la recuperación la atiende el ADMIN:

1. `POST /api/auth/recuperar`: si el correo es de una cuenta, deja un mensaje en `/api/contacto` con
   `motivo: PROBLEMA_CUENTA` y `recuperacion: true`. Si no existe o supera el antispam (3 cada 10 min),
   no guarda nada. La respuesta es idéntica en todos los casos, para no revelar qué correos existen.
2. `POST /api/usuarios/{id}/restablecer-password` (ADMIN): genera una contraseña temporal
   (formato `Bz-XXXX-XXXX`, sin 0/O/1/I/L) y la devuelve una sola vez en `passwordTemporal`; en la base solo
   queda su hash. La anterior deja de funcionar y la cuenta queda con `debeCambiarPassword: true`.
   La temporal no vence: sirve hasta que el usuario la use para crear su contraseña. El ADMIN no puede
   restablecer la suya desde aquí.
3. Al entrar con la temporal, `usuario.debeCambiarPassword` llega en `true`. Hasta crear la nueva solo puede
   usar `GET /api/usuarios/me`, `PUT /api/usuarios/me/password`, `POST /api/contacto` y las lecturas públicas;
   el resto responde 403 con `"codigo": "CAMBIO_PASSWORD_PENDIENTE"`.
4. `PUT /api/usuarios/me/password` con `{"passwordNueva"}` (sin la actual) y distinta de la temporal.

### Usuarios — `/api/usuarios`

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| GET | `/api/usuarios/me` | — | 200 usuario |
| PUT | `/api/usuarios/me` | `{"nombre","apellido","email"}` | 200 usuario · 409 correo en uso |
| PUT | `/api/usuarios/me/password` | `{"passwordActual","passwordNueva"}` (sin `passwordActual` si entró con una temporal) | 204 · 400 |
| GET | `/api/usuarios` | — | 200 lista (ADMIN) |
| PATCH | `/api/usuarios/{id}/rol` | `{"rol":"ADMIN"}` | 200 (ADMIN) |
| PATCH | `/api/usuarios/{id}/estado` | `{"estado":"INACTIVO"}` | 200 (ADMIN) |
| POST | `/api/usuarios/{id}/restablecer-password` | — | 200 `{idUsuario, username, email, passwordTemporal}` (ADMIN) |

Usuario de respuesta:
```json
{ "id": 1, "nombre": "Ana", "apellido": "Gómez", "username": "ana.gomez",
  "email": "ana@buildzone.com", "rol": "USUARIO", "estado": "ACTIVO",
  "fechaRegistro": "2026-09-23T10:15:00", "debeCambiarPassword": false }
```

### Planes — `/api/planes`

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| GET | `/api/planes` | — | 200 planes activos, del más barato al más caro |
| GET | `/api/planes/todos` | — | 200 todos (ADMIN) |
| POST | `/api/planes` | `{"nombre","descripcion","precio","duracionDias"}` | 201 (ADMIN) · 409 |
| PUT | `/api/planes/{id}` | igual que POST | 200 (ADMIN) |
| DELETE | `/api/planes/{id}` | — | 204: borrado lógico, `activo=false` (ADMIN) |

### Suscripciones — `/api/suscripciones`

| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| POST | `/api/suscripciones` | `{"planId": 2}` | 201. Si ya había una suscripción activa a otro plan, esa pasa a `CANCELADA` |
| GET | `/api/suscripciones/me/activa` | — | 200 la vigente · 204 si no hay |
| GET | `/api/suscripciones/me` | — | 200 historial propio |
| DELETE | `/api/suscripciones/{id}` | — | 204 · 403 si es de otro usuario · 400 si no está activa |
| GET | `/api/suscripciones` | — | 200 todas (ADMIN) |

Suscripción de respuesta:
```json
{ "id": 5, "usuarioId": 1,
  "plan": { "id": 2, "nombre": "Premium", "descripcion": "...", "precio": 29900.00, "duracionDias": 30, "activo": true },
  "fechaInicio": "2026-09-23", "fechaFin": "2026-10-23", "estado": "ACTIVA" }
```

### Catálogo — `/api/productos`, `/api/marcas`, `/api/categorias`

Cada recurso tiene los 5 endpoints CRUD (`GET` lista, `GET /{id}`, `POST`, `PUT /{id}`, `DELETE /{id}`).

- Marca / Categoría: body `{"nombre","descripcion"}`, nombre único (409 si se repite). Si se
  intenta borrar una marca o categoría que todavía tiene productos, la respuesta es 409.
- Producto: body `{"nombre","descripcion","imagen","idMarca","idCategoria"}` y, opcionales,
  `precioReferencia` (COP), `puntajes` (`{"potencia","eficiencia","valor","popularidad"}`, 0 a 100)
  y `especificaciones` (`[{"atributo","valor","unidad"}]`). Lo que no se envía no se modifica; los
  precios reales de las tiendas no se tocan desde aquí.
- La respuesta de producto incluye `nombreMarca`, `nombreCategoria` y lo que sale de las tablas
  `especificacion`, `precio` y `fuente_precio`:
  - `precio`: el menor precio entre las tiendas (o `null`).
  - `precios`: `[{"tienda","valor","fechaConsulta","url","referencia"}]`, de menor a mayor
    (`referencia: true` es el precio estimado de BuildZone, no una tienda).
  - `puntajes`: los 4 puntajes del comparador.
  - `especificaciones`: la ficha técnica.

### Blog — `/api/noticias`

CRUD de la tabla `noticia` (`GET` lista, `GET /{id}`, `POST`, `PUT /{id}`, `DELETE /{id}`).
Body: `{"titulo","categoria","resumen","contenido"}` (resumen opcional: si va vacío se toma
el inicio del contenido). La lista viene de la más reciente a la más antigua y cada noticia
incluye `fechaPublicacion` y `autor` (quien la publicó).
Pueden publicar el ADMIN y los usuarios con una suscripción activa a un plan de pago (mensual o anual); cada usuario edita
y elimina solo sus publicaciones (`GET /api/noticias/mias` las lista) y el ADMIN, todas.

### Mis comparaciones — `/api/comparaciones`

Duelos del Comparador guardados por el usuario (tablas `comparacion` y `detalle_comparacion`
del modelo original). Exclusivo de los planes de pago (mensual o anual) y del ADMIN.

- `GET /api/comparaciones/mias`: las comparaciones propias, la más reciente primero. Cada una trae
  `idComparacion`, `titulo`, `fechaCreacion` y `productos` (`idProducto`, `nombre`, `marca`, `categoria`).
  El ganador no se guarda: el front-end lo calcula con los puntajes actuales.
- `POST /api/comparaciones`: `{"idProductoA","idProductoB"}`. Los dos deben existir, ser distintos y de
  la misma categoría. Si ese duelo ya estaba guardado (en cualquier orden) solo se actualiza la fecha.
- `DELETE /api/comparaciones/{id}`: solo las propias.

Al eliminar un producto (`DELETE /api/productos/{id}`) se borran también las comparaciones que lo incluían.

### Contacto — `/api/contacto`

Formulario de la página Contacto, tabla `mensaje_contacto`.

- `POST /api/contacto` (público, con o sin sesión). Body:
  `{"nombre","correo","motivo","mensaje"}`, con `motivo` = `DUDA_PRODUCTO`, `SUGERENCIA`,
  `PROBLEMA_CUENTA`, `PLANES` u `OTRO`. Valida correo y mensaje de 10 a 1000 caracteres.
  Antispam: como máximo 3 mensajes por correo cada 10 minutos (el cuarto da 400).
  Responde 201 con el mensaje guardado (`idMensaje` es el número que ve el visitante).
  Si hay sesión, se guarda la cuenta (`cuentaRegistrada: true`).
- `GET /api/contacto` (ADMIN): todos los mensajes, el más reciente primero.
- `PATCH /api/contacto/{id}/estado` (ADMIN): `{"estado": "NUEVO" | "LEIDO" | "RESPONDIDO"}`.
- `DELETE /api/contacto/{id}` (ADMIN).

La API no envía correos (no hay servidor SMTP configurado): el administrador responde desde
su propio correo con el botón "Responder por correo" del panel (enlace `mailto:`).

### Límites de intentos (429)

`POST /api/auth/login`: 5 intentos fallidos sobre la misma cuenta en 15 minutos → 429
`Too Many Requests` (aunque luego la contraseña sea correcta). También hay límites por IP para
login, `POST /api/auth/registro`, `POST /api/contacto` y `POST /api/auth/recuperar`
(configurables en `buildzone.limites.*`).

### Formato de error (todas las rutas)

```json
{ "timestamp": "2026-09-23T10:15:00", "status": 400, "error": "Bad Request",
  "mensaje": "Los datos enviados no son validos.", "ruta": "/api/auth/registro",
  "detalles": ["El correo no tiene un formato valido."] }
```

| Código | Cuándo |
|---|---|
| 400 | Validación, JSON mal formado o regla de negocio (contraseña actual incorrecta, plan inactivo...) |
| 401 | Sin token, token vencido o alterado, o credenciales incorrectas |
| 403 | Rol insuficiente, cuenta inactiva o recurso de otro usuario |
| 404 | Id o ruta inexistente |
| 409 | Nombre, correo o username repetido; integridad referencial |
| 500 | Error inesperado (se registra en el log, sin detalles internos para el cliente) |

## Ambientes

| Ambiente | Perfil | Base de datos | Uso |
|---|---|---|---|
| Desarrollo rápido | `dev` | H2 en memoria, tablas creadas por Hibernate, catálogo de ejemplo | Probar todo sin XAMPP |
| Desarrollo con XAMPP / producción | (por defecto) | MySQL/MariaDB `buildzone` en `localhost:3306` | Datos reales |

### Opción A: sin XAMPP (perfil dev)

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

- Página web: `http://localhost:8080`
- API: `http://localhost:8080/api`
- Consola H2: `http://localhost:8080/h2-console` (JDBC URL `jdbc:h2:mem:buildzone`, usuario `sa`, sin contraseña)
- Administrador inicial: `admin@buildzone.com` / `Admin1234`

### Opción B: con MySQL/MariaDB (XAMPP)

1. Inicie Apache y MySQL en XAMPP.
2. No hace falta importar nada a mano: al arrancar, la API ejecuta sola los scripts de
   `database/mysql` (`00_estructura.sql`, `01_usuarios_suscripciones.sql`, `02_datos_completos.sql` y
   `03_cuentas_prueba.sql`). Si la base `buildzone` no existe la crea, agrega las tablas que falten y carga
   los 84 productos con su ficha técnica y precios de tiendas colombianas, el blog, duelos de ejemplo y
   5 cuentas de prueba (contraseña `Prueba1234`). Se repite en cada arranque sin duplicar ni borrar datos.
   En producción (perfil `prod`, ver `docs/DESPLIEGUE.md`) el script `03` **no** se ejecuta.
   Para desactivarlo: `spring.sql.init.mode=never` en `application-default.properties`.
3. (Opcional) Los mismos scripts se pueden importar a mano en phpMyAdmin.
4. Arranque la API:
   ```bash
      mvn spring-boot:run
   ```
   Al primer arranque se crean automáticamente el usuario ADMIN y los planes Gratuito, Premium
   y Premium Anual.

En NetBeans o IntelliJ basta con abrir la carpeta del proyecto (se reconoce el `pom.xml`) y
ejecutar `BuildzoneApiApplication`. Para el perfil dev agregue `-Dspring.profiles.active=dev`
en las opciones de la VM, o `spring.profiles.active=dev` en *Run → Set Project Configuration*.

### Variables de configuración

| Propiedad | Variable de entorno | Valor por defecto |
|---|---|---|
| `server.port` | `SERVER_PORT` | `8080` |
| `spring.datasource.username` | `DB_USER` | `root` |
| `spring.datasource.password` | `DB_PASSWORD` | *(vacío, como XAMPP)* |
| `buildzone.jwt.secret` | `JWT_SECRET` | clave de ejemplo: **cámbiela en producción** (Base64, mínimo 256 bits) |
| `buildzone.jwt.expiracion-ms` | `BUILDZONE_JWT_EXPIRACION_MS` | `28800000` (8 h) |
| `buildzone.admin.email` | `ADMIN_EMAIL` | `admin@buildzone.com` |
| `buildzone.admin.password` | `ADMIN_PASSWORD` | `Admin1234` |
| `buildzone.cors.origenes-permitidos` | `BUILDZONE_CORS_ORIGENES_PERMITIDOS` | `*` |

Para generar una clave JWT propia: `openssl rand -base64 48`.
