import fs from 'fs';
import { script_create_modeltables, script_create_temptables } from '../scripts/scripts_bd.js';
const fdidr = '../TSEdatasets'

export const getInicio = (req, res) => {
    res.send({
        message: "Api levantada correctamente"
    })
}


export const cargarbtemp = async (req, res) => {
     //Elimina comentarios del script
     let script = script_create_temptables.replace(/--.*\n/g, '')
     let salida = []
 
     try{
        const connection = await db.getConnection();
        //A. Crea las tablas temporales
        //Ejecuta el script1 sin comentarios
        const sqlCommands1 = script.split(";").map(command => command.trim());

        for(let i = 0; i < sqlCommands1.length; i++){
            if(sqlCommands1[i].length === 0){
                continue;
            }
            console.log(sqlCommands1[i])
            await connection.query(sqlCommands1[i])
        }

        let respuesta = {
            consulta: "cargartabtemp",
            res: true,
            message: 'Tablas temporales creadas correctamente'
        }
        salida.push(respuesta)

        //B. Carga los datos de los archivos csv
        // 1. PAIS
        const contenido1 = fs.readFileSync(fdidr + '/paises.csv', 'utf8')
        const filas1 = contenido1.split('\n');
        const paises = filas1.map(fila => fila.split(',')
                            .map(columna => columna.trim()))
                            .filter(columnas => columnas.length > 1);
        
        paises.shift()

        paises.forEach(async columnas => {
            const sql = `INSERT INTO temp_pais (id_pais, nombre) VALUES (?,?)`
            await connection.query(sql, columnas)
        })


        // 2. CATEGORIAS
        const contenido2 = fs.readFileSync(fdidr + '/Categorias.csv', 'utf8')
        const filas2 = contenido2.split('\n');
        const categorias = filas2.map(fila => fila.split(',')
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
        const clientes = filas3.map(fila => fila.split(',')
                            .map(columna => columna.trim()))
                            .filter(columnas => columnas.length > 1);
        clientes.shift()

        clientes.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[4] = Number(columnas[4])
            columnas[6] = Number(columnas[6])
            columnas[7] = Number(columnas[7])
            columnas[9] = Number(columnas[9])
            const sql = `INSERT INTO temp_cliente (id_cliente, nombre, apellido, direccion, telefono, tarjeta, edad, salario, genero, id_pais) VALUES (?,?,?,?,?,?,?)`
            await connection.query(sql, columnas)
        })

        // 4. ORDENES
        const contenido4 = fs.readFileSync(fdidr + '/ordenes.csv', 'utf8')
        const filas4 = contenido4.split('\n');
        const ordenes = filas4.map(fila => fila.split(',')
                                .map(columna => columna.trim()))
                                .filter(columnas => columnas.length > 1);

        ordenes.shift()

        ordenes.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[1] = Number(columnas[1])
            columnas[3] = Number(columnas[3])
            columnas[4] = Number(columnas[4])
            columnas[5] = Number(columnas[5])
            columnas[6] = Number(columnas[6])
            const col_fecha = columnas[2].split('/')
            const fecha = col_fecha[2] + '-' + col_fecha[1] + '-' + col_fecha[0]
            columnas[2] = fecha
            const sql = `INSERT INTO temp_orden (id_orden, linea_orden, fecha_orden, id_cliente, id_vendedor, id_prodcuto, cantidad) VALUES (?,?,?,?,?)`
            await connection.query(sql, columnas)
        })

        // 5. PRODUCTOS
        const contenido5 = fs.readFileSync(fdidr + '/productos.csv', 'utf8')
        const filas5 = contenido4.split('\n');
        const productos = filas4.map(fila => fila.split(',')
                                .map(columna => columna.trim()))
                                .filter(columnas => columnas.length > 1);

        productos.shift()

        productos.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[2] = Number(columnas[2])
            columnas[3] = Number(columnas[3])
            const sql = `INSERT INTO temp_producto (id_producto, nombre, precio, id_categoria) VALUES (?,?,?,?,?)`
            await connection.query(sql, columnas)
        })

        // 6. VENDEDORES
        const contenido6 = fs.readFileSync(fdidr + '/vendedores.csv', 'utf8')
        const filas6 = contenido6.split('\n');
        const vendedores = filas6.map(fila => fila.split(',')
                                .map(columna => columna.trim()))
                                .filter(columnas => columnas.length > 1);

        vendedores.shift()

        vendedores.forEach(async columnas => {
            columnas[0] = Number(columnas[0])
            columnas[2] = Number(columnas[2])
            const sql = `INSERT INTO temp_vendedor (id_vendedor, nombre, id_pais) VALUES (?,?,?,?,?)`
            await connection.query(sql, columnas)
        })

        respuesta = {
            consulta: "cargartabtemp",
            res: true,
            message: 'Datos cargados correctamente a las tablas temporales'
        }
        salida.push(respuesta)

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
        const sql4 = `INSERT INTO empr.PRODUCTO (id_producto, nombre, precio, id_categoria) SELECT id_producto, nombre, precio, id_categoria FROM temp_cliente`
        await connection.query(sql4)

        // 5. ORDEN
        const sql5 = `INSERT INTO empr.ORDEN (id_orden, linea_orden, fecha, id_cliente, id_vendedor) SELECT id_orden, linea_orden, fecha, id_cliente, id_vendedor FROM temp_orden`
        await connection.query(sql5)

        // 6. PRODUCTO_ORDEN
        const sql6 = `INSERT INTO empr.PRODUCTO_ORDEN (id_orden, linea_orden, fecha, id_cliente, id_vendedor) SELECT id_orden, linea_orden, fecha, id_cliente, id_vendedor FROM temp_orden`
        await connection.query(sql6)

        respuesta = {
            consulta: "cargartabtemp",
            res: true,
            message: 'Datos cargados correctamente a las tablas del modelo'
        }
        salida.push(respuesta)

        //D. Elimina las tablas temporales
        const sql7 = `DROP TEMPORARY TABLE temp_pais, temp_categoria, temp_cliente, temp_orden, temp_producto, temp_vendedor`
        await connection.query(sql7)

        respuesta = {
            consulta: "cargartabtemp",
            res: true,
            message: 'Tablas temporales eliminadas correctamente'
        }
        salida.push(respuesta)

        connection.release();
        //C. Carga los datos de las tablas temporales a las tablas del modelo
        res.status(200).send(salida)

     }catch(e){
        console.log(e)
        res.status(500).send({
            consulta: "cargartabtemp",
            res: false,
            message: 'Ocurrio un error: ', e
        })
     }


}

    export const cargarmodelo = async (req, res) => {
        //Elimina comentarios del script
    let script = script_create_modeltables.replace(/--.*\n/g, '')

    try{
        const connection = await db.getConnection();
        //A. Crea las tablas temporales
        //Ejecuta el script1 sin comentarios
        const sqlCommands1 = script.split(";").map(command => command.trim());

        for(let i = 0; i < sqlCommands1.length; i++){
            if(sqlCommands1[i].length === 0){
                continue;
            }
            console.log(sqlCommands1[i])
            await connection.query(sqlCommands1[i])
        }
        connection.release();

        res.status(200).send({
            consulta: "cargarmodelo",
            res: true,
            message: 'Modelo creado con éxito',
            tablas_modelo:[
                'empr.CATEGORIA',
                'empr.PAIS',
                'empr.CLIENTE',
                'empr.PRODUCTO',
                'empr.VENDEDOR',
                'empr.ORDEN',
                'empr.PRODUCTO_ORDEN'
            ]
        })


    }catch(e){
        console.log(e)
        res.status(500).send({
            consulta: "cargarmodelo",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}

export const eliminarmodelo = async (req, res) => {
    
    let script = 'DROP TABLE empr.categoria, pais, cliente, producto, vendedor, orden, producto_orden;'
    try{
        await db.query(script)
        res.status(200).send({
            consulta: "eliminarmodelo",
            res: true,
            message: 'Modelo eliminado con éxito'
        })
    }catch(e){
        console.log(e)
        res.status(500).send({
            consulta: "eliminarmodelo",
            res: false,
            message: 'Ocurrio un error: ', e
        })
    }
}