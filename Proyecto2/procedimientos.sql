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
-- ------ ///// registrarcuenta

DELIMITER $$
CREATE PROCEDURE registrarCuenta(
    IN  pc_id_cuenta DECIMAL(20,0),
    IN 	proc_monto_apertura  DECIMAL(12,2),
    IN	proc_saldo_cuenta    DECIMAL(12,2),
    IN	proc_descripcion     VARCHAR(200),
    IN	proc_fecha_apertura  VARCHAR(50),
    IN 	proc_otros_detalles  VARCHAR(100),
    IN	proc_tipo_cuenta     INT,
    IN	proc_id_cliente      INT
) 
BEGIN
	DECLARE cuenta_existente BOOLEAN;
    DECLARE tipo_cuenta_valido INT;
    DECLARE cliente_valido INT;
    DECLARE fecha_valida INT;
    DECLARE formatted_fecha_apertura DATETIME;
    
	SET cuenta_existente = cuentaExistente(pc_id_cuenta);
    SET fecha_valida = validarFecha(proc_fecha_apertura);

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
                FROM tipocuenta
                WHERE codigo = proc_tipo_cuenta;
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
                        IF proc_fecha_apertura = '' THEN
                            SET proc_fecha_apertura = NOW();
							INSERT INTO cuenta (id_cuenta, monto_apertura, saldo_cuenta, descripcion, fecha_apertura, otros_detalles, tipo_cuenta, id_cliente)
							VALUES (pc_id_cuenta, proc_monto_apertura, proc_saldo_cuenta, proc_descripcion, proc_fecha_apertura, proc_otros_detalles, proc_tipo_cuenta, proc_id_cliente);
							SELECT 'Cuenta registrada exitosamente' AS SUCCESS;
						ELSE
							-- IF fecha_valida THEN
								SET formatted_fecha_apertura = STR_TO_DATE(proc_fecha_apertura, '%d/%m/%Y %H:%i:%s');
								INSERT INTO cuenta (id_cuenta, monto_apertura, saldo_cuenta, descripcion, fecha_apertura, otros_detalles, tipo_cuenta, id_cliente)
								VALUES (pc_id_cuenta, proc_monto_apertura, proc_saldo_cuenta, proc_descripcion, formatted_fecha_apertura, proc_otros_detalles, proc_tipo_cuenta, proc_id_cliente);
								SELECT 'Cuenta registrada exitosamente' AS SUCCESS;
							-- ELSE
								-- SELECT 'Formato de fecha no valido' as ERROR;
                            -- END IF;
						END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
	END IF;
END$$

DELIMITER ;

------------------------------------------------------------------------------------------------------
-- ------ ///// realizar compra
DELIMITER $$
CREATE PROCEDURE realizarCompra(
    IN  proc_id_compra 	INT,
    IN 	proc_fecha 		VARCHAR(50),
    IN	proc_importe    DECIMAL(12,2),
    IN	proc_otros_det  VARCHAR(200),
    IN	proc_codigo_ps  INT,
    IN	proc_id_cliente INT
) 
BEGIN
	DECLARE producto_costo DECIMAL(12,2);
	DECLARE producto_tipo INT;
    DECLARE formatted_fecha DATE;
    
