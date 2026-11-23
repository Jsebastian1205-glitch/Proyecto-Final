-- =====================================================================
-- BuildZone - Script 02: datos completos de la base "buildzone"
-- Motor: MariaDB 10.4 (XAMPP) / MySQL 8+
--
-- Llena TODAS las tablas con la informacion del proyecto:
--   categoria, marca, producto ......... los 84 productos del catalogo
--   especificacion ..................... ficha tecnica + puntajes del comparador
--   fuente_precio, precio .............. tiendas colombianas y precio de cada producto
--   usuario ............................ autor del blog y de los duelos de ejemplo
--   noticia ............................ los 6 articulos del blog
--   comparacion, detalle_comparacion ... duelos de ejemplo
--   plan_suscripcion ................... los 3 planes (si la API aun no los creo)
--   usuario_cuenta, suscripcion ........ 5 cuentas de prueba con sus suscripciones
--
-- Orden: 1) 01_usuarios_suscripciones.sql   2) este script.
-- Es seguro ejecutarlo varias veces: NO duplica ni borra nada. Si un dato ya
-- existe (mismo nombre, mismo producto + atributo, mismo correo...) lo omite.
-- Reutiliza las categorias y marcas que ya tenga la base (por ejemplo
-- 'Procesadores' o 'Procesador').
-- Recomendado: hacer una copia antes (phpMyAdmin > Exportar).
--
-- Cuentas de prueba (contrasena de todas: Prueba1234):
--   laura.gomez@buildzone.com    Premium activo
--   andres.rojas@buildzone.com   Premium Anual activo
--   camila.diaz@buildzone.com    Premium vencido
--   santiago.mora@buildzone.com  Premium cancelado
--   valentina.ruiz@buildzone.com cuenta INACTIVA, sin suscripcion
-- El administrador (admin@buildzone.com / Admin1234) lo crea la API al arrancar.
--
-- Precios en pesos colombianos (COP):
--   * 45 productos agregados el 18/11/2026: precios reales consultados ese dia
--     en tiendas colombianas (Mercado Libre, Speed Logic, Falabella...), con
--     la URL de la pagina en precio.url_producto. Cambian con frecuencia.
--   * 39 productos originales: precio de REFERENCIA estimado por el equipo
--     (fuente "BuildZone (precio de referencia)").
-- Las fichas tecnicas son datos de referencia del fabricante.
-- =====================================================================

USE buildzone;
SET NAMES utf8mb4;
START TRANSACTION;

-- ---------------------------------------------------------------------
-- 1. Categorias (se reutiliza la existente si ya hay una parecida)
-- ---------------------------------------------------------------------
INSERT INTO categoria (nombre, descripcion)
SELECT 'Procesador', 'Procesadores (CPU) de escritorio Intel y AMD' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Proces%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Tarjeta Grafica', 'Tarjetas graficas (GPU) dedicadas' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Tarjeta%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Memoria RAM', 'Modulos de memoria DDR4 y DDR5' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Memoria%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Almacenamiento', 'Unidades SSD NVMe y discos duros' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Almacen%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Placa Madre', 'Placas base para Intel y AMD' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Placa%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Refrigeracion', 'Disipadores por aire y refrigeracion liquida' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Refrig%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Accesorio', 'Perifericos: mouse, teclados y audifonos' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Accesorio%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Fuente de Poder', 'Fuentes de poder certificadas 80 PLUS' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Fuente%');
INSERT INTO categoria (nombre, descripcion)
SELECT 'Monitor', 'Monitores gamer' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM categoria WHERE nombre LIKE 'Monitor%');

-- ---------------------------------------------------------------------
-- 2. Marcas
-- ---------------------------------------------------------------------
INSERT INTO marca (nombre, descripcion)
SELECT 'Intel', 'Fabricante estadounidense de procesadores.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Intel');
INSERT INTO marca (nombre, descripcion)
SELECT 'AMD', 'Fabricante de procesadores Ryzen y tarjetas graficas Radeon.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'AMD');
INSERT INTO marca (nombre, descripcion)
SELECT 'NVIDIA', 'Fabricante de tarjetas graficas GeForce RTX.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'NVIDIA');
INSERT INTO marca (nombre, descripcion)
SELECT 'Kingston', 'Memorias RAM y unidades de almacenamiento.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Kingston');
INSERT INTO marca (nombre, descripcion)
SELECT 'Corsair', 'Memorias, fuentes, refrigeracion y perifericos.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Corsair');
INSERT INTO marca (nombre, descripcion)
SELECT 'G.Skill', 'Memorias RAM de alto rendimiento.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'G.Skill');
INSERT INTO marca (nombre, descripcion)
SELECT 'Samsung', 'Unidades SSD y monitores.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Samsung');
INSERT INTO marca (nombre, descripcion)
SELECT 'WD', 'Western Digital: discos duros y unidades SSD.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'WD');
INSERT INTO marca (nombre, descripcion)
SELECT 'Seagate', 'Discos duros y almacenamiento.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Seagate');
INSERT INTO marca (nombre, descripcion)
SELECT 'ASUS', 'Placas madre, monitores y componentes.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'ASUS');
INSERT INTO marca (nombre, descripcion)
SELECT 'MSI', 'Placas madre, tarjetas graficas y fuentes.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'MSI');
INSERT INTO marca (nombre, descripcion)
SELECT 'Gigabyte', 'Placas madre y tarjetas graficas.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Gigabyte');
INSERT INTO marca (nombre, descripcion)
SELECT 'ASRock', 'Placas madre.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'ASRock');
INSERT INTO marca (nombre, descripcion)
SELECT 'DeepCool', 'Disipadores y refrigeracion.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'DeepCool');
INSERT INTO marca (nombre, descripcion)
SELECT 'Noctua', 'Disipadores y ventiladores de bajo ruido.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Noctua');
INSERT INTO marca (nombre, descripcion)
SELECT 'Arctic', 'Refrigeracion liquida y por aire.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Arctic');
INSERT INTO marca (nombre, descripcion)
SELECT 'Logitech', 'Perifericos: mouse, teclados y audifonos.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Logitech');
INSERT INTO marca (nombre, descripcion)
SELECT 'Razer', 'Perifericos gamer.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Razer');
INSERT INTO marca (nombre, descripcion)
SELECT 'Redragon', 'Perifericos gamer economicos.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Redragon');
INSERT INTO marca (nombre, descripcion)
SELECT 'HyperX', 'Audifonos y perifericos gamer.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'HyperX');
INSERT INTO marca (nombre, descripcion)
SELECT 'EVGA', 'Fuentes de poder.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'EVGA');
INSERT INTO marca (nombre, descripcion)
SELECT 'TeamGroup', 'Memorias RAM T-Force.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'TeamGroup');
INSERT INTO marca (nombre, descripcion)
SELECT 'Crucial', 'Unidades SSD y memorias (Micron).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Crucial');
INSERT INTO marca (nombre, descripcion)
SELECT 'Thermalright', 'Disipadores por aire.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Thermalright');
INSERT INTO marca (nombre, descripcion)
SELECT 'Cooler Master', 'Refrigeracion, fuentes y gabinetes.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Cooler Master');
INSERT INTO marca (nombre, descripcion)
SELECT 'NZXT', 'Refrigeracion liquida y gabinetes.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'NZXT');
INSERT INTO marca (nombre, descripcion)
SELECT 'Seasonic', 'Fuentes de poder de alta calidad.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Seasonic');
INSERT INTO marca (nombre, descripcion)
SELECT 'LG', 'Monitores UltraGear.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'LG');
INSERT INTO marca (nombre, descripcion)
SELECT 'AOC', 'Monitores gamer.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'AOC');
INSERT INTO marca (nombre, descripcion)
SELECT 'XPG', 'Linea gamer de ADATA: memorias y SSD.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'XPG');
-- Completa la descripcion de las marcas que se crearon sin ella
UPDATE marca SET descripcion = 'Fabricante estadounidense de procesadores.' WHERE nombre = 'Intel' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Fabricante de procesadores Ryzen y tarjetas graficas Radeon.' WHERE nombre = 'AMD' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Fabricante de tarjetas graficas GeForce RTX.' WHERE nombre = 'NVIDIA' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Memorias RAM y unidades de almacenamiento.' WHERE nombre = 'Kingston' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Memorias, fuentes, refrigeracion y perifericos.' WHERE nombre = 'Corsair' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Memorias RAM de alto rendimiento.' WHERE nombre = 'G.Skill' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Unidades SSD y monitores.' WHERE nombre = 'Samsung' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Western Digital: discos duros y unidades SSD.' WHERE nombre = 'WD' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Discos duros y almacenamiento.' WHERE nombre = 'Seagate' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Placas madre, monitores y componentes.' WHERE nombre = 'ASUS' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Placas madre, tarjetas graficas y fuentes.' WHERE nombre = 'MSI' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Placas madre y tarjetas graficas.' WHERE nombre = 'Gigabyte' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Placas madre.' WHERE nombre = 'ASRock' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Disipadores y refrigeracion.' WHERE nombre = 'DeepCool' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Disipadores y ventiladores de bajo ruido.' WHERE nombre = 'Noctua' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Refrigeracion liquida y por aire.' WHERE nombre = 'Arctic' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Perifericos: mouse, teclados y audifonos.' WHERE nombre = 'Logitech' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Perifericos gamer.' WHERE nombre = 'Razer' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Perifericos gamer economicos.' WHERE nombre = 'Redragon' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Audifonos y perifericos gamer.' WHERE nombre = 'HyperX' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Fuentes de poder.' WHERE nombre = 'EVGA' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Memorias RAM T-Force.' WHERE nombre = 'TeamGroup' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Unidades SSD y memorias (Micron).' WHERE nombre = 'Crucial' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Disipadores por aire.' WHERE nombre = 'Thermalright' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Refrigeracion, fuentes y gabinetes.' WHERE nombre = 'Cooler Master' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Refrigeracion liquida y gabinetes.' WHERE nombre = 'NZXT' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Fuentes de poder de alta calidad.' WHERE nombre = 'Seasonic' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Monitores UltraGear.' WHERE nombre = 'LG' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Monitores gamer.' WHERE nombre = 'AOC' AND (descripcion IS NULL OR descripcion = '');
UPDATE marca SET descripcion = 'Linea gamer de ADATA: memorias y SSD.' WHERE nombre = 'XPG' AND (descripcion IS NULL OR descripcion = '');

