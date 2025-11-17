// src/routes/auth.routes.js
import { Router } from 'express';
import { pool } from '../db.js';
import bcrypt from 'bcryptjs'; // Para hashear contraseñas
import jwt from 'jsonwebtoken'; // Para crear y verificar JWTs 
import 'dotenv/config'; // Para cargar variables de entorno
import crypto from 'crypto'; // Para tokens de recuperación
import nodemailer from 'nodemailer'; // Para enviar correos

const router = Router();

// Listas permitidas y normalización
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

// --- Configuración de correo para recuperación de contraseña ---
const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: false,
    auth: process.env.SMTP_USER && process.env.SMTP_PASS ? {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
    } : undefined
});

async function enviarCorreoRecuperacion(destinatario, nombre, enlace) {
    if (!process.env.SMTP_HOST) {
        console.warn('SMTP no configurado; no se enviará correo de recuperación.');
        return;
    }
    await transporter.sendMail({
        from: process.env.SMTP_FROM || '"Soporte" <no-reply@hidrico.local>',
        to: destinatario,
        subject: 'Recupera tu contraseña',
        html: `
            <p>Hola ${nombre || ''},</p>
            <p>Has solicitado restablecer tu contraseña.</p>
            <p>Haz clic en el siguiente enlace (válido por 1 hora):</p>
            <p><a href="${enlace}">${enlace}</a></p>
            <p>Si no fuiste tú, ignora este mensaje.</p>
        `
    });
}

/**
 * Endpoint: POST /api/auth/registro
 * Propósito: Registrar un nuevo usuario (RF01, RF02)
 */
router.post('/auth/registro', async (req, res) => {
    const { nombre, email, password, sexo, nivel_educativo } = req.body;

    // --- Práctica 1: Validación de Entradas ---
    if (!nombre || !email || !password || !sexo || !nivel_educativo) {
        return res.status(400).json({
            message: 'Todos los campos son obligatorios: nombre, email, password, sexo, nivel_educativo.'
        });
    }

    // Normalizamos y validamos listas permitidas
    const sexoNormalizado = normalizarValor(sexo);
    const nivelNormalizado = normalizarValor(nivel_educativo);
    const rolNormalizado = 'usuario'; // El registro público siempre crea usuario estándar

    if (!SEXO_PERMITIDOS.has(sexoNormalizado)) {
        return res.status(400).json({
            message: 'Valor de "sexo" inválido.',
            permitidos: Array.from(SEXO_PERMITIDOS)
        });
    }
    if (!NIVEL_EDUCATIVO_PERMITIDOS.has(nivelNormalizado)) {
        return res.status(400).json({
            message: 'Valor de "nivel_educativo" inválido.',
            permitidos: Array.from(NIVEL_EDUCATIVO_PERMITIDOS)
        });
    }

    try {
        // --- Práctica 2: Verificar Duplicados ---
        const [userExists] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);

        if (userExists.length > 0) {
            // 409 Conflict: El recurso ya existe.
            return res.status(409).json({ message: 'El correo electrónico ya está registrado.' });
        }

        // --- Práctica 3: Hashing de Contraseña ---
        // Nunca guardes contraseñas en texto plano.
        // 10 "rondas" de salt es un estándar de seguridad robusto.
        const passwordHash = await bcrypt.hash(password, 10);

        // --- Práctica 4: Insertar en la BD ---
        const [result] = await pool.query(
            'INSERT INTO usuarios (nombre, email, password_hash, sexo, nivel_educativo, rol) VALUES (?, ?, ?, ?, ?, ?)',
            [nombre, email, passwordHash, sexoNormalizado, nivelNormalizado, rolNormalizado]
        );

        // --- Práctica 5: Responder con Datos Limpios ---
        // 201 Created: El recurso se creó exitosamente.
        // No devuelvas NUNCA la contraseña (ni el hash).
        res.status(201).json({
            id: result.insertId,
            nombre: nombre,
            email: email,
            sexo: sexoNormalizado,
            nivel_educativo: nivelNormalizado,
            rol: rolNormalizado
        });

    } catch (error) {
        console.error('Error en el registro:', error);
        res.status(500).json({
            message: 'Error interno del servidor al registrar usuario',
            error: error.message
        });
    }
});

/**
 * Endpoint: POST /api/auth/login
 * Propósito: Autenticar un usuario y devolver un token.
 */
