-- Script para insertar preguntas y opciones
-- PostgreSQL Version
-- Ejecuta este script después de crear las tablas con script_postgresql.sql

BEGIN;

-- P1
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p01_consumo_diario_litros', '¿Cuántos litros de agua estimas en tu consumo al día?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Menos de 50 litros', 10.00 FROM preguntas WHERE codigo = 'p01_consumo_diario_litros'
UNION ALL
SELECT id, '50-100 litros', 25.00 FROM preguntas WHERE codigo = 'p01_consumo_diario_litros'
UNION ALL
SELECT id, '100-200 litros', 50.00 FROM preguntas WHERE codigo = 'p01_consumo_diario_litros'
UNION ALL
SELECT id, 'Más de 200 litros', 80.00 FROM preguntas WHERE codigo = 'p01_consumo_diario_litros';

-- P2
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p02_veces_ducha_dia', '¿Cuántas veces al día te duchas?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1 vez', 15.00 FROM preguntas WHERE codigo = 'p02_veces_ducha_dia'
UNION ALL
SELECT id, '2 veces', 35.00 FROM preguntas WHERE codigo = 'p02_veces_ducha_dia'
UNION ALL
SELECT id, '3 o más veces', 60.00 FROM preguntas WHERE codigo = 'p02_veces_ducha_dia';

-- P3
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p03_duracion_ducha', '¿Cuánto dura cada ducha?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Menos de 5 minutos', 10.00 FROM preguntas WHERE codigo = 'p03_duracion_ducha'
UNION ALL
SELECT id, '5-10 minutos', 25.00 FROM preguntas WHERE codigo = 'p03_duracion_ducha'
UNION ALL
SELECT id, '10-15 minutos', 45.00 FROM preguntas WHERE codigo = 'p03_duracion_ducha'
UNION ALL
SELECT id, 'Más de 15 minutos', 70.00 FROM preguntas WHERE codigo = 'p03_duracion_ducha';

-- P4
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p04_tipo_regadera', '¿Usas regadera de ahorro o convencional?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Regadera de ahorro', 5.00 FROM preguntas WHERE codigo = 'p04_tipo_regadera'
UNION ALL
SELECT id, 'Regadera convencional', 30.00 FROM preguntas WHERE codigo = 'p04_tipo_regadera';

-- P5
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p05_veces_lavas_dientes', '¿Cuántas veces al día lavas tus dientes?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1 vez', 5.00 FROM preguntas WHERE codigo = 'p05_veces_lavas_dientes'
UNION ALL
SELECT id, '2 veces', 10.00 FROM preguntas WHERE codigo = 'p05_veces_lavas_dientes'
UNION ALL
SELECT id, '3 o más veces', 20.00 FROM preguntas WHERE codigo = 'p05_veces_lavas_dientes';

-- P6
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p06_dejas_llave_abierta', '¿Dejas la llave abierta?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Siempre la cierro', 5.00 FROM preguntas WHERE codigo = 'p06_dejas_llave_abierta'
UNION ALL
SELECT id, 'A veces la dejo abierta', 20.00 FROM preguntas WHERE codigo = 'p06_dejas_llave_abierta'
UNION ALL
SELECT id, 'Casi siempre la dejo abierta', 40.00 FROM preguntas WHERE codigo = 'p06_dejas_llave_abierta';

-- P7
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p07_veces_inodoro_dia', '¿Cuántas veces al día utilizas el inodoro?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1-3 veces', 10.00 FROM preguntas WHERE codigo = 'p07_veces_inodoro_dia'
UNION ALL
SELECT id, '4-6 veces', 25.00 FROM preguntas WHERE codigo = 'p07_veces_inodoro_dia'
UNION ALL
SELECT id, 'Más de 6 veces', 45.00 FROM preguntas WHERE codigo = 'p07_veces_inodoro_dia';

-- P8
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p08_tipo_inodoro', '¿Tu inodoro es de descarga ahorradora o convencional?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Ahorradora', 5.00 FROM preguntas WHERE codigo = 'p08_tipo_inodoro'
UNION ALL
SELECT id, 'Convencional', 30.00 FROM preguntas WHERE codigo = 'p08_tipo_inodoro';

-- P9
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p09_veces_lavas_trastes_semana', '¿Cuántas veces por semana lavas los trastes?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1-2 veces', 10.00 FROM preguntas WHERE codigo = 'p09_veces_lavas_trastes_semana'
UNION ALL
SELECT id, '3-4 veces', 20.00 FROM preguntas WHERE codigo = 'p09_veces_lavas_trastes_semana'
UNION ALL
SELECT id, '5-7 veces', 35.00 FROM preguntas WHERE codigo = 'p09_veces_lavas_trastes_semana'
UNION ALL
SELECT id, 'Más de 7 veces', 50.00 FROM preguntas WHERE codigo = 'p09_veces_lavas_trastes_semana';

-- P10
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p10_enjabonas_con_llave', '¿Enjabonas con la llave abierta o cerrada?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Siempre cerrada', 5.00 FROM preguntas WHERE codigo = 'p10_enjabonas_con_llave'
UNION ALL
SELECT id, 'A veces abierta', 20.00 FROM preguntas WHERE codigo = 'p10_enjabonas_con_llave'
UNION ALL
SELECT id, 'Casi siempre abierta', 40.00 FROM preguntas WHERE codigo = 'p10_enjabonas_con_llave';

-- P11
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p11_veces_lavas_ropa_semana', '¿Cuántas veces lavas por semana tu ropa?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1-2 veces', 15.00 FROM preguntas WHERE codigo = 'p11_veces_lavas_ropa_semana'
UNION ALL
SELECT id, '3-4 veces', 35.00 FROM preguntas WHERE codigo = 'p11_veces_lavas_ropa_semana'
UNION ALL
SELECT id, '5-7 veces', 60.00 FROM preguntas WHERE codigo = 'p11_veces_lavas_ropa_semana'
UNION ALL
SELECT id, 'Más de 7 veces', 85.00 FROM preguntas WHERE codigo = 'p11_veces_lavas_ropa_semana';

