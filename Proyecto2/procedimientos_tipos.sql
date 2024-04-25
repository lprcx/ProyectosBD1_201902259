call banco.registrarTipoCliente(1, 'Individual Nacional', 'Este tipo de cliente es una persona individual de nacionalidad guatemalteca.');

call banco.registrarTipoCliente(2, 'Individual Extranjero', 'Este tipo de cliente es una persona individual de nacionalidad extranjera.');

call banco.registrarTipoCliente(3, 'Empresa PyMe', 'Este tipo de cliente es una empresa de tipo pequeña o mediana.');

call banco.registrarTipoCliente(4, 'Empresa S.C', 'Este tipo de cliente corresponde a las empresa grandes que tienen una sociedad colectiva.');

call banco.registrarTipoCliente(0, 'Cliente Extraordinario', 'Este cliente no esta definido en el enunciado es un tipo de cliente extra');

------------------------------------------------------------------------------------------------------

call banco.registrarTipoCuenta(1,'Cuenta de Cheques','Este tipo de cuenta ofrece la facilidad de emitir cheques para realizar transacciones monetarias.');

call banco.registrarTipoCuenta(2,'Cuenta de Ahorros','Esta cuenta genera un interés anual del 2%, lo que la hace ideal para guardar fondos a largo plazo.');

call banco.registrarTipoCuenta(3,'Cuenta de Ahorro Plus','Con una tasa de interés anual del 10%, esta cuenta de ahorros ofrece mayores rendimientos.');

call banco.registrarTipoCuenta(4,'Pequeña Cuenta','Una cuenta de ahorros con un interés semestral del 0.5%, ideal para pequeños ahorros y movimientos.');

call banco.registrarTipoCuenta(5,'Cuenta de Nomina','Diseñada para recibir depósitos de sueldo y realizar pagos, con acceso a servicios bancarios básicos.');

call banco.registrarTipoCuenta(6,'Cuenta de Inversion','Orientada a inversionistas, ofrece opciones de inversión y rendimientos más altos que una cuenta de ahorros estándar.');

------------------------------------------------------------------------------------------------------

call banco.crearProductoServicio(1, 1, 10.00, 'Servicio de tarjeta de debito');
call banco.crearProductoServicio(2, 1, 10.00, 'Servicio de chequera');
call banco.crearProductoServicio(3, 1, 400.00, 'Servicio de asesoramiento financiero');
call banco.crearProductoServicio(4, 1, 5.00, 'Servicio de banca personal');
call banco.crearProductoServicio(5, 1, 30.00, 'Seguro de vida');
call banco.crearProductoServicio(6, 1, 100.00, 'Seguro de vida plus');
call banco.crearProductoServicio(7, 1, 300.00, 'Seguro de automóvil');
call banco.crearProductoServicio(8, 1, 500.00, 'Seguro de automóvil plus');
call banco.crearProductoServicio(9, 1, 00.05, 'Servicio de deposito');
call banco.crearProductoServicio(10, 1, 00.10, 'Servicio de Debito');
call banco.crearProductoServicio(11, 2, 0, 'Pago de energía Eléctrica (EEGSA)');
call banco.crearProductoServicio(12, 2, 0, 'Pago de agua potable (Empagua');
call banco.crearProductoServicio(13, 2, 0, 'Pago de Matricula USAC');
call banco.crearProductoServicio(14, 2, 0, 'Pago de curso vacaciones USAC');
call banco.crearProductoServicio(15, 2, 0, 'Pago de servicio de internet');
call banco.crearProductoServicio(16, 2, 0, 'Servicio de suscripción plataformas streaming');
call banco.crearProductoServicio(17, 2, 0, 'Servicios Cloud');

------------------------------------------------------------------------------------------------------

