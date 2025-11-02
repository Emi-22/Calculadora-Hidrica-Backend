-- -----------------------------------------------------
-- Script para crear la Base de Datos y sus Tablas
-- Proyecto: Consumo Hídrico
-- -----------------------------------------------------

-- 1. CREACIÓN DE LA BASE DE DATOS
-- Usamos `IF NOT EXISTS` para evitar errores si ya existe.
-- `utf8mb4` es el estándar moderno para soportar todos los caracteres.
CREATE DATABASE IF NOT EXISTS db_consumo_hidrico
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2. SELECCIÓN DE LA BASE DE DATOS
USE db_consumo_hidrico;

-- -----------------------------------------------------
-- Tabla: `usuarios`
-- Almacena los datos de registro (RF01)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL, -- Para la contraseña hasheada con bcrypt
    `fecha_registro` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `fecha_actualizacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`id`),
    UNIQUE INDEX `idx_email_unique` (`email` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabla: `preguntas`
-- Almacena el texto de cada pregunta (RF05)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS preguntas (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `codigo` VARCHAR(50) NOT NULL, -- Un código corto (ej: "p1_ducha")
    `texto` TEXT NOT NULL, -- El texto completo de la pregunta
    `fecha_creacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`id`),
    UNIQUE INDEX `idx_codigo_unique` (`codigo` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabla: `opciones`
-- Almacena las opciones de cada pregunta (RF06) y su valor de consumo.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS opciones (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_pregunta` INT UNSIGNED NOT NULL,
    `texto_opcion` VARCHAR(255) NOT NULL,
    `valor_consumo` DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- Valor numérico (ej: litros)
    
    PRIMARY KEY (`id`),
    
    -- Índice para la clave foránea
    INDEX `idx_fk_pregunta` (`id_pregunta` ASC),
    
    -- Relación: Una opción pertenece a una pregunta
    CONSTRAINT `fk_opciones_preguntas`
        FOREIGN KEY (`id_pregunta`)
        REFERENCES `preguntas` (`id`)
        ON DELETE CASCADE -- Si se borra la pregunta, se borran sus opciones
        ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabla: `respuestas_usuario`
-- Conecta a un usuario con la opción que eligió (RF08)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS respuestas_usuario (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_usuario` INT UNSIGNED NOT NULL,
    `id_opcion` INT UNSIGNED NOT NULL,
    `fecha_respuesta` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`id`),
    
    -- Índices para las claves foráneas (acelera las búsquedas)
    INDEX `idx_fk_usuario` (`id_usuario` ASC),
    INDEX `idx_fk_opcion` (`id_opcion` ASC),
    
    -- Relación: La respuesta pertenece a un usuario
    CONSTRAINT `fk_respuestas_usuarios`
        FOREIGN KEY (`id_usuario`)
        REFERENCES `usuarios` (`id`)
        ON DELETE CASCADE -- Si se borra el usuario, se borran sus respuestas
        ON UPDATE CASCADE,
        
    -- Relación: La respuesta es una de las opciones
    CONSTRAINT `fk_respuestas_opciones`
        FOREIGN KEY (`id_opcion`)
        REFERENCES `opciones` (`id`)
        ON DELETE CASCADE -- Si se borra la opción, también se borra esta respuesta
        ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabla: `consumo_diario`
-- Almacena el consumo total calculado por día
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS consumo_diario (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_usuario` INT UNSIGNED NOT NULL,
    `fecha_calculo` DATE NOT NULL,
    `consumo_total` DECIMAL(10, 2) NOT NULL, -- Litros por día
    `fecha_registro` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`id`),
    INDEX `idx_fk_usuario_consumo` (`id_usuario` ASC),
    
    CONSTRAINT `fk_consumo_usuarios`
        FOREIGN KEY (`id_usuario`)
        REFERENCES `usuarios` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;