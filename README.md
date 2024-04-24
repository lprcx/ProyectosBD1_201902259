# ProyectosBD1_201902259

# MANUAL TECNICO

## Requerimientos

### Tecnologías
- nodejs: v18.17.0
- npm 9.6.7
- mysql 8.1.0

### Herramientas
- Visual Studio Code
- MySQL Workbench / DataGrip
- Postman

## MODELO DE LA BASE DE DATOS

### ENTIDADES
- PAIS
- CLIENTE
- VENDEDOR
- ORDEN
- PRODUCTO_ORDEN
- PRODUCTO
- CATEGORIA

### RELACIONES
- PAIS - CLIENTE
- PAIS - VENDEDOR
- VENDEDOR- PRODUCTO_ORDEN
- CLIENTE - ORDEN
- PRODUCTO_ORDEN - ORDEN
- PRODUCTO_ORDEN - PRODUCTO
- PRODUCTO - CATEGORIA

## Logica de la base de datos
Se conoce que la base de datos es de un pequeño emprendimiento. Como todo negocio, se manejan clientes y vendedores, cada uno con atributos especificos. Por ejemplo sus identificadores personales, nombres y apellidos, pero a diferencia de los vendedores, cuando se trata de clientes tienen más prioridad y por lo tanto más atributos. Dentro de dichos atributos se encuentra la nacionalidad, para la que se tiene una tabla con identificadores de cada país.

Existen productos y categorías, estos son necesarios para las ordenes de compra. Las ordenes de compra se componen de identificador, fecha, cliente, vendedor, lineas, etc. Para obtenes una orden se dividió en 2 entidades: orden y producto_orden.

La entidad orden contiene los datos esenciales de una orden: el identificador de la orden, así como la fecha en que esta fue creada y el identificador del cliente. 

La entidad producto_orden es la parte complementaria de la orden que se asocia más al vendedor y los productos adquiridos.


## Modelo Conceptual
![Modelo Conceptual](./Proyecto1/modelo/Img/Modelo%20Conceptual.png)

Este modelo está basado en relaciones simples

## Modelo Lógico
![Modelo Lógico](./Proyecto1/modelo/Img/Modelo%20Logico.png)

En este modelo se utilizaron llaves primarias en las distintas entidades para establecer relaciones que permitan conectar los datos. 

También se utilizaron relaciones de uno a muchos.

## Modelo Físico
![Modelo Físico](./Proyecto1/modelo/Img/Modelo%20Fisico.png)

En este modelo se logran visualizar las llaves foraneas, que corresponden a las llaves primarias de otras tablas.
De este modo se observa más detalladamente el modelo realizado.


## Creación de la base de datos
- Se realiza la creación del modelo con la peticion "crearmodelo"
- La carga de datos para las bases se realiza mediante la peticion cargarmodelo
Al realizar esta petición se cargan los datos de los archivos en formato csv previamente almacenados.
- Luego de lo anterior se pueden realizar distintas consultas de acuerdo a lo requerido.

Para la creación de la base de datos se utilizó el siguiente script en lenguaje MySQL

