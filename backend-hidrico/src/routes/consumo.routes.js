import { Router } from 'express';
import { pool } from '../db.js';

const router = Router();

// Calcular y guardar el consumo diario
router.post('/calcular-consumo', async (req, res) => {
    try {
        const { id_usuario, respuestas } = req.body;
        
        // Obtener todas las respuestas del usuario
        const resultados = await pool.query(
            `SELECT o.valor_consumo 
             FROM respuestas_usuario ru
             JOIN opciones o ON ru.id_opcion = o.id
             WHERE ru.id_usuario = $1`,
            [id_usuario]
        );

        // Calcular el consumo total
        const consumo_total = resultados.rows.reduce((total, row) => 
            total + parseFloat(row.valor_consumo), 0);

        // Guardar el consumo diario
        await pool.query(
            `INSERT INTO consumo_diario (id_usuario, fecha_calculo, consumo_total)
             VALUES ($1, CURRENT_DATE, $2)`,
            [id_usuario, consumo_total]
        );

        res.json({
            success: true,
            consumo_total,
            mensaje: 'Consumo calculado y guardado exitosamente'
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            mensaje: 'Error al calcular el consumo',
            error: error.message
        });
    }
});

// Obtener historial de consumo
router.get('/historial/:id_usuario', async (req, res) => {
    try {
        const historial = await pool.query(
            `SELECT fecha_calculo, consumo_total 
             FROM consumo_diario 
             WHERE id_usuario = $1
             ORDER BY fecha_calculo DESC`,
            [req.params.id_usuario]
        );

        res.json(historial.rows);
    } catch (error) {
        res.status(500).json({
            mensaje: 'Error al obtener el historial',
            error: error.message
        });
    }
});

export default router;