-- ---------------------------------------------------------------------
-- 3. Productos (84). El front-end los enlaza con su ficha por marca + nombre,
--    por eso los nombres deben quedar exactamente asi.
-- ---------------------------------------------------------------------
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Core i5-14600K', 'Procesador Intel Core i5-14600K: Núcleos: 14 (6 de rendimiento + 8 de eficiencia); Hilos: 20; Frecuencia máxima: 5,3 GHz.', NULL
FROM marca m WHERE m.nombre = 'Intel'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Core i5-14600K' OR x.nombre LIKE '% Core i5-14600K'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Core i7-14700K', 'Procesador Intel Core i7-14700K: Núcleos: 20 (8 de rendimiento + 12 de eficiencia); Hilos: 28; Frecuencia máxima: 5,6 GHz.', NULL
FROM marca m WHERE m.nombre = 'Intel'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Core i7-14700K' OR x.nombre LIKE '% Core i7-14700K'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Core i9-14900K', 'Procesador Intel Core i9-14900K: Núcleos: 24 (8 de rendimiento + 16 de eficiencia); Hilos: 32; Frecuencia máxima: 6,0 GHz.', NULL
FROM marca m WHERE m.nombre = 'Intel'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Core i9-14900K' OR x.nombre LIKE '% Core i9-14900K'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 5 7600X', 'Procesador AMD Ryzen 5 7600X: Núcleos: 6; Hilos: 12; Frecuencia máxima: 5,3 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 5 7600X' OR x.nombre LIKE '% Ryzen 5 7600X'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 7 7800X3D', 'Procesador AMD Ryzen 7 7800X3D: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,0 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 7 7800X3D' OR x.nombre LIKE '% Ryzen 7 7800X3D'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 7 7700X', 'Procesador AMD Ryzen 7 7700X: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,4 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 7 7700X' OR x.nombre LIKE '% Ryzen 7 7700X'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 7 9800X3D', 'Procesador AMD Ryzen 7 9800X3D: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,2 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 7 9800X3D' OR x.nombre LIKE '% Ryzen 7 9800X3D'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 5 9600X', 'Procesador AMD Ryzen 5 9600X: Núcleos: 6; Hilos: 12; Frecuencia máxima: 5,4 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 5 9600X' OR x.nombre LIKE '% Ryzen 5 9600X'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Core Ultra 7 265K', 'Procesador Intel Core Ultra 7 265K: Núcleos: 20 (8 de rendimiento + 12 de eficiencia); Hilos: 20; Frecuencia máxima: 5,5 GHz.', NULL
FROM marca m WHERE m.nombre = 'Intel'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Core Ultra 7 265K' OR x.nombre LIKE '% Core Ultra 7 265K'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Ryzen 5 5600', 'Procesador AMD Ryzen 5 5600: Núcleos: 6; Hilos: 12; Frecuencia máxima: 4,4 GHz.', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Ryzen 5 5600' OR x.nombre LIKE '% Ryzen 5 5600'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Proces%' ORDER BY id_categoria LIMIT 1), 'Core i5-12400F', 'Procesador Intel Core i5-12400F: Núcleos: 6 (solo de rendimiento); Hilos: 12; Frecuencia máxima: 4,4 GHz.', NULL
FROM marca m WHERE m.nombre = 'Intel'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Core i5-12400F' OR x.nombre LIKE '% Core i5-12400F'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 4060', 'Tarjeta gráfica NVIDIA RTX 4060: Memoria: 8 GB GDDR6; Bus de memoria: 128 bits; Núcleos CUDA: 3.072.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 4060' OR x.nombre LIKE '% RTX 4060'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 4070', 'Tarjeta gráfica NVIDIA RTX 4070: Memoria: 12 GB GDDR6X; Bus de memoria: 192 bits; Núcleos CUDA: 5.888.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 4070' OR x.nombre LIKE '% RTX 4070'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 4070 Ti', 'Tarjeta gráfica NVIDIA RTX 4070 Ti: Memoria: 12 GB GDDR6X; Bus de memoria: 192 bits; Núcleos CUDA: 7.680.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 4070 Ti' OR x.nombre LIKE '% RTX 4070 Ti'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'Radeon RX 7600', 'Tarjeta gráfica AMD Radeon RX 7600: Memoria: 8 GB GDDR6; Bus de memoria: 128 bits; Unidades de cómputo: 32 (2.048 procesadores).', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Radeon RX 7600' OR x.nombre LIKE '% Radeon RX 7600'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'Radeon RX 7800 XT', 'Tarjeta gráfica AMD Radeon RX 7800 XT: Memoria: 16 GB GDDR6; Bus de memoria: 256 bits; Unidades de cómputo: 60 (3.840 procesadores).', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Radeon RX 7800 XT' OR x.nombre LIKE '% Radeon RX 7800 XT'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 5060 Ti 16GB', 'Tarjeta gráfica NVIDIA RTX 5060 Ti 16GB: Memoria: 16 GB GDDR7; Bus de memoria: 128 bits; Núcleos CUDA: 4.608.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 5060 Ti 16GB' OR x.nombre LIKE '% RTX 5060 Ti 16GB'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 5070', 'Tarjeta gráfica NVIDIA RTX 5070: Memoria: 12 GB GDDR7; Bus de memoria: 192 bits; Núcleos CUDA: 6.144.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 5070' OR x.nombre LIKE '% RTX 5070'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'Radeon RX 9070 XT', 'Tarjeta gráfica AMD Radeon RX 9070 XT: Memoria: 16 GB GDDR6; Bus de memoria: 256 bits; Unidades de cómputo: 64 (4.096 procesadores).', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Radeon RX 9070 XT' OR x.nombre LIKE '% Radeon RX 9070 XT'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'RTX 5060 8GB', 'Tarjeta gráfica NVIDIA RTX 5060 8GB: Memoria: 8 GB GDDR7; Bus de memoria: 128 bits; Núcleos CUDA: 3.840.', NULL
FROM marca m WHERE m.nombre = 'NVIDIA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RTX 5060 8GB' OR x.nombre LIKE '% RTX 5060 8GB'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Tarjeta%' ORDER BY id_categoria LIMIT 1), 'Radeon RX 9060 XT 16GB', 'Tarjeta gráfica AMD Radeon RX 9060 XT 16GB: Memoria: 16 GB GDDR6; Bus de memoria: 128 bits; Unidades de cómputo: 32 (2.048 procesadores).', NULL
FROM marca m WHERE m.nombre = 'AMD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Radeon RX 9060 XT 16GB' OR x.nombre LIKE '% Radeon RX 9060 XT 16GB'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Fury Beast 16GB 3200MHz', 'Memoria RAM Kingston Fury Beast 16GB 3200MHz: Tipo: DDR4; Capacidad: 16 GB (1 × 16 GB); Velocidad: 3.200 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Kingston'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Fury Beast 16GB 3200MHz' OR x.nombre LIKE '% Fury Beast 16GB 3200MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Vengeance 32GB 6000MHz', 'Memoria RAM Corsair Vengeance 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Vengeance 32GB 6000MHz' OR x.nombre LIKE '% Vengeance 32GB 6000MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Trident Z5 32GB 6400MHz', 'Memoria RAM G.Skill Trident Z5 32GB 6400MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.400 MT/s.', NULL
FROM marca m WHERE m.nombre = 'G.Skill'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Trident Z5 32GB 6400MHz' OR x.nombre LIKE '% Trident Z5 32GB 6400MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Dominator Platinum 64GB 5600MHz', 'Memoria RAM Corsair Dominator Platinum 64GB 5600MHz: Tipo: DDR5; Capacidad: 64 GB (2 × 32 GB); Velocidad: 5.600 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Dominator Platinum 64GB 5600MHz' OR x.nombre LIKE '% Dominator Platinum 64GB 5600MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Fury Beast DDR5 32GB 6000MHz', 'Memoria RAM Kingston Fury Beast DDR5 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Kingston'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Fury Beast DDR5 32GB 6000MHz' OR x.nombre LIKE '% Fury Beast DDR5 32GB 6000MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'T-Force Delta RGB 32GB 6000MHz', 'Memoria RAM TeamGroup T-Force Delta RGB 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.', NULL
FROM marca m WHERE m.nombre = 'TeamGroup'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'T-Force Delta RGB 32GB 6000MHz' OR x.nombre LIKE '% T-Force Delta RGB 32GB 6000MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Vengeance LPX 16GB DDR4 3200MHz', 'Memoria RAM Corsair Vengeance LPX 16GB DDR4 3200MHz: Tipo: DDR4; Capacidad: 16 GB (2 × 8 GB); Velocidad: 3.200 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Vengeance LPX 16GB DDR4 3200MHz' OR x.nombre LIKE '% Vengeance LPX 16GB DDR4 3200MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Fury Beast DDR4 32GB 3200MHz', 'Memoria RAM Kingston Fury Beast DDR4 32GB 3200MHz: Tipo: DDR4; Capacidad: 32 GB (1 × 32 GB); Velocidad: 3.200 MT/s.', NULL
FROM marca m WHERE m.nombre = 'Kingston'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Fury Beast DDR4 32GB 3200MHz' OR x.nombre LIKE '% Fury Beast DDR4 32GB 3200MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Memoria%' ORDER BY id_categoria LIMIT 1), 'Lancer Blade DDR5 32GB 6000MHz', 'Memoria RAM XPG Lancer Blade DDR5 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (1 × 32 GB); Velocidad: 6.000 MT/s.', NULL
FROM marca m WHERE m.nombre = 'XPG'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Lancer Blade DDR5 32GB 6000MHz' OR x.nombre LIKE '% Lancer Blade DDR5 32GB 6000MHz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), '990 PRO 1TB NVMe', 'Unidad de almacenamiento Samsung 990 PRO 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'Samsung'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = '990 PRO 1TB NVMe' OR x.nombre LIKE '% 990 PRO 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'Black SN770 1TB NVMe', 'Unidad de almacenamiento WD Black SN770 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'WD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Black SN770 1TB NVMe' OR x.nombre LIKE '% Black SN770 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'NV2 1TB NVMe', 'Unidad de almacenamiento Kingston NV2 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'Kingston'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'NV2 1TB NVMe' OR x.nombre LIKE '% NV2 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'BarraCuda 2TB HDD', 'Unidad de almacenamiento Seagate BarraCuda 2TB HDD: Tipo: Disco duro (HDD); Capacidad: 2 TB; Interfaz: SATA 6 Gb/s.', NULL
FROM marca m WHERE m.nombre = 'Seagate'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'BarraCuda 2TB HDD' OR x.nombre LIKE '% BarraCuda 2TB HDD'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), '990 EVO Plus 1TB NVMe', 'Unidad de almacenamiento Samsung 990 EVO Plus 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4 / 5.0 x2.', NULL
FROM marca m WHERE m.nombre = 'Samsung'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = '990 EVO Plus 1TB NVMe' OR x.nombre LIKE '% 990 EVO Plus 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'P3 Plus 1TB NVMe', 'Unidad de almacenamiento Crucial P3 Plus 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'Crucial'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'P3 Plus 1TB NVMe' OR x.nombre LIKE '% P3 Plus 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'NV3 2TB NVMe', 'Unidad de almacenamiento Kingston NV3 2TB NVMe: Tipo: SSD NVMe; Capacidad: 2 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'Kingston'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'NV3 2TB NVMe' OR x.nombre LIKE '% NV3 2TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), 'Blue SN580 1TB NVMe', 'Unidad de almacenamiento WD Blue SN580 1TB NVMe: Tipo: SSD M.2 2280 NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.', NULL
FROM marca m WHERE m.nombre = 'WD'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Blue SN580 1TB NVMe' OR x.nombre LIKE '% Blue SN580 1TB NVMe'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Almacen%' ORDER BY id_categoria LIMIT 1), '870 EVO 1TB SATA', 'Unidad de almacenamiento Samsung 870 EVO 1TB SATA: Tipo: SSD 2,5" SATA; Capacidad: 1 TB; Interfaz: SATA III (6 Gb/s).', NULL
FROM marca m WHERE m.nombre = 'Samsung'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = '870 EVO 1TB SATA' OR x.nombre LIKE '% 870 EVO 1TB SATA'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'TUF Gaming B760M-Plus WiFi', 'Placa madre ASUS TUF Gaming B760M-Plus WiFi: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel B760; Formato: Micro-ATX.', NULL
FROM marca m WHERE m.nombre = 'ASUS'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'TUF Gaming B760M-Plus WiFi' OR x.nombre LIKE '% TUF Gaming B760M-Plus WiFi'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'MAG Z790 Tomahawk WiFi', 'Placa madre MSI MAG Z790 Tomahawk WiFi: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel Z790; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'MSI'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'MAG Z790 Tomahawk WiFi' OR x.nombre LIKE '% MAG Z790 Tomahawk WiFi'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'B650 Aorus Elite AX', 'Placa madre Gigabyte B650 Aorus Elite AX: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'Gigabyte'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'B650 Aorus Elite AX' OR x.nombre LIKE '% B650 Aorus Elite AX'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'X670E Steel Legend', 'Placa madre ASRock X670E Steel Legend: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD X670E; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'ASRock'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'X670E Steel Legend' OR x.nombre LIKE '% X670E Steel Legend'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'MAG B650 Tomahawk WiFi', 'Placa madre MSI MAG B650 Tomahawk WiFi: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'MSI'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'MAG B650 Tomahawk WiFi' OR x.nombre LIKE '% MAG B650 Tomahawk WiFi'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'TUF Gaming B650-Plus WiFi', 'Placa madre ASUS TUF Gaming B650-Plus WiFi: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'ASUS'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'TUF Gaming B650-Plus WiFi' OR x.nombre LIKE '% TUF Gaming B650-Plus WiFi'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'B760M DS3H DDR4', 'Placa madre Gigabyte B760M DS3H DDR4: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel B760; Formato: Micro-ATX.', NULL
FROM marca m WHERE m.nombre = 'Gigabyte'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'B760M DS3H DDR4' OR x.nombre LIKE '% B760M DS3H DDR4'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'B850 Gaming Plus WiFi', 'Placa madre MSI B850 Gaming Plus WiFi: Socket: AM5; Chipset: AMD B850; Formato: ATX.', NULL
FROM marca m WHERE m.nombre = 'MSI'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'B850 Gaming Plus WiFi' OR x.nombre LIKE '% B850 Gaming Plus WiFi'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Placa%' ORDER BY id_categoria LIMIT 1), 'Prime B550M-A WiFi II', 'Placa madre ASUS Prime B550M-A WiFi II: Socket: AM4; Chipset: AMD B550; Formato: Micro-ATX.', NULL
FROM marca m WHERE m.nombre = 'ASUS'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Prime B550M-A WiFi II' OR x.nombre LIKE '% Prime B550M-A WiFi II'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'AK400 (aire)', 'Refrigeración DeepCool AK400 (aire): Tipo: Disipador por aire (una torre); Ventiladores: 1 × 120 mm; Heatpipes: 4.', NULL
FROM marca m WHERE m.nombre = 'DeepCool'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'AK400 (aire)' OR x.nombre LIKE '% AK400 (aire)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'NH-D15 (aire)', 'Refrigeración Noctua NH-D15 (aire): Tipo: Disipador por aire (doble torre); Ventiladores: 2 × 140 mm; Heatpipes: 6.', NULL
FROM marca m WHERE m.nombre = 'Noctua'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'NH-D15 (aire)' OR x.nombre LIKE '% NH-D15 (aire)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'iCUE H100i Elite 240mm (líquida)', 'Refrigeración Corsair iCUE H100i Elite 240mm (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 240 mm; Ventiladores: 2 × 120 mm.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'iCUE H100i Elite 240mm (líquida)' OR x.nombre LIKE '% iCUE H100i Elite 240mm (líquida)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Liquid Freezer III 360mm (líquida)', 'Refrigeración Arctic Liquid Freezer III 360mm (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 360 mm; Ventiladores: 3 × 120 mm.', NULL
FROM marca m WHERE m.nombre = 'Arctic'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Liquid Freezer III 360mm (líquida)' OR x.nombre LIKE '% Liquid Freezer III 360mm (líquida)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Peerless Assassin 120 SE (aire)', 'Refrigeración Thermalright Peerless Assassin 120 SE (aire): Tipo: Disipador por aire (doble torre); Ventiladores: 2 × 120 mm; Heatpipes: 6.', NULL
FROM marca m WHERE m.nombre = 'Thermalright'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Peerless Assassin 120 SE (aire)' OR x.nombre LIKE '% Peerless Assassin 120 SE (aire)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Hyper 212 Black Edition (aire)', 'Refrigeración Cooler Master Hyper 212 Black Edition (aire): Tipo: Disipador por aire (una torre); Ventiladores: 1 × 120 mm; Heatpipes: 4 de contacto directo.', NULL
FROM marca m WHERE m.nombre = 'Cooler Master'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Hyper 212 Black Edition (aire)' OR x.nombre LIKE '% Hyper 212 Black Edition (aire)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Kraken 240 (líquida)', 'Refrigeración NZXT Kraken 240 (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 240 mm; Ventiladores: 2 × 120 mm.', NULL
FROM marca m WHERE m.nombre = 'NZXT'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Kraken 240 (líquida)' OR x.nombre LIKE '% Kraken 240 (líquida)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Phantom Spirit 120 SE (aire)', 'Refrigeración Thermalright Phantom Spirit 120 SE (aire): Tipo: Disipador por aire de doble torre; Tubos de calor: 7 × 6 mm; Ventiladores: 2 × 120 mm TL-C12B V2 (1.500 RPM).', NULL
FROM marca m WHERE m.nombre = 'Thermalright'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Phantom Spirit 120 SE (aire)' OR x.nombre LIKE '% Phantom Spirit 120 SE (aire)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Refrig%' ORDER BY id_categoria LIMIT 1), 'Liquid Freezer III Pro 240mm (líquida)', 'Refrigeración Arctic Liquid Freezer III Pro 240mm (líquida): Tipo: Refrigeración líquida AIO; Radiador: 240 mm (38 mm de grosor); Ventiladores: 2 × 120 mm P12 Pro.', NULL
FROM marca m WHERE m.nombre = 'Arctic'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Liquid Freezer III Pro 240mm (líquida)' OR x.nombre LIKE '% Liquid Freezer III Pro 240mm (líquida)'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Mouse G502 X', 'Accesorio Logitech Mouse G502 X: Tipo: Mouse gamer con cable; Sensor: HERO 25K; Resolución: hasta 25.600 DPI.', NULL
FROM marca m WHERE m.nombre = 'Logitech'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Mouse G502 X' OR x.nombre LIKE '% Mouse G502 X'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Mouse DeathAdder V3', 'Accesorio Razer Mouse DeathAdder V3: Tipo: Mouse gamer con cable; Sensor: Focus Pro 30K; Resolución: hasta 30.000 DPI.', NULL
FROM marca m WHERE m.nombre = 'Razer'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Mouse DeathAdder V3' OR x.nombre LIKE '% Mouse DeathAdder V3'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Teclado Kumara K552', 'Accesorio Redragon Teclado Kumara K552: Tipo: Teclado mecánico; Formato: TKL (87 teclas, sin teclado numérico); Interruptores: Mecánicos Outemu.', NULL
FROM marca m WHERE m.nombre = 'Redragon'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Teclado Kumara K552' OR x.nombre LIKE '% Teclado Kumara K552'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Audífonos Cloud III', 'Accesorio HyperX Audífonos Cloud III: Tipo: Audífonos gamer con cable; Parlantes: 53 mm; Micrófono: Desmontable con cancelación de ruido.', NULL
FROM marca m WHERE m.nombre = 'HyperX'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Audífonos Cloud III' OR x.nombre LIKE '% Audífonos Cloud III'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Mouse G Pro X Superlight 2', 'Accesorio Logitech Mouse G Pro X Superlight 2: Tipo: Mouse gamer inalámbrico (LIGHTSPEED); Sensor: HERO 2; Resolución: hasta 32.000 DPI.', NULL
FROM marca m WHERE m.nombre = 'Logitech'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Mouse G Pro X Superlight 2' OR x.nombre LIKE '% Mouse G Pro X Superlight 2'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Teclado Alloy Origins Core', 'Accesorio HyperX Teclado Alloy Origins Core: Tipo: Teclado mecánico; Formato: TKL (87 teclas, sin teclado numérico); Interruptores: Mecánicos HyperX.', NULL
FROM marca m WHERE m.nombre = 'HyperX'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Teclado Alloy Origins Core' OR x.nombre LIKE '% Teclado Alloy Origins Core'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Audífonos BlackShark V2 X', 'Accesorio Razer Audífonos BlackShark V2 X: Tipo: Audífonos gamer con cable; Parlantes: 50 mm; Micrófono: Cardioide.', NULL
FROM marca m WHERE m.nombre = 'Razer'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Audífonos BlackShark V2 X' OR x.nombre LIKE '% Audífonos BlackShark V2 X'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Mouse G305 Lightspeed', 'Accesorio Logitech Mouse G305 Lightspeed: Tipo: Mouse inalámbrico; Sensor: HERO (12.000 DPI); Conexión: LIGHTSPEED 2,4 GHz.', NULL
FROM marca m WHERE m.nombre = 'Logitech'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Mouse G305 Lightspeed' OR x.nombre LIKE '% Mouse G305 Lightspeed'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Accesorio%' ORDER BY id_categoria LIMIT 1), 'Teclado K617 Fizz 60%', 'Accesorio Redragon Teclado K617 Fizz 60%: Tipo: Teclado mecánico 60 % (61 teclas); Switches: Rojos lineales, hot-swap; Iluminación: RGB.', NULL
FROM marca m WHERE m.nombre = 'Redragon'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Teclado K617 Fizz 60%' OR x.nombre LIKE '% Teclado K617 Fizz 60%'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'RM750e 750W 80+ Gold', 'Fuente de poder Corsair RM750e 750W 80+ Gold: Potencia: 750 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RM750e 750W 80+ Gold' OR x.nombre LIKE '% RM750e 750W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), '600 BR 600W 80+ Bronze', 'Fuente de poder EVGA 600 BR 600W 80+ Bronze: Potencia: 600 W; Certificación: 80 PLUS Bronze; Cables: No modular.', NULL
FROM marca m WHERE m.nombre = 'EVGA'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = '600 BR 600W 80+ Bronze' OR x.nombre LIKE '% 600 BR 600W 80+ Bronze'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'Focus GX-850 850W 80+ Gold', 'Fuente de poder Seasonic Focus GX-850 850W 80+ Gold: Potencia: 850 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.', NULL
FROM marca m WHERE m.nombre = 'Seasonic'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Focus GX-850 850W 80+ Gold' OR x.nombre LIKE '% Focus GX-850 850W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'MPG A1000G 1000W 80+ Gold', 'Fuente de poder MSI MPG A1000G 1000W 80+ Gold: Potencia: 1.000 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.', NULL
FROM marca m WHERE m.nombre = 'MSI'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'MPG A1000G 1000W 80+ Gold' OR x.nombre LIKE '% MPG A1000G 1000W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'RM850x 850W 80+ Gold', 'Fuente de poder Corsair RM850x 850W 80+ Gold: Potencia: 850 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RM850x 850W 80+ Gold' OR x.nombre LIKE '% RM850x 850W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'MAG A650BN 650W 80+ Bronze', 'Fuente de poder MSI MAG A650BN 650W 80+ Bronze: Potencia: 650 W; Certificación: 80 PLUS Bronze; Cables: No modular.', NULL
FROM marca m WHERE m.nombre = 'MSI'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'MAG A650BN 650W 80+ Bronze' OR x.nombre LIKE '% MAG A650BN 650W 80+ Bronze'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'P650G 650W 80+ Gold', 'Fuente de poder Gigabyte P650G 650W 80+ Gold: Potencia: 650 W; Certificación: 80 PLUS Gold; Cables: No modular.', NULL
FROM marca m WHERE m.nombre = 'Gigabyte'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'P650G 650W 80+ Gold' OR x.nombre LIKE '% P650G 650W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'CX650 650W 80+ Bronze', 'Fuente de poder Corsair CX650 650W 80+ Bronze: Potencia: 650 W; Certificación: 80 PLUS Bronze (hasta 88 %); Modular: No.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'CX650 650W 80+ Bronze' OR x.nombre LIKE '% CX650 650W 80+ Bronze'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Fuente%' ORDER BY id_categoria LIMIT 1), 'RM750x 750W 80+ Gold', 'Fuente de poder Corsair RM750x 750W 80+ Gold: Potencia: 750 W; Certificación: 80 PLUS Gold; Modular: Totalmente modular.', NULL
FROM marca m WHERE m.nombre = 'Corsair'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'RM750x 750W 80+ Gold' OR x.nombre LIKE '% RM750x 750W 80+ Gold'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'UltraGear 27" QHD 180Hz', 'Monitor LG UltraGear 27" QHD 180Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: Nano IPS.', NULL
FROM marca m WHERE m.nombre = 'LG'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'UltraGear 27" QHD 180Hz' OR x.nombre LIKE '% UltraGear 27" QHD 180Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'Odyssey G5 32" QHD 165Hz', 'Monitor Samsung Odyssey G5 32" QHD 165Hz: Tamaño: 32 pulgadas (curvo 1000R); Resolución: QHD 2560 × 1440; Panel: VA.', NULL
FROM marca m WHERE m.nombre = 'Samsung'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Odyssey G5 32" QHD 165Hz' OR x.nombre LIKE '% Odyssey G5 32" QHD 165Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'TUF VG249Q 24" FHD 165Hz', 'Monitor ASUS TUF VG249Q 24" FHD 165Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.', NULL
FROM marca m WHERE m.nombre = 'ASUS'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'TUF VG249Q 24" FHD 165Hz' OR x.nombre LIKE '% TUF VG249Q 24" FHD 165Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'Q27G3XMN 27" QHD Mini-LED', 'Monitor AOC Q27G3XMN 27" QHD Mini-LED: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: VA Mini-LED (336 zonas).', NULL
FROM marca m WHERE m.nombre = 'AOC'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Q27G3XMN 27" QHD Mini-LED' OR x.nombre LIKE '% Q27G3XMN 27" QHD Mini-LED'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'Odyssey G4 27" FHD 240Hz', 'Monitor Samsung Odyssey G4 27" FHD 240Hz: Tamaño: 27 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.', NULL
FROM marca m WHERE m.nombre = 'Samsung'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'Odyssey G4 27" FHD 240Hz' OR x.nombre LIKE '% Odyssey G4 27" FHD 240Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'UltraGear 24GS60F 24" FHD 180Hz', 'Monitor LG UltraGear 24GS60F 24" FHD 180Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.', NULL
FROM marca m WHERE m.nombre = 'LG'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'UltraGear 24GS60F 24" FHD 180Hz' OR x.nombre LIKE '% UltraGear 24GS60F 24" FHD 180Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'TUF VG27AQ1A 27" QHD 170Hz', 'Monitor ASUS TUF VG27AQ1A 27" QHD 170Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: IPS.', NULL
FROM marca m WHERE m.nombre = 'ASUS'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'TUF VG27AQ1A 27" QHD 170Hz' OR x.nombre LIKE '% TUF VG27AQ1A 27" QHD 170Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), 'UltraGear 27GS75Q 27" QHD 180Hz', 'Monitor LG UltraGear 27GS75Q 27" QHD 180Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: IPS.', NULL
FROM marca m WHERE m.nombre = 'LG'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = 'UltraGear 27GS75Q 27" QHD 180Hz' OR x.nombre LIKE '% UltraGear 27GS75Q 27" QHD 180Hz'));
INSERT INTO producto (id_marca, id_categoria, nombre, descripcion, imagen)
SELECT m.id_marca, (SELECT id_categoria FROM categoria WHERE nombre LIKE 'Monitor%' ORDER BY id_categoria LIMIT 1), '24G15N 24" FHD 180Hz', 'Monitor AOC 24G15N 24" FHD 180Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: VA.', NULL
FROM marca m WHERE m.nombre = 'AOC'
  AND NOT EXISTS (SELECT 1 FROM producto x WHERE x.id_marca = m.id_marca AND (x.nombre = '24G15N 24" FHD 180Hz' OR x.nombre LIKE '% 24G15N 24" FHD 180Hz'));