IF proc_id_compra NOT IN(SELECT id_compra FROM compra) THEN
	IF proc_id_cliente IN(SELECT id_cliente FROM cliente) THEN
		IF proc_codigo_ps IN(SELECT codigo FROM producto_servicio) THEN
			SELECT tipo INTO producto_tipo FROM producto_servicio WHERE codigo = proc_codigo_ps;
			IF producto_tipo = 1 THEN
				SELECT costo INTO producto_costo FROM producto_servicio WHERE codigo = proc_codigo_ps;
				-- Verificar que el importe sea igual al costo del producto
				IF producto_costo = proc_importe THEN
					SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
					INSERT INTO COMPRA (id_compra, fecha, importe, otros_det, codigo_ps, id_cliente) 
					VALUES (proc_id_compra, formatted_fecha, proc_importe, proc_otros_det, proc_codigo_ps, proc_id_cliente);
					SELECT 'Compra de servicio registrada exitosamente' AS SUCCESS;
				ELSEIF proc_importe = 0 THEN
					SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
					INSERT INTO COMPRA (id_compra, fecha, importe, otros_det, codigo_ps, id_cliente) 
					VALUES (proc_id_compra, formatted_fecha, producto_costo, proc_otros_det, proc_codigo_ps, proc_id_cliente);
					SELECT 'Compra de servicio registrada exitosamente' AS SUCCESS;
				ELSE
					SELECT 'Importe incorrecto' AS ERROR;
				END IF;
			ELSE
				IF producto_tipo = 2 THEN
					IF proc_importe IS NOT NULL THEN
						IF proc_importe > 0 THEN
							SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
							INSERT INTO COMPRA (id_compra, fecha, importe, otros_det, codigo_ps, id_cliente) 
							VALUES (proc_id_compra, formatted_fecha, proc_importe, proc_otros_det, proc_codigo_ps, proc_id_cliente);
							SELECT 'Compra de servicio registrada exitosamente' AS SUCCESS;
                        ELSE
							SELECT 'Debe ingresar un importe mayor a cero' AS ERROR;
                        END IF;
                    ELSE
						SELECT 'Debe ingresar el importe' AS ERROR;
                    END IF;
                END IF;
			END IF;
		ELSE
			SELECT 'El producto no existe' AS ERROR;
		END IF;
    ELSE
		SELECT 'El cliente no existe' AS ERROR;
    END IF;
ELSE
	SELECT 'ID de compra ya existe' as ERROR;
END IF;

END$$

DELIMITER ;



-- -----------------------------------------------------------------
-- ------ ///// realizar DEPOSITO
DELIMITER $$
CREATE PROCEDURE realizarDeposito(
    IN  proc_id_deposito 	INT,
    IN 	proc_fecha 		VARCHAR(50),
    IN	proc_monto    DECIMAL(12,2),
    IN	proc_otros_det  VARCHAR(200),
    IN	proc_id_cliente INT
) 
BEGIN
    DECLARE formatted_fecha DATE;
    DECLARE iddebito_valido BOOLEAN;
    
    SET iddebito_valido = soloNumeros(proc_id_deposito);
    
IF proc_id_deposito NOT IN(SELECT id_deposito FROM deposito) THEN
	IF iddebito_valido THEN
		IF proc_id_cliente IN(SELECT id_cliente FROM cliente) THEN
			IF proc_monto > 0 THEN
				SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
				INSERT INTO DEPOSITO (id_deposito, fecha, monto, otros_detalles, id_cliente) 
				VALUES (proc_id_deposito, formatted_fecha, proc_monto, proc_otros_det, proc_id_cliente);
				SELECT 'Deposito registrado exitosamente' AS SUCCESS;
			ELSE
				SELECT 'Debe ingresar un importe mayor a cero' AS ERROR;
            END IF;
		ELSE
			SELECT 'El cliente no existe' AS ERROR;
		END IF;
	ELSE
		SELECT 'Ingrese un tipo de dato entero' as ERROR;
	END IF;
ELSE
	SELECT 'ID de deposito ya existe' as ERROR;
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------------------
-- ------ ///// realizar realizarDebito
DELIMITER $$
CREATE PROCEDURE realizarDebito(
    IN  proc_id_debito 	INT,
    IN 	proc_fecha 		VARCHAR(50),
    IN	proc_monto    DECIMAL(12,2),
    IN	proc_otros_det  VARCHAR(200),
    IN	proc_id_cliente INT
) 
BEGIN
    DECLARE formatted_fecha DATE;
    DECLARE iddebito_valido BOOLEAN;
    
    SET iddebito_valido = soloNumeros(proc_id_debito);
    
