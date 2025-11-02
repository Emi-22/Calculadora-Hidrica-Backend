// src/routes/respuestas.routes.js
import { Router } from 'express';
import { pool } from '../db.js';
import { protegerRuta } from '../middleware/authMiddleware.js'; // Middleware de protección de rutas

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

        connection = await pool.getConnection(); // Obtenemos una conexión del pool
        await connection.beginTransaction(); // Iniciamos la transacción

        // --- Práctica 3: Limpiar respuestas antiguas ---
        // Esto permite al usuario "volver a tomar" el cuestionario.
        // Borramos solo las respuestas de este usuario.
        // (Una lógica más avanzada podría borrar solo respuestas de las preguntas enviadas)
        await connection.query('DELETE FROM respuestas_usuario WHERE id_usuario = ?', [idUsuario]);

        // --- Práctica 4: Insertar Múltiples Filas Eficientemente ---

        // Convertimos el array [3, 5, 8] en un array de arrays: [[idUsuario, 3], [idUsuario, 5], [idUsuario, 8]]
        const valoresParaInsertar = opciones.map(idOpcion => [idUsuario, idOpcion]);

        // Creamos la consulta para inserción múltiple
        const sql = 'INSERT INTO respuestas_usuario (id_usuario, id_opcion) VALUES ?';

        // Ejecutamos la consulta con los valores
        await connection.query(sql, [valoresParaInsertar]);

        // Si todo salió bien, confirmamos la transacción
        await connection.commit();

        res.status(201).json({ message: 'Respuestas guardadas exitosamente.' });

    } catch (error) {
        // Si algo falló, revertimos la transacción
        if (connection) {
            await connection.rollback();
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