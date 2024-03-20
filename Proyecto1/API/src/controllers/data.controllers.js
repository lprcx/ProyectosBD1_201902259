import { db } from '../db.js';
import fs from 'fs';
import { script_create_modeltables, script_create_temptables } from '../scripts/scripts_bd.js';
const fdidr = '../data'

export const getInicio = (req, res) => {
    res.send({
        message: "Api levantada correctamente"
    })
}


export const cargarmodelo = async (req, res) => {
    //Elimina comentarios del script
    let script = script_create_temptables.replace(/--.*\n/g, '')

    try {
        const connection = await db.getConnection();
        //A. Crea las tablas temporales
        //Ejecuta el script1 sin comentarios
        const sqlCommands1 = script.split(";").map(command => command.trim());

        for (let i = 0; i < sqlCommands1.length; i++) {
            if (sqlCommands1[i].length === 0) {
                continue;
            }
            console.log(sqlCommands1[i])
            await connection.query(sqlCommands1[i])
        }


        //B. Carga los datos de los archivos csv
        // 1. PAIS
        const contenido1 = fs.readFileSync(fdidr + '/paises.csv', 'utf8')
        console.log(contenido1)
        const filas1 = contenido1.split('\n');
        const paises = filas1.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);

        paises.shift()

        paises.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            const sql = `INSERT INTO temp_pais (id_pais, nombre) VALUES (?,?)`
            await connection.query(sql, columnas)
        })
        const p = 'SELECT * FROM temp_pais'
        const [rows, fields] = await connection.query(p)
        console.log(rows)

        // 2. CATEGORIAS
        const contenido2 = fs.readFileSync(fdidr + '/Categorias.csv', 'utf8')
        const filas2 = contenido2.split('\n');
        const categorias = filas2.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);
        categorias.shift()

        categorias.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            const sql = `INSERT INTO temp_categoria (id_categoria, nombre) VALUES (?,?)`
            await connection.query(sql, columnas)
        })

        // 3. CLIENTES
        const contenido3 = fs.readFileSync(fdidr + '/clientes.csv', 'utf8')
        const filas3 = contenido3.split('\n');
        const clientes = filas3.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);
        clientes.shift()

        clientes.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[6] = Number(columnas[6])
            columnas[7] = Number(columnas[7])
            columnas[9] = Number(columnas[9])
            const sql = `INSERT INTO temp_cliente (id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais) VALUES (?,?,?,?,?,?,?,?,?,?)`
            await connection.query(sql, columnas)
        })

        // 6. VENDEDORES
        const contenido6 = fs.readFileSync(fdidr + '/vendedores.csv', 'utf8')
        const filas6 = contenido6.split('\n');
        const vendedores = filas6.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);

        vendedores.shift()

        vendedores.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[2] = Number(columnas[2])
            const sql = `INSERT INTO temp_vendedor (id_vendedor, nombre, id_pais) VALUES (?,?,?)`
            await connection.query(sql, columnas)
        })
        
        // 6. orden
        const contenido7 = fs.readFileSync(fdidr + '/ordenes.csv', 'utf8')
        const filas7 = contenido7.split('\n');
        const producto_orden = filas7.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);

        producto_orden.shift()

        producto_orden.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[3] = Number(columnas[3])
            const col_fecha = columnas[2].split('/')
            const fecha = col_fecha[2] + '-' + col_fecha[1] + '-' + col_fecha[0]
            columnas[2] = fecha
            const insertar = []
            insertar.push(columnas[0])
            insertar.push(columnas[2])
            insertar.push(columnas[3])
            const sql = `INSERT INTO temp_orden (id_orden, fecha, id_cliente) VALUES (?,?,?)`
            await connection.query(sql, insertar)
        })

        // 4. ORDENES_producto
        const contenido4 = fs.readFileSync(fdidr + '/ordenes.csv', 'utf8')
        const filas4 = contenido4.split('\n');
        const ordenes = filas4.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);

        ordenes.shift()

        ordenes.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[4] = Number(columnas[4])
            columnas[1] = Number(columnas[1])
            columnas[5] = Number(columnas[5])
            columnas[6] = Number(columnas[6])
            
            const insertar = []
            insertar.push(columnas[0])
            insertar.push(columnas[4])
            insertar.push(columnas[1])
            insertar.push(columnas[5])
            insertar.push(columnas[6])
            const sql = `INSERT INTO temp_producto_orden (id_orden, id_vendedor, linea_orden, id_producto, cantidad) VALUES (?,?,?,?,?)`
            await connection.query(sql, insertar)
        })

        // 5. PRODUCTOS
        const contenido5 = fs.readFileSync(fdidr + '/productos.csv', 'utf8')
        const filas5 = contenido5.split('\n');
        const productos = filas5.map(fila => fila.split(';')
            .map(columna => columna.trim()))
            .filter(columnas => columnas.length > 1);

        productos.shift()

        productos.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[2] = Number(columnas[2])
            columnas[3] = Number(columnas[3])
            const sql = `INSERT INTO temp_producto (id_producto, nombre, precio, id_categoria) VALUES (?,?,?,?)`
            await connection.query(sql, columnas)
        })

        

        


        //C. Carga los datos de las tablas temporales a las tablas del modelo
        // 1. CATEGORIA
        const sql1 = `INSERT INTO empr.CATEGORIA (id_categoria, nombre) SELECT id_categoria, nombre FROM temp_categoria`
        await connection.query(sql1)

        // 2. PAIS
        const sql2 = `INSERT INTO empr.PAIS (id_pais, nombre) SELECT id_pais, nombre FROM temp_pais`
        await connection.query(sql2)

        // 3. CLIENTE
        const sql3 = `INSERT INTO empr.CLIENTE (id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais) SELECT id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais FROM temp_cliente`
        await connection.query(sql3)

        // 4. PRODUCTO
        const sql4 = `INSERT INTO empr.PRODUCTO (id_producto, nombre, precio, id_categoria) SELECT id_producto, nombre, precio, id_categoria FROM temp_producto`
        await connection.query(sql4)

        // 5. VENDEDOR
        const sql5 = `INSERT INTO empr.VENDEDOR (id_vendedor, nombre, id_pais) SELECT id_vendedor, nombre, id_pais FROM temp_vendedor`
        await connection.query(sql5)

        // 6. ORDEN
        const sql6 = `INSERT INTO empr.ORDEN (id_orden, fecha, id_cliente) SELECT id_orden, fecha, id_cliente FROM temp_orden`
        await connection.query(sql6)

        // 7. PRODUCTO_ORDEN
        const sql7 = `INSERT INTO empr.PRODUCTO_ORDEN (id_lineastabla, id_orden, id_producto, cantidad, linea_orden, id_vendedor) SELECT id_lineastabla, id_orden, id_producto, cantidad, linea_orden, id_vendedor FROM temp_producto_orden`
        await connection.query(sql7)


       //
        const sql8 = `DROP TEMPORARY TABLE temp_pais, temp_categoria, temp_cliente, temp_orden, temp_producto, temp_producto_orden, temp_vendedor`
        await connection.query(sql8)

        let respuesta = {
            consulta: "cargarmodelo",
            res: true,
            message: 'Modelo cargado correctamente'
        }
        

        connection.release();
        //C. Carga los datos de las tablas temporales a las tablas del modelo
        res.status(200).send(respuesta)

    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "cargarmodelo",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }


}

