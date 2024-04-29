-- ---------------------------------------------------------------------------------------------
-- // CONSULTAR SALDO CLIENTE
DELIMITER $$
CREATE PROCEDURE consultarSaldoCliente(
    IN	proc_numerocuenta	BIGINT
) 
BEGIN
DECLARE idc INT;
DECLARE nombrec VARCHAR(50);
DECLARE tipoc INT;
DECLARE tipocu INT;
DECLARE saldoc  DECIMAL(12,2);
DECLARE montoap  DECIMAL(12,2);

IF proc_numerocuenta IN(SELECT id_cuenta FROM cuenta) THEN
	SELECT id_cliente INTO idc FROM cuenta WHERE proc_numerocuenta = id_cuenta;
    SELECT nombre INTO nombrec FROM cliente WHERE idc = id_cliente;
    SELECT tipo_cliente INTO tipoc FROM cliente WHERE idc = id_cliente;
    SELECT tipo_cuenta INTO tipocu FROM cuenta WHERE proc_numerocuenta = id_cuenta;
    SELECT saldo_cuenta INTO saldoc FROM cuenta WHERE proc_numerocuenta = id_cuenta;
	SELECT monto_apertura INTO montoap FROM cuenta WHERE proc_numerocuenta = id_cuenta;
    
    SELECT 
            nombrec AS Nombre_Cliente,
            tipoc AS Tipo_de_Cliente,
            tipocu AS Tipo_de_Cuenta,
            saldoc AS Saldo_Cuenta,
            montoap AS Saldo_Apertura;
ELSE
	SELECT 'El número de cuenta no existe' as ERROR;
END IF;


END$$

DELIMITER ;


DROP PROCEDURE consultarSaldoCliente;



-- -------------------------------------------------------
-- // CONSULTAR CLIENTE
DELIMITER $$

CREATE PROCEDURE consultarCliente(
    IN proc_idCliente INT
)
BEGIN
    DECLARE cliente_existente INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE id_cliente = proc_idCliente;

    IF cliente_existente = 0 THEN
        SELECT 'El cliente no existe' AS ERROR;
    ELSE
        -- Obtener información del cliente
        SELECT 
            c.id_cliente AS Id_Cliente,
            CONCAT(c.nombre, ' ', c.apellidos) AS Nombre_Completo,
            MAX(cu.fecha_apertura) AS Fecha_Creacion, -- Utilizamos una función de agregación
            c.usuario AS Usuario,
			(SELECT GROUP_CONCAT(t.telefono) FROM telefono t WHERE t.id_cliente = c.id_cliente) AS Telefonos,
            (SELECT GROUP_CONCAT(correo) FROM correo cr WHERE cr.id_cliente = c.id_cliente) AS Correos,
			(SELECT COUNT(*) FROM cuenta cu WHERE cu.id_cliente = c.id_cliente) AS Numero_Cuentas, -- Conteo directo de cuentas
            GROUP_CONCAT(DISTINCT tc.nombre) AS Tipos_Cuenta -- Utilizamos DISTINCT aquí
        FROM cliente c
        LEFT JOIN telefono t ON c.id_cliente = t.id_cliente
        LEFT JOIN correo ON c.id_cliente = correo.id_cliente
        LEFT JOIN cuenta ct ON c.id_cliente = ct.id_cliente
        LEFT JOIN tipocuenta tc ON ct.tipo_cuenta = tc.codigo
        LEFT JOIN cuenta cu ON c.id_cliente = cu.id_cliente
        WHERE c.id_cliente = proc_idCliente
        GROUP BY c.id_cliente, c.usuario; -- Agregamos 'c.usuario' a la cláusula GROUP BY
    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------------------------
-- // MOVIMIENTOS CLIENTE
DELIMITER $$

