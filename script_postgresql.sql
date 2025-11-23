-- -----------------------------------------------------
-- Script para crear la Base de Datos y sus Tablas
-- Proyecto: Consumo Hídrico
-- PostgreSQL Version
-- -----------------------------------------------------

-- 1. CREACIÓN DE LA BASE DE DATOS
-- Nota: En PostgreSQL, normalmente se crea la base de datos desde psql o pgAdmin
-- Ejecuta esto como superusuario: CREATE DATABASE db_consumo_hidrico ENCODING 'UTF8' LC_COLLATE='es_ES.UTF-8' LC_CTYPE='es_ES.UTF-8';
-- O usa: createdb -E UTF8 -l es_ES.UTF-8 db_consumo_hidrico
-- IMPORTANTE: Asegúrate de que la base de datos se cree con codificación UTF-8

-- 2. CONECTARSE A LA BASE DE DATOS
-- \c db_consumo_hidrico (en psql)
-- O especifica la base de datos en la conexión

-- 3. CONFIGURAR CODIFICACIÓN DE LA SESIÓN (ejecutar después de conectarse)
-- SET client_encoding = 'UTF8';

-- -----------------------------------------------------
-- Tabla: `usuarios`
-- Almacena los datos de registro (RF01)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Para la contraseña hasheada con bcrypt
    sexo VARCHAR(50) NOT NULL CHECK (sexo IN ('femenino','masculino','otro','prefiero_no_decir')),
    nivel_educativo VARCHAR(50) NOT NULL CHECK (nivel_educativo IN ('primaria','secundaria','tecnico','universitario','postgrado','otro')),
    rol VARCHAR(50) NOT NULL DEFAULT 'usuario' CHECK (rol IN ('usuario','admin')),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índice único para email (ya está incluido en UNIQUE, pero lo dejamos explícito)
CREATE UNIQUE INDEX IF NOT EXISTS idx_email_unique ON usuarios(email);

-- Trigger para actualizar fecha_actualizacion automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- -----------------------------------------------------
-- Tabla: `preguntas`
-- Almacena el texto de cada pregunta (RF05)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS preguntas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE, -- Un código corto (ej: "p1_ducha")
    texto TEXT NOT NULL, -- El texto completo de la pregunta
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índice único para codigo (ya está incluido en UNIQUE)
CREATE UNIQUE INDEX IF NOT EXISTS idx_codigo_unique ON preguntas(codigo);

-- -----------------------------------------------------
-- Tabla: `opciones`
-- Almacena las opciones de cada pregunta (RF06) y su valor de consumo.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS opciones (
    id SERIAL PRIMARY KEY,
    id_pregunta INTEGER NOT NULL,
    texto_opcion VARCHAR(255) NOT NULL,
    valor_consumo DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- Valor numérico (ej: litros)
    
    -- Relación: Una opción pertenece a una pregunta
    CONSTRAINT fk_opciones_preguntas
        FOREIGN KEY (id_pregunta)
        REFERENCES preguntas(id)
        ON DELETE CASCADE -- Si se borra la pregunta, se borran sus opciones
        ON UPDATE CASCADE
);

-- Índice para la clave foránea (mejora el rendimiento)
CREATE INDEX IF NOT EXISTS idx_fk_pregunta ON opciones(id_pregunta);

-- -----------------------------------------------------
-- Tabla: `respuestas_usuario`
-- Conecta a un usuario con la opción que eligió (RF08)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS respuestas_usuario (
    id SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    id_opcion INTEGER NOT NULL,
    fecha_respuesta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Relación: La respuesta pertenece a un usuario
    CONSTRAINT fk_respuestas_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id)
        ON DELETE CASCADE -- Si se borra el usuario, se borran sus respuestas
        ON UPDATE CASCADE,
        
    -- Relación: La respuesta es una de las opciones
    CONSTRAINT fk_respuestas_opciones
        FOREIGN KEY (id_opcion)
        REFERENCES opciones(id)
        ON DELETE CASCADE -- Si se borra la opción, también se borra esta respuesta
        ON UPDATE CASCADE
);

-- Índices para las claves foráneas (acelera las búsquedas)
CREATE INDEX IF NOT EXISTS idx_fk_usuario ON respuestas_usuario(id_usuario);
CREATE INDEX IF NOT EXISTS idx_fk_opcion ON respuestas_usuario(id_opcion);

-- -----------------------------------------------------
-- Tabla: `consumo_diario`
-- Almacena el consumo total calculado por día
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS consumo_diario (
    id SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    fecha_calculo DATE NOT NULL,
    consumo_total DECIMAL(10, 2) NOT NULL, -- Litros por día
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_consumo_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Índice para la clave foránea
CREATE INDEX IF NOT EXISTS idx_fk_usuario_consumo ON consumo_diario(id_usuario);

