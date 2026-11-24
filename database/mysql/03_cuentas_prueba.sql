-- =====================================================================
-- BuildZone - Script 03: cuentas de prueba (SOLO para uso local)
-- Motor: MariaDB 10.4 (XAMPP) / MySQL 8+
--
-- Crea 5 cuentas de rol USUARIO para probar y sustentar el proyecto.
-- Contrasena de todas: Prueba1234
--   laura.gomez@buildzone.com    Premium activo
--   andres.rojas@buildzone.com   Premium Anual activo
--   camila.diaz@buildzone.com    Premium vencido
--   santiago.mora@buildzone.com  Premium cancelado
--   valentina.ruiz@buildzone.com cuenta INACTIVA, sin suscripcion
--
-- IMPORTANTE: el perfil de produccion (prod) NO ejecuta este script. Una
-- pagina publicada en internet no debe tener cuentas con una contrasena
-- que conoce cualquiera que lea el repositorio.
--
-- Orden: despues de 02_datos_completos.sql (necesita los planes).
-- Se puede ejecutar varias veces: no duplica nada.
-- =====================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- ---------------------------------------------------------------------
-- 1. Cuentas de prueba (rol USUARIO). Contrasena de todas: Prueba1234
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
-- 2. Suscripciones de las cuentas de prueba. Las fechas se calculan desde
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