CREATE PROCEDURE consultarMovsCliente(
    IN proc_idCliente INT
)
BEGIN
    DECLARE cliente_existente INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE id_cliente = proc_idCliente;

    IF cliente_existente = 0 THEN
        SELECT 'El cliente no existe' AS ERROR;
    ELSE
        -- Obtener movimientos del cliente
        SELECT 
            t.id_transaccion AS Id_Transaccion,
            tt.nombre AS Tipo_Transaccion,
            CASE
                WHEN c.id_compra IS NOT NULL THEN c.importe
                WHEN d.id_deposito IS NOT NULL THEN d.monto
                WHEN deb.id_debito IS NOT NULL THEN deb.monto
                ELSE NULL
            END AS Monto,
            CASE
                WHEN c.id_compra IS NOT NULL THEN 'Compra'
                WHEN d.id_deposito IS NOT NULL THEN 'Depósito'
                WHEN deb.id_debito IS NOT NULL THEN 'Débito'
                ELSE 'Otro'
            END AS Tipo_Servicio,
            t.numero_cuenta AS No_Cuenta,
            tc.nombre AS Tipo_Cuenta
        FROM transaccion t
        LEFT JOIN tipo_transaccion tt ON t.id_tipo_transaccion = tt.codigo_transaccion
        LEFT JOIN compra c ON t.id_compra = c.id_compra
        LEFT JOIN deposito d ON t.id_deposito = d.id_deposito
        LEFT JOIN debito deb ON t.id_debito = deb.id_debito
        LEFT JOIN cuenta cu ON t.numero_cuenta = cu.id_cuenta
        LEFT JOIN tipocuenta tc ON cu.tipo_cuenta = tc.codigo
        WHERE cu.id_cliente = proc_idCliente;
    END IF;
END$$

DELIMITER ;


-- -------------------------------------------------------------------------
-- // consultarTipoCuentas
DELIMITER $$

CREATE PROCEDURE consultarTipoCuentas(
    IN proc_idTipoCuenta INT
)
BEGIN
    DECLARE tipo_cuenta_existente INT;

    -- Verificar si el tipo de cuenta existe
    SELECT COUNT(*) INTO tipo_cuenta_existente FROM tipocuenta WHERE codigo = proc_idTipoCuenta;

    IF tipo_cuenta_existente = 0 THEN
        SELECT 'El tipo de cuenta no existe' AS ERROR;
    ELSE
        -- Obtener información de clientes por tipo de cuenta
        SELECT 
            tc.codigo AS Codigo_Tipo_Cuenta,
            tc.nombre AS Nombre_Cuenta,
            COUNT(c.id_cliente) AS Cantidad_Clientes
        FROM tipocuenta tc
        LEFT JOIN cuenta cu ON tc.codigo = cu.tipo_cuenta
        LEFT JOIN cliente c ON cu.id_cliente = c.id_cliente
        WHERE tc.codigo = proc_idTipoCuenta
        GROUP BY tc.codigo, tc.nombre;
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------------------
-- // MOVIMIENTOS GENERALES POR FECHAS
DELIMITER $$

CREATE PROCEDURE consultarMovsGenFech(
    IN proc_fechaInicio VARCHAR(10),
    IN proc_fechaFin VARCHAR(10)
)
BEGIN
    -- Validar formato de fecha de inicio
    IF STR_TO_DATE(proc_fechaInicio, '%d/%m/%Y') IS NULL THEN
        SELECT 'Formato de fecha de inicio inválido. Use DD/MM/YYYY' AS ERROR;
    -- Validar formato de fecha de fin
    ELSEIF STR_TO_DATE(proc_fechaFin, '%d/%m/%Y') IS NULL THEN
        SELECT 'Formato de fecha de fin inválido. Use DD/MM/YYYY' AS ERROR;
    ELSE
        -- Obtener movimientos generales por rango de fechas
        SELECT 
            t.id_transaccion AS Id_Transaccion,
            tt.nombre AS Tipo_Transaccion,
            CASE
                WHEN c.id_compra IS NOT NULL THEN 'Compra'
                WHEN d.id_deposito IS NOT NULL THEN 'Depósito'
                WHEN deb.id_debito IS NOT NULL THEN 'Débito'
                ELSE 'Otro'
            END AS Tipo_Servicio,
            CONCAT(cli.nombre, ' ', cli.apellidos) AS Nombre_Cliente,
            t.numero_cuenta AS No_Cuenta,
            tc.nombre AS Tipo_Cuenta,
            t.fecha AS Fecha,
            CASE
                WHEN c.id_compra IS NOT NULL THEN c.importe
                WHEN d.id_deposito IS NOT NULL THEN d.monto
                WHEN deb.id_debito IS NOT NULL THEN deb.monto
                ELSE NULL
            END AS Monto,
            t.otros_det AS Otros_Detalles
        FROM transaccion t
        LEFT JOIN tipo_transaccion tt ON t.id_tipo_transaccion = tt.codigo_transaccion
        LEFT JOIN compra c ON t.id_compra = c.id_compra
        LEFT JOIN deposito d ON t.id_deposito = d.id_deposito
        LEFT JOIN debito deb ON t.id_debito = deb.id_debito
        LEFT JOIN cuenta cu ON t.numero_cuenta = cu.id_cuenta
        LEFT JOIN tipocuenta tc ON cu.tipo_cuenta = tc.codigo
        LEFT JOIN cliente cli ON cu.id_cliente = cli.id_cliente
        WHERE t.fecha BETWEEN STR_TO_DATE(proc_fechaInicio, '%d/%m/%Y') AND STR_TO_DATE(proc_fechaFin, '%d/%m/%Y');
    END IF;
