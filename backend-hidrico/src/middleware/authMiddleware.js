// src/middleware/authMiddleware.js
import jwt from 'jsonwebtoken';
import 'dotenv/config';

/**
 * Middleware para verificar la autenticación del usuario mediante JWT.
 */
export const protegerRuta = (req, res, next) => {
    // 1. Obtener el token del encabezado 'Authorization'
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        // 401 Unauthorized: No se proporcionó token
        return res.status(401).json({ message: 'No hay token, autorización denegada.' });
    }

    // El token viene como "Bearer <token>"
    const token = authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Token malformado, autorización denegada.' });
    }

    try {
        // 2. Verificar el token con nuestro secreto
        const decodificado = jwt.verify(token, process.env.JWT_SECRET);

        // 3. Añadir el payload del usuario (id, email, etc.) al objeto 'req'
        // Ahora todos los endpoints protegidos tendrán acceso a 'req.usuario'
        req.usuario = decodificado;

        // 4. Continuar al siguiente middleware o al endpoint
        next();

    } catch (error) {
        console.error('Error al verificar token:', error.message);
        // 403 Forbidden: El token no es válido (firmado mal, expirado, etc.)
        res.status(403).json({ message: 'Token no es válido.' });
    }
};

/**
 * Middleware de autorización por rol.
 * Uso: router.get('/ruta', protegerRuta, requerirRol('admin'), handler)
 */
export const requerirRol = (...rolesPermitidos) => {
    return (req, res, next) => {
        const rolUsuario = req?.usuario?.rol;
        if (!rolUsuario) {
            return res.status(403).json({ message: 'Acceso denegado.' });
        }
        if (!rolesPermitidos.includes(rolUsuario)) {
            return res.status(403).json({ message: 'Permisos insuficientes.' });
        }
        next();
    };
};