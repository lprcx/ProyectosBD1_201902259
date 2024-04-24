--- BASE DE DATOS
CREATE DATABASE IF NOT EXISTS banco;

------ MODELO DE DATOS ---------
CREATE TABLE IF NOT EXISTS banco.TIPOCL (
    id_tipo INT(10) NOT NULL,
    nombre       VARCHAR(40) NOT NULL,
    descripcion  VARCHAR(200) NOT NULL,
    PRIMARY KEY (id_tipo)
);

CREATE TABLE IF NOT EXISTS banco.CLIENTE (
    id_cliente INT(10) NOT NULL,
    nombre      VARCHAR(40) NOT NULL,
    apellidos      VARCHAR(40) NOT NULL,
    usuario      VARCHAR(40) NOT NULL,
    contraseña      VARCHAR(200) NOT NULL,
    tipo_cliente      INT(10) NOT NULL,
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (tipo_cliente) REFERENCES TIPOCL(id_tipo)
);

CREATE TABLE IF NOT EXISTS banco.CORREO (
    correlativoc INT AUTO_INCREMENT,
    id_cliente   INT(10) NOT NULL,
    correo VARCHAR(40) NOT NULL,
    PRIMARY KEY (correlativoc),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TELEFONO (
    correlativot INT AUTO_INCREMENT,
    id_cliente   INT(10) NOT NULL,
    telefono VARCHAR(12) NOT NULL,
    PRIMARY KEY (correlativot),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TIPOCUENTA (
    codigo  INT(10) AUTO_INCREMENT,
    nombre VARCHAR(20) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    PRIMARY KEY (codigo)
);

CREATE TABLE IF NOT EXISTS banco.CUENTA (
    id_cuenta       BIGINT(10) NOT NULL,
    monto_apertura  DECIMAL(12,2) NOT NULL,
    saldo_cuenta    DECIMAL(12,2) NOT NULL,
    descripcion     VARCHAR(200)   NOT NULL,
    fecha_apertura  DATETIME NOT NULL,
    otros_detalles  VARCHAR(100)    NOT NULL,
    tipo_cuenta     INT(10) NOT NULL,
    id_cliente      INT(10) NOT NULL,
    PRIMARY KEY (id_cuenta),
    FOREIGN KEY (tipo_cuenta) REFERENCES TIPOCUENTA(codigo),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)

);

CREATE TABLE IF NOT EXISTS banco.PRODUCTO_SERVICIO (
    codigo      INT NOT NULL,
    tipo        INT(1) NOT NULL,
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
    otros_detalles  VARCHAR(40),
    id_cliente      INT NOT NULL,
    PRIMARY KEY (id_debito),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE IF NOT EXISTS banco.TIPO_TRANSACCION (
    codigo_transaccion  INT NOT NULL,
    nombre              VARCHAR(20),
    descripcion         VARCHAR(200),
    PRIMARY KEY (codigo_transaccion)
);

CREATE TABLE IF NOT EXISTS banco.TRANSACCION (
    id_transaccion      INT AUTO_INCREMENT,
    fecha               DATE NOT NULL,
    otros_det           VARCHAR(40),
    id_tipo_transaccion INT NOT NULL,
    id_compra           INT,
    id_deposito         INT,
    id_debito           INT,
    numero_cuenta       BIGINT(10) NOT NULL,
    PRIMARY KEY (id_transaccion),
    FOREIGN KEY (id_tipo_transaccion) REFERENCES TIPO_TRANSACCION(codigo_transaccion),
    FOREIGN KEY (id_compra) REFERENCES COMPRA(id_compra),
    FOREIGN KEY (id_deposito) REFERENCES DEPOSITO(id_deposito),
    FOREIGN KEY (id_debito) REFERENCES DEBITO(id_debito),
    FOREIGN KEY (numero_cuenta) REFERENCES CUENTA(id_cuenta)
);


----------funciones------------
DELIMITER $$
CREATE FUNCTION soloLetras(str VARCHAR(100))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
RETURN IF (str REGEXP '^[a-zA-Zaáéíóú ]*$',true,false);
END $$
DELIMITER ;

select soloLetras("esta es 2 cadena");

DELIMITER $$ 


DELIMITER $$
CREATE FUNCTION validarEmail(email VARCHAR(60))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
RETURN IF 
(email REGEXP '^[a-zA-Z0-9]+@[a-zA-Z]+(\.[a-zA-Z]+)+$',true,false);
END $$
DELIMITER ;

---- PROCEDIMIENTOS-----------

----- ////registrar tipo de cliente
DELIMITER $$

CREATE PROCEDURE registrarTipoCliente(
    IN proc_idtipo INT(10),
    IN proc_nombre VARCHAR(20),
    IN proc_descripcion VARCHAR(200),
    IN new_idtipo INT(10)
)
BEGIN
    DECLARE descripcion_valida INT;
    SET descripcion_valida = soloLetras(proc_descripcion);

    IF descripcion_valida THEN
        IF proc_idtipo IS NOT NULL THEN
            INSERT INTO TIPOCL(id_tipo, nombre, descripcion)
            VALUES (proc_idtipo, proc_nombre, proc_descripcion)
        ELSE 
            SELECT COALESCE(MAX(id_tipo), 0) + 1 INTO new_idtipo FROM TIPOCL;
            INSERT INTO TIPOCL(id_tipo, nombre, descripcion)
            VALUES (new_idtipo, proc_nombre, proc_descripcion)
        END IF;
    END IF;
END$$

DELIMITER ;

----- almacenar la contraseña encriptada--
DELIMITER $$

CREATE PROCEDURE almacenarContraseña(
    IN p_usuario VARCHAR(40),
    IN p_contraseña VARCHAR(200)
)
BEGIN
    DECLARE hashed_password VARCHAR(64);

    -- Encriptar la contraseña usando SHA-256
    SET hashed_password = SHA2(p_contraseña, 256);

    -- Insertar el usuario y la contraseña en la tabla de usuarios
    INSERT INTO usuarios (usuario, contraseña) VALUES (p_usuario, hashed_password);
END$$

DELIMITER ;

CALL almacenarContraseña('usuario_prueba', 'contraseña_prueba');


-------- ///// registrarcliente
DROP PROCEDURE IF EXISTS registrarCliente;
delimiter $$
CREATE PROCEDURE registrarCliente(
    IN    proc_id_cliente INT(10),
    IN    proc_nombre      VARCHAR(40),
    IN    proc_apellidos      VARCHAR(40),
    IN    proc_telefonos      VARCHAR(12),
    IN    proc_correos     VARCHAR(40),
    IN    proc_usuario      VARCHAR(40),
    IN    proc_contraseña      VARCHAR(200),
    IN    proc_tipo_cliente      INT(10)
)  
BEGIN
    DECLARE v_correo      INT;
    DECLARE v_telefono    INT;
    DECLARE nombre_valido BOOLEAN;
    DECLARE apellido_valido BOOLEAN;
    DECLARE correo_valido BOOLEAN;

    -- Validar que el nombre solo contenga letras
    SET nombre_valido = soloLetras(proc_nombre);
    SET apellido_valido = soloLetras(proc_apellidos);
    SET correo_valido = validarEmail(proc_correos);

    IF nombre_valido AND apellido_valido THEN
        IF proc_id_cliente IS NOT NULL THEN
            IF proc_id_cliente NOT IN(SELECT id_cliente FROM cliente) THEN
                IF proc_usuario NOT IN(SELECT usuario FROM cliente) THEN
                    --- eliminar codigo de area
                    SET proc_telefonos = RIGHT(proc_telefonos, 8); 
                    INSERT INTO cliente (id_cliente, nombre, apellidos, telefonos, correos, usuario, contraseña, tipo_cliente)
                    VALUES (proc_id_cliente, proc_nombre, proc_apellidos, proc_telefonos, proc_correos, proc_usuario, proc_contraseña, proc_tipo_cliente);
                    
                    -- Insertar correos del cliente
                    FOR c IN (SELECT trim(regexp_substr(proc_correos, '[^|]+', 1, level)) correo
                              FROM dual
                              CONNECT BY regexp_substr(proc_correos, '[^|]+', 1, level) IS NOT NULL)
                    LOOP
                        INSERT INTO correo (id_correo, idcliente, correo)
                        VALUES (correo_seq.NEXTVAL, proc_id_cliente, c.correo);
                    END LOOP;

                    -- Insertar teléfonos del cliente
                    FOR t IN (SELECT trim(regexp_substr(proc_telefonos, '[^-|]+', 1, level)) telefono
                              FROM dual
                              CONNECT BY regexp_substr(proc_telefonos, '[^-|]+', 1, level) IS NOT NULL)
                    LOOP
                        -- Verificar y truncar si el teléfono tiene más de 12 caracteres
                        IF LENGTH(t.telefono) > 12 THEN
                            SET t.telefono = SUBSTR(t.telefono, 1, 12);
                        END IF;

                        -- Insertar el teléfono
                        INSERT INTO telefono (id_telefono, idcliente, telefono)
                        VALUES (telefono_seq.NEXTVAL, proc_id_cliente, t.telefono);
                    END LOOP;
                ELSE
                    SELECT 'El nombre de usuario ya existe'
                END IF;
            ELSE
                SELECT 'CLIENTE YA EXISTE' as ERROR;
            END IF;
        ELSE:
            SELECT COALESCE(MAX(id_cliente), 0) + 1 INTO id_cliente FROM cliente;
            INSERT INTO cliente (id_cliente, nombre, apellidos, telefonos, correos, usuario, contraseña, tipo_cliente)  
            VALUES (proc_id_cliente, proc_nombre, proc_apellidos, proc_telefonos, proc_correos, proc_usuario, proc_contraseña, proc_tipo_cliente);
        END IF;
    END IF;
END $$
delimiter;

----- ////registrar tipo de cuenta
DELIMITER $$

CREATE PROCEDURE registrarTipoCuenta(
    IN proc_codigo INT(10),
    IN proc_nombre VARCHAR(20),
    IN proc_descripcion VARCHAR(200)
)
BEGIN
    DECLARE descripcion_valida INT;
    SET descripcion_valida = soloLetras(proc_descripcion);

    IF descripcion_valida THEN
        IF proc_codigo IS NOT NULL THEN
            INSERT INTO TIPOCUENTA(codigo, nombre, descripcion)
            VALUES (proc_codigo, proc_nombre, proc_descripcion)
        ELSE 
            SELECT 'Tipo de cuenta no válida' as ERROR;
        END IF;
    END IF;
END$$

DELIMITER ;






