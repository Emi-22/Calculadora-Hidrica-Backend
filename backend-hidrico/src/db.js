// src/db.js
import pkg from 'pg';
const { Pool } = pkg;
import 'dotenv/config'; // Carga las variables de .env en process.env

export const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'db_consumo_hidrico',
    // Configuración para Render.com (usa SSL si está disponible)
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

console.log('📦 Pool de conexiones a PostgreSQL creado.');