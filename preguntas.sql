use db_consumo_hidrico;

START TRANSACTION;

-- P1
INSERT INTO preguntas (codigo, texto)
VALUES ('p01_consumo_diario_litros', '¿Cuántos litros de agua estimas en tu consumo al día?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p1 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p1;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p1, 'Menos de 50 litros', 10.00),
(@p1, '50-100 litros', 25.00),
(@p1, '100-200 litros', 50.00),
(@p1, 'Más de 200 litros', 80.00);

-- P2
INSERT INTO preguntas (codigo, texto)
VALUES ('p02_veces_ducha_dia', '¿Cuántas veces al día te duchas?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p2 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p2;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p2, '1 vez', 15.00),
(@p2, '2 veces', 35.00),
(@p2, '3 o más veces', 60.00);

-- P3
INSERT INTO preguntas (codigo, texto)
VALUES ('p03_duracion_ducha', '¿Cuánto dura cada ducha?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p3 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p3;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p3, 'Menos de 5 minutos', 10.00),
(@p3, '5-10 minutos', 25.00),
(@p3, '10-15 minutos', 45.00),
(@p3, 'Más de 15 minutos', 70.00);

-- P4
INSERT INTO preguntas (codigo, texto)
VALUES ('p04_tipo_regadera', '¿Usas regadera de ahorro o convencional?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p4 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p4;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p4, 'Regadera de ahorro', 5.00),
(@p4, 'Regadera convencional', 30.00);

-- P5
INSERT INTO preguntas (codigo, texto)
VALUES ('p05_veces_lavas_dientes', '¿Cuántas veces al día lavas tus dientes?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p5 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p5;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p5, '1 vez', 5.00),
(@p5, '2 veces', 10.00),
(@p5, '3 o más veces', 20.00);

-- P6
INSERT INTO preguntas (codigo, texto)
VALUES ('p06_dejas_llave_abierta', '¿Dejas la llave abierta?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p6 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p6;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p6, 'Siempre la cierro', 5.00),
(@p6, 'A veces la dejo abierta', 20.00),
(@p6, 'Casi siempre la dejo abierta', 40.00);

-- P7
INSERT INTO preguntas (codigo, texto)
VALUES ('p07_veces_inodoro_dia', '¿Cuántas veces al día utilizas el inodoro?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p7 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p7;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p7, '1-3 veces', 10.00),
(@p7, '4-6 veces', 25.00),
(@p7, 'Más de 6 veces', 45.00);

-- P8
INSERT INTO preguntas (codigo, texto)
VALUES ('p08_tipo_inodoro', '¿Tu inodoro es de descarga ahorradora o convencional?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p8 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p8;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p8, 'Ahorradora', 5.00),
(@p8, 'Convencional', 30.00);

-- P9
INSERT INTO preguntas (codigo, texto)
VALUES ('p09_veces_lavas_trastes_semana', '¿Cuántas veces por semana lavas los trastes?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p9 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p9;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p9, '1-2 veces', 10.00),
(@p9, '3-4 veces', 20.00),
(@p9, '5-7 veces', 35.00),
(@p9, 'Más de 7 veces', 50.00);

-- P10
INSERT INTO preguntas (codigo, texto)
VALUES ('p10_enjabonas_con_llave', '¿Enjabonas con la llave abierta o cerrada?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p10 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p10;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p10, 'Siempre cerrada', 5.00),
(@p10, 'A veces abierta', 20.00),
(@p10, 'Casi siempre abierta', 40.00);

-- P11
INSERT INTO preguntas (codigo, texto)
VALUES ('p11_veces_lavas_ropa_semana', '¿Cuántas veces lavas por semana tu ropa?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p11 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p11;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p11, '1-2 veces', 15.00),
(@p11, '3-4 veces', 35.00),
(@p11, '5-7 veces', 60.00),
(@p11, 'Más de 7 veces', 85.00);

-- P12
INSERT INTO preguntas (codigo, texto)
VALUES ('p12_tipo_lavadora', '¿Tu lavadora es de alta eficiencia o convencional?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p12 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p12;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p12, 'Alta eficiencia', 10.00),
(@p12, 'Convencional', 40.00);

-- P13
INSERT INTO preguntas (codigo, texto)
VALUES ('p13_veces_trapear_semana', '¿Cuántas veces a la semana trapeas o limpias pisos haciendo uso de agua?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p13 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p13;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p13, '1-2 veces', 10.00),
(@p13, '3-4 veces', 20.00),
(@p13, '5-7 veces', 35.00),
(@p13, 'Más de 7 veces', 50.00);

-- P14
INSERT INTO preguntas (codigo, texto)
VALUES ('p14_agua_embotellada', '¿Consumes agua embotellada regularmente?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p14 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p14;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p14, 'Nunca', 5.00),
(@p14, 'Ocasionalmente', 20.00),
(@p14, 'Frecuentemente', 45.00),
(@p14, 'Siempre', 70.00);

-- P15
INSERT INTO preguntas (codigo, texto)
VALUES ('p15_tienes_automovil', '¿Tienes automóvil propio?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p15 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p15;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p15, 'No', 0.00),
(@p15, 'Sí', 30.00);

-- P16
INSERT INTO preguntas (codigo, texto)
VALUES ('p16_veces_lavas_auto_mes', '¿Cuántas veces al mes lo lavas?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p16 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p16;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p16, 'No aplica', 0.00),
(@p16, '1-2 veces', 15.00),
(@p16, '3-4 veces', 30.00),
(@p16, 'Más de 4 veces', 50.00);

-- P17
INSERT INTO preguntas (codigo, texto)
VALUES ('p17_veces_consumes_carne_mes', '¿Aproximadamente cuántas veces por mes consumes carne para alimentarte?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p17 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p17;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p17, 'Nunca (vegetariano/vegano)', 5.00),
(@p17, '1-5 veces', 20.00),
(@p17, '6-15 veces', 45.00),
(@p17, 'Más de 15 veces', 75.00);

-- P18
INSERT INTO preguntas (codigo, texto)
VALUES ('p18_sales_fiesta', '¿Sales regularmente de fiesta?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p18 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p18;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p18, 'Nunca', 5.00),
(@p18, 'Ocasionalmente', 20.00),
(@p18, 'Frecuentemente', 40.00);

-- P19
INSERT INTO preguntas (codigo, texto)
VALUES ('p19_consumes_bebidas_alcoholicas', '¿Consumes bebidas alcohólicas?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p19 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p19;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p19, 'No', 5.00),
(@p19, 'Sí', 30.00);

-- P20
INSERT INTO preguntas (codigo, texto)
VALUES ('p20_consumo_bebidas_por_reunion', '¿Cuál es tu consumo estimado de bebidas alcohólicas por reunión?')
ON DUPLICATE KEY UPDATE texto = VALUES(texto), id = LAST_INSERT_ID(id);
SET @p20 := LAST_INSERT_ID();
DELETE FROM opciones WHERE id_pregunta = @p20;
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo) VALUES
(@p20, 'No aplica', 0.00),
(@p20, '1-2 bebidas', 15.00),
(@p20, '3-4 bebidas', 35.00),
(@p20, 'Más de 4 bebidas', 60.00);

COMMIT;