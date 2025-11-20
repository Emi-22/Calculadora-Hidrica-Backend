// src/routes/respuestas.routes.js
import { Router } from 'express';
import { pool } from '../db.js';
import { protegerRuta, requerirRol } from '../middleware/authMiddleware.js'; // Protección y roles

const router = Router();

/**
 * Endpoint: POST /api/respuestas
 * Propósito: Guardar el conjunto de respuestas de un usuario (RF08).
 * Ruta protegida: Solo usuarios autenticados pueden acceder.
 */
router.post('/respuestas', protegerRuta, async (req, res) => {
    // Gracias al middleware 'protegerRuta', aquí tenemos acceso a 'req.usuario'
    const idUsuario = req.usuario.id;

    // Esperamos que el front-end envíe un array de IDs de opciones seleccionadas
    // Ej: { "opciones": [3, 5, 8, 12] }
    const { opciones } = req.body;

    // --- Práctica 1: Validación ---
    if (!opciones || !Array.isArray(opciones) || opciones.length === 0) {
        return res.status(400).json({ message: 'Se requiere un array de "opciones" seleccionadas.' });
    }

    let connection; // Definimos la conexión aquí para usarla en try/catch/finally

    try {
        // --- Práctica 2: Transacción de Base de Datos ---
        // Usamos una transacción para asegurar que todas las operaciones (borrar y luego insertar)
        // se completen exitosamente. Si algo falla, se revierte todo.

        connection = await pool.connect(); // Obtenemos una conexión del pool
        await connection.query('BEGIN'); // Iniciamos la transacción

        // --- Práctica 3: Limpiar respuestas antiguas ---
        // Esto permite al usuario "volver a tomar" el cuestionario.
        // Borramos solo las respuestas de este usuario.
        // (Una lógica más avanzada podría borrar solo respuestas de las preguntas enviadas)
        await connection.query('DELETE FROM respuestas_usuario WHERE id_usuario = $1', [idUsuario]);

        // --- Práctica 4: Insertar Múltiples Filas Eficientemente ---
        // En PostgreSQL usamos un loop o múltiples INSERTs
        for (const idOpcion of opciones) {
            await connection.query(
                'INSERT INTO respuestas_usuario (id_usuario, id_opcion) VALUES ($1, $2)',
                [idUsuario, idOpcion]
            );
        }

        // Si todo salió bien, confirmamos la transacción
        await connection.query('COMMIT');

        res.status(201).json({ message: 'Respuestas guardadas exitosamente.' });

    } catch (error) {
        // Si algo falló, revertimos la transacción
        if (connection) {
            await connection.query('ROLLBACK');
        }
        console.error('Error al guardar respuestas:', error);
        res.status(500).json({
            message: 'Error interno del servidor al guardar las respuestas',
            error: error.message
        });
    } finally {
        // --- Práctica 5: Liberar la conexión ---
        // Pase lo que pase (éxito o error), siempre liberamos la conexión
        // para que el pool pueda reutilizarla.
        if (connection) {
            connection.release();
        }
    }
});

export default router;

/**
 * Endpoint: GET /api/respuestas/estadisticas
 * Propósito: Obtener estadísticas agregadas de respuestas (solo admin).
 */
router.get('/respuestas/estadisticas', protegerRuta, requerirRol('admin', 'administrador'), async (req, res) => {
    try {
        // Obtener estadísticas por pregunta y opción
        const rows = await pool.query(`
            SELECT 
                p.id           AS id_pregunta,
                p.codigo       AS codigo_pregunta,
                p.texto        AS texto_pregunta,
                o.id           AS id_opcion,
                o.texto_opcion AS texto_opcion,
                COUNT(ru.id)   AS total_respuestas
            FROM preguntas p
            JOIN opciones o ON o.id_pregunta = p.id
            LEFT JOIN respuestas_usuario ru ON ru.id_opcion = o.id
            GROUP BY p.id, o.id
            ORDER BY p.id ASC, o.id ASC
        `);

        // Obtener conteo de usuarios únicos que completaron la encuesta
        // Un usuario completó la encuesta si tiene al menos una respuesta
        const usuariosCompletaron = await pool.query(`
            SELECT COUNT(DISTINCT id_usuario) AS total_usuarios
            FROM respuestas_usuario
        `);

        res.json({
            estadisticas: rows.rows,
            totalUsuariosCompletaron: usuariosCompletaron.rows[0]?.total_usuarios || 0
        });
    } catch (error) {
        res.status(500).json({
            message: 'Error al obtener estadísticas',
            error: error.message
        });
    }
});