// src/db.js
import { createPool } from 'mysql2/promise'; // Usamos la versión con promesas
import 'dotenv/config'; // Carga las variables de .env en process.env

console.log('Loading environment variables:', {
    DB_HOST: process.env.DB_HOST,
    DB_USER: process.env.DB_USER,
    DB_NAME: process.env.DB_NAME,
    DB_PORT: process.env.DB_PORT
});

export const pool = createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    port: process.env.DB_PORT || 3306,
    database: process.env.DB_NAME || 'db_consumo_hidrico'
});

console.log('📦 Pool de conexiones a MySQL creado.');