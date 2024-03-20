import {config} from 'dotenv';
import {createPool} from 'mysql2/promise';
config();

export const db = createPool({
    host: process.env.HOSTDB,
    user: process.env.USERDB,
    password: process.env.PASSWORDDB,
    database: process.env.DBDB,
    port: process.env.PORTDB
})