IF proc_id_debito NOT IN(SELECT id_debito FROM debito) THEN
	IF iddebito_valido THEN
		IF proc_id_cliente IN(SELECT id_cliente FROM cliente) THEN
			IF proc_monto > 0 THEN
					SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
					INSERT INTO DEBITO (id_debito, fecha, monto, otros_detalles, id_cliente) 
					VALUES (proc_id_debito, formatted_fecha, proc_monto, proc_otros_det, proc_id_cliente);
					SELECT 'Debito registrado exitosamente' AS SUCCESS;
			ELSE
				SELECT 'Debe ingresar un importe mayor a cero' AS ERROR;
            END IF;
		ELSE
			SELECT 'El cliente no existe' AS ERROR;
		END IF;
	ELSE
		SELECT 'Ingrese un tipo de dato entero' as ERROR;
	END IF;
ELSE
	SELECT 'ID de debido ya existe' as ERROR;
END IF;
END$$

DELIMITER ;



-- -----------------------------------------------------------------
-- ------ ///// realizar registrarTipoTransaccion
DELIMITER $$
CREATE PROCEDURE registrarTipoTransaccion(
    IN  proc_codigo_transaccion 	INT,
    IN 	proc_nombre 		VARCHAR(40),
    IN	proc_descripcion  VARCHAR(200)
) 
BEGIN
    
IF proc_codigo_transaccion NOT IN(SELECT codigo_transaccion FROM tipo_transaccion) THEN
		IF proc_nombre NOT IN(SELECT nombre FROM tipo_transaccion) THEN
				INSERT INTO tipo_transaccion (codigo_transaccion, nombre, descripcion) 
				VALUES (proc_codigo_transaccion, proc_nombre, proc_descripcion);
				SELECT 'Tipo de transacción registrado exitosamente' AS SUCCESS;
		ELSE
			SELECT 'El nombre de la transacción ya existe' AS ERROR;
		END IF;
