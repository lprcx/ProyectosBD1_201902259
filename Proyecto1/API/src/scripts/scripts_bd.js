export const script_create_temptables = `
---- TABLAS TEMPORALES
CREATE TEMPORARY TABLE temp_categoria (
    id_categoria INT,
    nombre       VARCHAR(100) 
);

CREATE TEMPORARY TABLE temp_pais (
    id_pais INT,
    nombre  VARCHAR(100) 
);

CREATE TEMPORARY TABLE temp_cliente (
    id_cliente   INT,
    nombre       VARCHAR(100),
    apellido     VARCHAR(100),
    direccion    VARCHAR(200),
    telefono     VARCHAR(8),
    tarjeta      VARCHAR(20),
    edad         INT,
    salario      INT,
    genero       VARCHAR(1),
    id_pais      INT 
);

CREATE TEMPORARY TABLE temp_producto (
    id_producto            INT,
    nombre                 VARCHAR(100),
    precio                 FLOAT,
    id_categoria           INT 
);

CREATE TEMPORARY TABLE temp_vendedor (
    id_vendedor  INT,
    nombre       VARCHAR(200),
    id_pais      INT 
);

CREATE TEMPORARY TABLE temp_orden (
    id_orden             INT,
    linea_orden          INT,
    fecha                DATE,
    id_cliente           INT,
    id_vendedor          INT 
);

CREATE TEMPORARY TABLE temp_producto_orden (
    id_orden             INT,
    id_producto          INT,
    cantidad             INT 
);
`;

export const script_create_modeltables = `
------ MODELO DE DATOS ---------
CREATE TABLE empr.CATEGORIA (
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE empr.PAIS (
    id_pais INT NOT NULL,
    nombre  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_pais)
);

CREATE TABLE empr.CLIENTE (
    id_cliente   INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    direccion    VARCHAR(200) NOT NULL,
    telefono     INT NOT NULL,
    tarjeta      VARCHAR(20) NOT NULL,
    edad         INT NOT NULL,
    salario      INT NOT NULL,
    genero       VARCHAR(1) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (id_pais) REFERENCES empr.PAIS(id_pais)
);

CREATE TABLE empr.PRODUCTO (
    id_producto            INT NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    precio                 FLOAT NOT NULL,
    id_categoria           INT NOT NULL,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_categoria) REFERENCES empr.CATEGORIA(id_categoria)
);

CREATE TABLE empr.VENDEDOR (
    id_vendedor  INT NOT NULL,
    nombre       VARCHAR(200) NOT NULL,
    id_pais      INT NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_pais) REFERENCES empr.PAIS(id_pais)
);

CREATE TABLE empr.ORDEN (
    id_orden             INT NOT NULL,
    linea_orden          INT NOT NULL,
    fecha                DATE NOT NULL,
    id_cliente           INT NOT NULL,
    id_vendedor          INT NOT NULL,
    PRIMARY KEY (id_orden),
    FOREIGN KEY (id_cliente) REFERENCES empr.CLIENTE(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES empr.VENDEDOR(id_vendedor)
);

CREATE TABLE empr.PRODUCTO_ORDEN (
    id_orden             INT NOT NULL,
    id_producto          INT NOT NULL,
    cantidad             INT NOT NULL,
    FOREIGN KEY (id_orden) REFERENCES empr.ORDEN(id_orden),
    FOREIGN KEY (id_producto) REFERENCES empr.PRODUCTO(id_producto)
);
`;
