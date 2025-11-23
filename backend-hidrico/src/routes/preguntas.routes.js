import {Router} from 'express';
import { pool } from '../db.js';

const router = Router();

// Obtener todas las preguntas

/**
 * Endpoint: GET /api/preguntas
 * Propósito: Obtener todas las preguntas con sus opciones.
 */
router.get('/preguntas', async (req, res) => {
    try {
        // 1. Consultamos las preguntas
        const preguntasRows = await pool.query('SELECT * FROM preguntas ORDER BY id ASC');

        // 2. Consultamos TODAS las opciones de una vez (más eficiente)
        const opcionesRows = await pool.query('SELECT * FROM opciones ORDER BY id_pregunta ASC');

        // 3. Estructuramos la respuesta.
        // Convertimos el array de preguntas en un objeto para fácil acceso
        const preguntasMap = {};
        const preguntasFormateadas = preguntasRows.rows.map(pregunta => {
            const preguntaConOpciones = {
                id: pregunta.id,
                codigo: pregunta.codigo,
                texto: pregunta.texto,
                opciones: [] // Aquí pondremos sus opciones
            };
            preguntasMap[pregunta.id] = preguntaConOpciones;
            return preguntaConOpciones;
        });

        // 4. Asignamos cada opción a su pregunta correspondiente
        opcionesRows.rows.forEach(opcion => {
            if (preguntasMap[opcion.id_pregunta]) {
                preguntasMap[opcion.id_pregunta].opciones.push({
                    id: opcion.id,
                    texto: opcion.texto_opcion,
                    valor_consumo: Number(opcion.valor_consumo)
                });
            }
        });
        
        // 5. Enviamos el JSON formateado con charset UTF-8
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.json(preguntasFormateadas);

    } catch (error) {
        console.error('Error al obtener preguntas:', error);
        res.status(500).json({
            message: 'Error interno del servidor al obtener preguntas',
            error: error.message
        });
    }
});

// Exportamos el enrutador para usarlo en index.js
export default router;