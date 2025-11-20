// src/index.js
import express from 'express';
import cors from 'cors';
import { pool } from './db.js'; // Importamos nuestro pool de conexión
import preguntasRoutes from './routes/preguntas.routes.js'; // Importamos las rutas de preguntas
import authRoutes from './routes/auth.routes.js'; // Importamos las rutas de autenticación
import respuestasRoutes from './routes/respuestas.routes.js'; // Importamos las rutas de respuestas
import consumoRoutes from './routes/consumo.routes.js'; // Importamos las rutas de consumo
import usuariosRoutes from './routes/usuarios.routes.js'; // Rutas de administración de usuarios

// --- Configuración Inicial ---
const app = express();
const PORT = process.env.PORT || process.env.API_PORT || 5000;

// --- Middlewares Esenciales ---
// 1. Permite peticiones de otros dominios (tu front-end)
app.use(cors()); 
// 2. Permite al servidor entender JSON enviado desde el front-end
app.use(express.json()); 

// --- Rutas (Endpoints) ---

// Ruta de bienvenida (para probar que el servidor funciona)
app.get('/', (req, res) => {
    res.send('¡API de Consumo Hídrico en funcionamiento! 🚀');
});

// Ruta de "Health Check" (para probar que la API Y la BD funcionan)
app.get('/ping', async (req, res) => {
    try {
        // Saca una conexión del pool y ejecuta una consulta simple
        const result = await pool.query('SELECT 1 + 1 AS solucion');
        res.json({
            message: "Conexión a la BD exitosa ✅",
            resultado: result.rows[0].solucion
        });
    } catch (error) {
        res.status(500).json({
            message: "Error al conectar con la BD ❌",
            error: error.message
        });
    }
});

// Usamos las rutas de preguntas
app.use('/api', preguntasRoutes);
app.use('/api', authRoutes);
app.use('/api', respuestasRoutes);
app.use('/api', consumoRoutes);
app.use('/api', usuariosRoutes);

// --- Iniciar el Servidor ---
app.listen(PORT, '0.0.0.0', () => {
    console.log(`📡 Servidor escuchando en el puerto ${PORT}`);
});