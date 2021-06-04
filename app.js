const express = require('express');
const mysql = require('mysql')
const app = express();

const port = 3000;

const configDB = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306
}

console.log(configDB);

const connection = mysql.createConnection(configDB);

app.get('/', (req, res) => {
    
    connection.query('select * from members', function (err, rows, fields) {
        if (err) throw err
        
        res.json(rows);
    });
})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`);
})
