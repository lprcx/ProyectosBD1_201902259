-- PROCEDIMIENTOS

DROP PROCEDURE registrarTipoCliente;
----- ////registrar tipo de cliente
DELIMITER $$

CREATE PROCEDURE registrarTipoCliente(
    IN proc_idtipo INT,
    IN proc_nombre VARCHAR(50),
    IN proc_descripcion VARCHAR(200)
)
BEGIN
	DECLARE idtipo_valido BOOLEAN;
	DECLARE new_idtipo INT;
    DECLARE descripcion_valida BOOLEAN;
    SET idtipo_valido = soloNumeros(proc_idtipo);
    SET descripcion_valida = soloLetras(proc_descripcion);

	IF proc_idtipo IS NOT NULL THEN
		IF idtipo_valido THEN
			IF proc_idtipo NOT IN(SELECT id_tipo FROM tipocl) THEN
				IF descripcion_valida THEN
					INSERT INTO tipocl(id_tipo, nombre, descripcion)
					VALUES (proc_idtipo, proc_nombre, proc_descripcion);
				ELSE
					SELECT 'La descripción ingresada no es válida, ingresar únicamente letras' as ERROR;
				END IF;
			ELSE
				SELECT 'El ID ingresado ya existe' as ERROR;
			END IF;
		ELSEIF proc_idtipo != '' THEN
			SELECT COALESCE(MAX(id_tipo), 0) + 1 INTO new_idtipo FROM TIPOCL;
			INSERT INTO tipocl(id_tipo, nombre, descripcion)
			VALUES (new_idtipo, proc_nombre, proc_descripcion);
		ELSE
			SELECT 'El ID ingresado no es valido' as ERROR;
		END IF;
	ELSE
		SELECT COALESCE(MAX(id_tipo), 0) + 1 INTO new_idtipo FROM TIPOCL;
		INSERT INTO tipocl(id_tipo, nombre, descripcion)
		VALUES (new_idtipo, proc_nombre, proc_descripcion);
	END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------------------
DROP PROCEDURE registrarTipoCuenta;

----- ////registrar tipo de cuenta
DELIMITER $$

CREATE PROCEDURE registrarTipoCuenta(
    IN proc_codigo INT,
    IN proc_nombre VARCHAR(50),
    IN proc_descripcion VARCHAR(200)
)
BEGIN
	IF proc_codigo IS NOT NULL THEN
		IF proc_codigo NOT IN(SELECT codigo FROM tipocuenta) THEN
			IF proc_nombre NOT IN(SELECT nombre FROM tipocuenta) THEN
				INSERT INTO TIPOCUENTA(codigo, nombre, descripcion)
				VALUES (proc_codigo, proc_nombre, proc_descripcion);
			ELSE
				SELECT 'Nombre de Cuenta ya registrado' as ERROR;
            END IF;
		ELSE
			SELECT 'Tipo de cuenta ya registrado' as ERROR;
		END IF;
	END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------------------
DROP PROCEDURE crearProductoServicio;

----- ////registrar productos_servicios
DELIMITER $$

CREATE PROCEDURE crearProductoServicio(
    IN proc_codigo INT,
    IN proc_tipo INT,
    IN proc_costo DECIMAL(12,2),
    IN proc_descripcion_ps VARCHAR(200)

)
BEGIN
	DECLARE codigovalido BOOLEAN;
    DECLARE tipovalido BOOLEAN;
	SET codigovalido = soloNumeros(proc_codigo);
    SET tipovalido = validartipo(proc_tipo);
    
	IF codigovalido THEN
		IF tipovalido THEN
			IF proc_codigo NOT IN(SELECT codigo FROM producto_servicio) THEN
				IF proc_costo = 0 THEN
					IF proc_tipo = 1 THEN
						SELECT 'Debe ingresar el costo' as ERROR;
					ELSEIF proc_tipo = 2 THEN
						INSERT INTO producto_servicio(codigo, tipo, costo, descripcion_ps)
						VALUES (proc_codigo, proc_tipo, proc_costo, proc_descripcion_ps);
					ELSE
						SELECT 'Ingrese un tipo existente' as ERROR;
					END IF;
				ELSE
					INSERT INTO producto_servicio(codigo, tipo, costo, descripcion_ps)
					VALUES (proc_codigo, proc_tipo, proc_costo, proc_descripcion_ps);
				END IF;
			ELSE
				SELECT 'El codigo ingresado ya existe' as ERROR; 
			END IF;
		ELSE
			SELECT 'Tipo no valido' as ERROR;
		END IF;
	ELSE
		SELECT 'El codigo ingresado no es valido' as ERROR;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------------------
