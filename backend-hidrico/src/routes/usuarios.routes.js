import { Router } from 'express';
import { pool } from '../db.js';
import { protegerRuta, requerirRol } from '../middleware/authMiddleware.js';
import bcrypt from 'bcryptjs';

const router = Router();

// Normalización y catálogos permitidos
const normalizarValor = (valor) =>
    typeof valor === 'string' ? valor.trim().toLowerCase().replace(/\s+/g, '_') : '';

const SEXO_PERMITIDOS = new Set(['femenino', 'masculino', 'otro', 'prefiero_no_decir']);
const NIVEL_EDUCATIVO_PERMITIDOS = new Set([
    'primaria',
    'secundaria',
    'tecnico',
    'universitario',
    'postgrado',
    'otro'
]);
const ROLES_PERMITIDOS = new Set(['usuario', 'admin']);

/**
 * Endpoint: GET /api/usuarios
 * Propósito: Obtener lista de usuarios (solo admin)
 * Soporta filtros opcionales:
 *  - q: búsqueda por nombre o email
 *  - rol: 'admin' | 'usuario'
 *  - page, pageSize: paginación (por defecto 1 y 20)
 */
router.get('/usuarios', protegerRuta, requerirRol('admin'), async (req, res) => {
    try {
        const { q, rol, page = 1, pageSize = 20 } = req.query;

        const filtros = [];
        const valores = [];
        let paramIndex = 1;

        if (q && String(q).trim() !== '') {
            filtros.push(`(nombre LIKE $${paramIndex} OR email LIKE $${paramIndex + 1})`);
            const like = `%${String(q).trim()}%`;
            valores.push(like, like);
            paramIndex += 2;
        }

        if (rol && (rol === 'admin' || rol === 'usuario')) {
            filtros.push(`rol = $${paramIndex}`);
            valores.push(rol);
            paramIndex += 1;
        }

        const whereClause = filtros.length > 0 ? `WHERE ${filtros.join(' AND ')}` : '';

        const limitNum = Math.max(1, parseInt(pageSize, 10) || 20);
        const pageNum = Math.max(1, parseInt(page, 10) || 1);
        const offset = (pageNum - 1) * limitNum;

        // Total para paginación
        const countQuery = `SELECT COUNT(*) AS total FROM usuarios ${whereClause}`;
        const countRows = await pool.query(countQuery, valores);
        const total = parseInt(countRows.rows[0]?.total ?? 0, 10);

        // Datos paginados
        const usuariosQuery = `
            SELECT 
                id,
                nombre,
                email,
                rol,
                sexo,
                nivel_educativo,
                fecha_registro
            FROM usuarios
            ${whereClause}
            ORDER BY fecha_registro DESC
            LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
        `;
        const usuariosParams = [...valores, limitNum, offset];
        const usuarios = await pool.query(usuariosQuery, usuariosParams);

        res.json({
            data: usuarios.rows,
            pagination: {
                total,
                page: pageNum,
                pageSize: limitNum,
                totalPages: Math.ceil(total / limitNum)
            }
        });
    } catch (error) {
        res.status(500).json({
            message: 'Error al obtener usuarios',
            error: error.message
        });
    }
});

/**
 * Endpoint: GET /api/usuarios/:id
 * Propósito: Obtener un usuario por ID (solo admin)
 */
