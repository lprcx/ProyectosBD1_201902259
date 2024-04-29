-- ------------------------------------TRIGGERS---------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_tipocl
AFTER INSERT ON tipocl
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla tipocl', 'INSERT', 'tipocl');
END$$

CREATE TRIGGER tr_historial_update_tipocl
AFTER UPDATE ON tipocl
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla tipocl', 'UPDATE', 'tipocl');
END$$

CREATE TRIGGER tr_historial_delete_tipocl
AFTER DELETE ON tipocl
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla tipocl', 'DELETE', 'tipocl');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_cliente
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla cliente', 'INSERT', 'cliente');
END$$

CREATE TRIGGER tr_historial_update_cliente
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla cliente', 'UPDATE', 'cliente');
END$$

CREATE TRIGGER tr_historial_delete_cliente
AFTER DELETE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla cliente', 'DELETE', 'cliente');
END$$

DELIMITER ;


-- ---------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_correo
AFTER INSERT ON correo
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla correo', 'INSERT', 'correo');
END$$

CREATE TRIGGER tr_historial_update_correo
AFTER UPDATE ON correo
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla correo', 'UPDATE', 'correo');
END$$

CREATE TRIGGER tr_historial_delete_correo
AFTER DELETE ON correo
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla correo', 'DELETE', 'correo');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_telefono
AFTER INSERT ON telefono
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla telefono', 'INSERT', 'telefono');
END$$

CREATE TRIGGER tr_historial_update_telefono
AFTER UPDATE ON telefono
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla telefono', 'UPDATE', 'telefono');
END$$

CREATE TRIGGER tr_historial_delete_telefono
AFTER DELETE ON telefono
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla telefono', 'DELETE', 'telefono');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_tipocuenta
AFTER INSERT ON tipocuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla tipocuenta', 'INSERT', 'tipocuenta');
END$$

CREATE TRIGGER tr_historial_update_tipocuenta
AFTER UPDATE ON tipocuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla tipocuenta', 'UPDATE', 'tipocuenta');
END$$

CREATE TRIGGER tr_historial_delete_tipocuenta
AFTER DELETE ON tipocuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla tipocuenta', 'DELETE', 'tipocuenta');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_cuenta
AFTER INSERT ON cuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla cuenta', 'INSERT', 'cuenta');
END$$

CREATE TRIGGER tr_historial_update_cuenta
AFTER UPDATE ON cuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla cuenta', 'UPDATE', 'cuenta');
END$$

CREATE TRIGGER tr_historial_delete_cuenta
AFTER DELETE ON cuenta
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla cuenta', 'DELETE', 'cuenta');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_producto_servicio
AFTER INSERT ON producto_servicio
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla producto_servicio', 'INSERT', 'producto_servicio');
END$$

CREATE TRIGGER tr_historial_update_producto_servicio
AFTER UPDATE ON producto_servicio
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla producto_servicio', 'UPDATE', 'producto_servicio');
END$$

CREATE TRIGGER tr_historial_delete_producto_servicio
AFTER DELETE ON producto_servicio
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla producto_servicio', 'DELETE', 'producto_servicio');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla compra', 'INSERT', 'compra');
END$$

CREATE TRIGGER tr_historial_update_compra
AFTER UPDATE ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla compra', 'UPDATE', 'compra');
END$$

CREATE TRIGGER tr_historial_delete_compra
AFTER DELETE ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla compra', 'DELETE', 'compra');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_deposito
AFTER INSERT ON deposito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla deposito', 'INSERT', 'deposito');
END$$

CREATE TRIGGER tr_historial_update_deposito
AFTER UPDATE ON deposito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla deposito', 'UPDATE', 'deposito');
END$$

CREATE TRIGGER tr_historial_delete_deposito
AFTER DELETE ON deposito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla deposito', 'DELETE', 'deposito');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_debito
AFTER INSERT ON debito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla debito', 'INSERT', 'debito');
END$$

CREATE TRIGGER tr_historial_update_debito
AFTER UPDATE ON debito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla debito', 'UPDATE', 'debito');
END$$

CREATE TRIGGER tr_historial_delete_debito
AFTER DELETE ON debito
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla debito', 'DELETE', 'debito');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_tipo_transaccion
AFTER INSERT ON tipo_transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla tipo_transaccion', 'INSERT', 'tipo_transaccion');
END$$

CREATE TRIGGER tr_historial_update_tipo_transaccion
AFTER UPDATE ON tipo_transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla tipo_transaccion', 'UPDATE', 'tipo_transaccion');
END$$

CREATE TRIGGER tr_historial_delete_tipo_transaccion
AFTER DELETE ON tipo_transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla tipo_transaccion', 'DELETE', 'tipo_transaccion');
END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER tr_historial_insert_transaccion
AFTER INSERT ON transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una inserción en la tabla transaccion', 'INSERT', 'transaccion');
END$$

CREATE TRIGGER tr_historial_update_transaccion
AFTER UPDATE ON transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado una actualización en la tabla transaccion', 'UPDATE', 'transaccion');
END$$

CREATE TRIGGER tr_historial_delete_transaccion
AFTER DELETE ON transaccion
FOR EACH ROW
BEGIN
    INSERT INTO historial_transacciones (descripcion, tipo, nombre_tabla_afectada)
    VALUES ('Se ha realizado un delete en la tabla transaccion', 'DELETE', 'transaccion');
END$$

DELIMITER ;

DROP TRIGGER tr_historial_insert;
DROP TRIGGER tr_historial_update;
DROP TRIGGER tr_historial_delete;