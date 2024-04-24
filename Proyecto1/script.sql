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
    telefono     VARCHAR(20) NOT NULL,
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
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL
);

CREATE TEMPORARY TABLE empr.temp_producto_orden (
    id_lineastabla      INT AUTO INCREMENT,
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL,
    linea_orden          INT NOT NULL,
    id_vendedor          INT NOT NULL
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
    telefono     VARCHAR(20) NOT NULL,
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
    id                  INT NOT NULL AUTO_INCREMENT,
    id_orden             INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE IF NOT EXISTS empr.PRODUCTO_ORDEN (
    id_lineastabla      INT AUTO_INCREMENT,
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL,
    linea_orden          INT NOT NULL,
    id_vendedor          INT NOT NULL,
    PRIMARY KEY (id_lineastabla),
    FOREIGN KEY (id_orden) REFERENCES orden(id_orden),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
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

--  // 5. VENDEDOR
INSERT INTO empr.VENDEDOR (id_vendedor, nombre, id_pais) SELECT id_vendedor, nombre, id_pais FROM temp_cliente

-- // 6. ORDEN
INSERT INTO empr.ORDEN (id_orden, fecha, id_cliente) SELECT id_orden, fecha, id_cliente FROM temp_orden;

--  // 7. PRODUCTO_ORDEN
INSERT INTO empr.PRODUCTO_ORDEN (id_orden, id_producto, cantidad, linea_orden, id_vendedor) SELECT id_orden, id_producto, cantidad, linea_orden, id_vendedor FROM temp_producto_orden;

--//D. Elimina las tablas temporales
DROP TEMPORARY TABLE empr.temp_pais, temp_categoria, temp_cliente, temp_orden, temp_producto, temp_vendedor;

-- ELIMINAR MODELO 
DROP TABLE empr.categoria, pais, cliente, producto, vendedor, orden, producto_orden;


-- ************************ CONSULTAS ************************************
--1
--Mostrar el cliente que más ha comprado. Se debe de mostrar el id del cliente, nombre, apellido, país y monto total.
SELECT 
    c.id_cliente,
    c.nombre,
    c.apellido,
    p.nombre AS pais,
    COUNT(o.id_orden) AS numero_compras,
    SUM(po.cantidad * pr.precio) AS monto_total
FROM 
    empr.ORDEN o
INNER JOIN 
    empr.CLIENTE c ON c.id_cliente = o.id_cliente
INNER JOIN 
    empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
INNER JOIN 
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
INNER JOIN 
    empr.PAIS p ON c.id_pais = p.id_pais
GROUP BY 
    c.id_cliente
ORDER BY 
    monto_total DESC
LIMIT 1;

-- 2
--  
SELECT
            max_comp.id_producto AS id_prod_mas_comp,
            max_comp.nombre AS nombre_prod_mas_comp,
            max_comp.categoria AS categoria_prod_mas_comp,
            max_comp.cantidad AS cant_u_prod_mas_comp,
            max_comp.monto AS monto_prod_mas_comp,
            min_comp.id_producto AS id_prod_menos_comp,
            min_comp.nombre AS nombre_prod_menos_comp,
            min_comp.categoria AS categoria_prod_menos_comp,
            min_comp.cantidad AS cant_u_prod_menos_comp,
            min_comp.monto AS monto_prod_menos_comp
        FROM
            (SELECT
                pr.id_producto,
                pr.nombre,
                c.nombre AS categoria,
                SUM(po.cantidad) AS cantidad,
                SUM(po.cantidad * pr.precio) AS monto
            FROM
                empr.PRODUCTO pr
            JOIN
                empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
            JOIN
                empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
            GROUP BY
                pr.id_producto
            ORDER BY
                cantidad DESC
            LIMIT 1) AS max_comp
        CROSS JOIN
            (SELECT
                pr.id_producto,
                pr.nombre,
                c.nombre AS categoria,
                SUM(po.cantidad) AS cantidad,
                SUM(po.cantidad * pr.precio) AS monto
            FROM
                empr.PRODUCTO pr
            JOIN
                empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
            JOIN
                empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
            GROUP BY
                pr.id_producto
            ORDER BY
                cantidad ASC
            LIMIT 1) AS min_comp;


--- 3
---Mostrar a la persona que más ha vendido. Se debe mostrar el id del vendedor, nombre del vendedor, monto total vendido
SELECT
            v.id_vendedor,
            v.nombre AS nombre_vendedor,
            SUM(po.cantidad * pr.precio) AS monto_total_vendido
        FROM
            empr.VENDEDOR v
        JOIN
            empr.PRODUCTO_ORDEN po ON v.id_vendedor = po.id_vendedor
        JOIN
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY
            v.id_vendedor
        ORDER BY
            monto_total_vendido DESC
        LIMIT 1;

-- 4
-- 4. Mostrar el país que más y menos ha vendido. Debe mostrar el nombre del país y el monto. (Una sola consulta).
SELECT 
            p.nombre AS nombre_pais_menos_vendido, 
            SUM(po.cantidad*pr.precio) AS monto
        FROM 
            empr.PRODUCTO_ORDEN po
        INNER JOIN 
            empr.VENDEDOR v ON po.id_vendedor = v.id_vendedor
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
        GROUP BY 
            p.nombre
        ORDER BY 
            monto ASC    
        LIMIT 1;

        -----------
SELECT 
            p.nombre AS nombre_pais_mas_vendido, 
            SUM(po.cantidad*pr.precio) AS monto
        FROM 
            empr.PRODUCTO_ORDEN po
        INNER JOIN 
            empr.VENDEDOR v ON po.id_vendedor = v.id_vendedor
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
        GROUP BY 
            p.nombre
        ORDER BY 
            monto DESC    
        LIMIT 1;

-- 5
-- Top 5 de países que más han comprado en orden ascendente. Se le solicita mostrar el id del país, nombre y monto total.
SELECT 
            p.id_pais,
            p.nombre AS nombre_pais,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.PAIS p
        INNER JOIN 
            empr.CLIENTE c ON p.id_pais = c.id_pais
        INNER JOIN 
            empr.ORDEN o ON c.id_cliente = o.id_cliente
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            p.id_pais, p.nombre
        ORDER BY 
            monto_total ASC
        LIMIT 5;



-- 6
-- Mostrar la categoría que más y menos se ha comprado. Debe de mostrar el nombre de la categoría y cantidad de unidades. (Una sola consulta).
 SELECT 
            ca.nombre AS nombre_categoria_menos_vendida, 
            SUM(po.cantidad) AS unidades
        FROM 
            empr.PRODUCTO_ORDEN po
		INNER JOIN
			empr.orden o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.CLIENTE c ON o.id_cliente = c.id_cliente
        INNER JOIN 
            empr.PAIS p ON c.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
		INNER JOIN
			empr.categoria ca ON ca.id_categoria = pr.id_categoria
        GROUP BY 
            ca.nombre
        ORDER BY 
            unidades ASC    
        LIMIT 1;
---------------------
 SELECT 
            ca.nombre AS nombre_categoria_mas_vendida, 
            SUM(po.cantidad) AS unidades
        FROM 
            empr.PRODUCTO_ORDEN po
		INNER JOIN
			empr.orden o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.CLIENTE c ON o.id_cliente = c.id_cliente
        INNER JOIN 
            empr.PAIS p ON c.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
		INNER JOIN
			empr.categoria ca ON ca.id_categoria = pr.id_categoria
        GROUP BY 
            ca.nombre
        ORDER BY 
            unidades desc    
        LIMIT 1;

-- 7
-- Mostrar la categoría más comprada por cada país. Se debe de mostrar el nombre del país, nombre de la categoría y cantidad de unidades.
SELECT 
            p.nombre AS nombre_pais,
            cat.nombre AS nombre_categoria,
            SUM(po.cantidad) AS cantidad_unidades
        FROM 
            empr.PAIS p
        INNER JOIN 
            empr.CLIENTE c ON p.id_pais = c.id_pais
        INNER JOIN 
            empr.ORDEN o ON c.id_cliente = o.id_cliente
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        INNER JOIN 
            empr.CATEGORIA cat ON pr.id_categoria = cat.id_categoria
        GROUP BY 
            p.id_pais, cat.id_categoria
        HAVING 
            SUM(po.cantidad) = (
                SELECT 
                    MAX(sub.total_unidades)
                FROM 
                    (SELECT 
                        p.id_pais,
                        cat.id_categoria,
                        SUM(po.cantidad) AS total_unidades
                    FROM 
                        empr.PAIS p
                    INNER JOIN 
                        empr.CLIENTE c ON p.id_pais = c.id_pais
                    INNER JOIN 
                        empr.ORDEN o ON c.id_cliente = o.id_cliente
                    INNER JOIN 
                        empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
                    INNER JOIN 
                        empr.PRODUCTO pr ON po.id_producto = pr.id_producto
                    INNER JOIN 
                        empr.CATEGORIA cat ON pr.id_categoria = cat.id_categoria
                    GROUP BY 
                        p.id_pais, cat.id_categoria) AS sub
                WHERE 
                    sub.id_pais = p.id_pais
            );

-- 8
-- Mostrar las ventas por mes de Inglaterra. Debe de mostrar el número del mes y el monto.
SELECT 
            MONTH(o.fecha) AS numero_mes,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.VENDEDOR v
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON v.id_vendedor = po.id_vendedor
        INNER JOIN
            empr.ORDEN o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        WHERE 
            p.nombre = 'Inglaterra'
        GROUP BY 
            numero_mes
        ORDER BY 
            numero_mes;


-- 9
-- Mostrar el mes con más y menos ventas. Se debe de mostrar el número de mes y monto.
SELECT 
            MONTH(o.fecha) AS numero_mes_mas_vendido,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.ORDEN o
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            numero_mes_mas_vendido
        ORDER BY 
            monto_total DESC
        LIMIT 1;
---------------------------
SELECT 
            MONTH(o.fecha) AS numero_mes_menos_vendido,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.ORDEN o
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            numero_mes_menos_vendido
        ORDER BY 
            monto_total ASC
        LIMIT 1;


-- 10
-- Mostrar las ventas de cada producto de la categoría deportes. Se debe de mostrar el id del producto, nombre y monto

 SELECT 
            pr.id_producto,
            pr.nombre AS nombre_producto,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.PRODUCTO pr
        JOIN 
            empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
        JOIN 
            empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
        WHERE 
            c.nombre = 'deportes'
        GROUP BY 
            pr.id_producto, pr.nombre;