export const crearmodelo = async (req, res) => {
    //Elimina comentarios del script
    let script = script_create_modeltables.replace(/--.*\n/g, '')

    try {
        const connection = await db.getConnection();
        //A. Crea las tablas temporales
        //Ejecuta el script1 sin comentarios
        const sqlCommands1 = script.split(";").map(command => command.trim());

        for (let i = 0; i < sqlCommands1.length; i++) {
            if (sqlCommands1[i].length === 0) {
                continue;
            }
            console.log(sqlCommands1[i])
            await connection.query(sqlCommands1[i])
        }
        connection.release();

        res.status(200).send({
            consulta: "crearmodelo",
            res: true,
            message: 'Modelo creado con éxito',
            tablas_modelo: [
                'empr.CATEGORIA',
                'empr.PAIS',
                'empr.CLIENTE',
                'empr.PRODUCTO',
                'empr.VENDEDOR',
                'empr.ORDEN',
                'empr.PRODUCTO_ORDEN'
            ]
        })


    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "crearmodelo",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}

export const eliminarmodelo = async (req, res) => {

    let script = 'DROP TABLE empr.categoria, pais, cliente, producto, vendedor, orden, producto_orden;'
    try {
        await db.query(script)
        res.status(200).send({
            consulta: "eliminarmodelo",
            res: true,
            message: 'Modelo eliminado con éxito'
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "eliminarmodelo",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}

export const borrarinfodb = async (req, res) => {

    
    try {
        let script = 'DELETE FROM empr.producto_orden'
        await db.query(script)
        script = 'DELETE FROM empr.orden'
        await db.query(script)
        script = 'DELETE FROM empr.cliente'
        await db.query(script)
        script = 'DELETE FROM empr.vendedor'
        await db.query(script)
        script = 'DELETE FROM empr.producto'
        await db.query(script)
        script = 'DELETE FROM empr.categoria'
        await db.query(script)
        script = 'DELETE FROM empr.pais'
        await db.query(script)
        
        

        
        res.status(200).send({
            consulta: "borrarinfodb",
            res: true,
            message: 'Datos eliminados con éxito'
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "borrarinfodb",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}


// ********************************** CONSULTAS ******************************************

/* 1
Mostrar el cliente que más ha comprado. Se debe de mostrar el id del cliente, nombre, apellido, país y monto total.            */
export const consulta1 = async (req, res) => {
    try {
        const script = `
        SELECT 
            c.id_cliente,
            c.nombre,
            c.apellido,
            p.nombre AS pais,
            COUNT(o.id_orden) AS numero_compras,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.ORDEN o
        INNER JOIN 
            empr.CLIENTE c ON c.id_cliente = o.id_cliente
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        INNER JOIN 
            empr.PAIS p ON c.id_pais = p.id_pais
        GROUP BY 
            c.id_cliente
        ORDER BY 
            monto_total DESC
        LIMIT 1;
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta1",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta1",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}


/* 2
Mostrar el producto más y menos comprado. Se debe mostrar el id del producto, nombre del producto, categoría, cantidad de unidades y monto vendido. Producto más comprado                */
export const consulta2 = async (req, res) => {
    try {
        const script = `
        SELECT
            max_comp.id_producto AS id_prod_mas_comp,
            max_comp.nombre AS nombre_prod_mas_comp,
            max_comp.categoria AS categoria_prod_mas_comp,
            max_comp.cantidad AS cant_u_prod_mas_comp,
            max_comp.monto AS monto_prod_mas_comp,
            min_comp.id_producto AS id_prod_menos_comp,
            min_comp.nombre AS nombre_prod_menos_comp,
            min_comp.categoria AS categoria_prod_menos_comp,
            min_comp.cantidad AS cant_u_prod_menos_comp,
            min_comp.monto AS monto_prod_menos_comp
        FROM
            (SELECT
                pr.id_producto,
                pr.nombre,
                c.nombre AS categoria,
                SUM(po.cantidad) AS cantidad,
                SUM(po.cantidad * pr.precio) AS monto
            FROM
                empr.PRODUCTO pr
            JOIN
                empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
            JOIN
                empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
            GROUP BY
                pr.id_producto
            ORDER BY
                cantidad DESC
            LIMIT 1) AS max_comp
        CROSS JOIN
            (SELECT
                pr.id_producto,
                pr.nombre,
                c.nombre AS categoria,
                SUM(po.cantidad) AS cantidad,
                SUM(po.cantidad * pr.precio) AS monto
            FROM
                empr.PRODUCTO pr
            JOIN
                empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
            JOIN
                empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
            GROUP BY
                pr.id_producto
            ORDER BY
                cantidad ASC
            LIMIT 1) AS min_comp;

        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta2",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta2",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 3
Mostrar a la persona que más ha vendido. Se debe mostrar el id del vendedor, nombre del vendedor, monto total vendido                */
export const consulta3 = async (req, res) => {
    try {
        const script = `
        SELECT
            v.id_vendedor,
            v.nombre AS nombre_vendedor,
            SUM(po.cantidad * pr.precio) AS monto_total_vendido
        FROM
            empr.VENDEDOR v
        JOIN
            empr.PRODUCTO_ORDEN po ON v.id_vendedor = po.id_vendedor
        JOIN
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY
            v.id_vendedor
        ORDER BY
            monto_total_vendido DESC
        LIMIT 1;
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta3",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta3",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 4
Mostrar el país que más y menos ha vendido. Debe mostrar el nombre del país y el monto.                */
export const consulta4 = async (req, res) => {
    try {
        const connection = await db.getConnection();
        const script = `
        SELECT 
            p.nombre AS nombre_pais_menos_vendido, 
            SUM(po.cantidad*pr.precio) AS monto
        FROM 
            empr.PRODUCTO_ORDEN po
        INNER JOIN 
            empr.VENDEDOR v ON po.id_vendedor = v.id_vendedor
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
        GROUP BY 
            p.nombre
        ORDER BY 
            monto ASC    
        LIMIT 1;
        `
        const [rows1, fields1] = await connection.query(script)
        let resultado = []
        resultado.push(rows1[0])
        const script2 = `
        SELECT 
            p.nombre AS nombre_pais_mas_vendido, 
            SUM(po.cantidad*pr.precio) AS monto
        FROM 
            empr.PRODUCTO_ORDEN po
        INNER JOIN 
            empr.VENDEDOR v ON po.id_vendedor = v.id_vendedor
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
        GROUP BY 
            p.nombre
        ORDER BY 
            monto DESC    
        LIMIT 1;
        `
        ;
        const [rows2, fields2] = await connection.query(script2)
        resultado.push(rows2[0])
        connection.release();

        res.status(200).send({
            consulta: "consulta4",
            res: true,
            resultado: resultado
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta4",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 5
Top 5 de países que más han comprado en orden ascendente. Se le solicita mostrar el id del país, nombre y monto total.                */
export const consulta5 = async (req, res) => {
    try {
        const script = `
        SELECT 
            p.id_pais,
            p.nombre AS nombre_pais,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.PAIS p
        INNER JOIN 
            empr.CLIENTE c ON p.id_pais = c.id_pais
        INNER JOIN 
            empr.ORDEN o ON c.id_cliente = o.id_cliente
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            p.id_pais, p.nombre
        ORDER BY 
            monto_total ASC
        LIMIT 5;
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta5",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta5",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 6
Mostrar la categoría que más y menos se ha comprado. Debe de mostrar el nombre de la categoría y cantidad de unidades.                */
export const consulta6 = async (req, res) => {
    try {
        const connection = await db.getConnection();
        const script = `
        SELECT 
            ca.nombre AS nombre_categoria_menos_vendida, 
            SUM(po.cantidad) AS unidades
        FROM 
            empr.PRODUCTO_ORDEN po
		INNER JOIN
			empr.orden o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.CLIENTE c ON o.id_cliente = c.id_cliente
        INNER JOIN 
            empr.PAIS p ON c.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
		INNER JOIN
			empr.categoria ca ON ca.id_categoria = pr.id_categoria
        GROUP BY 
            ca.nombre
        ORDER BY 
            unidades ASC    
        LIMIT 1;
        `
        const [rows1, fields1] = await connection.query(script)
        let resultado = []
        resultado.push(rows1[0])
        const script2 = `
        SELECT 
            ca.nombre AS nombre_categoria_mas_vendida, 
            SUM(po.cantidad) AS unidades
        FROM 
            empr.PRODUCTO_ORDEN po
		INNER JOIN
			empr.orden o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.CLIENTE c ON o.id_cliente = c.id_cliente
        INNER JOIN 
            empr.PAIS p ON c.id_pais = p.id_pais
        INNER JOIN
            empr.PRODUCTO pr ON pr.id_producto = po.id_producto
		INNER JOIN
			empr.categoria ca ON ca.id_categoria = pr.id_categoria
        GROUP BY 
            ca.nombre
        ORDER BY 
            unidades desc    
        LIMIT 1;
        `
        ;
        const [rows2, fields2] = await connection.query(script2)
        resultado.push(rows2[0])
        connection.release();

        res.status(200).send({
            consulta: "consulta6",
            res: true,
            resultado: resultado
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta6",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 7
Mostrar la categoría más comprada por cada país. Se debe de mostrar el nombre del país, nombre de la categoría y cantidad de unidades.                */
export const consulta7 = async (req, res) => {
    try {
        const script = `
        SELECT 
            p.nombre AS nombre_pais,
            cat.nombre AS nombre_categoria,
            SUM(po.cantidad) AS cantidad_unidades
        FROM 
            empr.PAIS p
        INNER JOIN 
            empr.CLIENTE c ON p.id_pais = c.id_pais
        INNER JOIN 
            empr.ORDEN o ON c.id_cliente = o.id_cliente
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        INNER JOIN 
            empr.CATEGORIA cat ON pr.id_categoria = cat.id_categoria
        GROUP BY 
            p.id_pais, cat.id_categoria
        HAVING 
            SUM(po.cantidad) = (
                SELECT 
                    MAX(sub.total_unidades)
                FROM 
                    (SELECT 
                        p.id_pais,
                        cat.id_categoria,
                        SUM(po.cantidad) AS total_unidades
                    FROM 
                        empr.PAIS p
                    INNER JOIN 
                        empr.CLIENTE c ON p.id_pais = c.id_pais
                    INNER JOIN 
                        empr.ORDEN o ON c.id_cliente = o.id_cliente
                    INNER JOIN 
                        empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
                    INNER JOIN 
                        empr.PRODUCTO pr ON po.id_producto = pr.id_producto
                    INNER JOIN 
                        empr.CATEGORIA cat ON pr.id_categoria = cat.id_categoria
                    GROUP BY 
                        p.id_pais, cat.id_categoria) AS sub
                WHERE 
                    sub.id_pais = p.id_pais
            );
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta7",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta7",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 8
Mostrar las ventas por mes de Inglaterra. Debe de mostrar el número del mes y el monto.                */
export const consulta8 = async (req, res) => {
    try {
        const script = `
        SELECT 
            MONTH(o.fecha) AS numero_mes,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.VENDEDOR v
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON v.id_vendedor = po.id_vendedor
        INNER JOIN
            empr.ORDEN o ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        INNER JOIN 
            empr.PAIS p ON v.id_pais = p.id_pais
        WHERE 
            p.nombre = 'Inglaterra'
        GROUP BY 
            numero_mes
        ORDER BY 
            numero_mes;
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta8",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta8",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 9
Mostrar el mes con más y menos ventas. Se debe de mostrar el número de mes y monto.                */
export const consulta9 = async (req, res) => {
    try {
        
        const connection = await db.getConnection();
        const script = `
        SELECT 
            MONTH(o.fecha) AS numero_mes_mas_vendido,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.ORDEN o
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            numero_mes_mas_vendido
        ORDER BY 
            monto_total DESC
        LIMIT 1;
        `
        const [rows1, fields1] = await connection.query(script)
        let resultado = []
        resultado.push(rows1[0])
        const script2 = `
        SELECT 
            MONTH(o.fecha) AS numero_mes_menos_vendido,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.ORDEN o
        INNER JOIN 
            empr.PRODUCTO_ORDEN po ON o.id = po.id_lineastabla
        INNER JOIN 
            empr.PRODUCTO pr ON po.id_producto = pr.id_producto
        GROUP BY 
            numero_mes_menos_vendido
        ORDER BY 
            monto_total ASC
        LIMIT 1;
        `
        ;
        const [rows2, fields2] = await connection.query(script2)
        resultado.push(rows2[0])
        connection.release();

        res.status(200).send({
            consulta: "consulta9",
            res: true,
            resultado: resultado
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta9",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}



/* 10
Mostrar las ventas de cada producto de la categoría deportes. Se debe de mostrar el id del producto, nombre y monto                */
export const consulta10 = async (req, res) => {
    try {
        const script = `
        SELECT 
            pr.id_producto,
            pr.nombre AS nombre_producto,
            SUM(po.cantidad * pr.precio) AS monto_total
        FROM 
            empr.PRODUCTO pr
        JOIN 
            empr.CATEGORIA c ON pr.id_categoria = c.id_categoria
        JOIN 
            empr.PRODUCTO_ORDEN po ON pr.id_producto = po.id_producto
        WHERE 
            c.nombre = 'deportes'
        GROUP BY 
            pr.id_producto, pr.nombre;
        `
        const [rows, fields] = await db.query(script)

        res.status(200).send({
            consulta: "consulta10",
            res: true,
            resultado: rows
        })
    } catch (e) {
        console.log(e)
        res.status(500).send({
            consulta: "consulta10",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}