-- Reemplaza la descripcion generica que dejaba el script 03 anterior
UPDATE producto SET descripcion = 'Procesador Intel Core i5-14600K: Núcleos: 14 (6 de rendimiento + 8 de eficiencia); Hilos: 20; Frecuencia máxima: 5,3 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i5-14600K' OR pr.nombre LIKE '% Core i5-14600K') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador Intel Core i7-14700K: Núcleos: 20 (8 de rendimiento + 12 de eficiencia); Hilos: 28; Frecuencia máxima: 5,6 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i7-14700K' OR pr.nombre LIKE '% Core i7-14700K') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador Intel Core i9-14900K: Núcleos: 24 (8 de rendimiento + 16 de eficiencia); Hilos: 32; Frecuencia máxima: 6,0 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i9-14900K' OR pr.nombre LIKE '% Core i9-14900K') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 5 7600X: Núcleos: 6; Hilos: 12; Frecuencia máxima: 5,3 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 7600X' OR pr.nombre LIKE '% Ryzen 5 7600X') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 7 7800X3D: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,0 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 7800X3D' OR pr.nombre LIKE '% Ryzen 7 7800X3D') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 7 7700X: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,4 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 7700X' OR pr.nombre LIKE '% Ryzen 7 7700X') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 7 9800X3D: Núcleos: 8; Hilos: 16; Frecuencia máxima: 5,2 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 9800X3D' OR pr.nombre LIKE '% Ryzen 7 9800X3D') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 5 9600X: Núcleos: 6; Hilos: 12; Frecuencia máxima: 5,4 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 9600X' OR pr.nombre LIKE '% Ryzen 5 9600X') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador Intel Core Ultra 7 265K: Núcleos: 20 (8 de rendimiento + 12 de eficiencia); Hilos: 20; Frecuencia máxima: 5,5 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core Ultra 7 265K' OR pr.nombre LIKE '% Core Ultra 7 265K') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador AMD Ryzen 5 5600: Núcleos: 6; Hilos: 12; Frecuencia máxima: 4,4 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 5600' OR pr.nombre LIKE '% Ryzen 5 5600') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Procesador Intel Core i5-12400F: Núcleos: 6 (solo de rendimiento); Hilos: 12; Frecuencia máxima: 4,4 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i5-12400F' OR pr.nombre LIKE '% Core i5-12400F') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 4060: Memoria: 8 GB GDDR6; Bus de memoria: 128 bits; Núcleos CUDA: 3.072.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4060' OR pr.nombre LIKE '% RTX 4060') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 4070: Memoria: 12 GB GDDR6X; Bus de memoria: 192 bits; Núcleos CUDA: 5.888.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4070' OR pr.nombre LIKE '% RTX 4070') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 4070 Ti: Memoria: 12 GB GDDR6X; Bus de memoria: 192 bits; Núcleos CUDA: 7.680.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4070 Ti' OR pr.nombre LIKE '% RTX 4070 Ti') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica AMD Radeon RX 7600: Memoria: 8 GB GDDR6; Bus de memoria: 128 bits; Unidades de cómputo: 32 (2.048 procesadores).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 7600' OR pr.nombre LIKE '% Radeon RX 7600') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica AMD Radeon RX 7800 XT: Memoria: 16 GB GDDR6; Bus de memoria: 256 bits; Unidades de cómputo: 60 (3.840 procesadores).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 7800 XT' OR pr.nombre LIKE '% Radeon RX 7800 XT') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 5060 Ti 16GB: Memoria: 16 GB GDDR7; Bus de memoria: 128 bits; Núcleos CUDA: 4.608.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5060 Ti 16GB' OR pr.nombre LIKE '% RTX 5060 Ti 16GB') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 5070: Memoria: 12 GB GDDR7; Bus de memoria: 192 bits; Núcleos CUDA: 6.144.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5070' OR pr.nombre LIKE '% RTX 5070') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica AMD Radeon RX 9070 XT: Memoria: 16 GB GDDR6; Bus de memoria: 256 bits; Unidades de cómputo: 64 (4.096 procesadores).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 9070 XT' OR pr.nombre LIKE '% Radeon RX 9070 XT') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica NVIDIA RTX 5060 8GB: Memoria: 8 GB GDDR7; Bus de memoria: 128 bits; Núcleos CUDA: 3.840.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5060 8GB' OR pr.nombre LIKE '% RTX 5060 8GB') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Tarjeta gráfica AMD Radeon RX 9060 XT 16GB: Memoria: 16 GB GDDR6; Bus de memoria: 128 bits; Unidades de cómputo: 32 (2.048 procesadores).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 9060 XT 16GB' OR pr.nombre LIKE '% Radeon RX 9060 XT 16GB') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Kingston Fury Beast 16GB 3200MHz: Tipo: DDR4; Capacidad: 16 GB (1 × 16 GB); Velocidad: 3.200 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast 16GB 3200MHz' OR pr.nombre LIKE '% Fury Beast 16GB 3200MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Corsair Vengeance 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Vengeance 32GB 6000MHz' OR pr.nombre LIKE '% Vengeance 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM G.Skill Trident Z5 32GB 6400MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.400 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'G.Skill' AND (pr.nombre = 'Trident Z5 32GB 6400MHz' OR pr.nombre LIKE '% Trident Z5 32GB 6400MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Corsair Dominator Platinum 64GB 5600MHz: Tipo: DDR5; Capacidad: 64 GB (2 × 32 GB); Velocidad: 5.600 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Dominator Platinum 64GB 5600MHz' OR pr.nombre LIKE '% Dominator Platinum 64GB 5600MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Kingston Fury Beast DDR5 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast DDR5 32GB 6000MHz' OR pr.nombre LIKE '% Fury Beast DDR5 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM TeamGroup T-Force Delta RGB 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (2 × 16 GB); Velocidad: 6.000 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'TeamGroup' AND (pr.nombre = 'T-Force Delta RGB 32GB 6000MHz' OR pr.nombre LIKE '% T-Force Delta RGB 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Corsair Vengeance LPX 16GB DDR4 3200MHz: Tipo: DDR4; Capacidad: 16 GB (2 × 8 GB); Velocidad: 3.200 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Vengeance LPX 16GB DDR4 3200MHz' OR pr.nombre LIKE '% Vengeance LPX 16GB DDR4 3200MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM Kingston Fury Beast DDR4 32GB 3200MHz: Tipo: DDR4; Capacidad: 32 GB (1 × 32 GB); Velocidad: 3.200 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast DDR4 32GB 3200MHz' OR pr.nombre LIKE '% Fury Beast DDR4 32GB 3200MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Memoria RAM XPG Lancer Blade DDR5 32GB 6000MHz: Tipo: DDR5; Capacidad: 32 GB (1 × 32 GB); Velocidad: 6.000 MT/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'XPG' AND (pr.nombre = 'Lancer Blade DDR5 32GB 6000MHz' OR pr.nombre LIKE '% Lancer Blade DDR5 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Samsung 990 PRO 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '990 PRO 1TB NVMe' OR pr.nombre LIKE '% 990 PRO 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento WD Black SN770 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'WD' AND (pr.nombre = 'Black SN770 1TB NVMe' OR pr.nombre LIKE '% Black SN770 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Kingston NV2 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'NV2 1TB NVMe' OR pr.nombre LIKE '% NV2 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Seagate BarraCuda 2TB HDD: Tipo: Disco duro (HDD); Capacidad: 2 TB; Interfaz: SATA 6 Gb/s.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Seagate' AND (pr.nombre = 'BarraCuda 2TB HDD' OR pr.nombre LIKE '% BarraCuda 2TB HDD') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Samsung 990 EVO Plus 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4 / 5.0 x2.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '990 EVO Plus 1TB NVMe' OR pr.nombre LIKE '% 990 EVO Plus 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Crucial P3 Plus 1TB NVMe: Tipo: SSD NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Crucial' AND (pr.nombre = 'P3 Plus 1TB NVMe' OR pr.nombre LIKE '% P3 Plus 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Kingston NV3 2TB NVMe: Tipo: SSD NVMe; Capacidad: 2 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'NV3 2TB NVMe' OR pr.nombre LIKE '% NV3 2TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento WD Blue SN580 1TB NVMe: Tipo: SSD M.2 2280 NVMe; Capacidad: 1 TB; Interfaz: PCIe 4.0 x4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'WD' AND (pr.nombre = 'Blue SN580 1TB NVMe' OR pr.nombre LIKE '% Blue SN580 1TB NVMe') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Unidad de almacenamiento Samsung 870 EVO 1TB SATA: Tipo: SSD 2,5" SATA; Capacidad: 1 TB; Interfaz: SATA III (6 Gb/s).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '870 EVO 1TB SATA' OR pr.nombre LIKE '% 870 EVO 1TB SATA') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre ASUS TUF Gaming B760M-Plus WiFi: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel B760; Formato: Micro-ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF Gaming B760M-Plus WiFi' OR pr.nombre LIKE '% TUF Gaming B760M-Plus WiFi') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre MSI MAG Z790 Tomahawk WiFi: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel Z790; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG Z790 Tomahawk WiFi' OR pr.nombre LIKE '% MAG Z790 Tomahawk WiFi') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre Gigabyte B650 Aorus Elite AX: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'B650 Aorus Elite AX' OR pr.nombre LIKE '% B650 Aorus Elite AX') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre ASRock X670E Steel Legend: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD X670E; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASRock' AND (pr.nombre = 'X670E Steel Legend' OR pr.nombre LIKE '% X670E Steel Legend') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre MSI MAG B650 Tomahawk WiFi: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG B650 Tomahawk WiFi' OR pr.nombre LIKE '% MAG B650 Tomahawk WiFi') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre ASUS TUF Gaming B650-Plus WiFi: Socket: AM5 (Ryzen 7000 y posteriores); Chipset: AMD B650; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF Gaming B650-Plus WiFi' OR pr.nombre LIKE '% TUF Gaming B650-Plus WiFi') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre Gigabyte B760M DS3H DDR4: Socket: LGA 1700 (Intel 12.ª a 14.ª gen.); Chipset: Intel B760; Formato: Micro-ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'B760M DS3H DDR4' OR pr.nombre LIKE '% B760M DS3H DDR4') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre MSI B850 Gaming Plus WiFi: Socket: AM5; Chipset: AMD B850; Formato: ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'B850 Gaming Plus WiFi' OR pr.nombre LIKE '% B850 Gaming Plus WiFi') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Placa madre ASUS Prime B550M-A WiFi II: Socket: AM4; Chipset: AMD B550; Formato: Micro-ATX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'Prime B550M-A WiFi II' OR pr.nombre LIKE '% Prime B550M-A WiFi II') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración DeepCool AK400 (aire): Tipo: Disipador por aire (una torre); Ventiladores: 1 × 120 mm; Heatpipes: 4.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'DeepCool' AND (pr.nombre = 'AK400 (aire)' OR pr.nombre LIKE '% AK400 (aire)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Noctua NH-D15 (aire): Tipo: Disipador por aire (doble torre); Ventiladores: 2 × 140 mm; Heatpipes: 6.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Noctua' AND (pr.nombre = 'NH-D15 (aire)' OR pr.nombre LIKE '% NH-D15 (aire)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Corsair iCUE H100i Elite 240mm (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 240 mm; Ventiladores: 2 × 120 mm.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'iCUE H100i Elite 240mm (líquida)' OR pr.nombre LIKE '% iCUE H100i Elite 240mm (líquida)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Arctic Liquid Freezer III 360mm (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 360 mm; Ventiladores: 3 × 120 mm.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Arctic' AND (pr.nombre = 'Liquid Freezer III 360mm (líquida)' OR pr.nombre LIKE '% Liquid Freezer III 360mm (líquida)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Thermalright Peerless Assassin 120 SE (aire): Tipo: Disipador por aire (doble torre); Ventiladores: 2 × 120 mm; Heatpipes: 6.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Thermalright' AND (pr.nombre = 'Peerless Assassin 120 SE (aire)' OR pr.nombre LIKE '% Peerless Assassin 120 SE (aire)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Cooler Master Hyper 212 Black Edition (aire): Tipo: Disipador por aire (una torre); Ventiladores: 1 × 120 mm; Heatpipes: 4 de contacto directo.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Cooler Master' AND (pr.nombre = 'Hyper 212 Black Edition (aire)' OR pr.nombre LIKE '% Hyper 212 Black Edition (aire)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración NZXT Kraken 240 (líquida): Tipo: Refrigeración líquida (AIO); Radiador: 240 mm; Ventiladores: 2 × 120 mm.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NZXT' AND (pr.nombre = 'Kraken 240 (líquida)' OR pr.nombre LIKE '% Kraken 240 (líquida)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Thermalright Phantom Spirit 120 SE (aire): Tipo: Disipador por aire de doble torre; Tubos de calor: 7 × 6 mm; Ventiladores: 2 × 120 mm TL-C12B V2 (1.500 RPM).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Thermalright' AND (pr.nombre = 'Phantom Spirit 120 SE (aire)' OR pr.nombre LIKE '% Phantom Spirit 120 SE (aire)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Refrigeración Arctic Liquid Freezer III Pro 240mm (líquida): Tipo: Refrigeración líquida AIO; Radiador: 240 mm (38 mm de grosor); Ventiladores: 2 × 120 mm P12 Pro.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Arctic' AND (pr.nombre = 'Liquid Freezer III Pro 240mm (líquida)' OR pr.nombre LIKE '% Liquid Freezer III Pro 240mm (líquida)') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Logitech Mouse G502 X: Tipo: Mouse gamer con cable; Sensor: HERO 25K; Resolución: hasta 25.600 DPI.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G502 X' OR pr.nombre LIKE '% Mouse G502 X') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Razer Mouse DeathAdder V3: Tipo: Mouse gamer con cable; Sensor: Focus Pro 30K; Resolución: hasta 30.000 DPI.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Razer' AND (pr.nombre = 'Mouse DeathAdder V3' OR pr.nombre LIKE '% Mouse DeathAdder V3') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Redragon Teclado Kumara K552: Tipo: Teclado mecánico; Formato: TKL (87 teclas, sin teclado numérico); Interruptores: Mecánicos Outemu.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Redragon' AND (pr.nombre = 'Teclado Kumara K552' OR pr.nombre LIKE '% Teclado Kumara K552') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio HyperX Audífonos Cloud III: Tipo: Audífonos gamer con cable; Parlantes: 53 mm; Micrófono: Desmontable con cancelación de ruido.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'HyperX' AND (pr.nombre = 'Audífonos Cloud III' OR pr.nombre LIKE '% Audífonos Cloud III') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Logitech Mouse G Pro X Superlight 2: Tipo: Mouse gamer inalámbrico (LIGHTSPEED); Sensor: HERO 2; Resolución: hasta 32.000 DPI.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G Pro X Superlight 2' OR pr.nombre LIKE '% Mouse G Pro X Superlight 2') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio HyperX Teclado Alloy Origins Core: Tipo: Teclado mecánico; Formato: TKL (87 teclas, sin teclado numérico); Interruptores: Mecánicos HyperX.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'HyperX' AND (pr.nombre = 'Teclado Alloy Origins Core' OR pr.nombre LIKE '% Teclado Alloy Origins Core') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Razer Audífonos BlackShark V2 X: Tipo: Audífonos gamer con cable; Parlantes: 50 mm; Micrófono: Cardioide.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Razer' AND (pr.nombre = 'Audífonos BlackShark V2 X' OR pr.nombre LIKE '% Audífonos BlackShark V2 X') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Logitech Mouse G305 Lightspeed: Tipo: Mouse inalámbrico; Sensor: HERO (12.000 DPI); Conexión: LIGHTSPEED 2,4 GHz.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G305 Lightspeed' OR pr.nombre LIKE '% Mouse G305 Lightspeed') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Accesorio Redragon Teclado K617 Fizz 60%: Tipo: Teclado mecánico 60 % (61 teclas); Switches: Rojos lineales, hot-swap; Iluminación: RGB.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Redragon' AND (pr.nombre = 'Teclado K617 Fizz 60%' OR pr.nombre LIKE '% Teclado K617 Fizz 60%') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Corsair RM750e 750W 80+ Gold: Potencia: 750 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM750e 750W 80+ Gold' OR pr.nombre LIKE '% RM750e 750W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder EVGA 600 BR 600W 80+ Bronze: Potencia: 600 W; Certificación: 80 PLUS Bronze; Cables: No modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'EVGA' AND (pr.nombre = '600 BR 600W 80+ Bronze' OR pr.nombre LIKE '% 600 BR 600W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Seasonic Focus GX-850 850W 80+ Gold: Potencia: 850 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Seasonic' AND (pr.nombre = 'Focus GX-850 850W 80+ Gold' OR pr.nombre LIKE '% Focus GX-850 850W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder MSI MPG A1000G 1000W 80+ Gold: Potencia: 1.000 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MPG A1000G 1000W 80+ Gold' OR pr.nombre LIKE '% MPG A1000G 1000W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Corsair RM850x 850W 80+ Gold: Potencia: 850 W; Certificación: 80 PLUS Gold; Cables: Totalmente modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM850x 850W 80+ Gold' OR pr.nombre LIKE '% RM850x 850W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder MSI MAG A650BN 650W 80+ Bronze: Potencia: 650 W; Certificación: 80 PLUS Bronze; Cables: No modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG A650BN 650W 80+ Bronze' OR pr.nombre LIKE '% MAG A650BN 650W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Gigabyte P650G 650W 80+ Gold: Potencia: 650 W; Certificación: 80 PLUS Gold; Cables: No modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'P650G 650W 80+ Gold' OR pr.nombre LIKE '% P650G 650W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Corsair CX650 650W 80+ Bronze: Potencia: 650 W; Certificación: 80 PLUS Bronze (hasta 88 %); Modular: No.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'CX650 650W 80+ Bronze' OR pr.nombre LIKE '% CX650 650W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Fuente de poder Corsair RM750x 750W 80+ Gold: Potencia: 750 W; Certificación: 80 PLUS Gold; Modular: Totalmente modular.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM750x 750W 80+ Gold' OR pr.nombre LIKE '% RM750x 750W 80+ Gold') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor LG UltraGear 27" QHD 180Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: Nano IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 27" QHD 180Hz' OR pr.nombre LIKE '% UltraGear 27" QHD 180Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor Samsung Odyssey G5 32" QHD 165Hz: Tamaño: 32 pulgadas (curvo 1000R); Resolución: QHD 2560 × 1440; Panel: VA.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = 'Odyssey G5 32" QHD 165Hz' OR pr.nombre LIKE '% Odyssey G5 32" QHD 165Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor ASUS TUF VG249Q 24" FHD 165Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF VG249Q 24" FHD 165Hz' OR pr.nombre LIKE '% TUF VG249Q 24" FHD 165Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor AOC Q27G3XMN 27" QHD Mini-LED: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: VA Mini-LED (336 zonas).' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AOC' AND (pr.nombre = 'Q27G3XMN 27" QHD Mini-LED' OR pr.nombre LIKE '% Q27G3XMN 27" QHD Mini-LED') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor Samsung Odyssey G4 27" FHD 240Hz: Tamaño: 27 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = 'Odyssey G4 27" FHD 240Hz' OR pr.nombre LIKE '% Odyssey G4 27" FHD 240Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor LG UltraGear 24GS60F 24" FHD 180Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 24GS60F 24" FHD 180Hz' OR pr.nombre LIKE '% UltraGear 24GS60F 24" FHD 180Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor ASUS TUF VG27AQ1A 27" QHD 170Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF VG27AQ1A 27" QHD 170Hz' OR pr.nombre LIKE '% TUF VG27AQ1A 27" QHD 170Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor LG UltraGear 27GS75Q 27" QHD 180Hz: Tamaño: 27 pulgadas; Resolución: QHD 2560 × 1440; Panel: IPS.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 27GS75Q 27" QHD 180Hz' OR pr.nombre LIKE '% UltraGear 27GS75Q 27" QHD 180Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');
UPDATE producto SET descripcion = 'Monitor AOC 24G15N 24" FHD 180Hz: Tamaño: 23,8 pulgadas; Resolución: Full HD 1920 × 1080; Panel: VA.' WHERE id_producto = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AOC' AND (pr.nombre = '24G15N 24" FHD 180Hz' OR pr.nombre LIKE '% 24G15N 24" FHD 180Hz') ORDER BY pr.id_producto LIMIT 1) AND (descripcion IS NULL OR descripcion = '' OR descripcion LIKE '%catalogo BuildZone');

-- ---------------------------------------------------------------------
-- 4. Especificaciones: ficha tecnica + los 4 puntajes que usa el comparador
--    (atributos 'Puntaje: ...', de 0 a 100, unidad 'pts')
-- ---------------------------------------------------------------------
-- Intel Core i5-14600K
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i5-14600K' OR pr.nombre LIKE '% Core i5-14600K') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '14 (6 de rendimiento + 8 de eficiencia)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '20', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,3 GHz', NULL
  UNION ALL SELECT 'Caché', '24 MB', NULL
  UNION ALL SELECT 'Socket', 'LGA 1700', NULL
  UNION ALL SELECT 'Consumo base (TDP)', '125 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'Intel UHD 770', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Intel Core i7-14700K
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i7-14700K' OR pr.nombre LIKE '% Core i7-14700K') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '20 (8 de rendimiento + 12 de eficiencia)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '28', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,6 GHz', NULL
  UNION ALL SELECT 'Caché', '33 MB', NULL
  UNION ALL SELECT 'Socket', 'LGA 1700', NULL
  UNION ALL SELECT 'Consumo base (TDP)', '125 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'Intel UHD 770', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '65', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '85', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Intel Core i9-14900K
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i9-14900K' OR pr.nombre LIKE '% Core i9-14900K') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '24 (8 de rendimiento + 16 de eficiencia)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '32', NULL
  UNION ALL SELECT 'Frecuencia máxima', '6,0 GHz', NULL
  UNION ALL SELECT 'Caché', '36 MB', NULL
  UNION ALL SELECT 'Socket', 'LGA 1700', NULL
  UNION ALL SELECT 'Consumo base (TDP)', '125 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'Intel UHD 770', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '98', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '55', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 5 7600X
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 7600X' OR pr.nombre LIKE '% Ryzen 5 7600X') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '12', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,3 GHz', NULL
  UNION ALL SELECT 'Caché L3', '32 MB', NULL
  UNION ALL SELECT 'Socket', 'AM5', NULL
  UNION ALL SELECT 'Consumo (TDP)', '105 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'AMD Radeon (2 núcleos)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 7 7800X3D
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 7800X3D' OR pr.nombre LIKE '% Ryzen 7 7800X3D') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '8' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '16', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,0 GHz', NULL
  UNION ALL SELECT 'Caché L3', '96 MB (3D V-Cache)', NULL
  UNION ALL SELECT 'Socket', 'AM5', NULL
  UNION ALL SELECT 'Consumo (TDP)', '120 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'AMD Radeon (2 núcleos)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '93', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 7 7700X
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 7700X' OR pr.nombre LIKE '% Ryzen 7 7700X') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '8' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '16', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,4 GHz', NULL
  UNION ALL SELECT 'Caché L3', '32 MB', NULL
  UNION ALL SELECT 'Socket', 'AM5', NULL
  UNION ALL SELECT 'Consumo (TDP)', '105 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'AMD Radeon (2 núcleos)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '95', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 7 9800X3D
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 9800X3D' OR pr.nombre LIKE '% Ryzen 7 9800X3D') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '8' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '16', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,2 GHz', NULL
  UNION ALL SELECT 'Caché L3', '96 MB (3D V-Cache de 2.ª generación)', NULL
  UNION ALL SELECT 'Socket', 'AM5', NULL
  UNION ALL SELECT 'Consumo (TDP)', '120 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'AMD Radeon (2 núcleos)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '99', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '97', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 5 9600X
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 9600X' OR pr.nombre LIKE '% Ryzen 5 9600X') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '12', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,4 GHz', NULL
  UNION ALL SELECT 'Caché L3', '32 MB', NULL
  UNION ALL SELECT 'Socket', 'AM5', NULL
  UNION ALL SELECT 'Consumo (TDP)', '65 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'AMD Radeon (2 núcleos)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '93', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Intel Core Ultra 7 265K
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core Ultra 7 265K' OR pr.nombre LIKE '% Core Ultra 7 265K') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '20 (8 de rendimiento + 12 de eficiencia)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '20', NULL
  UNION ALL SELECT 'Frecuencia máxima', '5,5 GHz', NULL
  UNION ALL SELECT 'Caché', '30 MB', NULL
  UNION ALL SELECT 'Socket', 'LGA 1851', NULL
  UNION ALL SELECT 'Consumo base (TDP)', '125 W', NULL
  UNION ALL SELECT 'Extra', 'NPU para tareas de IA', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '72', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Ryzen 5 5600
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 5 5600' OR pr.nombre LIKE '% Ryzen 5 5600') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '12', NULL
  UNION ALL SELECT 'Frecuencia máxima', '4,4 GHz', NULL
  UNION ALL SELECT 'Caché L3', '32 MB', NULL
  UNION ALL SELECT 'Socket', 'AM4', NULL
  UNION ALL SELECT 'Consumo (TDP)', '65 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'No', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '95', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '94', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Intel Core i5-12400F
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i5-12400F' OR pr.nombre LIKE '% Core i5-12400F') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Núcleos' AS atributo, '6 (solo de rendimiento)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Hilos', '12', NULL
  UNION ALL SELECT 'Frecuencia máxima', '4,4 GHz', NULL
  UNION ALL SELECT 'Caché', '18 MB', NULL
  UNION ALL SELECT 'Socket', 'LGA 1700', NULL
  UNION ALL SELECT 'Consumo base (TDP)', '65 W', NULL
  UNION ALL SELECT 'Gráficos integrados', 'No (requiere tarjeta gráfica)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '92', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 4060
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4060' OR pr.nombre LIKE '% RTX 4060') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '8 GB GDDR6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '128 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '3.072', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.460 MHz', NULL
  UNION ALL SELECT 'Consumo', '115 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x8', NULL
  UNION ALL SELECT 'Fuente recomendada', '550 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 4070
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4070' OR pr.nombre LIKE '% RTX 4070') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '12 GB GDDR6X' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '192 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '5.888', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.475 MHz', NULL
  UNION ALL SELECT 'Consumo', '200 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '650 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '85', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 4070 Ti
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4070 Ti' OR pr.nombre LIKE '% RTX 4070 Ti') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '12 GB GDDR6X' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '192 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '7.680', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.610 MHz', NULL
  UNION ALL SELECT 'Consumo', '285 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '700 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '78', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Radeon RX 7600
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 7600' OR pr.nombre LIKE '% Radeon RX 7600') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '8 GB GDDR6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '128 bits', NULL
  UNION ALL SELECT 'Unidades de cómputo', '32 (2.048 procesadores)', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.655 MHz', NULL
  UNION ALL SELECT 'Consumo', '165 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x8', NULL
  UNION ALL SELECT 'Fuente recomendada', '550 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '65', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '75', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Radeon RX 7800 XT
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 7800 XT' OR pr.nombre LIKE '% Radeon RX 7800 XT') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '16 GB GDDR6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '256 bits', NULL
  UNION ALL SELECT 'Unidades de cómputo', '60 (3.840 procesadores)', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.430 MHz', NULL
  UNION ALL SELECT 'Consumo', '263 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '700 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '82', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 5060 Ti 16GB
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5060 Ti 16GB' OR pr.nombre LIKE '% RTX 5060 Ti 16GB') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '16 GB GDDR7' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '128 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '4.608', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.572 MHz', NULL
  UNION ALL SELECT 'Consumo', '180 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 5.0 x8', NULL
  UNION ALL SELECT 'Fuente recomendada', '600 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 5070
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5070' OR pr.nombre LIKE '% RTX 5070') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '12 GB GDDR7' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '192 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '6.144', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.512 MHz', NULL
  UNION ALL SELECT 'Consumo', '250 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 5.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '650 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '92', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Radeon RX 9070 XT
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 9070 XT' OR pr.nombre LIKE '% Radeon RX 9070 XT') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '16 GB GDDR6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '256 bits', NULL
  UNION ALL SELECT 'Unidades de cómputo', '64 (4.096 procesadores)', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.970 MHz', NULL
  UNION ALL SELECT 'Consumo', '304 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 5.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '750 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '93', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NVIDIA RTX 5060 8GB
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 5060 8GB' OR pr.nombre LIKE '% RTX 5060 8GB') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '8 GB GDDR7' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '128 bits', NULL
  UNION ALL SELECT 'Núcleos CUDA', '3.840', NULL
  UNION ALL SELECT 'Frecuencia boost', '2.497 MHz', NULL
  UNION ALL SELECT 'Consumo', '145 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 5.0 x8', NULL
  UNION ALL SELECT 'Fuente recomendada', '550 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AMD Radeon RX 9060 XT 16GB
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 9060 XT 16GB' OR pr.nombre LIKE '% Radeon RX 9060 XT 16GB') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Memoria' AS atributo, '16 GB GDDR6' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Bus de memoria', '128 bits', NULL
  UNION ALL SELECT 'Unidades de cómputo', '32 (2.048 procesadores)', NULL
  UNION ALL SELECT 'Frecuencia boost', '3.130 MHz', NULL
  UNION ALL SELECT 'Consumo', '160 W', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 5.0 x16', NULL
  UNION ALL SELECT 'Fuente recomendada', '450 W', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Kingston Fury Beast 16GB 3200MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast 16GB 3200MHz' OR pr.nombre LIKE '% Fury Beast 16GB 3200MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR4' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '16 GB (1 × 16 GB)', NULL
  UNION ALL SELECT 'Velocidad', '3.200 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL16', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '55', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '85', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair Vengeance 32GB 6000MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Vengeance 32GB 6000MHz' OR pr.nombre LIKE '% Vengeance 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (2 × 16 GB)', NULL
  UNION ALL SELECT 'Velocidad', '6.000 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL36', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP 3.0', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- G.Skill Trident Z5 32GB 6400MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'G.Skill' AND (pr.nombre = 'Trident Z5 32GB 6400MHz' OR pr.nombre LIKE '% Trident Z5 32GB 6400MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (2 × 16 GB)', NULL
  UNION ALL SELECT 'Velocidad', '6.400 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL32', NULL
  UNION ALL SELECT 'Voltaje', '1,40 V', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair Dominator Platinum 64GB 5600MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Dominator Platinum 64GB 5600MHz' OR pr.nombre LIKE '% Dominator Platinum 64GB 5600MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '64 GB (2 × 32 GB)', NULL
  UNION ALL SELECT 'Velocidad', '5.600 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL40', NULL
  UNION ALL SELECT 'Voltaje', '1,25 V', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '55', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '76', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Kingston Fury Beast DDR5 32GB 6000MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast DDR5 32GB 6000MHz' OR pr.nombre LIKE '% Fury Beast DDR5 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (2 × 16 GB)', NULL
  UNION ALL SELECT 'Velocidad', '6.000 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL36', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP 3.0 y AMD EXPO', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- TeamGroup T-Force Delta RGB 32GB 6000MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'TeamGroup' AND (pr.nombre = 'T-Force Delta RGB 32GB 6000MHz' OR pr.nombre LIKE '% T-Force Delta RGB 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (2 × 16 GB)', NULL
  UNION ALL SELECT 'Velocidad', '6.000 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL30', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP 3.0 y AMD EXPO', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '82', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair Vengeance LPX 16GB DDR4 3200MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Vengeance LPX 16GB DDR4 3200MHz' OR pr.nombre LIKE '% Vengeance LPX 16GB DDR4 3200MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR4' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '16 GB (2 × 8 GB)', NULL
  UNION ALL SELECT 'Velocidad', '3.200 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL16', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP 2.0', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '55', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Kingston Fury Beast DDR4 32GB 3200MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'Fury Beast DDR4 32GB 3200MHz' OR pr.nombre LIKE '% Fury Beast DDR4 32GB 3200MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR4' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (1 × 32 GB)', NULL
  UNION ALL SELECT 'Velocidad', '3.200 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL16', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP / AMD Ryzen Ready', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '62', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- XPG Lancer Blade DDR5 32GB 6000MHz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'XPG' AND (pr.nombre = 'Lancer Blade DDR5 32GB 6000MHz' OR pr.nombre LIKE '% Lancer Blade DDR5 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'DDR5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '32 GB (1 × 32 GB)', NULL
  UNION ALL SELECT 'Velocidad', '6.000 MT/s', NULL
  UNION ALL SELECT 'Latencia', 'CL30', NULL
  UNION ALL SELECT 'Voltaje', '1,35 V', NULL
  UNION ALL SELECT 'Perfil', 'Intel XMP 3.0 y AMD EXPO', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '78', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Samsung 990 PRO 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '990 PRO 1TB NVMe' OR pr.nombre LIKE '% 990 PRO 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 7.450 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 6.900 MB/s', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '95', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '92', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- WD Black SN770 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'WD' AND (pr.nombre = 'Black SN770 1TB NVMe' OR pr.nombre LIKE '% Black SN770 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 5.150 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 4.900 MB/s', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Kingston NV2 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'NV2 1TB NVMe' OR pr.nombre LIKE '% NV2 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 3.500 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 2.100 MB/s', NULL
  UNION ALL SELECT 'Garantía', '3 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '65', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Seagate BarraCuda 2TB HDD
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Seagate' AND (pr.nombre = 'BarraCuda 2TB HDD' OR pr.nombre LIKE '% BarraCuda 2TB HDD') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disco duro (HDD)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '2 TB', NULL
  UNION ALL SELECT 'Interfaz', 'SATA 6 Gb/s', NULL
  UNION ALL SELECT 'Formato', '3,5 pulgadas', NULL
  UNION ALL SELECT 'Velocidad de giro', '7.200 RPM', NULL
  UNION ALL SELECT 'Caché', '256 MB', NULL
  UNION ALL SELECT 'Transferencia', 'hasta 220 MB/s', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '35', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '78', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Samsung 990 EVO Plus 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '990 EVO Plus 1TB NVMe' OR pr.nombre LIKE '% 990 EVO Plus 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4 / 5.0 x2', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 7.150 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 6.300 MB/s', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Crucial P3 Plus 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Crucial' AND (pr.nombre = 'P3 Plus 1TB NVMe' OR pr.nombre LIKE '% P3 Plus 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 5.000 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 3.600 MB/s', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '85', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Kingston NV3 2TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Kingston' AND (pr.nombre = 'NV3 2TB NVMe' OR pr.nombre LIKE '% NV3 2TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '2 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Formato', 'M.2 2280', NULL
  UNION ALL SELECT 'Lectura', 'hasta 6.000 MB/s', NULL
  UNION ALL SELECT 'Escritura', 'hasta 5.000 MB/s', NULL
  UNION ALL SELECT 'Garantía', '3 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- WD Blue SN580 1TB NVMe
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'WD' AND (pr.nombre = 'Blue SN580 1TB NVMe' OR pr.nombre LIKE '% Blue SN580 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD M.2 2280 NVMe' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'PCIe 4.0 x4', NULL
  UNION ALL SELECT 'Lectura secuencial', '4.150 MB/s', NULL
  UNION ALL SELECT 'Escritura secuencial', '4.150 MB/s', NULL
  UNION ALL SELECT 'Durabilidad', '600 TBW', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Samsung 870 EVO 1TB SATA
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '870 EVO 1TB SATA' OR pr.nombre LIKE '% 870 EVO 1TB SATA') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'SSD 2,5" SATA' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Capacidad', '1 TB', NULL
  UNION ALL SELECT 'Interfaz', 'SATA III (6 Gb/s)', NULL
  UNION ALL SELECT 'Lectura secuencial', '560 MB/s', NULL
  UNION ALL SELECT 'Escritura secuencial', '530 MB/s', NULL
  UNION ALL SELECT 'Durabilidad', '600 TBW', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '55', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '92', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASUS TUF Gaming B760M-Plus WiFi
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF Gaming B760M-Plus WiFi' OR pr.nombre LIKE '% TUF Gaming B760M-Plus WiFi') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'LGA 1700 (Intel 12.ª a 14.ª gen.)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'Intel B760', NULL
  UNION ALL SELECT 'Formato', 'Micro-ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6 + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- MSI MAG Z790 Tomahawk WiFi
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG Z790 Tomahawk WiFi' OR pr.nombre LIKE '% MAG Z790 Tomahawk WiFi') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'LGA 1700 (Intel 12.ª a 14.ª gen.)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'Intel Z790', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6E + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '82', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Gigabyte B650 Aorus Elite AX
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'B650 Aorus Elite AX' OR pr.nombre LIKE '% B650 Aorus Elite AX') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM5 (Ryzen 7000 y posteriores)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD B650', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6E + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASRock X670E Steel Legend
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASRock' AND (pr.nombre = 'X670E Steel Legend' OR pr.nombre LIKE '% X670E Steel Legend') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM5 (Ryzen 7000 y posteriores)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD X670E', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6E + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '68', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '74', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- MSI MAG B650 Tomahawk WiFi
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG B650 Tomahawk WiFi' OR pr.nombre LIKE '% MAG B650 Tomahawk WiFi') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM5 (Ryzen 7000 y posteriores)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD B650', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6E + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASUS TUF Gaming B650-Plus WiFi
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF Gaming B650-Plus WiFi' OR pr.nombre LIKE '% TUF Gaming B650-Plus WiFi') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM5 (Ryzen 7000 y posteriores)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD B650', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6 + LAN 2,5 Gb', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Gigabyte B760M DS3H DDR4
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'B760M DS3H DDR4' OR pr.nombre LIKE '% B760M DS3H DDR4') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'LGA 1700 (Intel 12.ª a 14.ª gen.)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'Intel B760', NULL
  UNION ALL SELECT 'Formato', 'Micro-ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR4', NULL
  UNION ALL SELECT 'Red', 'LAN 2,5 Gb (sin Wi-Fi)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '62', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- MSI B850 Gaming Plus WiFi
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'B850 Gaming Plus WiFi' OR pr.nombre LIKE '% B850 Gaming Plus WiFi') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM5' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD B850', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR5 (hasta 256 GB)', NULL
  UNION ALL SELECT 'Almacenamiento', '1 × M.2 PCIe 5.0 + 2 × M.2 PCIe 4.0', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 7, Bluetooth 5.4 y LAN 5G', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASUS Prime B550M-A WiFi II
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'Prime B550M-A WiFi II' OR pr.nombre LIKE '% Prime B550M-A WiFi II') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Socket' AS atributo, 'AM4' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Chipset', 'AMD B550', NULL
  UNION ALL SELECT 'Formato', 'Micro-ATX', NULL
  UNION ALL SELECT 'Memoria', '4 ranuras DDR4 (hasta 128 GB)', NULL
  UNION ALL SELECT 'Almacenamiento', '2 × M.2 (1 PCIe 4.0)', NULL
  UNION ALL SELECT 'Red', 'Wi-Fi 6 y LAN 1G', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '64', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- DeepCool AK400 (aire)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'DeepCool' AND (pr.nombre = 'AK400 (aire)' OR pr.nombre LIKE '% AK400 (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disipador por aire (una torre)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Ventiladores', '1 × 120 mm', NULL
  UNION ALL SELECT 'Heatpipes', '4', NULL
  UNION ALL SELECT 'Altura', '155 mm', NULL
  UNION ALL SELECT 'Disipa hasta', '220 W', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '65', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '95', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Noctua NH-D15 (aire)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Noctua' AND (pr.nombre = 'NH-D15 (aire)' OR pr.nombre LIKE '% NH-D15 (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disipador por aire (doble torre)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Ventiladores', '2 × 140 mm', NULL
  UNION ALL SELECT 'Heatpipes', '6', NULL
  UNION ALL SELECT 'Altura', '165 mm', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '65', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair iCUE H100i Elite 240mm (líquida)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'iCUE H100i Elite 240mm (líquida)' OR pr.nombre LIKE '% iCUE H100i Elite 240mm (líquida)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Refrigeración líquida (AIO)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Radiador', '240 mm', NULL
  UNION ALL SELECT 'Ventiladores', '2 × 120 mm', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '68', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '82', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Arctic Liquid Freezer III 360mm (líquida)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Arctic' AND (pr.nombre = 'Liquid Freezer III 360mm (líquida)' OR pr.nombre LIKE '% Liquid Freezer III 360mm (líquida)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Refrigeración líquida (AIO)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Radiador', '360 mm', NULL
  UNION ALL SELECT 'Ventiladores', '3 × 120 mm', NULL
  UNION ALL SELECT 'Extra', 'Ventilador para la zona de VRM', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Thermalright Peerless Assassin 120 SE (aire)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Thermalright' AND (pr.nombre = 'Peerless Assassin 120 SE (aire)' OR pr.nombre LIKE '% Peerless Assassin 120 SE (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disipador por aire (doble torre)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Ventiladores', '2 × 120 mm', NULL
  UNION ALL SELECT 'Heatpipes', '6', NULL
  UNION ALL SELECT 'Altura', '155 mm', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700/1851 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '96', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Cooler Master Hyper 212 Black Edition (aire)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Cooler Master' AND (pr.nombre = 'Hyper 212 Black Edition (aire)' OR pr.nombre LIKE '% Hyper 212 Black Edition (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disipador por aire (una torre)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Ventiladores', '1 × 120 mm', NULL
  UNION ALL SELECT 'Heatpipes', '4 de contacto directo', NULL
  UNION ALL SELECT 'Acabado', 'Negro', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '62', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- NZXT Kraken 240 (líquida)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NZXT' AND (pr.nombre = 'Kraken 240 (líquida)' OR pr.nombre LIKE '% Kraken 240 (líquida)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Refrigeración líquida (AIO)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Radiador', '240 mm', NULL
  UNION ALL SELECT 'Ventiladores', '2 × 120 mm', NULL
  UNION ALL SELECT 'Extra', 'Pantalla LCD en la bomba', NULL
  UNION ALL SELECT 'Compatibilidad', 'Intel LGA 1700 y AMD AM5/AM4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Thermalright Phantom Spirit 120 SE (aire)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Thermalright' AND (pr.nombre = 'Phantom Spirit 120 SE (aire)' OR pr.nombre LIKE '% Phantom Spirit 120 SE (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Disipador por aire de doble torre' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Tubos de calor', '7 × 6 mm', NULL
  UNION ALL SELECT 'Ventiladores', '2 × 120 mm TL-C12B V2 (1.500 RPM)', NULL
  UNION ALL SELECT 'Altura', '154 mm', NULL
  UNION ALL SELECT 'Ruido máximo', '25,6 dBA', NULL
  UNION ALL SELECT 'Sockets', 'AM4, AM5, LGA 1700/1851', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '96', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Arctic Liquid Freezer III Pro 240mm (líquida)
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Arctic' AND (pr.nombre = 'Liquid Freezer III Pro 240mm (líquida)' OR pr.nombre LIKE '% Liquid Freezer III Pro 240mm (líquida)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Refrigeración líquida AIO' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Radiador', '240 mm (38 mm de grosor)', NULL
  UNION ALL SELECT 'Ventiladores', '2 × 120 mm P12 Pro', NULL
  UNION ALL SELECT 'Extra', 'Ventilador para el VRM integrado', NULL
  UNION ALL SELECT 'Sockets', 'AM4, AM5, LGA 1700/1851', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Logitech Mouse G502 X
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G502 X' OR pr.nombre LIKE '% Mouse G502 X') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Mouse gamer con cable' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Sensor', 'HERO 25K', NULL
  UNION ALL SELECT 'Resolución', 'hasta 25.600 DPI', NULL
  UNION ALL SELECT 'Botones', '13 programables', NULL
  UNION ALL SELECT 'Interruptores', 'LIGHTFORCE híbridos', NULL
  UNION ALL SELECT 'Peso', '89 g', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '92', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Razer Mouse DeathAdder V3
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Razer' AND (pr.nombre = 'Mouse DeathAdder V3' OR pr.nombre LIKE '% Mouse DeathAdder V3') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Mouse gamer con cable' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Sensor', 'Focus Pro 30K', NULL
  UNION ALL SELECT 'Resolución', 'hasta 30.000 DPI', NULL
  UNION ALL SELECT 'Interruptores', 'Ópticos de 3.ª generación', NULL
  UNION ALL SELECT 'Peso', '59 g', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Redragon Teclado Kumara K552
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Redragon' AND (pr.nombre = 'Teclado Kumara K552' OR pr.nombre LIKE '% Teclado Kumara K552') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Teclado mecánico' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Formato', 'TKL (87 teclas, sin teclado numérico)', NULL
  UNION ALL SELECT 'Interruptores', 'Mecánicos Outemu', NULL
  UNION ALL SELECT 'Iluminación', 'Retroiluminado', NULL
  UNION ALL SELECT 'Conexión', 'USB con cable', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- HyperX Audífonos Cloud III
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'HyperX' AND (pr.nombre = 'Audífonos Cloud III' OR pr.nombre LIKE '% Audífonos Cloud III') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Audífonos gamer con cable' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Parlantes', '53 mm', NULL
  UNION ALL SELECT 'Micrófono', 'Desmontable con cancelación de ruido', NULL
  UNION ALL SELECT 'Audio espacial', 'DTS Headphone:X', NULL
  UNION ALL SELECT 'Conexión', '3,5 mm, USB-C y USB-A', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Logitech Mouse G Pro X Superlight 2
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G Pro X Superlight 2' OR pr.nombre LIKE '% Mouse G Pro X Superlight 2') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Mouse gamer inalámbrico (LIGHTSPEED)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Sensor', 'HERO 2', NULL
  UNION ALL SELECT 'Resolución', 'hasta 32.000 DPI', NULL
  UNION ALL SELECT 'Peso', '60 g', NULL
  UNION ALL SELECT 'Batería', 'hasta 95 horas', NULL
  UNION ALL SELECT 'Carga', 'USB-C', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- HyperX Teclado Alloy Origins Core
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'HyperX' AND (pr.nombre = 'Teclado Alloy Origins Core' OR pr.nombre LIKE '% Teclado Alloy Origins Core') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Teclado mecánico' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Formato', 'TKL (87 teclas, sin teclado numérico)', NULL
  UNION ALL SELECT 'Interruptores', 'Mecánicos HyperX', NULL
  UNION ALL SELECT 'Iluminación', 'RGB por tecla', NULL
  UNION ALL SELECT 'Chasis', 'Aluminio', NULL
  UNION ALL SELECT 'Conexión', 'Cable USB-C desmontable', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Razer Audífonos BlackShark V2 X
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Razer' AND (pr.nombre = 'Audífonos BlackShark V2 X' OR pr.nombre LIKE '% Audífonos BlackShark V2 X') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Audífonos gamer con cable' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Parlantes', '50 mm', NULL
  UNION ALL SELECT 'Micrófono', 'Cardioide', NULL
  UNION ALL SELECT 'Audio', 'Sonido envolvente 7.1 (en Windows)', NULL
  UNION ALL SELECT 'Conexión', '3,5 mm', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Logitech Mouse G305 Lightspeed
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Logitech' AND (pr.nombre = 'Mouse G305 Lightspeed' OR pr.nombre LIKE '% Mouse G305 Lightspeed') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Mouse inalámbrico' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Sensor', 'HERO (12.000 DPI)', NULL
  UNION ALL SELECT 'Conexión', 'LIGHTSPEED 2,4 GHz', NULL
  UNION ALL SELECT 'Botones', '6 programables', NULL
  UNION ALL SELECT 'Peso', '99 g', NULL
  UNION ALL SELECT 'Batería', 'Hasta 250 h (1 pila AA)', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '74', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '95', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Redragon Teclado K617 Fizz 60%
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Redragon' AND (pr.nombre = 'Teclado K617 Fizz 60%' OR pr.nombre LIKE '% Teclado K617 Fizz 60%') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tipo' AS atributo, 'Teclado mecánico 60 % (61 teclas)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Switches', 'Rojos lineales, hot-swap', NULL
  UNION ALL SELECT 'Iluminación', 'RGB', NULL
  UNION ALL SELECT 'Conexión', 'Cable USB-C desmontable', NULL
  UNION ALL SELECT 'Uso', 'Gaming y escritorio compacto', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '62', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair RM750e 750W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM750e 750W 80+ Gold' OR pr.nombre LIKE '% RM750e 750W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '750 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Cables', 'Totalmente modular', NULL
  UNION ALL SELECT 'Norma', 'ATX 3.0', NULL
  UNION ALL SELECT 'Ventilador', '120 mm', NULL
  UNION ALL SELECT 'Garantía', '7 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- EVGA 600 BR 600W 80+ Bronze
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'EVGA' AND (pr.nombre = '600 BR 600W 80+ Bronze' OR pr.nombre LIKE '% 600 BR 600W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '600 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Bronze', NULL
  UNION ALL SELECT 'Cables', 'No modular', NULL
  UNION ALL SELECT 'Ventilador', '120 mm', NULL
  UNION ALL SELECT 'Garantía', '3 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '78', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Seasonic Focus GX-850 850W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Seasonic' AND (pr.nombre = 'Focus GX-850 850W 80+ Gold' OR pr.nombre LIKE '% Focus GX-850 850W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '850 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Cables', 'Totalmente modular', NULL
  UNION ALL SELECT 'Ventilador', '120 mm', NULL
  UNION ALL SELECT 'Garantía', '10 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- MSI MPG A1000G 1000W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MPG A1000G 1000W 80+ Gold' OR pr.nombre LIKE '% MPG A1000G 1000W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '1.000 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Cables', 'Totalmente modular', NULL
  UNION ALL SELECT 'Norma', 'ATX 3.0', NULL
  UNION ALL SELECT 'Ventilador', '135 mm', NULL
  UNION ALL SELECT 'Garantía', '10 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '95', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '88', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '76', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair RM850x 850W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM850x 850W 80+ Gold' OR pr.nombre LIKE '% RM850x 850W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '850 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Cables', 'Totalmente modular', NULL
  UNION ALL SELECT 'Ventilador', '135 mm', NULL
  UNION ALL SELECT 'Garantía', '10 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- MSI MAG A650BN 650W 80+ Bronze
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'MSI' AND (pr.nombre = 'MAG A650BN 650W 80+ Bronze' OR pr.nombre LIKE '% MAG A650BN 650W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '650 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Bronze', NULL
  UNION ALL SELECT 'Cables', 'No modular', NULL
  UNION ALL SELECT 'Ventilador', '120 mm', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '62', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '72', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Gigabyte P650G 650W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Gigabyte' AND (pr.nombre = 'P650G 650W 80+ Gold' OR pr.nombre LIKE '% P650G 650W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '650 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Cables', 'No modular', NULL
  UNION ALL SELECT 'Ventilador', '120 mm (rodamiento hidráulico)', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '64', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '80', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair CX650 650W 80+ Bronze
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'CX650 650W 80+ Bronze' OR pr.nombre LIKE '% CX650 650W 80+ Bronze') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '650 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Bronze (hasta 88 %)', NULL
  UNION ALL SELECT 'Modular', 'No', NULL
  UNION ALL SELECT 'Ventilador', '120 mm', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Garantía', '5 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '60', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Corsair RM750x 750W 80+ Gold
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'RM750x 750W 80+ Gold' OR pr.nombre LIKE '% RM750x 750W 80+ Gold') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Potencia' AS atributo, '750 W' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Certificación', '80 PLUS Gold', NULL
  UNION ALL SELECT 'Modular', 'Totalmente modular', NULL
  UNION ALL SELECT 'Ventilador', '135 mm con modo semipasivo', NULL
  UNION ALL SELECT 'Formato', 'ATX', NULL
  UNION ALL SELECT 'Garantía', '10 años', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- LG UltraGear 27" QHD 180Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 27" QHD 180Hz' OR pr.nombre LIKE '% UltraGear 27" QHD 180Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '27 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'QHD 2560 × 1440', NULL
  UNION ALL SELECT 'Panel', 'Nano IPS', NULL
  UNION ALL SELECT 'Frecuencia', '180 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'HDR', 'HDR400', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '85', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Samsung Odyssey G5 32" QHD 165Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = 'Odyssey G5 32" QHD 165Hz' OR pr.nombre LIKE '% Odyssey G5 32" QHD 165Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '32 pulgadas (curvo 1000R)' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'QHD 2560 × 1440', NULL
  UNION ALL SELECT 'Panel', 'VA', NULL
  UNION ALL SELECT 'Frecuencia', '165 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'Sincronización', 'AMD FreeSync Premium', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '75', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '85', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASUS TUF VG249Q 24" FHD 165Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF VG249Q 24" FHD 165Hz' OR pr.nombre LIKE '% TUF VG249Q 24" FHD 165Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '23,8 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'Full HD 1920 × 1080', NULL
  UNION ALL SELECT 'Panel', 'IPS', NULL
  UNION ALL SELECT 'Frecuencia', '165 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'Sincronización', 'AMD FreeSync Premium', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '68', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '92', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '87', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AOC Q27G3XMN 27" QHD Mini-LED
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AOC' AND (pr.nombre = 'Q27G3XMN 27" QHD Mini-LED' OR pr.nombre LIKE '% Q27G3XMN 27" QHD Mini-LED') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '27 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'QHD 2560 × 1440', NULL
  UNION ALL SELECT 'Panel', 'VA Mini-LED (336 zonas)', NULL
  UNION ALL SELECT 'Frecuencia', '180 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'HDR', 'HDR1000', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '90', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '79', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- Samsung Odyssey G4 27" FHD 240Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = 'Odyssey G4 27" FHD 240Hz' OR pr.nombre LIKE '% Odyssey G4 27" FHD 240Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '27 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'Full HD 1920 × 1080', NULL
  UNION ALL SELECT 'Panel', 'IPS', NULL
  UNION ALL SELECT 'Frecuencia', '240 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'Sincronización', 'G-Sync Compatible y FreeSync', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '78', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '76', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- LG UltraGear 24GS60F 24" FHD 180Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 24GS60F 24" FHD 180Hz' OR pr.nombre LIKE '% UltraGear 24GS60F 24" FHD 180Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '23,8 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'Full HD 1920 × 1080', NULL
  UNION ALL SELECT 'Panel', 'IPS', NULL
  UNION ALL SELECT 'Frecuencia', '180 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms', NULL
  UNION ALL SELECT 'HDR', 'HDR10', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '66', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '90', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- ASUS TUF VG27AQ1A 27" QHD 170Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'ASUS' AND (pr.nombre = 'TUF VG27AQ1A 27" QHD 170Hz' OR pr.nombre LIKE '% TUF VG27AQ1A 27" QHD 170Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '27 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'QHD 2560 × 1440', NULL
  UNION ALL SELECT 'Panel', 'IPS', NULL
  UNION ALL SELECT 'Frecuencia', '170 Hz (overclock)', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms (MPRT)', NULL
  UNION ALL SELECT 'HDR', 'HDR10', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '80', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '86', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- LG UltraGear 27GS75Q 27" QHD 180Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'LG' AND (pr.nombre = 'UltraGear 27GS75Q 27" QHD 180Hz' OR pr.nombre LIKE '% UltraGear 27GS75Q 27" QHD 180Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '27 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'QHD 2560 × 1440', NULL
  UNION ALL SELECT 'Panel', 'IPS', NULL
  UNION ALL SELECT 'Frecuencia', '180 Hz (200 Hz con overclock por DisplayPort)', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms (GtG)', NULL
  UNION ALL SELECT 'HDR', 'HDR10', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '86', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '84', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '88', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);
-- AOC 24G15N 24" FHD 180Hz
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AOC' AND (pr.nombre = '24G15N 24" FHD 180Hz' OR pr.nombre LIKE '% 24G15N 24" FHD 180Hz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO especificacion (id_producto, atributo, valor, unidad)
SELECT @p, s.atributo, s.valor, s.unidad FROM (
  SELECT 'Tamaño' AS atributo, '23,8 pulgadas' AS valor, CAST(NULL AS CHAR(50)) AS unidad
  UNION ALL SELECT 'Resolución', 'Full HD 1920 × 1080', NULL
  UNION ALL SELECT 'Panel', 'VA', NULL
  UNION ALL SELECT 'Frecuencia', '180 Hz', NULL
  UNION ALL SELECT 'Tiempo de respuesta', '1 ms (MPRT)', NULL
  UNION ALL SELECT 'Conexiones', 'HDMI 2.0 y DisplayPort 1.4', NULL
  UNION ALL SELECT 'Puntaje: Potencia', '70', 'pts'
  UNION ALL SELECT 'Puntaje: Eficiencia', '82', 'pts'
  UNION ALL SELECT 'Puntaje: Valor', '94', 'pts'
  UNION ALL SELECT 'Puntaje: Popularidad', '84', 'pts'
) AS s
WHERE @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM especificacion e WHERE e.id_producto = @p AND e.atributo = s.atributo);

-- ---------------------------------------------------------------------
-- 5. Fuentes de precio (tiendas) y precios
-- ---------------------------------------------------------------------
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'BuildZone (precio de referencia)', NULL, 'Precio de referencia estimado por el equipo BuildZone en pesos colombianos. No corresponde a una tienda especifica.' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'BuildZone (precio de referencia)');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Alavista', 'https://alavista.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Alavista');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Cadena Multi', 'https://cadenamulti.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Cadena Multi');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Castor Data', 'https://www.castordata.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Castor Data');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Centauri PC', 'https://centauripc.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Centauri PC');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Cometware', 'https://cometware.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Cometware');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Compudemano', 'https://www.compudemano.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Compudemano');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Computadores y Servicio Técnico', 'https://www.computadoresyserviciotecnico.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Computadores y Servicio Técnico');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Devaltech', 'https://www.devaltech.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Devaltech');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Digital World', 'https://digitalworld.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Digital World');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Discos Duros Colombia', 'https://discosduros.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Discos Duros Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Doble Click', 'https://dobleclicknet.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Doble Click');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Dot Technology', 'https://dottechnology.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Dot Technology');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Encarguelo', 'https://encarguelo.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Encarguelo');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Enjoy VideoGames', 'https://enjoyvideogames.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Enjoy VideoGames');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Falabella Colombia', 'https://www.falabella.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Falabella Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Gamers Colombia', 'https://gamerscolombia.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Gamers Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Logitech Store Colombia', 'https://www.logitechstore.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Logitech Store Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Mercado Libre Colombia', 'https://www.mercadolibre.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Mercado Libre Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Mi PC Parque Central', 'https://www.mipcparquecentral.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Mi PC Parque Central');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Mips Colombia', 'https://mipscolombia.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Mips Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Nuevo Punto', 'https://www.nuevopunto.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Nuevo Punto');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'PC Masters Bogotá', 'https://pcmastersbogota.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'PC Masters Bogotá');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'PC Store Colombia', 'https://www.pcstorecolombia.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'PC Store Colombia');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Speed Logic', 'https://speedlogic.com.co', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Speed Logic');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'Tauret Computadores', 'https://tauretcomputadores.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'Tauret Computadores');
INSERT INTO fuente_precio (nombre, sitio_web, descripcion)
SELECT 'TigerTech', 'https://tigercomputadores.com', 'Tienda en linea en Colombia (precios con IVA, en COP).' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM fuente_precio WHERE nombre = 'TigerTech');
-- 5a. Precio de referencia de los 39 productos originales
SET @fuente = (SELECT id_fuente FROM fuente_precio WHERE nombre = 'BuildZone (precio de referencia)' LIMIT 1);
INSERT INTO precio (id_producto, id_fuente, valor, fecha_consulta, url_producto)
SELECT pr.id_producto, @fuente, t.valor, '2026-11-18 00:00:00', NULL
FROM (
  SELECT 'Intel' AS marca, 'Core i5-14600K' AS nombre, 320000 AS valor
  UNION ALL SELECT 'Intel', 'Core i7-14700K', 480000
  UNION ALL SELECT 'Intel', 'Core i9-14900K', 650000
  UNION ALL SELECT 'AMD', 'Ryzen 5 7600X', 300000
  UNION ALL SELECT 'AMD', 'Ryzen 7 7800X3D', 1600000
  UNION ALL SELECT 'AMD', 'Ryzen 7 7700X', 450000
  UNION ALL SELECT 'NVIDIA', 'RTX 4060', 1800000
  UNION ALL SELECT 'NVIDIA', 'RTX 4070', 2600000
  UNION ALL SELECT 'NVIDIA', 'RTX 4070 Ti', 3600000
  UNION ALL SELECT 'AMD', 'Radeon RX 7600', 1500000
  UNION ALL SELECT 'AMD', 'Radeon RX 7800 XT', 2900000
  UNION ALL SELECT 'Kingston', 'Fury Beast 16GB 3200MHz', 220000
  UNION ALL SELECT 'Corsair', 'Vengeance 32GB 6000MHz', 480000
  UNION ALL SELECT 'G.Skill', 'Trident Z5 32GB 6400MHz', 620000
  UNION ALL SELECT 'Corsair', 'Dominator Platinum 64GB 5600MHz', 950000
  UNION ALL SELECT 'Samsung', '990 PRO 1TB NVMe', 520000
  UNION ALL SELECT 'WD', 'Black SN770 1TB NVMe', 330000
  UNION ALL SELECT 'Kingston', 'NV2 1TB NVMe', 250000
  UNION ALL SELECT 'Seagate', 'BarraCuda 2TB HDD', 280000
  UNION ALL SELECT 'ASUS', 'TUF Gaming B760M-Plus WiFi', 750000
  UNION ALL SELECT 'MSI', 'MAG Z790 Tomahawk WiFi', 1250000
  UNION ALL SELECT 'Gigabyte', 'B650 Aorus Elite AX', 950000
  UNION ALL SELECT 'ASRock', 'X670E Steel Legend', 1350000
  UNION ALL SELECT 'DeepCool', 'AK400 (aire)', 140000
  UNION ALL SELECT 'Noctua', 'NH-D15 (aire)', 520000
  UNION ALL SELECT 'Corsair', 'iCUE H100i Elite 240mm (líquida)', 650000
  UNION ALL SELECT 'Arctic', 'Liquid Freezer III 360mm (líquida)', 480000
  UNION ALL SELECT 'Logitech', 'Mouse G502 X', 280000
  UNION ALL SELECT 'Razer', 'Mouse DeathAdder V3', 340000
  UNION ALL SELECT 'Redragon', 'Teclado Kumara K552', 160000
  UNION ALL SELECT 'HyperX', 'Audífonos Cloud III', 420000
  UNION ALL SELECT 'Corsair', 'RM750e 750W 80+ Gold', 480000
  UNION ALL SELECT 'EVGA', '600 BR 600W 80+ Bronze', 260000
  UNION ALL SELECT 'Seasonic', 'Focus GX-850 850W 80+ Gold', 620000
  UNION ALL SELECT 'MSI', 'MPG A1000G 1000W 80+ Gold', 850000
  UNION ALL SELECT 'LG', 'UltraGear 27" QHD 180Hz', 1400000
  UNION ALL SELECT 'Samsung', 'Odyssey G5 32" QHD 165Hz', 1250000
  UNION ALL SELECT 'ASUS', 'TUF VG249Q 24" FHD 165Hz', 750000
  UNION ALL SELECT 'AOC', 'Q27G3XMN 27" QHD Mini-LED', 1550000
) AS t
JOIN marca m ON m.nombre = t.marca
JOIN producto pr ON pr.id_marca = m.id_marca AND (pr.nombre = t.nombre OR pr.nombre LIKE CONCAT('% ', t.nombre))
WHERE NOT EXISTS (SELECT 1 FROM precio x WHERE x.id_producto = pr.id_producto AND x.id_fuente = @fuente);

-- 5b. Precios reales en tiendas colombianas de los 45 productos agregados (consultados el 18/11/2026)
INSERT INTO precio (id_producto, id_fuente, valor, fecha_consulta, url_producto)
SELECT pr.id_producto, f.id_fuente, t.valor, '2026-11-18 00:00:00', t.url
FROM (
  SELECT 'AMD' AS marca, 'Ryzen 7 9800X3D' AS nombre, 'PC Store Colombia' AS tienda, 2470000 AS valor, 'https://www.pcstorecolombia.com/comprar/ryzen-7-9800x3d-procesador/' AS url
  UNION ALL SELECT 'AMD', 'Ryzen 7 9800X3D', 'Mercado Libre Colombia', 2569000, 'https://www.mercadolibre.com.co/procesador-amd-ryzen-7-9800x3d-am5-de-47-ghz-turbo-de-52-ghz/p/MCO44455598'
  UNION ALL SELECT 'AMD', 'Ryzen 5 9600X', 'Mercado Libre Colombia', 970296, 'https://www.mercadolibre.com.co/procesador-amd-ryzen-5-9600x-6-nucleos-am5/p/MCO39391929'
  UNION ALL SELECT 'AMD', 'Ryzen 5 9600X', 'Speed Logic', 1079000, 'https://speedlogic.com.co/tienda/procesadores/procesador-amd-ryzen-5-9600x-54-6core-radeon-am5-no-fan/'
  UNION ALL SELECT 'Intel', 'Core Ultra 7 265K', 'Mercado Libre Colombia', 1690000, 'https://listado.mercadolibre.com.co/intel-core-ultra-7'
  UNION ALL SELECT 'Intel', 'Core Ultra 7 265K', 'Speed Logic', 1845000, 'https://speedlogic.com.co/tienda/procesadores/intel/procesador-intel-core-ultra-7-265k-39-36m-20cor-no-fan/'
  UNION ALL SELECT 'AMD', 'Ryzen 5 5600', 'Mercado Libre Colombia', 599000, 'https://listado.mercadolibre.com.co/amd-ryzen-5-5600-cpu'
  UNION ALL SELECT 'Intel', 'Core i5-12400F', 'Mercado Libre Colombia', 678900, 'https://www.mercadolibre.com.co/procesador-gamer-intel-core-i5-12400f-bx8071512400f-de-6-nucleos-y-44ghz-de-frecuencia/p/MCO18733972'
  UNION ALL SELECT 'Intel', 'Core i5-12400F', 'Falabella Colombia', 899900, 'https://www.falabella.com.co/falabella-co/product/150258373/procesador-intel-core-i5-12400f-de-12-generacion-con-6-nucleos-para-equipos-de-alto-rendimiento/150258374'
  UNION ALL SELECT 'NVIDIA', 'RTX 5060 Ti 16GB', 'Mercado Libre Colombia', 2750000, 'https://listado.mercadolibre.com.co/rtx-5060-ti'
  UNION ALL SELECT 'NVIDIA', 'RTX 5060 Ti 16GB', 'Mi PC Parque Central', 2799000, 'https://www.mipcparquecentral.com/products/msi-geforce-rtx-5060-ti-16g-gaming-oc-en-colombia'
  UNION ALL SELECT 'NVIDIA', 'RTX 5070', 'Speed Logic', 3389000, 'https://speedlogic.com.co/tienda/tarjetas-graficas/nvidia/tarjeta-de-video-nvidia-gigabyte-geforce-rtx-5070-gaming-oc-win-3x-12-gigas/'
  UNION ALL SELECT 'NVIDIA', 'RTX 5070', 'Mercado Libre Colombia', 3430000, 'https://listado.mercadolibre.com.co/rtx-5070'
  UNION ALL SELECT 'AMD', 'Radeon RX 9070 XT', 'Enjoy VideoGames', 3080000, 'https://enjoyvideogames.com.co/product/tarjeta-de-video-sapphire-nitro-radeon-rx-9070-xt-16gb/'
  UNION ALL SELECT 'AMD', 'Radeon RX 9070 XT', 'Cometware', 3863000, 'https://cometware.com/tienda/gigabyte-gaming-radeon-rx-9070-xt-16gb-3-fan/'
  UNION ALL SELECT 'NVIDIA', 'RTX 5060 8GB', 'Enjoy VideoGames', 1690000, 'https://enjoyvideogames.com.co/product/tarjeta-de-video-zotac-gaming-geforce-rtx-5060-low-profile-8gb-gddr7/'
  UNION ALL SELECT 'NVIDIA', 'RTX 5060 8GB', 'Nuevo Punto', 1850000, 'https://www.nuevopunto.com.co/producto/tarjeta-de-video-gigabyte-rtx-5060-8gb-eagle-oc/'
  UNION ALL SELECT 'NVIDIA', 'RTX 5060 8GB', 'Mercado Libre Colombia', 2400000, 'https://www.mercadolibre.com.co/tarjeta-de-video-asus-rtx-5060-8gb-dual-gddr7-128-bits/p/MCO50801559'
  UNION ALL SELECT 'AMD', 'Radeon RX 9060 XT 16GB', 'Mercado Libre Colombia', 2380000, 'https://listado.mercadolibre.com.co/rx-9060-xt-16gb'
  UNION ALL SELECT 'AMD', 'Radeon RX 9060 XT 16GB', 'Enjoy VideoGames', 2800000, 'https://enjoyvideogames.com.co/product/tarjeta-de-video-sapphire-pulse-radeon-rx-9060-xt-16gb/'
  UNION ALL SELECT 'Kingston', 'Fury Beast DDR5 32GB 6000MHz', 'Speed Logic', 2099000, 'https://speedlogic.com.co/tienda/memorias-ram/kit-memoria-ram-ddr5-32g-6000-kingston-fury-beast-rgb-16x2/'
  UNION ALL SELECT 'TeamGroup', 'T-Force Delta RGB 32GB 6000MHz', 'PC Masters Bogotá', 1899000, 'https://pcmastersbogota.com.co/producto/memoria-ram-t-force-delta-rgb-32gb-2-x-16gb-ddr5-6000mhz/'
  UNION ALL SELECT 'TeamGroup', 'T-Force Delta RGB 32GB 6000MHz', 'Enjoy VideoGames', 2120000, 'https://enjoyvideogames.com.co/product/memoria-ram-teamgroup-t-force-delta-rgb-32gb-2-x-16gb-288-pin-ddr5-6000-mhz-cl30-black/'
  UNION ALL SELECT 'Corsair', 'Vengeance LPX 16GB DDR4 3200MHz', 'Mercado Libre Colombia', 306900, 'https://listado.mercadolibre.com.co/corsair-vengeance-lpx-16gb'
  UNION ALL SELECT 'Kingston', 'Fury Beast DDR4 32GB 3200MHz', 'Mercado Libre Colombia', 319999, 'https://listado.mercadolibre.com.co/memoria-ram-pc-kingston-fury-beast-ddr4-32gb-3200mhz-rgb'
  UNION ALL SELECT 'Kingston', 'Fury Beast DDR4 32GB 3200MHz', 'Tauret Computadores', 889000, 'https://tauretcomputadores.com/product/memoria-ram-pc-kingston-fury-beast-ddr4-32gb-3200mt-s'
  UNION ALL SELECT 'XPG', 'Lancer Blade DDR5 32GB 6000MHz', 'Devaltech', 589900, 'https://www.devaltech.com.co/products/memoria-ram-xpg-lancer-blade-white-ddr5-6000mhz-16gb'
  UNION ALL SELECT 'XPG', 'Lancer Blade DDR5 32GB 6000MHz', 'Castor Data', 628240, 'https://www.castordata.com.co/shop/ax5u6000c3032g-slabrwh-memoria-ram-xpg-adata-ddr5-32gb-lancer-blade-rgb-6000mhz-6288'
  UNION ALL SELECT 'XPG', 'Lancer Blade DDR5 32GB 6000MHz', 'Gamers Colombia', 1890000, 'https://gamerscolombia.com/products/memoria-ram-xpg-lancer-blade-ddr5-6000mhz-32gb-cl30-alto-rendimiento-baja-latencia-diseno-compacto'
  UNION ALL SELECT 'Samsung', '990 EVO Plus 1TB NVMe', 'Computadores y Servicio Técnico', 950000, 'https://www.computadoresyserviciotecnico.com/producto/ssdsamsung990evoplus/'
  UNION ALL SELECT 'Samsung', '990 EVO Plus 1TB NVMe', 'Speed Logic', 1089000, 'https://speedlogic.com.co/tienda/unidades-ssd/m-2-nvme/unidad-de-estado-1tb-samsung-ssd-990-evo-plus-7150x6300/'
  UNION ALL SELECT 'Crucial', 'P3 Plus 1TB NVMe', 'Speed Logic', 689000, 'https://speedlogic.com.co/tienda/unidades-ssd/m-2-nvme/unidad-de-estado-solido-m2-nvme-1tb-crucial-p3-plus-5000-x-3600/'
  UNION ALL SELECT 'Crucial', 'P3 Plus 1TB NVMe', 'Digital World', 690000, 'https://digitalworld.com.co/producto/1415-unidad-de-estado-solido-crucial-p3-plus-de-1-tb-pcie-40-3d-nand-nvme-m2-hasta-5000-mbs-ct1000p3pssd8/'
  UNION ALL SELECT 'Kingston', 'NV3 2TB NVMe', 'Mips Colombia', 1000000, 'https://mipscolombia.com.co/producto/ssd-m2-nvme-2280-2tb-kingston-nv3-gen4-6000mbs-cn/'
  UNION ALL SELECT 'Kingston', 'NV3 2TB NVMe', 'Speed Logic', 1159000, 'https://speedlogic.com.co/tienda/unidades-ssd/m-2-nvme/unidad-de-estado-solido-m2-nvme-2tb-kingston-nv3-6000-x-5000/'
  UNION ALL SELECT 'WD', 'Blue SN580 1TB NVMe', 'Mercado Libre Colombia', 279900, 'https://articulo.mercadolibre.com.co/MCO-1342905141-wd-blue-sn580-m2-nvme-ssd-1tb-4150mbs-super-precio-_JM'
  UNION ALL SELECT 'Samsung', '870 EVO 1TB SATA', 'Mercado Libre Colombia', 501346, 'https://listado.mercadolibre.com.co/samsung-870-evo-1tb'
  UNION ALL SELECT 'Samsung', '870 EVO 1TB SATA', 'Discos Duros Colombia', 851750, 'https://discosduros.com.co/samsung-870-1tb-sata-iii-ssd-interno/'
  UNION ALL SELECT 'MSI', 'MAG B650 Tomahawk WiFi', 'Speed Logic', 1119000, 'https://speedlogic.com.co/tienda/placas-madre/amd-placas-madre/board-msi-mag-b650-tomahawk-wifi-2gpu-4-ddr5-ryz/'
  UNION ALL SELECT 'MSI', 'MAG B650 Tomahawk WiFi', 'TigerTech', 1133000, 'https://tigercomputadores.com/producto/mother-msi-b650-mag-tomahawk-wifi-ddr5-am5/'
  UNION ALL SELECT 'ASUS', 'TUF Gaming B650-Plus WiFi', 'Dot Technology', 779900, 'https://dottechnology.co/producto/board-asus-tuf-gaming-b650-plus-wifi/'
  UNION ALL SELECT 'ASUS', 'TUF Gaming B650-Plus WiFi', 'Mercado Libre Colombia', 1112466, 'https://articulo.mercadolibre.com.co/MCO-2654676686-placa-madre-asus-tuf-gaming-b650-plus-wifi-amd-b650-am5-_JM'
  UNION ALL SELECT 'Gigabyte', 'B760M DS3H DDR4', 'Mercado Libre Colombia', 539900, 'https://www.mercadolibre.com.co/tarjeta-madre-gigabyte-b760m-ds3h-ddr4-intel-lga1700/p/MCO23553067'
  UNION ALL SELECT 'MSI', 'B850 Gaming Plus WiFi', 'Enjoy VideoGames', 700000, 'https://enjoyvideogames.com.co/product/motherboard-msi-b850-gaming-plus-wifi-socket-am5-atx/'
  UNION ALL SELECT 'MSI', 'B850 Gaming Plus WiFi', 'Cometware', 798000, 'https://cometware.com/tienda/msi-b850-gaming-plus-wifi-bt/'
  UNION ALL SELECT 'MSI', 'B850 Gaming Plus WiFi', 'Speed Logic', 1039000, 'https://speedlogic.com.co/tienda/placas-madre/amd-placas-madre/board-msi-b850-gaming-plus-wifi-4-gpu-pci-50-4-ddr5-ryzen/'
  UNION ALL SELECT 'ASUS', 'Prime B550M-A WiFi II', 'Enjoy VideoGames', 390000, 'https://enjoyvideogames.com.co/product/motherboard-asus-prime-b550m-a-wifi-ii-socket-am4-micro-atx/'
  UNION ALL SELECT 'ASUS', 'Prime B550M-A WiFi II', 'Mercado Libre Colombia', 604900, 'https://listado.mercadolibre.com.co/asus-b550m'
  UNION ALL SELECT 'Thermalright', 'Peerless Assassin 120 SE (aire)', 'Enjoy VideoGames', 190000, 'https://enjoyvideogames.com.co/product/disipador-thermalright-peerless-assassin-120-se-v3-black-2-fans-120mm-amd-am4-am5-intel-lga-1700-1851/'
  UNION ALL SELECT 'Thermalright', 'Peerless Assassin 120 SE (aire)', 'Mercado Libre Colombia', 230000, 'https://listado.mercadolibre.com.co/thermalright-peerless-assassin-120-se-argb'
  UNION ALL SELECT 'Cooler Master', 'Hyper 212 Black Edition (aire)', 'Mercado Libre Colombia', 177900, 'https://listado.mercadolibre.com.co/hyper-212-black-edition'
  UNION ALL SELECT 'NZXT', 'Kraken 240 (líquida)', 'Mercado Libre Colombia', 708900, 'https://listado.mercadolibre.com.co/nzxt-kraken'
  UNION ALL SELECT 'Thermalright', 'Phantom Spirit 120 SE (aire)', 'Centauri PC', 200000, 'https://centauripc.com/index.php/refrigeracion-aire-thermalright-phantom-spirit-120se/'
  UNION ALL SELECT 'Thermalright', 'Phantom Spirit 120 SE (aire)', 'Encarguelo', 231942, 'https://encarguelo.com/producto/B0D93R3YY9/thermalright-phantom-spirit-120-se-negro-enfriador-de-cpu-doble-ventilador-pwm-tl-c12b-v2-y-torres-dobles-enfriador-de-disipador-de-7-tubos-de-calor-para-am4am5-y-intel'
  UNION ALL SELECT 'Arctic', 'Liquid Freezer III Pro 240mm (líquida)', 'Cometware', 219000, 'https://cometware.com/product-category/refrigeracion/liquida/'
  UNION ALL SELECT 'Logitech', 'Mouse G Pro X Superlight 2', 'Logitech Store Colombia', 499900, 'https://www.logitechstore.com.co/products/mco-2515207914-mouse-gamer-inalambrico-logitech-g-pro-x-superlight-2-negro-jm'
  UNION ALL SELECT 'Logitech', 'Mouse G Pro X Superlight 2', 'Falabella Colombia', 699900, 'https://www.falabella.com.co/falabella-co/product/132944298/Mouse-Gamer-Inalambrico-Logitech-G-Pro-X-Superlight-2-Negro/132944299'
  UNION ALL SELECT 'HyperX', 'Teclado Alloy Origins Core', 'Mercado Libre Colombia', 379900, 'https://listado.mercadolibre.com.co/hyperx-alloy-origins-core'
  UNION ALL SELECT 'HyperX', 'Teclado Alloy Origins Core', 'Alavista', 399900, 'https://alavista.co/producto/teclado-gaming-alloy-origins-core/'
  UNION ALL SELECT 'Razer', 'Audífonos BlackShark V2 X', 'Cadena Multi', 215000, 'https://cadenamulti.co/products/razer-blackshark-v2-x'
  UNION ALL SELECT 'Razer', 'Audífonos BlackShark V2 X', 'Falabella Colombia', 239900, 'https://www.falabella.com.co/falabella-co/product/149258754/Razer-BlackShark-V2-X-Diadema-Ligera-Negra/149258755'
  UNION ALL SELECT 'Logitech', 'Mouse G305 Lightspeed', 'Falabella Colombia', 134900, 'https://www.falabella.com.co/falabella-co/product/126066567/Mouse-Gamer-Inalambrico-Logitech-G305-Lightspeed-12000dpi/126066568'
  UNION ALL SELECT 'Logitech', 'Mouse G305 Lightspeed', 'Mercado Libre Colombia', 167900, 'https://listado.mercadolibre.com.co/logitech-g-305'
  UNION ALL SELECT 'Logitech', 'Mouse G305 Lightspeed', 'Cometware', 179000, 'https://cometware.com/tienda/logitech-g305-blanco-inalambrico-lightspeed/'
  UNION ALL SELECT 'Redragon', 'Teclado K617 Fizz 60%', 'Encarguelo', 153135, 'https://encarguelo.com/producto/B09BVCVTBC/teclado-redragon-k617-fizz-para-juegos-rgb-con-cable-al-60-teclado-mecanico-compacto-intercambiado-en-caliente-de-61-teclas-con-teclas-de-color-blanco-y-gris-interruptor-rojo'
  UNION ALL SELECT 'Redragon', 'Teclado K617 Fizz 60%', 'Mercado Libre Colombia', 190822, 'https://listado.mercadolibre.com.co/redragon-fizz-k617'
  UNION ALL SELECT 'Corsair', 'RM850x 850W 80+ Gold', 'Mercado Libre Colombia', 728000, 'https://listado.mercadolibre.com.co/corsair-850w'
  UNION ALL SELECT 'Corsair', 'RM850x 850W 80+ Gold', 'Speed Logic', 737000, 'https://speedlogic.com.co/tienda/fuentes/fuente-corsair-rm850x-850w-80-plus-gold/'
  UNION ALL SELECT 'MSI', 'MAG A650BN 650W 80+ Bronze', 'Mercado Libre Colombia', 370000, 'https://www.mercadolibre.com.co/msi-mag-a650bn-fuente-de-alimentacion-para-juegos-80-plus-bronze-certified-650w-atx-psu/p/MCO24028888'
  UNION ALL SELECT 'Gigabyte', 'P650G 650W 80+ Gold', 'Doble Click', 280900, 'https://dobleclicknet.com/producto/fuente-de-poder-gigabyte-650w-p650g-80-plus-gold/'
  UNION ALL SELECT 'Gigabyte', 'P650G 650W 80+ Gold', 'Dot Technology', 389900, 'https://dottechnology.co/producto/fuente-gigabyte-p650g-650w-80-plus-gold-no-modular-copia/'
  UNION ALL SELECT 'Corsair', 'CX650 650W 80+ Bronze', 'Speed Logic', 219000, 'https://speedlogic.com.co/tienda/fuentes/fuente-corsair-650w-80-plus-cx650/'
  UNION ALL SELECT 'Corsair', 'CX650 650W 80+ Bronze', 'Mips Colombia', 270000, 'https://mipscolombia.com.co/producto/fuente-de-poder-corsair-650w-80plus-bronze-cx650/'
  UNION ALL SELECT 'Corsair', 'CX650 650W 80+ Bronze', 'Cometware', 272000, 'https://cometware.com/tienda/corsair-650w-cx-80-plus-bronze-no-modular/'
  UNION ALL SELECT 'Corsair', 'RM750x 750W 80+ Gold', 'Mercado Libre Colombia', 533900, 'https://computacion.mercadolibre.com.co/corsair-rm750x'
  UNION ALL SELECT 'Corsair', 'RM750x 750W 80+ Gold', 'Speed Logic', 579000, 'https://speedlogic.com.co/tienda/fuentes/fuente-corsair-rm750w-80-plus-gold-full-modular/'
  UNION ALL SELECT 'Samsung', 'Odyssey G4 27" FHD 240Hz', 'Mercado Libre Colombia', 1705179, 'https://listado.mercadolibre.com.co/monitor-gamer-samsung-27-odyssey-g4-s27bg402'
  UNION ALL SELECT 'LG', 'UltraGear 24GS60F 24" FHD 180Hz', 'Mercado Libre Colombia', 625900, 'https://listado.mercadolibre.com.co/lg-ultragear'
  UNION ALL SELECT 'ASUS', 'TUF VG27AQ1A 27" QHD 170Hz', 'Encarguelo', 1119870, 'https://encarguelo.com/producto/B08CZ8QJTX/monitor-asus-tuf-gaming-27-2k-hdr-vg27aq1a-qhd-2560-x-1440-ips-170-hz-admite-144-hz-1-ms-movimiento-borroso-extremadamente-bajo-altavoz-compatible-con-g-sync-montable-vesa-di'
  UNION ALL SELECT 'ASUS', 'TUF VG27AQ1A 27" QHD 170Hz', 'Mercado Libre Colombia', 1216899, 'https://listado.mercadolibre.com.co/asus-tuf-gaming-vg27aq'
  UNION ALL SELECT 'LG', 'UltraGear 27GS75Q 27" QHD 180Hz', 'Mercado Libre Colombia', 1356900, 'https://listado.mercadolibre.com.co/lg-ultragear-27%22'
  UNION ALL SELECT 'LG', 'UltraGear 27GS75Q 27" QHD 180Hz', 'Compudemano', 1699900, 'https://www.compudemano.com/producto/monitor-gaming-lcd-lg-ultragear-27gs75q-b-27/'
  UNION ALL SELECT 'AOC', '24G15N 24" FHD 180Hz', 'Mercado Libre Colombia', 573750, 'https://listado.mercadolibre.com.co/aoc-24g2-24'
) AS t
JOIN marca m ON m.nombre = t.marca
JOIN producto pr ON pr.id_marca = m.id_marca AND (pr.nombre = t.nombre OR pr.nombre LIKE CONCAT('% ', t.nombre))
JOIN fuente_precio f ON f.nombre = t.tienda
WHERE NOT EXISTS (SELECT 1 FROM precio x WHERE x.id_producto = pr.id_producto AND x.id_fuente = f.id_fuente);

-- ---------------------------------------------------------------------
-- 6. Autor del blog y de los duelos de ejemplo (tabla 'usuario' del modelo
--    original; las cuentas para iniciar sesion estan en 'usuario_cuenta').
--    La contrasena es un hash BCrypt de un valor aleatorio: esta fila no
--    se usa para iniciar sesion.
-- ---------------------------------------------------------------------
INSERT INTO usuario (nombre, apellido, correo, contrasena, fecha_registro)
SELECT 'Equipo', 'BuildZone', 'equipo@buildzone.com', '$2a$10$L7cJkVuhXRLlZhE8dXmH4.6iITRBxz8fpI3ZUg.2ieWz2HBMeqepW', '2025-01-15 09:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario WHERE correo = 'equipo@buildzone.com');
SET @autor = (SELECT id_usuario FROM usuario WHERE correo = 'equipo@buildzone.com' LIMIT 1);

-- ---------------------------------------------------------------------
-- 7. Noticias: los 6 articulos del blog (con categoria y resumen).
--    Las demas se publican desde el panel de administracion > Blog.
-- ---------------------------------------------------------------------
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'Cómo elegir el mejor procesador para tu PC en 2025', 'Guías', 'Antes de comprar un procesador define primero para qué lo vas a usar: gaming, edición de video o trabajo de oficina.', 'Antes de comprar un procesador define primero para qué lo vas a usar: gaming, edición de video o trabajo de oficina. Compara núcleos, hilos y velocidad, y no olvides revisar que sea compatible con tu placa madre antes de decidir.', '2025-02-10 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'Cómo elegir el mejor procesador para tu PC en 2025');
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'Guía para armar tu PC paso a paso sin errores', 'Tutorial', 'Arma tu PC en orden: primero el procesador y la RAM sobre la placa madre, luego móntala en el gabinete, conecta la fuente de poder y por último la tarjeta gráfica.', 'Arma tu PC en orden: primero el procesador y la RAM sobre la placa madre, luego móntala en el gabinete, conecta la fuente de poder y por último la tarjeta gráfica. Revisa cada conexión antes de encender el equipo por primera vez.', '2025-03-18 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'Guía para armar tu PC paso a paso sin errores');
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'Nuevas GPUs lanzadas en 2025: análisis completo', 'Novedades', 'Este año llegaron tarjetas gráficas con mejoras notables en eficiencia energética y trazado de rayos.', 'Este año llegaron tarjetas gráficas con mejoras notables en eficiencia energética y trazado de rayos. Aquí en BuildZone puedes comparar las especificaciones y precios de los modelos más recientes en la sección de Comparador.', '2025-05-06 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'Nuevas GPUs lanzadas en 2025: análisis completo');
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'RAM: ¿cuánta necesitas y qué velocidad elegir?', 'Guías', 'Para uso general 16GB son suficientes, pero si editas video o usas máquinas virtuales, considera 32GB o más.', 'Para uso general 16GB son suficientes, pero si editas video o usas máquinas virtuales, considera 32GB o más. La velocidad en MHz también influye en el rendimiento, especialmente en procesadores AMD.', '2025-06-24 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'RAM: ¿cuánta necesitas y qué velocidad elegir?');
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'Refrigeración líquida vs aire: cuál conviene más', 'Tutorial', 'La refrigeración por aire es más económica y fácil de mantener, mientras que la líquida ofrece mejores temperaturas en procesadores de alto rendimiento.', 'La refrigeración por aire es más económica y fácil de mantener, mientras que la líquida ofrece mejores temperaturas en procesadores de alto rendimiento. La elección depende de tu presupuesto y de cuánto exijas a tu equipo.', '2025-08-12 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'Refrigeración líquida vs aire: cuál conviene más');
INSERT INTO noticia (id_usuario, titulo, categoria, resumen, contenido, fecha_publicacion)
SELECT @autor, 'AMD vs Intel en 2025: ¿quién gana en relación precio-rendimiento?', 'Comparativas', 'AMD suele destacar en relación precio-rendimiento para gaming, mientras que Intel mantiene ventaja en tareas de un solo núcleo.', 'AMD suele destacar en relación precio-rendimiento para gaming, mientras que Intel mantiene ventaja en tareas de un solo núcleo. Usa el Comparador de BuildZone para ver las estadísticas lado a lado antes de decidir.', '2025-10-01 10:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM noticia WHERE titulo = 'AMD vs Intel en 2025: ¿quién gana en relación precio-rendimiento?');
-- Completa categoria y resumen de las noticias que se cargaron antes sin ellos
UPDATE noticia SET categoria = 'Guías' WHERE titulo = 'Cómo elegir el mejor procesador para tu PC en 2025' AND categoria IS NULL;
UPDATE noticia SET resumen = 'Antes de comprar un procesador define primero para qué lo vas a usar: gaming, edición de video o trabajo de oficina.' WHERE titulo = 'Cómo elegir el mejor procesador para tu PC en 2025' AND resumen IS NULL;
UPDATE noticia SET categoria = 'Tutorial' WHERE titulo = 'Guía para armar tu PC paso a paso sin errores' AND categoria IS NULL;
UPDATE noticia SET resumen = 'Arma tu PC en orden: primero el procesador y la RAM sobre la placa madre, luego móntala en el gabinete, conecta la fuente de poder y por último la tarjeta gráfica.' WHERE titulo = 'Guía para armar tu PC paso a paso sin errores' AND resumen IS NULL;
UPDATE noticia SET categoria = 'Novedades' WHERE titulo = 'Nuevas GPUs lanzadas en 2025: análisis completo' AND categoria IS NULL;
UPDATE noticia SET resumen = 'Este año llegaron tarjetas gráficas con mejoras notables en eficiencia energética y trazado de rayos.' WHERE titulo = 'Nuevas GPUs lanzadas en 2025: análisis completo' AND resumen IS NULL;
UPDATE noticia SET categoria = 'Guías' WHERE titulo = 'RAM: ¿cuánta necesitas y qué velocidad elegir?' AND categoria IS NULL;
UPDATE noticia SET resumen = 'Para uso general 16GB son suficientes, pero si editas video o usas máquinas virtuales, considera 32GB o más.' WHERE titulo = 'RAM: ¿cuánta necesitas y qué velocidad elegir?' AND resumen IS NULL;
UPDATE noticia SET categoria = 'Tutorial' WHERE titulo = 'Refrigeración líquida vs aire: cuál conviene más' AND categoria IS NULL;
UPDATE noticia SET resumen = 'La refrigeración por aire es más económica y fácil de mantener, mientras que la líquida ofrece mejores temperaturas en procesadores de alto rendimiento.' WHERE titulo = 'Refrigeración líquida vs aire: cuál conviene más' AND resumen IS NULL;
UPDATE noticia SET categoria = 'Comparativas' WHERE titulo = 'AMD vs Intel en 2025: ¿quién gana en relación precio-rendimiento?' AND categoria IS NULL;
UPDATE noticia SET resumen = 'AMD suele destacar en relación precio-rendimiento para gaming, mientras que Intel mantiene ventaja en tareas de un solo núcleo.' WHERE titulo = 'AMD vs Intel en 2025: ¿quién gana en relación precio-rendimiento?' AND resumen IS NULL;

-- ---------------------------------------------------------------------
-- 8. Comparaciones de ejemplo (duelos de 2 productos)
-- ---------------------------------------------------------------------
INSERT INTO comparacion (id_usuario, titulo, fecha_creacion)
SELECT @autor, 'Duelo: Ryzen 7 7800X3D vs Core i7-14700K', '2025-11-03 15:30:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comparacion WHERE titulo = 'Duelo: Ryzen 7 7800X3D vs Core i7-14700K');
SET @c = (SELECT id_comparacion FROM comparacion WHERE titulo = 'Duelo: Ryzen 7 7800X3D vs Core i7-14700K' LIMIT 1);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Ryzen 7 7800X3D' OR pr.nombre LIKE '% Ryzen 7 7800X3D') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Intel' AND (pr.nombre = 'Core i7-14700K' OR pr.nombre LIKE '% Core i7-14700K') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
INSERT INTO comparacion (id_usuario, titulo, fecha_creacion)
SELECT @autor, 'Duelo: RTX 4070 vs Radeon RX 7800 XT', '2025-11-10 18:00:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comparacion WHERE titulo = 'Duelo: RTX 4070 vs Radeon RX 7800 XT');
SET @c = (SELECT id_comparacion FROM comparacion WHERE titulo = 'Duelo: RTX 4070 vs Radeon RX 7800 XT' LIMIT 1);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'NVIDIA' AND (pr.nombre = 'RTX 4070' OR pr.nombre LIKE '% RTX 4070') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'AMD' AND (pr.nombre = 'Radeon RX 7800 XT' OR pr.nombre LIKE '% Radeon RX 7800 XT') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
INSERT INTO comparacion (id_usuario, titulo, fecha_creacion)
SELECT @autor, 'Duelo: 990 PRO 1TB NVMe vs Black SN770 1TB NVMe', '2026-01-20 11:15:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comparacion WHERE titulo = 'Duelo: 990 PRO 1TB NVMe vs Black SN770 1TB NVMe');
SET @c = (SELECT id_comparacion FROM comparacion WHERE titulo = 'Duelo: 990 PRO 1TB NVMe vs Black SN770 1TB NVMe' LIMIT 1);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Samsung' AND (pr.nombre = '990 PRO 1TB NVMe' OR pr.nombre LIKE '% 990 PRO 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'WD' AND (pr.nombre = 'Black SN770 1TB NVMe' OR pr.nombre LIKE '% Black SN770 1TB NVMe') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
INSERT INTO comparacion (id_usuario, titulo, fecha_creacion)
SELECT @autor, 'Duelo: Vengeance 32GB 6000MHz vs Trident Z5 32GB 6400MHz', '2026-03-05 20:45:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comparacion WHERE titulo = 'Duelo: Vengeance 32GB 6000MHz vs Trident Z5 32GB 6400MHz');
SET @c = (SELECT id_comparacion FROM comparacion WHERE titulo = 'Duelo: Vengeance 32GB 6000MHz vs Trident Z5 32GB 6400MHz' LIMIT 1);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Corsair' AND (pr.nombre = 'Vengeance 32GB 6000MHz' OR pr.nombre LIKE '% Vengeance 32GB 6000MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'G.Skill' AND (pr.nombre = 'Trident Z5 32GB 6400MHz' OR pr.nombre LIKE '% Trident Z5 32GB 6400MHz') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
INSERT INTO comparacion (id_usuario, titulo, fecha_creacion)
SELECT @autor, 'Duelo: AK400 (aire) vs Liquid Freezer III 360mm (líquida)', '2026-06-14 16:20:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM comparacion WHERE titulo = 'Duelo: AK400 (aire) vs Liquid Freezer III 360mm (líquida)');
SET @c = (SELECT id_comparacion FROM comparacion WHERE titulo = 'Duelo: AK400 (aire) vs Liquid Freezer III 360mm (líquida)' LIMIT 1);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'DeepCool' AND (pr.nombre = 'AK400 (aire)' OR pr.nombre LIKE '% AK400 (aire)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);
SET @p = (SELECT pr.id_producto FROM producto pr JOIN marca m ON m.id_marca = pr.id_marca WHERE m.nombre = 'Arctic' AND (pr.nombre = 'Liquid Freezer III 360mm (líquida)' OR pr.nombre LIKE '% Liquid Freezer III 360mm (líquida)') ORDER BY pr.id_producto LIMIT 1);
INSERT INTO detalle_comparacion (id_comparacion, id_producto)
SELECT @c, @p FROM DUAL
WHERE @c IS NOT NULL AND @p IS NOT NULL AND NOT EXISTS (SELECT 1 FROM detalle_comparacion WHERE id_comparacion = @c AND id_producto = @p);

-- ---------------------------------------------------------------------
-- 9. Planes (los mismos que crea la API en DatosInicialesConfig; si ya
--    existen no se tocan)
-- ---------------------------------------------------------------------
INSERT INTO plan_suscripcion (nombre, descripcion, precio, duracion_dias, activo)
SELECT 'Gratuito', 'Acceso basico al catalogo y al comparador de componentes.', 0, 3650, b'1' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM plan_suscripcion WHERE nombre = 'Gratuito');
INSERT INTO plan_suscripcion (nombre, descripcion, precio, duracion_dias, activo)
SELECT 'Premium', 'Guarda tus duelos en Mis comparaciones y publica noticias, tutoriales y guías en el blog.', 29900, 30, b'1' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM plan_suscripcion WHERE nombre = 'Premium');
INSERT INTO plan_suscripcion (nombre, descripcion, precio, duracion_dias, activo)
SELECT 'Premium Anual', 'Todo lo de Premium con dos meses de descuento.', 299000, 365, b'1' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM plan_suscripcion WHERE nombre = 'Premium Anual');
-- La descripcion del Premium dice solo lo que el plan incluye de verdad
-- (guardar comparaciones y publicar en el blog). Se corrige en las bases
-- que ya tenian el plan con una descripcion anterior; si el admin la
-- cambio a mano, no se toca.
UPDATE plan_suscripcion SET descripcion = 'Guarda tus duelos en Mis comparaciones y publica noticias, tutoriales y guías en el blog.'
WHERE nombre = 'Premium' AND descripcion IN (
    'Comparaciones ilimitadas, alertas de precio y soporte prioritario.',
    'Comparaciones ilimitadas y soporte prioritario.');

-- ---------------------------------------------------------------------
-- 10. Cuentas de prueba (rol USUARIO). Contrasena de todas: Prueba1234
--     (guardada como hash BCrypt, igual que las que crea la API)
-- ---------------------------------------------------------------------
INSERT INTO usuario_cuenta (nombre, apellido, username, email, password_hash, rol, estado, fecha_registro)
SELECT 'Laura', 'Gomez', 'laura.gomez', 'laura.gomez@buildzone.com', '$2a$10$hk/bWJM4GTd/cjuHJpEOqu/u6ZlL8gda8c91JRRllpkfTaKek/Ipq', 'USUARIO', 'ACTIVO', '2026-02-11 09:20:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario_cuenta WHERE email = 'laura.gomez@buildzone.com' OR username = 'laura.gomez');
INSERT INTO usuario_cuenta (nombre, apellido, username, email, password_hash, rol, estado, fecha_registro)
SELECT 'Andres', 'Rojas', 'andres.rojas', 'andres.rojas@buildzone.com', '$2a$10$hk/bWJM4GTd/cjuHJpEOqu/u6ZlL8gda8c91JRRllpkfTaKek/Ipq', 'USUARIO', 'ACTIVO', '2026-03-02 14:05:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario_cuenta WHERE email = 'andres.rojas@buildzone.com' OR username = 'andres.rojas');
INSERT INTO usuario_cuenta (nombre, apellido, username, email, password_hash, rol, estado, fecha_registro)
SELECT 'Camila', 'Diaz', 'camila.diaz', 'camila.diaz@buildzone.com', '$2a$10$hk/bWJM4GTd/cjuHJpEOqu/u6ZlL8gda8c91JRRllpkfTaKek/Ipq', 'USUARIO', 'ACTIVO', '2026-04-19 19:40:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario_cuenta WHERE email = 'camila.diaz@buildzone.com' OR username = 'camila.diaz');
INSERT INTO usuario_cuenta (nombre, apellido, username, email, password_hash, rol, estado, fecha_registro)
SELECT 'Santiago', 'Mora', 'santiago.mora', 'santiago.mora@buildzone.com', '$2a$10$hk/bWJM4GTd/cjuHJpEOqu/u6ZlL8gda8c91JRRllpkfTaKek/Ipq', 'USUARIO', 'ACTIVO', '2026-06-07 11:10:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario_cuenta WHERE email = 'santiago.mora@buildzone.com' OR username = 'santiago.mora');
INSERT INTO usuario_cuenta (nombre, apellido, username, email, password_hash, rol, estado, fecha_registro)
SELECT 'Valentina', 'Ruiz', 'valentina.ruiz', 'valentina.ruiz@buildzone.com', '$2a$10$hk/bWJM4GTd/cjuHJpEOqu/u6ZlL8gda8c91JRRllpkfTaKek/Ipq', 'USUARIO', 'INACTIVO', '2026-08-23 16:55:00' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM usuario_cuenta WHERE email = 'valentina.ruiz@buildzone.com' OR username = 'valentina.ruiz');