ELSE
	SELECT 'ID de transacción ya existe' as ERROR;
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------------------
-- ------ ///// realizar asignarTransaccion
DELIMITER $$
CREATE PROCEDURE asignarTransaccion(
    IN proc_id_transaccion      INT,
    IN proc_fecha               VARCHAR(50),
    IN proc_otros_det           VARCHAR(200),
    IN proc_id_tipo_transaccion INT,
    IN proc_id_cdd           INT,
    IN proc_numero_cuenta       DECIMAL(20,0)
) 
BEGIN
DECLARE tipotrans INT;
DECLARE formatted_fecha DATE;
DECLARE nuevo_saldo DECIMAL(12,2);
DECLARE saldoc DECIMAL(12,2);
DECLARE importec DECIMAL(12,2);
DECLARE idc INT;
DECLARE montoc DECIMAL(12,2);
DECLARE montod DECIMAL(12,2);

	IF proc_id_transaccion NOT IN(SELECT id_transaccion FROM transaccion) THEN
		IF proc_id_tipo_transaccion IN(SELECT codigo_transaccion FROM tipo_transaccion) THEN
			SELECT codigo_transaccion INTO tipotrans FROM tipo_transaccion WHERE codigo_transaccion = proc_id_tipo_transaccion;
			IF tipotrans = 1 THEN -- COMPRA
				IF proc_id_cdd IN(SELECT id_compra FROM compra) THEN
					SELECT id_cliente INTO idc FROM compra WHERE id_compra = proc_id_cdd;
					SELECT saldo_cuenta INTO saldoc FROM cuenta WHERE id_cliente = idc;
					SELECT importe INTO importec FROM compra WHERE id_compra = proc_id_cdd;
					IF saldoc > importec THEN
						SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
						INSERT INTO TRANSACCION (id_transaccion, fecha, otros_det, id_tipo_transaccion, id_compra, numero_cuenta) 
						VALUES (proc_id_transaccion, formatted_fecha, proc_otros_det, proc_id_tipo_transaccion, proc_id_cdd, proc_numero_cuenta);
						SELECT 'Compra registrada exitosamente' AS SUCCESS;
						-- nuevo saldo de la cuenta
						SET nuevo_saldo = saldoc - importec;
						UPDATE cuenta 
						SET saldo_cuenta = nuevo_saldo
						WHERE id_cliente = idc;
					ELSE
						SELECT 'Saldo insuficiente para realizar la compra' AS ERROR;
					END IF;
				ELSE
					SELECT 'El id de compra no existe' AS ERROR;
				END IF;
			ELSEIF tipotrans = 2 THEN -- DEPOSITO
				IF proc_id_cdd IN(SELECT id_deposito FROM deposito) THEN
					SELECT id_cliente INTO idc FROM deposito WHERE id_deposito = proc_id_cdd;
					SELECT saldo_cuenta INTO saldoc FROM cuenta WHERE id_cliente = idc;
					SELECT monto INTO montoc FROM deposito WHERE id_deposito = proc_id_cdd;
						SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
						INSERT INTO TRANSACCION (id_transaccion, fecha, otros_det, id_tipo_transaccion, id_deposito, numero_cuenta) 
						VALUES (proc_id_transaccion, formatted_fecha, proc_otros_det, proc_id_tipo_transaccion, proc_id_cdd, proc_numero_cuenta);
						SELECT 'Deposito registrado exitosamente' AS SUCCESS;
						-- nuevo saldo de la cuenta
						SET nuevo_saldo = saldoc + montoc;
						UPDATE cuenta 
						SET saldo_cuenta = nuevo_saldo
						WHERE id_cliente = idc;
				ELSE
					SELECT 'El id de deposito no existe' AS ERROR;
				END IF;
			ELSEIF tipotrans = 3 THEN -- DEBITO
				IF proc_id_cdd IN(SELECT id_debito FROM debito) THEN
					SELECT id_cliente INTO idc FROM debito WHERE id_debito = proc_id_cdd;
					SELECT saldo_cuenta INTO saldoc FROM cuenta WHERE id_cliente = idc;
					SELECT monto INTO montod FROM debito WHERE id_debito = proc_id_cdd;
					IF saldoc > montod THEN
						SET formatted_fecha = STR_TO_DATE(proc_fecha, '%d/%m/%Y');
						INSERT INTO TRANSACCION (id_transaccion, fecha, otros_det, id_tipo_transaccion, id_debito, numero_cuenta) 
						VALUES (proc_id_transaccion, formatted_fecha, proc_otros_det, proc_id_tipo_transaccion, proc_id_cdd, proc_numero_cuenta);
						SELECT 'Debito registrado exitosamente' AS SUCCESS;
						-- nuevo saldo de la cuenta
						SET nuevo_saldo = saldoc - montod;
						UPDATE cuenta 
						SET saldo_cuenta = nuevo_saldo
						WHERE id_cliente = idc;
					ELSE
						SELECT 'Saldo insuficiente para realizar el debito' AS ERROR;
					END IF;
				ELSE
					SELECT 'El id de debito no existe' AS ERROR;
				END IF;
			ELSE
				SELECT 'El tipo de transacción no ha sido validado' AS ERROR;
			END IF;
		ELSE
			SELECT 'El tipo de transacción no existe' AS ERROR;
		END IF;
	ELSE
		SELECT 'ID de transacción ya existe' as ERROR;
	END IF;
END$$

DELIMITER ;

DROP PROCEDURE registrarTipoCliente;
DROP PROCEDURE registrarTipoCuenta;
DROP PROCEDURE crearProductoServicio;
DROP PROCEDURE registrarCliente;
DROP PROCEDURE registrarCuenta;
DROP PROCEDURE realizarCompra;
DROP PROCEDURE realizarDeposito;
DROP PROCEDURE realizarDebito;
DROP PROCEDURE registrarTipoTransaccion;
DROP PROCEDURE asignarTransaccion;