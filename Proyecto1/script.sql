--- BASE DE DATOS
CREATE DATABASE IF NOT EXISTS empr;

---- TABLAS TEMPORALES
CREATE TEMPORARY TABLE categoria (
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL
);

CREATE TEMPORARY TABLE pais (
    id_pais INT NOT NULL,
    nombre  VARCHAR(100) NOT NULL
);

CREATE TEMPORARY TABLE cliente (
    id_cliente   INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    direccion    VARCHAR(200) NOT NULL,
    telefono     VARCHAR(8) NOT NULL,
    tarjeta      INT NOT NULL,
    edad         INT NOT NULL,
    salario      INT NOT NULL,
    genero       VARCHAR(1) NOT NULL,
    id_pais      INT NOT NULL
);

CREATE TEMPORARY TABLE producto (
    id_producto            INT NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    precio                 INT NOT NULL,
    id_categoria           INT NOT NULL
);

CREATE TEMPORARY TABLE vendedor (
    id_vendedor  INT NOT NULL,
    nombre       VARCHAR(200) NOT NULL,
    id_pais      INT NOT NULL
);

CREATE TEMPORARY TABLE orden (
    id_orden             INT NOT NULL,
    linea_orden          INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    id_vendedor          INT NOT NULL
);

CREATE TEMPORARY TABLE producto_orden (
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL
);


------ MODELO DE DATOS ---------
CREATE TABLE categoria (
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE pais (
    id_pais INT NOT NULL,
    nombre  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_pais)
);

CREATE TABLE cliente (
    id_cliente   INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    direccion    VARCHAR(200) NOT NULL,
    telefono     VARCHAR(8) NOT NULL,
    tarjeta      INT NOT NULL,
    edad         INT NOT NULL,
    salario      INT NOT NULL,
    genero       VARCHAR(1) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

CREATE TABLE producto (
    id_producto            INT NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    precio                 INT NOT NULL,
    id_categoria           INT NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE vendedor (
    id_vendedor  INT NOT NULL,
    nombre       VARCHAR(200) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

CREATE TABLE orden (
    id_orden             INT NOT NULL,
    linea_orden          INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    id_vendedor          INT NOT NULL,
    PRIMARY KEY (id_orden),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

CREATE TABLE producto_orden (
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES orden(id_orden),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);



