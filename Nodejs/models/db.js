const mysql = require("mysql2");
// require("dotenv").config(); // Load environment variables from .env file

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
// ...existing code...

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER, 
  password: process.env.DB_PASSWORD || '', // Use empty string if DB_PASSWORD is not set
  database: process.env.DB_NAME, 
  port: process.env.PORT,
  // waitForConnections: true, // Enable connection pooling
  // ssl: {
  //   rejectUnauthorized: true, // Disable SSL certificate validation
  // },
 
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed:", err);
    return;
  }
  console.log("Connected to MySQL database");
});

module.exports = db;
