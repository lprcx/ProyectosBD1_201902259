-- FUNCIONES
DELIMITER $$
CREATE FUNCTION soloLetras(str VARCHAR(200))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
RETURN IF (str REGEXP '^[a-zA-Zaáéíóúñ. ]*$',true,false);
END $$
DELIMITER ;

DELIMITER $$ 

-- -------------------
DELIMITER $$

CREATE FUNCTION soloNumeros(num VARCHAR(100))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
    DECLARE isPositiveInteger BOOLEAN;
    SET isPositiveInteger = FALSE;

    -- Verificar si el parámetro es un número entero positivo
    IF num REGEXP '^[0-9]+$' THEN
        SET isPositiveInteger = TRUE;
    END IF;

    RETURN isPositiveInteger;
END$$

DELIMITER ;
-- --------------------------
DELIMITER $$
CREATE FUNCTION validartipo(num VARCHAR(1))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
RETURN IF (num REGEXP '^[1-2]$',true,false);
END $$
DELIMITER ;

-- ----------------------
DELIMITER $$
CREATE FUNCTION validarEmail(email VARCHAR(60))
RETURNS BOOLEAN DETERMINISTIC
BEGIN
RETURN IF 
(email REGEXP '^[a-zA-Z0-9]+@[a-zA-Z]+(\.[a-zA-Z]+)+$',true,false);
END $$
DELIMITER ;

-- ---------------------------
DELIMITER $$

CREATE FUNCTION cuentaExistente(proc_id_cuenta INT) RETURNS BOOLEAN
BEGIN
    DECLARE cuenta_existente INT;
    -- Verificar si el número de cuenta ya existe
    SELECT COUNT(*) INTO cuenta_existente
    FROM cuenta
    WHERE id_cuenta = proc_id_cuenta;
    -- Si la cuenta existe, devuelve verdadero, de lo contrario, devuelve falso
    RETURN cuenta_existente > 0;
END$$

DELIMITER ;

-- -------------------------------------------