router.get('/usuarios/:id', protegerRuta, requerirRol('admin'), async (req, res) => {
    try {
        const rows = await pool.query(
            `
            SELECT 
                id, nombre, email, rol, sexo, nivel_educativo, fecha_registro, fecha_actualizacion
            FROM usuarios
            WHERE id = $1
            `,
            [req.params.id]
        );
        if (rows.rows.length === 0) return res.status(404).json({ message: 'Usuario no encontrado' });
        res.json(rows.rows[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error al obtener usuario', error: error.message });
    }
});

/**
 * Endpoint: POST /api/usuarios
 * Propósito: Crear un usuario (solo admin)
 */
router.post('/usuarios', protegerRuta, requerirRol('admin'), async (req, res) => {
    const { nombre, email, password, sexo, nivel_educativo, rol } = req.body;

    if (!nombre || !email || !password || !sexo || !nivel_educativo || !rol) {
        return res.status(400).json({
            message: 'Campos obligatorios: nombre, email, password, sexo, nivel_educativo, rol'
        });
    }

    const sexoNorm = normalizarValor(sexo);
    const nivelNorm = normalizarValor(nivel_educativo);
    const rolNorm = normalizarValor(rol);

    if (!SEXO_PERMITIDOS.has(sexoNorm)) {
        return res.status(400).json({ message: 'Valor de "sexo" inválido.', permitidos: Array.from(SEXO_PERMITIDOS) });
    }
    if (!NIVEL_EDUCATIVO_PERMITIDOS.has(nivelNorm)) {
        return res.status(400).json({ message: 'Valor de "nivel_educativo" inválido.', permitidos: Array.from(NIVEL_EDUCATIVO_PERMITIDOS) });
    }
    if (!ROLES_PERMITIDOS.has(rolNorm)) {
        return res.status(400).json({ message: 'Valor de "rol" inválido.', permitidos: Array.from(ROLES_PERMITIDOS) });
    }

    try {
        // Unicidad de email
        const dupes = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email]);
        if (dupes.rows.length > 0) {
            return res.status(409).json({ message: 'El correo electrónico ya está registrado.' });
        }

        const passwordHash = await bcrypt.hash(password, 10);
        const result = await pool.query(
            `INSERT INTO usuarios (nombre, email, password_hash, sexo, nivel_educativo, rol)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
            [nombre, email, passwordHash, sexoNorm, nivelNorm, rolNorm]
        );

        res.status(201).json({
            id: result.rows[0].id,
            nombre,
            email,
            sexo: sexoNorm,
            nivel_educativo: nivelNorm,
            rol: rolNorm
        });
    } catch (error) {
        res.status(500).json({ message: 'Error al crear usuario', error: error.message });
    }
});

/**
 * Endpoint: PATCH /api/usuarios/:id
 * Propósito: Actualizar parcialmente un usuario (solo admin)
 */
router.patch('/usuarios/:id', protegerRuta, requerirRol('admin'), async (req, res) => {
    const { nombre, email, password, sexo, nivel_educativo, rol } = req.body || {};

    // Construimos dinámicamente el UPDATE
    const sets = [];
    const values = [];

    if (typeof nombre === 'string') {
        sets.push('nombre = $' + (values.length + 1));
        values.push(nombre);
    }
    if (typeof email === 'string') {
        // verificar email duplicado
        try {
            const dupes = await pool.query('SELECT id FROM usuarios WHERE email = $1 AND id <> $2', [email, req.params.id]);
            if (dupes.rows.length > 0) {
                return res.status(409).json({ message: 'El correo electrónico ya está registrado por otro usuario.' });
            }
        } catch (error) {
            return res.status(500).json({ message: 'Error al validar email', error: error.message });
        }
        sets.push('email = $' + (values.length + 1));
        values.push(email);
    }
    if (typeof password === 'string' && password.length > 0) {
        const hash = await bcrypt.hash(password, 10);
        sets.push('password_hash = $' + (values.length + 1));
        values.push(hash);
    }
    if (typeof sexo === 'string') {
        const sexoNorm = normalizarValor(sexo);
        if (!SEXO_PERMITIDOS.has(sexoNorm)) {
            return res.status(400).json({ message: 'Valor de "sexo" inválido.', permitidos: Array.from(SEXO_PERMITIDOS) });
        }
        sets.push('sexo = $' + (values.length + 1));
        values.push(sexoNorm);
    }
    if (typeof nivel_educativo === 'string') {
        const nivelNorm = normalizarValor(nivel_educativo);
        if (!NIVEL_EDUCATIVO_PERMITIDOS.has(nivelNorm)) {
            return res.status(400).json({ message: 'Valor de "nivel_educativo" inválido.', permitidos: Array.from(NIVEL_EDUCATIVO_PERMITIDOS) });
        }
        sets.push('nivel_educativo = $' + (values.length + 1));
        values.push(nivelNorm);
    }
    if (typeof rol === 'string') {
        const rolNorm = normalizarValor(rol);
        if (!ROLES_PERMITIDOS.has(rolNorm)) {
            return res.status(400).json({ message: 'Valor de "rol" inválido.', permitidos: Array.from(ROLES_PERMITIDOS) });
        }
        sets.push('rol = $' + (values.length + 1));
        values.push(rolNorm);
    }

    if (sets.length === 0) {
        return res.status(400).json({ message: 'No se proporcionaron campos para actualizar.' });
    }

    try {
        const sql = `UPDATE usuarios SET ${sets.join(', ')}, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $${values.length + 1}`;
        values.push(req.params.id);
        const result = await pool.query(sql, values);
        if (result.rowCount === 0) return res.status(404).json({ message: 'Usuario no encontrado' });
        res.json({ message: 'Usuario actualizado correctamente.' });
    } catch (error) {
        res.status(500).json({ message: 'Error al actualizar usuario', error: error.message });
    }
});

/**
 * Endpoint: DELETE /api/usuarios/:id
 * Propósito: Eliminar un usuario (solo admin)
 */
router.delete('/usuarios/:id', protegerRuta, requerirRol('admin'), async (req, res) => {
    try {
        const result = await pool.query('DELETE FROM usuarios WHERE id = $1', [req.params.id]);
        if (result.rowCount === 0) return res.status(404).json({ message: 'Usuario no encontrado' });
        res.json({ message: 'Usuario eliminado correctamente.' });
    } catch (error) {
        res.status(500).json({ message: 'Error al eliminar usuario', error: error.message });
    }
});

export default router;