-- P12
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p12_tipo_lavadora', '¿Tu lavadora es de alta eficiencia o convencional?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Alta eficiencia', 10.00 FROM preguntas WHERE codigo = 'p12_tipo_lavadora'
UNION ALL
SELECT id, 'Convencional', 40.00 FROM preguntas WHERE codigo = 'p12_tipo_lavadora';

-- P13
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p13_veces_trapear_semana', '¿Cuántas veces a la semana trapeas o limpias pisos haciendo uso de agua?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, '1-2 veces', 10.00 FROM preguntas WHERE codigo = 'p13_veces_trapear_semana'
UNION ALL
SELECT id, '3-4 veces', 20.00 FROM preguntas WHERE codigo = 'p13_veces_trapear_semana'
UNION ALL
SELECT id, '5-7 veces', 35.00 FROM preguntas WHERE codigo = 'p13_veces_trapear_semana'
UNION ALL
SELECT id, 'Más de 7 veces', 50.00 FROM preguntas WHERE codigo = 'p13_veces_trapear_semana';

-- P14
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p14_agua_embotellada', '¿Consumes agua embotellada regularmente?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Nunca', 5.00 FROM preguntas WHERE codigo = 'p14_agua_embotellada'
UNION ALL
SELECT id, 'Ocasionalmente', 20.00 FROM preguntas WHERE codigo = 'p14_agua_embotellada'
UNION ALL
SELECT id, 'Frecuentemente', 45.00 FROM preguntas WHERE codigo = 'p14_agua_embotellada'
UNION ALL
SELECT id, 'Siempre', 70.00 FROM preguntas WHERE codigo = 'p14_agua_embotellada';

-- P15
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p15_tienes_automovil', '¿Tienes automóvil propio?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'No', 0.00 FROM preguntas WHERE codigo = 'p15_tienes_automovil'
UNION ALL
SELECT id, 'Sí', 30.00 FROM preguntas WHERE codigo = 'p15_tienes_automovil';

-- P16
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p16_veces_lavas_auto_mes', '¿Cuántas veces al mes lo lavas?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'No aplica', 0.00 FROM preguntas WHERE codigo = 'p16_veces_lavas_auto_mes'
UNION ALL
SELECT id, '1-2 veces', 15.00 FROM preguntas WHERE codigo = 'p16_veces_lavas_auto_mes'
UNION ALL
SELECT id, '3-4 veces', 30.00 FROM preguntas WHERE codigo = 'p16_veces_lavas_auto_mes'
UNION ALL
SELECT id, 'Más de 4 veces', 50.00 FROM preguntas WHERE codigo = 'p16_veces_lavas_auto_mes';

-- P17
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p17_veces_consumes_carne_mes', '¿Aproximadamente cuántas veces por mes consumes carne para alimentarte?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Nunca (vegetariano/vegano)', 5.00 FROM preguntas WHERE codigo = 'p17_veces_consumes_carne_mes'
UNION ALL
SELECT id, '1-5 veces', 20.00 FROM preguntas WHERE codigo = 'p17_veces_consumes_carne_mes'
UNION ALL
SELECT id, '6-15 veces', 45.00 FROM preguntas WHERE codigo = 'p17_veces_consumes_carne_mes'
UNION ALL
SELECT id, 'Más de 15 veces', 75.00 FROM preguntas WHERE codigo = 'p17_veces_consumes_carne_mes';

-- P18
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p18_sales_fiesta', '¿Sales regularmente de fiesta?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'Nunca', 5.00 FROM preguntas WHERE codigo = 'p18_sales_fiesta'
UNION ALL
SELECT id, 'Ocasionalmente', 20.00 FROM preguntas WHERE codigo = 'p18_sales_fiesta'
UNION ALL
SELECT id, 'Frecuentemente', 40.00 FROM preguntas WHERE codigo = 'p18_sales_fiesta';

-- P19
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p19_consumes_bebidas_alcoholicas', '¿Consumes bebidas alcohólicas?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'No', 5.00 FROM preguntas WHERE codigo = 'p19_consumes_bebidas_alcoholicas'
UNION ALL
SELECT id, 'Sí', 30.00 FROM preguntas WHERE codigo = 'p19_consumes_bebidas_alcoholicas';

-- P20
WITH pregunta_insert AS (
    INSERT INTO preguntas (codigo, texto)
    VALUES ('p20_consumo_bebidas_por_reunion', '¿Cuál es tu consumo estimado de bebidas alcohólicas por reunión?')
    ON CONFLICT (codigo) DO UPDATE SET texto = EXCLUDED.texto
    RETURNING id
)
DELETE FROM opciones WHERE id_pregunta = (SELECT id FROM pregunta_insert);
INSERT INTO opciones (id_pregunta, texto_opcion, valor_consumo)
SELECT id, 'No aplica', 0.00 FROM preguntas WHERE codigo = 'p20_consumo_bebidas_por_reunion'
UNION ALL
SELECT id, '1-2 bebidas', 15.00 FROM preguntas WHERE codigo = 'p20_consumo_bebidas_por_reunion'
UNION ALL
SELECT id, '3-4 bebidas', 35.00 FROM preguntas WHERE codigo = 'p20_consumo_bebidas_por_reunion'
UNION ALL
SELECT id, 'Más de 4 bebidas', 60.00 FROM preguntas WHERE codigo = 'p20_consumo_bebidas_por_reunion';

COMMIT;