END$$

DELIMITER ;


-- -------------------------------------------------------------------------
-- MOVIMIENTOS GENERALES DEL CLIENTE 
DELIMITER $$

CREATE PROCEDURE consultarMovsFechClien(
    IN proc_idCliente INT,
    IN proc_fechaInicio VARCHAR(10),
    IN proc_fechaFin VARCHAR(10)
)
BEGIN
    DECLARE cliente_existente INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existente FROM cliente WHERE id_cliente = proc_idCliente;

    IF cliente_existente = 0 THEN
        SELECT 'El cliente no existe' AS ERROR;
    ELSE
        -- Validar formato de fecha de inicio
        IF STR_TO_DATE(proc_fechaInicio, '%d/%m/%Y') IS NULL THEN
            SELECT 'Formato de fecha de inicio inválido. Use DD/MM/YYYY' AS ERROR;
        -- Validar formato de fecha de fin
        ELSEIF STR_TO_DATE(proc_fechaFin, '%d/%m/%Y') IS NULL THEN
            SELECT 'Formato de fecha de fin inválido. Use DD/MM/YYYY' AS ERROR;
        ELSE
            -- Obtener movimientos por rango de fechas para el cliente específico
            SELECT 
                t.id_transaccion AS Id_Transaccion,
                tt.nombre AS Tipo_Transaccion,
                CASE
                    WHEN c.id_compra IS NOT NULL THEN 'Compra'
                    WHEN d.id_deposito IS NOT NULL THEN 'Depósito'
                    WHEN deb.id_debito IS NOT NULL THEN 'Débito'
                    ELSE 'Otro'
                END AS Tipo_Servicio,
                CONCAT(cli.nombre, ' ', cli.apellidos) AS Nombre_Cliente,
                t.numero_cuenta AS No_Cuenta,
                tc.nombre AS Tipo_Cuenta,
                t.fecha AS Fecha,
                CASE
                    WHEN c.id_compra IS NOT NULL THEN c.importe
                    WHEN d.id_deposito IS NOT NULL THEN d.monto
                    WHEN deb.id_debito IS NOT NULL THEN deb.monto
                    ELSE NULL
                END AS Monto,
                t.otros_det AS Otros_Detalles
            FROM transaccion t
            LEFT JOIN tipo_transaccion tt ON t.id_tipo_transaccion = tt.codigo_transaccion
            LEFT JOIN compra c ON t.id_compra = c.id_compra
            LEFT JOIN deposito d ON t.id_deposito = d.id_deposito
            LEFT JOIN debito deb ON t.id_debito = deb.id_debito
            LEFT JOIN cuenta cu ON t.numero_cuenta = cu.id_cuenta
            LEFT JOIN tipocuenta tc ON cu.tipo_cuenta = tc.codigo
            LEFT JOIN cliente cli ON cu.id_cliente = cli.id_cliente
            WHERE cu.id_cliente = proc_idCliente
            AND t.fecha BETWEEN STR_TO_DATE(proc_fechaInicio, '%d/%m/%Y') AND STR_TO_DATE(proc_fechaFin, '%d/%m/%Y');
        END IF;
    END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------------
-- // CONSULTAR DESASIGNACION
DELIMITER $$

CREATE PROCEDURE consultarDesasignacion()
BEGIN
    -- Consultar productos y servicios
    SELECT
        codigo AS Codigo,
        descripcion_ps AS Nombre,
        CASE
            WHEN tipo = 1 THEN 'Tipo = 1'
            WHEN tipo = 2 THEN 'Tipo = 2'
            ELSE 'Tipo = Otro'
        END AS Descripcion,
        CASE
            WHEN tipo = 1 THEN 'Producto'
            WHEN tipo = 2 THEN 'Servicio'
            ELSE 'Otro'
        END AS Tipo
    FROM PRODUCTO_SERVICIO;
END$$

DELIMITER ;







DROP PROCEDURE consultarSaldoCliente;
DROP PROCEDURE consultarCliente;
DROP PROCEDURE consultarMovsCliente;
DROP PROCEDURE consultarTipoCuentas;
DROP PROCEDURE consultarMovsGenFech;
DROP PROCEDURE consultarMovsFechClien;
DROP PROCEDURE consultarDesasignacion;