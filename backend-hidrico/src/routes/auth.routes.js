// src/routes/auth.routes.js
import { Router } from 'express';
import { pool } from '../db.js';
import bcrypt from 'bcryptjs'; // Para hashear contraseñas
import jwt from 'jsonwebtoken'; // Para crear y verificar JWTs 
import 'dotenv/config'; // Para cargar variables de entorno

const router = Router();

/**
 * Endpoint: POST /api/auth/registro
 * Propósito: Registrar un nuevo usuario (RF01, RF02)
 */
router.post('/auth/registro', async (req, res) => {
    const { nombre, email, password } = req.body;

    // --- Práctica 1: Validación de Entradas ---
    if (!nombre || !email || !password) {
        return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
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
            'INSERT INTO usuarios (nombre, email, password_hash) VALUES (?, ?, ?)',
            [nombre, email, passwordHash]
        );

        // --- Práctica 5: Responder con Datos Limpios ---
        // 201 Created: El recurso se creó exitosamente.
        // No devuelvas NUNCA la contraseña (ni el hash).
        res.status(201).json({
            id: result.insertId,
            nombre: nombre,
            email: email
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
            nombre: user.nombre
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
                email: user.email
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


export default router;