-- ------ ///// registrarcliente
DROP PROCEDURE IF EXISTS registrarCliente;
DELIMITER $$
CREATE PROCEDURE registrarCliente(
    IN    proc_id_cliente INT,
    IN    proc_nombre      VARCHAR(40),
    IN    proc_apellidos      VARCHAR(40),
    IN    proc_telefonos      VARCHAR(50),
    IN    proc_correos     VARCHAR(40),
    IN    proc_usuario      VARCHAR(40),
    IN    proc_contraseña      VARCHAR(200),
    IN    proc_tipo_cliente      INT
) 
BEGIN
	DECLARE v_correo      VARCHAR(40);
    DECLARE v_telefono    INT;
    DECLARE nombre_valido BOOLEAN;
    DECLARE apellido_valido BOOLEAN;
    DECLARE correo_valido BOOLEAN;
    
    -- Validar que el nombre solo contenga letras
    SET nombre_valido = soloLetras(proc_nombre);
    SET apellido_valido = soloLetras(proc_apellidos);

	IF proc_id_cliente IS NOT NULL THEN
        IF nombre_valido AND apellido_valido THEN
			IF proc_id_cliente NOT IN(SELECT id_cliente FROM cliente) THEN
				IF proc_usuario NOT IN(SELECT usuario FROM cliente) THEN
					IF proc_tipo_cliente IN(SELECT id_tipo FROM tipocl) THEN
						INSERT INTO cliente (id_cliente, nombre, apellidos, usuario, contraseña, tipo_cliente)
						VALUES (proc_id_cliente, proc_nombre, proc_apellidos, proc_usuario, proc_contraseña, proc_tipo_cliente);
                         -- Dividir y eliminar el código de área de los teléfonos
                        WHILE LENGTH(proc_telefonos) > 0 DO
                            SET v_telefono = TRIM(SUBSTRING_INDEX(proc_telefonos, '-', 1));
                            SET proc_telefonos = TRIM(SUBSTRING(proc_telefonos FROM LENGTH(v_telefono) + 2));
							-- Eliminar el código de área
                            SET v_telefono = RIGHT(v_telefono, 8); 
                            IF v_telefono NOT IN(SELECT telefono FROM telefono) THEN
								-- Insertar el teléfono en la tabla de teléfonos
								INSERT INTO telefono(id_cliente, telefono)
								VALUES (proc_id_cliente, v_telefono);
							ELSE
								DELETE FROM cliente
                                WHERE id_cliente = proc_id_cliente;
								SELECT 'Telefono ingresado no valido' as ERROR;
                            END IF;
                        END WHILE;
                        
                        -- Dividir los correos separados por comas
                        WHILE LENGTH(proc_correos) > 0 DO
                            SET v_correo = TRIM(SUBSTRING_INDEX(proc_correos, '|', 1));
                            SET proc_correos = TRIM(SUBSTRING(proc_correos FROM LENGTH(v_correo) + 2));
							SET correo_valido = validarEmail(v_correo);
							IF correo_valido THEN
								 IF v_correo NOT IN(SELECT correo FROM correo) THEN
									-- Insertar el correo en la tabla de correos
									INSERT INTO correo(id_cliente, correo)
									VALUES (proc_id_cliente, v_correo);
								 ELSE
									DELETE FROM cliente
									WHERE id_cliente = proc_id_cliente;
									 SELECT 'Correo ya existe' as ERROR;
                                 END IF;
							ELSE
								SELECT 'Correo ingresado no valido' as ERROR;
                            END IF;
                        END WHILE;
                    ELSE
						SELECT 'El tipo de cliente ingresado no es valido' as ERROR;
                    END IF;
                ELSE
					SELECT 'El usuario ingresado ya existe' as ERROR;
                END IF;
            ELSE
				SELECT 'El ID de cliente ya existe' as ERROR;
            END IF;
		ELSE
			SELECT 'Ingrese un nombre o apellido válido, solo puede ingresar letras' as ERROR;
        END IF;
    ELSE
		SELECT 'El id de cliente es nulo' as ERROR;
    END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------------------
-- ------ ///// registrarcuenta
DROP PROCEDURE IF EXISTS registrarCuenta;
DELIMITER $$
CREATE PROCEDURE registrarCuenta(
    IN  proc_id_cuenta BIGINT,
    IN 	proc_monto_apertura  DECIMAL(12,2),
    IN	proc_saldo_cuenta    DECIMAL(12,2),
    IN	proc_descripcion     VARCHAR(200),
    IN	proc_fecha_apertura  DATETIME,
    IN 	proc_otros_detalles  VARCHAR(100),
    IN	proc_tipo_cuenta     INT,
    IN	proc_id_cliente      INT
) 
BEGIN
	DECLARE cuenta_existente BOOLEAN;
    DECLARE tipo_cuenta_valido INT;
    DECLARE cliente_valido INT;
	SET cuenta_existente = cuentaExistente(proc_id_cuenta);

	IF cuenta_existente THEN
		SELECT 'El número de cuenta ya existe' AS ERROR;
	ELSE
        IF proc_monto_apertura <= 0 THEN
            SELECT 'El monto de apertura debe ser positivo' AS ERROR;
        ELSE
            IF proc_saldo_cuenta < 0 THEN
                SELECT 'El saldo de cuenta no puede ser negativo' AS ERROR;
            ELSE
                SELECT COUNT(*) INTO tipo_cuenta_valido
                FROM tipo_cuenta
                WHERE id_tipo = proc_tipo_cuenta;
                IF tipo_cuenta_valido = 0 THEN
                    SELECT 'El tipo de cuenta no existe' AS ERROR;
                ELSE
                    SELECT COUNT(*) INTO cliente_valido
                    FROM cliente
                    WHERE id_cliente = proc_id_cliente;
                    IF cliente_valido = 0 THEN
                        SELECT 'El cliente no existe' AS ERROR;
                    ELSE
						-- Si no se proporciona una fecha de apertura, utilizar la fecha y hora actual
                        IF proc_fecha_apertura IS NULL THEN
                            SET proc_fecha_apertura = NOW();
                        END IF;
                        INSERT INTO cuenta (id_cuenta, monto_apertura, saldo_cuenta, descripcion, fecha_apertura, otros_detalles, tipo_cuenta, id_cliente)
                        VALUES (proc_id_cuenta, proc_monto_apertura, proc_saldo_cuenta, proc_descripcion, proc_fecha_apertura, proc_otros_detalles, proc_tipo_cuenta, proc_id_cliente);
                        SELECT 'Cuenta registrada exitosamente' AS SUCCESS;
                    END IF;
                END IF;
            END IF;
        END IF;
	END IF;
END$$

DELIMITER ;