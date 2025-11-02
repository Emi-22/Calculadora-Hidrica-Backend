## Backend – Calculadora Hídrica

API REST en Node.js + Express + MySQL para registrar usuarios, gestionar el cuestionario de consumo hídrico, guardar respuestas y calcular el consumo diario.

### Tecnologías
- Node.js (ESM)
- Express
- MySQL (mysql2/promise)
- JWT (jsonwebtoken) y bcryptjs
- dotenv, cors

### Estructura
```
Calculadora-Hidrica/
  backend-hidrico/
    src/
      index.js             # arranque del servidor y rutas
      db.js                # pool MySQL
      routes/
        auth.routes.js     # registro y login
        preguntas.routes.js
        respuestas.routes.js
        consumo.routes.js
      middleware/
        authMiddleware.js  # proteger rutas con JWT
  script.sql               # esquema BD (tablas)
```

### Requisitos
- Node 18+
- MySQL 8.x en local o remoto

### Instalación
```bash
git clone <este-repo>
cd Calculadora-Hidrica/backend-hidrico
npm install
```

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
```

### Base de datos
1) Ejecuta `script.sql` en MySQL para crear el esquema:
```sql
SOURCE /ruta/completa/a/Calculadora-Hidrica/script.sql;
```
2) (Opcional) Semilla mínima para probar:
```sql
USE db_consumo_hidrico;

INSERT INTO preguntas (codigo, texto) VALUES
('p1_ducha', '¿Cuánto dura tu ducha?'),
('p2_grifo', '¿Cierras el grifo al cepillarte?');

SET @p1 := (SELECT id FROM preguntas WHERE codigo='p1_ducha');
SET @p2 := (SELECT id FROM preguntas WHERE codigo='p2_grifo');

INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p1, '<5 min', 30.00),
(@p1, '5-10 min', 70.00),
(@p1, '>10 min', 120.00),
(@p2, 'Sí', 0.00),
(@p2, 'No', 10.00);
```

### Ejecutar
```bash
cd backend-hidrico
npm run dev      # nodemon
# ó
npm start        # node
```
Servidor en `http://localhost:${API_PORT}` (por defecto, 5000).

### Endpoints
- Salud
  - GET `/` → texto de bienvenida
  - GET `/ping` → health check de API y BD

- Autenticación
  - POST `/api/auth/registro`
    ```json
    { "nombre": "Juan", "email": "juan@example.com", "password": "Secreta123" }
    ```
  - POST `/api/auth/login`
    ```json
    { "email": "juan@example.com", "password": "Secreta123" }
    ```
    Respuesta: `{ token, usuario }`

- Preguntas
  - GET `/api/preguntas` → listado con opciones

- Respuestas (PROTEGIDO – requiere JWT)
  - POST `/api/respuestas` (Header: `Authorization: Bearer <token>`)
    ```json
    { "opciones": [3, 5, 8, 12] }
    ```

- Consumo
  - POST `/api/calcular-consumo`
    ```json
    { "id_usuario": 1 }
    ```
  - GET `/api/historial/:id_usuario`

### Uso con Postman
1) Crea un Environment con:
   - `baseUrl` = `http://localhost:5000`
   - `token` = (vacío)
2) En la request de login, pestaña Tests:
```javascript
const data = pm.response.json();
if (data.token) pm.environment.set('token', data.token);
```
3) En rutas protegidas añade Header `Authorization: Bearer {{token}}`.

### Errores comunes y solución
- JSON inválido → usa Body raw JSON con comillas dobles y sin comas finales.
- `secretOrPrivateKey must have a value` → falta `JWT_SECRET` en `.env`.
- 404 `Cannot POST /api/register` → usa `/api/auth/registro` y `/api/auth/login`.
- Restricción de clave foránea al guardar respuestas → los `id` en `opciones` deben existir. Primero consulta `GET /api/preguntas` o revisa con SQL: `SELECT id, id_pregunta, texto_opcion FROM opciones;`.

### Scripts disponibles
```json
{
  "start": "node src/index.js",
  "dev": "nodemon src/index.js"
}
```

### Licencia
ISC (ver `package.json`).
