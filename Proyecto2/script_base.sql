DROP DATABASE banco;
--- BASE DE DATOS
CREATE DATABASE IF NOT EXISTS banco;

------ MODELO DE DATOS ---------
CREATE TABLE IF NOT EXISTS banco.TIPOCL (
    id_tipo INT AUTO_INCREMENT,
    nombre       VARCHAR(40) NOT NULL,
    descripcion  VARCHAR(200) NOT NULL,
    PRIMARY KEY (id_tipo)
);

CREATE TABLE IF NOT EXISTS banco.CLIENTE (
    id_cliente INT NOT NULL,
    nombre      VARCHAR(50) NOT NULL,
    apellidos      VARCHAR(50) NOT NULL,
    usuario      VARCHAR(40) NOT NULL,
    contraseña      VARCHAR(200) NOT NULL,
    tipo_cliente      INT NOT NULL,
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (tipo_cliente) REFERENCES TIPOCL(id_tipo)
);

CREATE TABLE IF NOT EXISTS banco.CORREO (
    correlativoc INT AUTO_INCREMENT,
    id_cliente   INT NOT NULL,
    correo VARCHAR(40) NOT NULL,
    PRIMARY KEY (correlativoc),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TELEFONO (
    correlativot INT AUTO_INCREMENT,
    id_cliente   INT NOT NULL,
    telefono VARCHAR(12) NOT NULL,
    PRIMARY KEY (correlativot),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TIPOCUENTA (
    codigo  INT AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    PRIMARY KEY (codigo)
);

CREATE TABLE IF NOT EXISTS banco.CUENTA (
    id_cuenta       DECIMAL(20,0) NOT NULL,
    monto_apertura  DECIMAL(12,2) NOT NULL,
    saldo_cuenta    DECIMAL(12,2) NOT NULL,
    descripcion     VARCHAR(200)   NOT NULL,
    fecha_apertura  DATETIME,
    otros_detalles  VARCHAR(200),
    tipo_cuenta     INT NOT NULL,
    id_cliente      INT NOT NULL,
    PRIMARY KEY (id_cuenta),
    FOREIGN KEY (tipo_cuenta) REFERENCES TIPOCUENTA(codigo),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)

);

CREATE TABLE IF NOT EXISTS banco.PRODUCTO_SERVICIO (
    codigo      INT NOT NULL,
    tipo        INT NOT NULL,
    costo       DECIMAL(12,2) NOT NULL,
    descripcion_ps VARCHAR(200) NOT NULL,
    PRIMARY KEY (codigo)
);

CREATE TABLE IF NOT EXISTS banco.COMPRA (
    id_compra   INT NOT NULL,
    fecha       DATE NOT NULL,
    importe     DECIMAL(12,2),
    otros_det   VARCHAR(40),
    codigo_ps   INT NOT NULL,
    id_cliente  INT NOT NULL,
    PRIMARY KEY (id_compra),
    FOREIGN KEY (codigo_ps) REFERENCES PRODUCTO_SERVICIO(codigo),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.DEPOSITO (
    id_deposito     INT NOT NULL,
    fecha           DATE NOT NULL,
    monto           DECIMAL(12,2) NOT NULL,
    otros_detalles  VARCHAR(40),
    id_cliente      INT NOT NULL,
    PRIMARY KEY (id_deposito),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.DEBITO (
    id_debito     INT NOT NULL,
    fecha           DATE NOT NULL,
    monto           DECIMAL(12,2) NOT NULL,
    otros_detalles  VARCHAR(100),
    id_cliente      INT NOT NULL,
    PRIMARY KEY (id_debito),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TIPO_TRANSACCION (
    codigo_transaccion  INT AUTO_INCREMENT,
    nombre              VARCHAR(40) NOT NULL,
    descripcion         VARCHAR(200) NOT NULL,
    PRIMARY KEY (codigo_transaccion)
);

CREATE TABLE IF NOT EXISTS banco.TRANSACCION (
    id_transaccion      INT AUTO_INCREMENT,
    fecha               DATE NOT NULL,
    otros_det           VARCHAR(200),
    id_tipo_transaccion INT NOT NULL,
    id_compra           INT,
    id_deposito         INT,
    id_debito           INT,
    numero_cuenta       DECIMAL(20,0) NOT NULL,
    PRIMARY KEY (id_transaccion),
    FOREIGN KEY (id_tipo_transaccion) REFERENCES TIPO_TRANSACCION(codigo_transaccion),
    FOREIGN KEY (id_compra) REFERENCES COMPRA(id_compra),
    FOREIGN KEY (id_deposito) REFERENCES DEPOSITO(id_deposito),
    FOREIGN KEY (id_debito) REFERENCES DEBITO(id_debito),
    FOREIGN KEY (numero_cuenta) REFERENCES CUENTA(id_cuenta)
);


CREATE TABLE historial_transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion VARCHAR(200),
    tipo ENUM('INSERT', 'UPDATE', 'DELETE'),
    nombre_tabla_afectada VARCHAR(50)
);






SELECT * FROM banco.transaccion;
DELETE FROM banco.transaccion;

SELECT * FROM banco.tipo_transaccion;
DELETE FROM banco.tipo_transaccion;

SELECT * FROM banco.deposito;
DELETE FROM banco.deposito;

SELECT * FROM banco.compra;
DELETE FROM banco.compra;

SELECT * FROM banco.cuenta;
DELETE FROM banco.cuenta;

SELECT * FROM banco.cliente;
DELETE FROM banco.cliente;

SELECT * FROM banco.producto_servicio;
DELETE FROM banco.producto_servicio;

SELECT * FROM banco.tipocuenta;
DELETE FROM banco.tipocuenta;

SELECT * FROM banco.tipocl;
DELETE FROM banco.tipocl;

SELECT * FROM banco.correo;
DELETE FROM banco.correo;
SELECT * FROM banco.telefono;
DELETE FROM banco.telefono;