router.post('/auth/login', async (req, res) => {
    const { email, password } = req.body;

    // --- Práctica 1: Validación de Entradas ---
    if (!email || !password) {
        return res.status(400).json({ message: 'Correo y contraseña son obligatorios.' });
    }

    try {
        // --- Práctica 2: Buscar al Usuario ---
        const [users] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);

        if (users.length === 0) {
            // 401 Unauthorized.
            // Práctica de seguridad: Envía un mensaje genérico.
            // NO digas "El usuario no existe".
            return res.status(401).json({ message: 'Credenciales inválidas.' });
        }

        const user = users[0];

        // --- Práctica 3: Comparar Contraseña Hasheada ---
        const isMatch = await bcrypt.compare(password, user.password_hash);

        if (!isMatch) {
            // 401 Unauthorized.
            // Mismo mensaje genérico para evitar que adivinen usuarios.
            return res.status(401).json({ message: 'Credenciales inválidas.' });
        }

        // --- Práctica 4: Crear el JSON Web Token (JWT) ---
        // El "payload" es la información que guardamos en el token.
        // SOLO guarda información NO sensible (como el ID del usuario).
        const payload = {
            id: user.id,
            email: user.email,
            nombre: user.nombre,
            rol: user.rol
        };

        // Firmamos el token con nuestro secreto y le damos 1 día de expiración
        const token = jwt.sign(
            payload, 
            process.env.JWT_SECRET, 
            { expiresIn: '1d' }
        );

        // --- Práctica 5: Enviar el Token ---
        // 200 OK. El front-end debe guardar este token.
        res.status(200).json({
            message: 'Login exitoso',
            token: token,
            usuario: {
                id: user.id,
                nombre: user.nombre,
                email: user.email,
                sexo: user.sexo ?? null,
                nivel_educativo: user.nivel_educativo ?? null,
                rol: user.rol
            }
        });

    } catch (error) {
        console.error('Error en el login:', error);
        res.status(500).json({
            message: 'Error interno del servidor al iniciar sesión',
            error: error.message
        });
    }
});

/**
 * Endpoint: POST /api/auth/forgot-password
 * Propósito: Solicitar recuperación de contraseña (siempre responde genérico)
 */
router.post('/auth/forgot-password', async (req, res) => {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ message: 'Email requerido.' });
    }

    try {
        const [rows] = await pool.query('SELECT id, nombre, email FROM usuarios WHERE email = ?', [email]);
        const usuario = rows[0];

        if (usuario) {
            const token = crypto.randomBytes(32).toString('hex');
            const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
            const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hora

            await pool.query(
                'INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
                [usuario.id, tokenHash, expiresAt]
            );

            const baseUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
            const link = `${baseUrl}/reset-password?token=${token}`;
            await enviarCorreoRecuperacion(usuario.email, usuario.nombre, link);
        }

        res.json({ message: 'Si el correo existe, se envió un enlace de recuperación.' });
    } catch (error) {
        console.error('Error en forgot-password:', error);
        res.status(500).json({ message: 'Error al procesar solicitud', error: error.message });
    }
});

/**
 * Endpoint: POST /api/auth/reset-password
 * Propósito: Cambiar la contraseña usando un token válido
 */
router.post('/auth/reset-password', async (req, res) => {
    const { token, password } = req.body;

    if (!token || !password) {
        return res.status(400).json({ message: 'Token y nueva contraseña son requeridos.' });
    }

    try {
        const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
        const [rows] = await pool.query(
            `SELECT id, user_id FROM password_reset_tokens
             WHERE token_hash = ? AND used_at IS NULL AND expires_at > NOW()
             LIMIT 1`,
            [tokenHash]
        );

        if (rows.length === 0) {
            return res.status(400).json({ message: 'Token inválido o expirado.' });
        }

        const row = rows[0];
        const passwordHash = await bcrypt.hash(password, 10);

        await pool.query('UPDATE usuarios SET password_hash = ? WHERE id = ?', [passwordHash, row.user_id]);
        await pool.query('UPDATE password_reset_tokens SET used_at = NOW() WHERE id = ?', [row.id]);
        await pool.query(
            'DELETE FROM password_reset_tokens WHERE user_id = ? AND (used_at IS NOT NULL OR expires_at <= NOW())',
            [row.user_id]
        );

        res.json({ message: 'Contraseña actualizada correctamente.' });
    } catch (error) {
        console.error('Error en reset-password:', error);
        res.status(500).json({ message: 'Error al restablecer contraseña', error: error.message });
    }
});


export default router;