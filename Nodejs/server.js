const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Koneksi ke Database MySQL (XAMPP)
const db = mysql.createConnection({
  host: "localhost",
  user: "root", // User default di XAMPP
  password: "", // Password default kosong
  database: "nomnomsave", // Ganti sesuai dengan nama database yang ada di phpMyAdmin
});

// Cek koneksi ke database
db.connect((err) => {
  if (err) {
    console.error("❌ Database connection failed:", err);
    return;
  }
  console.log("✅ Connected to MySQL database");
});


// Tambahkan rute untuk menangani GET /
app.get('/', (req, res) => {
  res.send('Server is running! 🚀');
});

// API untuk login
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email dan password harus diisi" });
  }

  const sql = "SELECT * FROM msuser WHERE email = ? AND password = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) {
      console.error("❌ Database query error:", err);
      return res.status(500).json({ message: "Terjadi kesalahan pada server" });
    }

    if (results.length > 0) {
      res.status(200).json({ message: "Login berhasil", user: results[0] });
    } else {
      res.status(401).json({ message: "Email atau password salah" });
    }
  });
});

// Jalankan server
app.listen(port, () => {
  console.log(`🚀 Server berjalan di http://localhost:${port}`);
});

app.post("/register", (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName || !phone) {
    return res.status(400).json({ message: "Semua field harus diisi!" });
  }

  const sql = "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword) VALUES (?, ?, ?, ?)";
  db.query(sql, [fullName, email, phone, password], (err, result) => {
    if (err) {
      console.error("❌ Error saat registrasi:", err);
      return res.status(500).json({ message: "Terjadi kesalahan saat registrasi." });
    }
    res.status(201).json({ message: "Registrasi berhasil!" });
  });
});

