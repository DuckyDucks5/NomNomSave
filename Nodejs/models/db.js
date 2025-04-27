const mysql = require("mysql2");

const db = mysql.createConnection({
  host: "localhost",
  user: "root", // Default user in XAMPP
  password: "", // Default password is empty
  database: "nomnomsave", // Replace with your database name
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed:", err);
    return;
  }
  console.log("Connected to MySQL database");
});

module.exports = db;
