## Calculadora Hídrica – Backend y SQL

API REST en Node.js + Express + MySQL para gestionar usuarios, preguntas/opciones del cuestionario de consumo hídrico, guardar respuestas y calcular consumo diario. Incluye roles (admin/usuario), recuperación de contraseña por email y endpoints de administración.

### Tecnologías
- Node.js (ESM)
- Express
- MySQL (mysql2/promise)
- JWT (jsonwebtoken) y bcryptjs
- dotenv, cors, nodemailer

### Estructura del repo
```
Calculadora-Hidrica/
  backend-hidrico/
    src/
      index.js             # arranque del servidor y registro de rutas
      db.js                # pool MySQL
      routes/
        auth.routes.js     # registro/login, recuperación de contraseña
        preguntas.routes.js# listado de preguntas + opciones (+valor_consumo)
        respuestas.routes.js# guardar respuestas y estadísticas (admin)
        consumo.routes.js  # cálculo e historial de consumo
        usuarios.routes.js # CRUD de usuarios (admin)
      middleware/
        authMiddleware.js  # proteger rutas y requerir roles
  script.sql               # esquema de base de datos completo
  preguntas.sql            # carga de 20 preguntas con opciones y valores
  asignarAdmin.sql         # utilitario: ascender/descender admin por email
```

### Requisitos
- Node 18+
- MySQL 8.x (local o remoto)

### Instalación y arranque
```bash
git clone <este-repo>
cd Calculadora-Hidrica/backend-hidrico
npm install
npm run dev   # nodemon
# ó
npm start     # node
```
Servidor por defecto en `http://localhost:5000` (configurable con `API_PORT`).

### Variables de entorno
Crear `backend-hidrico/.env`:
```bash
API_PORT=5000
JWT_SECRET=un_secreto_seguro_bien_largo

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_PORT=3306
DB_NAME=db_consumo_hidrico

# URL del frontend para enlaces de recuperación
FRONTEND_URL=http://localhost:5173

# SMTP (correo) para recuperación de contraseña
SMTP_HOST=smtp.tu-proveedor.com
SMTP_PORT=587
SMTP_USER=usuario_smtp
SMTP_PASS=clave_smtp
SMTP_FROM="Soporte Hidrico" <no-reply@tuapp.com>
```

### Base de datos
1) Crear esquema ejecutando en MySQL:
```sql
SOURCE /ruta/completa/a/Calculadora-Hidrica/script.sql;
```
2) Cargar preguntas y opciones con impactos:
```sql
SOURCE /ruta/completa/a/Calculadora-Hidrica/preguntas.sql;
```
3) (Opcional) Asignar un admin por correo:
```sql
SOURCE /ruta/completa/a/Calculadora-Hidrica/asignarAdmin.sql;
```

### Autenticación y roles
- Registro exige: `nombre`, `email`, `password`, `sexo`, `nivel_educativo` (ambos ENUM normalizados), crea `rol='usuario'` por defecto.
- Login devuelve `{ token, usuario }` e incluye `rol` en el payload JWT.
- Rutas protegidas: usar header `Authorization: Bearer <token>`.
- Rutas admin requieren `requerirRol('admin')`.

### Endpoints principales
- Salud
  - GET `/` → texto de bienvenida
  - GET `/ping` → health check de API y BD

- Autenticación
  - POST `/api/auth/registro`
  - POST `/api/auth/login`
  - POST `/api/auth/forgot-password` → genera token y envía email
  - POST `/api/auth/reset-password` → cambia contraseña usando `token`

- Preguntas
  - GET `/api/preguntas` → listado con opciones incluyendo `valor_consumo`

- Respuestas (requiere JWT)
  - POST `/api/respuestas` → guarda IDs de opciones seleccionadas
  - GET `/api/respuestas/estadisticas` (admin) → agregados por pregunta/opción

- Consumo
  - POST `/api/calcular-consumo` → calcula y guarda consumo del día
  - GET `/api/historial/:id_usuario` → historial de consumo

- Usuarios (admin)
  - GET `/api/usuarios` → lista con filtros `q`, `rol`, `page`, `pageSize`
  - GET `/api/usuarios/:id`
  - POST `/api/usuarios` → crea usuario (hash de contraseña)
  - PATCH `/api/usuarios/:id` → actualización parcial (incluye cambio de password)
  - DELETE `/api/usuarios/:id`

### Uso con Postman/Thunder
1) Hacer login y guardar `token` de respuesta.
2) En rutas protegidas añadir `Authorization: Bearer {{token}}`.
3) Para probar recuperación: llamar `/api/auth/forgot-password` y luego `/api/auth/reset-password` con `{ token, password }`.

### Problemas comunes
- Falta `nodemailer` → instala en `backend-hidrico`: `npm install` (y, si hace falta, `npm install nodemailer`).
- `secretOrPrivateKey must have a value` → falta `JWT_SECRET` en `.env`.
- Error de collation en SQL (comparación por email) → alinea la sesión con `SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;` o usa `... WHERE email = 'correo' COLLATE utf8mb4_unicode_ci`.
- Restricción de FK al guardar respuestas → asegúrate de cargar `preguntas.sql` primero.

### Scripts de npm
```json
{
  "start": "node src/index.js",
  "dev": "nodemon src/index.js"
}
```

### Licencia
ISC (ver `package.json`).