```SQL
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
    cl.id_cliente,
    cl.nombre,
    cl.apellido,
    p.nombre AS pais,
    COUNT(DISTINCT o.id_orden) AS numero_compras,
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

-- 2
--  
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

-- Producto menos comprado
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
    nombre_pais_masvendido,
    monto_pais_masvendido,
    nombre_pais_menosvendido,
    monto_pais_menosvendido
FROM
    (SELECT 
        p.nombre AS nombre_pais_masvendido,
        SUM(po.cantidad * pr.precio) AS monto_pais_masvendido
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
        monto_pais_masvendido DESC
    LIMIT 1) AS pais_masvendido,
    (SELECT 
        p.nombre AS nombre_pais_menosvendido,
        SUM(po.cantidad * pr.precio) AS monto_pais_menosvendido
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
        monto_pais_menosvendido ASC
    LIMIT 1) AS pais_menosvendido;

-- 5
-- Top 5 de países que más han comprado en orden ascendente. Se le solicita mostrar el id del país, nombre y monto total.
SELECT 
    id_pais,
    nombre_pais,
    monto_total_comprado
FROM (
    SELECT 
        p.id_pais,
        p.nombre AS nombre_pais,
        SUM(po.cantidad * pr.precio) AS monto_total_comprado
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
        p.id_pais, p.nombre
    ORDER BY
        monto_total_comprado DESC
    LIMIT 5
) AS top_countries
ORDER BY
    monto_total_comprado ASC;


-- 6
-- Mostrar la categoría que más y menos se ha comprado. Debe de mostrar el nombre de la categoría y cantidad de unidades. (Una sola consulta).
WITH CategoriasRank AS (
    SELECT 
        c.nombre AS nombre_categoria,
        SUM(po.cantidad) AS cantidad_unidades,
        RANK() OVER (ORDER BY SUM(po.cantidad) DESC) AS rank_mas_vendida,
        RANK() OVER (ORDER BY SUM(po.cantidad)) AS rank_menos_vendida
    FROM 
        empr.CATEGORIA c
    JOIN 
        empr.PRODUCTO pr ON c.id_categoria = pr.id_categoria
    JOIN 
        empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
    GROUP BY 
        c.id_categoria
)
SELECT 
    MAX(CASE WHEN rank_mas_vendida = 1 THEN nombre_categoria END) AS categoria_mas_vendida,
    MAX(CASE WHEN rank_mas_vendida = 1 THEN cantidad_unidades END) AS u_mas_vendida,
    MAX(CASE WHEN rank_menos_vendida = 1 THEN nombre_categoria END) AS categoria_menos_vendida,
    MAX(CASE WHEN rank_menos_vendida = 1 THEN cantidad_unidades END) AS u_menos_vendida
FROM 
    CategoriasRank;

-- 7
-- Mostrar la categoría más comprada por cada país. Se debe de mostrar el nombre del país, nombre de la categoría y cantidad de unidades.
SELECT 
    nombre_pais,
    nombre_categoria,
    cantidad_unidades
FROM (
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
) AS unidades_por_categoria_pais
WHERE
    cantidad_unidades = (
        SELECT MAX(subquery.cantidad_unidades)
        FROM (
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
        ) AS subquery
        WHERE
            subquery.nombre_pais = unidades_por_categoria_pais.nombre_pais
    )
ORDER BY
    nombre_pais;

-- 8
-- Mostrar las ventas por mes de Inglaterra. Debe de mostrar el número del mes y el monto.
SELECT 
    MONTH(o.fecha) AS numero_mes,
    SUM(po.cantidad * pr.precio) AS monto
FROM 
    empr.ORDEN o
JOIN 
    empr.CLIENTE c ON o.id_cliente = c.id_cliente
JOIN 
    empr.PAIS p ON c.id_pais = p.id_pais
JOIN 
    empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
JOIN 
    empr.PRODUCTO pr ON po.id_producto = pr.id_producto
WHERE 
    p.nombre = 'Inglaterra'
GROUP BY 
    MONTH(o.fecha)
ORDER BY 
    numero_mes;


-- 9
-- Mostrar el mes con más y menos ventas. Se debe de mostrar el número de mes y monto.
SELECT
    max_month.num_mes AS num_mes_mas_ventas,
    MONTHNAME(max_month.fecha) AS nombre_mes_mas_ventas,
    max_month.monto AS monto_mes_mas_ventas,
    min_month.num_mes AS num_mes_menos_ventas,
    MONTHNAME(min_month.fecha) AS nombre_mes_menos_ventas,
    min_month.monto AS monto_mes_menos_ventas
FROM
    (SELECT
        MONTH(o.fecha) AS num_mes,
        o.fecha AS fecha,
        SUM(po.cantidad * pr.precio) AS monto
    FROM
        empr.ORDEN o
    JOIN
        empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
    JOIN
        empr.PRODUCTO pr ON po.id_producto = pr.id_producto
    GROUP BY
        MONTH(o.fecha)
    ORDER BY
        monto DESC
    LIMIT 1) AS max_month
CROSS JOIN
    (SELECT
        MONTH(o.fecha) AS num_mes,
        o.fecha AS fecha,
        SUM(po.cantidad * pr.precio) AS monto
    FROM
        empr.ORDEN o
    JOIN
        empr.PRODUCTO_ORDEN po ON o.id_orden = po.id_orden
    JOIN
        empr.PRODUCTO pr ON po.id_producto = pr.id_producto
    GROUP BY
        MONTH(o.fecha)
    ORDER BY
        monto ASC
    LIMIT 1) AS min_month;


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

```