-- ---------------------------------------------------------------------
-- 11. Suscripciones de las cuentas de prueba. Las fechas se calculan desde
--     el dia en que se ejecuta el script, asi las activas siguen vigentes.
--     Solo se crean si la cuenta todavia no tiene ninguna suscripcion.
-- ---------------------------------------------------------------------
INSERT INTO suscripcion (id_usuario, id_plan, fecha_inicio, fecha_fin, estado)
SELECT u.id_usuario, pl.id_plan, DATE_ADD(CURDATE(), INTERVAL -10 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'ACTIVA'
FROM usuario_cuenta u JOIN plan_suscripcion pl ON pl.nombre = 'Premium'
WHERE u.username = 'laura.gomez' AND NOT EXISTS (SELECT 1 FROM suscripcion s WHERE s.id_usuario = u.id_usuario);
INSERT INTO suscripcion (id_usuario, id_plan, fecha_inicio, fecha_fin, estado)
SELECT u.id_usuario, pl.id_plan, DATE_ADD(CURDATE(), INTERVAL -100 DAY), DATE_ADD(CURDATE(), INTERVAL 265 DAY), 'ACTIVA'
FROM usuario_cuenta u JOIN plan_suscripcion pl ON pl.nombre = 'Premium Anual'
WHERE u.username = 'andres.rojas' AND NOT EXISTS (SELECT 1 FROM suscripcion s WHERE s.id_usuario = u.id_usuario);
INSERT INTO suscripcion (id_usuario, id_plan, fecha_inicio, fecha_fin, estado)
SELECT u.id_usuario, pl.id_plan, DATE_ADD(CURDATE(), INTERVAL -60 DAY), DATE_ADD(CURDATE(), INTERVAL -30 DAY), 'VENCIDA'
FROM usuario_cuenta u JOIN plan_suscripcion pl ON pl.nombre = 'Premium'
WHERE u.username = 'camila.diaz' AND NOT EXISTS (SELECT 1 FROM suscripcion s WHERE s.id_usuario = u.id_usuario);
INSERT INTO suscripcion (id_usuario, id_plan, fecha_inicio, fecha_fin, estado)
SELECT u.id_usuario, pl.id_plan, DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'CANCELADA'
FROM usuario_cuenta u JOIN plan_suscripcion pl ON pl.nombre = 'Premium'
WHERE u.username = 'santiago.mora' AND NOT EXISTS (SELECT 1 FROM suscripcion s WHERE s.id_usuario = u.id_usuario);

COMMIT;

-- ---------------------------------------------------------------------
-- Comprobacion: cuantas filas quedo en cada tabla
-- ---------------------------------------------------------------------
SELECT 'categoria' AS tabla, COUNT(*) AS filas FROM categoria
UNION ALL SELECT 'marca', COUNT(*) FROM marca
UNION ALL SELECT 'producto', COUNT(*) FROM producto
UNION ALL SELECT 'especificacion', COUNT(*) FROM especificacion
UNION ALL SELECT 'fuente_precio', COUNT(*) FROM fuente_precio
UNION ALL SELECT 'precio', COUNT(*) FROM precio
UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'noticia', COUNT(*) FROM noticia
UNION ALL SELECT 'comparacion', COUNT(*) FROM comparacion
UNION ALL SELECT 'detalle_comparacion', COUNT(*) FROM detalle_comparacion
UNION ALL SELECT 'plan_suscripcion', COUNT(*) FROM plan_suscripcion
UNION ALL SELECT 'usuario_cuenta', COUNT(*) FROM usuario_cuenta
UNION ALL SELECT 'suscripcion', COUNT(*) FROM suscripcion;
