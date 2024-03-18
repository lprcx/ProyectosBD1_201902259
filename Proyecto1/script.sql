--- BASE DE DATOS
CREATE DATABASE IF NOT EXISTS empr;

---- TABLAS TEMPORALES
CREATE TEMPORARY TABLE empr.temp_categoria (
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_pais (
    id_pais INT NOT NULL,
    nombre  VARCHAR(100) NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_cliente (
    id_cliente   INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    direccion    VARCHAR(200) NOT NULL,
    telefono     VARCHAR(15) NOT NULL,
    tarjeta      VARCHAR(50) NOT NULL,
    edad         INT NOT NULL,
    salario      INT NOT NULL,
    genero       VARCHAR(1) NOT NULL,
    id_pais      INT NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_producto (
    id_producto            INT NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    precio                 DECIMAL(5,2) NOT NULL,
    id_categoria           INT NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_vendedor (
    id_vendedor  INT NOT NULL,
    nombre       VARCHAR(200) NOT NULL,
    id_pais      INT NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_orden (
    id_orden             INT NOT NULL,
    linea_orden          INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    id_vendedor          INT NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_producto_orden (
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL
);


------ MODELO DE DATOS ---------
CREATE TABLE IF NOT EXISTS empr.CATEGORIA (
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE IF NOT EXISTS empr.PAIS (
    id_pais INT NOT NULL,
    nombre  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_pais)
);

CREATE TABLE IF NOT EXISTS empr.CLIENTE (
    id_cliente   INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    direccion    VARCHAR(200) NOT NULL,
    telefono     VARCHAR(15) NOT NULL,
    tarjeta      VARCHAR(50) NOT NULL,
    edad         INT NOT NULL,
    salario      INT NOT NULL,
    genero       VARCHAR(1) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

CREATE TABLE IF NOT EXISTS empr.PRODUCTO (
    id_producto            INT NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    precio                 DECIMAL(5,2) NOT NULL,
    id_categoria           INT NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE IF NOT EXISTS empr.VENDEDOR (
    id_vendedor  INT NOT NULL,
    nombre       VARCHAR(200) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

CREATE TABLE IF NOT EXISTS empr.ORDEN (
    id_orden             INT NOT NULL,
    linea_orden          INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    id_vendedor          INT NOT NULL,
    PRIMARY KEY (id_orden),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

CREATE TABLE IF NOT EXISTS empr.PRODUCTO_ORDEN (
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES orden(id_orden),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);


-- carga de datos
--// 1. CATEGORIA
INSERT INTO empr.CATEGORIA (id_categoria, nombre) SELECT id_categoria, nombre FROM temp_categoria;

-- // 2. PAIS
INSERT INTO empr.PAIS (id_pais, nombre) SELECT id_pais, nombre FROM temp_pais;

--  // 3. CLIENTE
INSERT INTO empr.CLIENTE (id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais) SELECT id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais FROM temp_cliente;

--  // 4. PRODUCTO
INSERT INTO empr.PRODUCTO (id_producto, nombre, precio, id_categoria) SELECT id_producto, nombre, precio, id_categoria FROM temp_producto;

-- // 5. ORDEN
INSERT INTO empr.ORDEN (id_orden, linea_orden, fecha, id_cliente, id_vendedor) SELECT id_orden, linea_orden, fecha, id_cliente, id_vendedor FROM temp_orden;

--  // 6. PRODUCTO_ORDEN
INSERT INTO empr.PRODUCTO_ORDEN (id_orden, linea_orden, fecha, id_cliente, id_vendedor) SELECT id_orden, linea_orden, fecha, id_cliente, id_vendedor FROM temp_orden;

--//D. Elimina las tablas temporales
DROP TEMPORARY TABLE empr.temp_pais, temp_categoria, temp_cliente, temp_orden, temp_producto, temp_vendedor;

-- ELIMINAR MODELO 
DROP TABLE empr.categoria, pais, cliente, producto, vendedor, orden, producto_orden;


-- ************************ CONSULTAS ************************************

--Mostrar la categoría más comprada por cada país. Se debe de mostrar el nombre del 
-- país, nombre de la categoría y cantidad de unidades.

SELECT
    p.nombre AS nombre_pais,
    c.nombre AS nombre_categoria,
    SUM(po.cantidad) AS cantidad_unidades
FROM
    empr.ORDEN o
JOIN
    empr.CLIENTE cl ON o.id_cliente = cl.id_cliente
JOIN
    empr.PAIS p ON cl.id_pais = p.id_pais
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
JOIN
    empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
GROUP BY
    p.nombre,
    c.nombre
ORDER BY
    p.nombre,
    SUM(po.cantidad) DESC;


-- 1. ----------
SELECT
    cl.id_cliente,
    cl.nombre,
    cl.apellido,
    p.nombre AS pais,
    SUM(po.cantidad * pr.precio) AS monto_total
FROM
    empr.CLIENTE cl
JOIN
    empr.PAIS p ON cl.id_pais = p.id_pais
JOIN
    empr.ORDEN o ON cl.id_cliente = o.id_cliente
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
GROUP BY
    cl.id_cliente
ORDER BY
    monto_total DESC
LIMIT 1;


---------------2-----------------
SELECT
    pr.id_producto,
    pr.nombre AS nombre_producto,
    c.nombre AS categoria,
    SUM(po.cantidad) AS cantidad_unidades,
    SUM(po.cantidad * pr.precio) AS monto_vendido
FROM
    empr.PRODUCTO pr
JOIN
    empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    pr.id_producto
ORDER BY
    cantidad_unidades DESC
LIMIT 1;

SELECT
    pr.id_producto,
    pr.nombre AS nombre_producto,
    c.nombre AS categoria,
    SUM(po.cantidad) AS cantidad_unidades,
    SUM(po.cantidad * pr.precio) AS monto_vendido
FROM
    empr.PRODUCTO pr
JOIN
    empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    pr.id_producto
ORDER BY
    cantidad_unidades ASC
LIMIT 1;


----------------------3---------------------
SELECT
    pr.id_producto,
    pr.nombre AS nombre_producto,
    c.nombre AS categoria,
    SUM(po.cantidad) AS cantidad_unidades,
    SUM(po.cantidad * pr.precio) AS monto_vendido
FROM
    empr.PRODUCTO pr
JOIN
    empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    pr.id_producto
ORDER BY
    cantidad_unidades DESC
LIMIT 1;

SELECT
    pr.id_producto,
    pr.nombre AS nombre_producto,
    c.nombre AS categoria,
    SUM(po.cantidad) AS cantidad_unidades,
    SUM(po.cantidad * pr.precio) AS monto_vendido
FROM
    empr.PRODUCTO pr
JOIN
    empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    pr.id_producto
ORDER BY
    cantidad_unidades ASC
LIMIT 1;


------------4----------
SELECT
    v.id_vendedor,
    v.nombre AS nombre_vendedor,
    SUM(po.cantidad * pr.precio) AS monto_total_vendido
FROM
    empr.VENDEDOR v
JOIN
    empr.ORDEN o ON v.id_vendedor = o.id_vendedor
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
GROUP BY
    v.id_vendedor
ORDER BY
    monto_total_vendido DESC
LIMIT 1;


-------5---------
SELECT
    p.nombre AS nombre_pais,
    SUM(po.cantidad * pr.precio) AS monto_total_vendido
FROM
    empr.PAIS p
JOIN
    empr.CLIENTE cl ON p.id_pais = cl.id_pais
JOIN
    empr.ORDEN o ON cl.id_cliente = o.id_cliente
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
GROUP BY
    p.nombre
ORDER BY
    monto_total_vendido DESC
LIMIT 1;

SELECT
    p.nombre AS nombre_pais,
    SUM(po.cantidad * pr.precio) AS monto_total_vendido
FROM
    empr.PAIS p
JOIN
    empr.CLIENTE cl ON p.id_pais = cl.id_pais
JOIN
    empr.ORDEN o ON cl.id_cliente = o.id_cliente
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
GROUP BY
    p.nombre
ORDER BY
    monto_total_vendido ASC
LIMIT 1;

----------6---------
SELECT
    p.id_pais,
    p.nombre AS nombre_pais,
    SUM(po.cantidad * pr.precio) AS monto_total
FROM
    empr.PAIS p
JOIN
    empr.CLIENTE cl ON p.id_pais = cl.id_pais
JOIN
    empr.ORDEN o ON cl.id_cliente = o.id_cliente
JOIN
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
GROUP BY
    p.id_pais,
    p.nombre
ORDER BY
    monto_total DESC
LIMIT 5;


---7---
SELECT
    c.nombre AS nombre_categoria,
    SUM(po.cantidad) AS cantidad_unidades
FROM
    empr.CATEGORIA c
JOIN
    empr.PRODUCTO pr ON c.id_categoria = pr.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    c.nombre
ORDER BY
    cantidad_unidades DESC
LIMIT 1;

SELECT
    c.nombre AS nombre_categoria,
    SUM(po.cantidad) AS cantidad_unidades
FROM
    empr.CATEGORIA c
JOIN
    empr.PRODUCTO pr ON c.id_categoria = pr.id_categoria
JOIN
    empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
GROUP BY
    c.nombre
ORDER BY
    cantidad_unidades ASC
LIMIT 1;
 