-- =====================================================================
-- BuildZone - Script 00: estructura de las 10 tablas del modelo original
-- Motor: MariaDB 10.4 (XAMPP) / MySQL 8+
--
-- Misma estructura que la base "buildzone" exportada de phpMyAdmin
-- (categoria, marca, producto, especificacion, fuente_precio, precio,
-- usuario, noticia, comparacion, detalle_comparacion).
--
-- Usa CREATE TABLE IF NOT EXISTS: si la tabla ya existe NO la toca, asi
-- que es seguro en la base actual y permite crear todo desde cero en una
-- base vacia. La API lo ejecuta sola al arrancar (perfil MySQL), seguido
-- de 01_usuarios_suscripciones.sql y 02_datos_completos.sql.
-- =====================================================================

CREATE TABLE IF NOT EXISTS categoria (
    id_categoria INT(11)      NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(100) NOT NULL,
    descripcion  TEXT         DEFAULT NULL,
    PRIMARY KEY (id_categoria),
    UNIQUE KEY nombre (nombre)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS marca (
    id_marca    INT(11)      NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100) NOT NULL,
    descripcion TEXT         DEFAULT NULL,
    PRIMARY KEY (id_marca),
    UNIQUE KEY nombre (nombre)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS producto (
    id_producto  INT(11)      NOT NULL AUTO_INCREMENT,
    id_marca     INT(11)      NOT NULL,
    id_categoria INT(11)      NOT NULL,
    nombre       VARCHAR(150) NOT NULL,
    descripcion  TEXT         DEFAULT NULL,
    imagen       VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id_producto),
    KEY fk_producto_marca (id_marca),
    KEY fk_producto_categoria (id_categoria),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
    CONSTRAINT fk_producto_marca FOREIGN KEY (id_marca) REFERENCES marca (id_marca)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS especificacion (
    id_especificacion INT(11)      NOT NULL AUTO_INCREMENT,
    id_producto       INT(11)      NOT NULL,
    atributo          VARCHAR(100) NOT NULL,
    valor             VARCHAR(255) NOT NULL,
    unidad            VARCHAR(50)  DEFAULT NULL,
    PRIMARY KEY (id_especificacion),
    KEY fk_especificacion_producto (id_producto),
    CONSTRAINT fk_especificacion_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fuente_precio (
    id_fuente   INT(11)      NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100) NOT NULL,
    sitio_web   VARCHAR(255) DEFAULT NULL,
    descripcion TEXT         DEFAULT NULL,
    PRIMARY KEY (id_fuente)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS precio (
    id_precio      INT(11)       NOT NULL AUTO_INCREMENT,
    id_producto    INT(11)       NOT NULL,
    id_fuente      INT(11)       NOT NULL,
    valor          DECIMAL(12,2) NOT NULL,
    fecha_consulta DATETIME      NOT NULL,
    url_producto   VARCHAR(255)  DEFAULT NULL,
    PRIMARY KEY (id_precio),
    KEY fk_precio_producto (id_producto),
    KEY fk_precio_fuente (id_fuente),
    CONSTRAINT fk_precio_fuente FOREIGN KEY (id_fuente) REFERENCES fuente_precio (id_fuente),
    CONSTRAINT fk_precio_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuario (
    id_usuario     INT(11)      NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(50)  NOT NULL,
    apellido       VARCHAR(50)  NOT NULL,
    correo         VARCHAR(100) DEFAULT NULL,
    contrasena     VARCHAR(255) NOT NULL,
    fecha_registro DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY correo (correo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS noticia (
    id_noticia        INT(11)      NOT NULL AUTO_INCREMENT,
    id_usuario        INT(11)      NOT NULL,
    titulo            VARCHAR(200) NOT NULL,
    contenido         TEXT         NOT NULL,
    fecha_publicacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_noticia),
    KEY fk_noticia_usuario (id_usuario),
    CONSTRAINT fk_noticia_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS comparacion (
    id_comparacion INT(11)      NOT NULL AUTO_INCREMENT,
    id_usuario     INT(11)      NOT NULL,
    titulo         VARCHAR(150) DEFAULT NULL,
    fecha_creacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_comparacion),
    KEY fk_comparacion_usuario (id_usuario),
    CONSTRAINT fk_comparacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS detalle_comparacion (
    id_detalle     INT(11) NOT NULL AUTO_INCREMENT,
    id_comparacion INT(11) NOT NULL,
    id_producto    INT(11) NOT NULL,
    PRIMARY KEY (id_detalle),
    KEY fk_detalle_comparacion (id_comparacion),
    KEY fk_detalle_producto (id_producto),
    CONSTRAINT fk_detalle_comparacion FOREIGN KEY (id_comparacion) REFERENCES comparacion (id_comparacion) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
