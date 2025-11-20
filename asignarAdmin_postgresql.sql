-- Script para asignar rol de administrador a un usuario
-- PostgreSQL Version
-- IMPORTANTE: Cambia 'correo@gmail.com' por el email real del usuario

UPDATE usuarios
SET rol = 'admin'
WHERE email = 'correo@gmail.com';

