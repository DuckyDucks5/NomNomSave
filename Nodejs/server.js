require('dotenv').config();

const express = require("express");
const passport = require("passport");
const session = require("express-session");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database Connection
const db = mysql.createConnection({
  host: "localhost",
  user: "root", // Default user in XAMPP
  password: "", // Default password is empty
  database: "nomnomsave", // Replace with your database name
});

db.connect((err) => {
  if (err) {
    console.error("❌ Database connection failed:", err);
    return;
  }
  console.log("✅ Connected to MySQL database");
});

// Session Configuration
app.use(
  session({
    secret: "secret",
    resave: false,
    saveUninitialized: true,
  })
);

app.use(passport.initialize());
app.use(passport.session());

// Google OAuth Strategy
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://localhost:3000/auth/google/callback",
    },
    (accessToken, refreshToken, profile, done) => {
      console.log("Google Profile:", profile);

      // Save user data in DB (if not exists)
      const sql =
        "INSERT INTO msuser (UserName, UserEmail) VALUES (?, ?) ON DUPLICATE KEY UPDATE UserEmail=UserEmail";
      db.query(
        sql,
        [profile.displayName, profile.emails[0].value],
        (err) => {
          if (err) {
            return done(err, null);
          }
          return done(null, profile);
        }
      );
    }
  )
);

// Serialize & Deserialize User
passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((obj, done) => done(null, obj));

// Routes
app.get("/", (req, res) => {
  res.send("Server is running! 🚀");
});

// Login API
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  const sql = "SELECT * FROM msuser WHERE UserEmail = ? AND UserPassword = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) {
      console.error("❌ Database query error:", err);
      return res.status(500).json({ message: "Server error occurred" });
    }

    if (results.length > 0) {
      res.status(200).json({ message: "Login successful", user: results[0] });
    } else {
      res.status(401).json({ message: "Invalid email or password" });
    }
  });
});

// Registration API
app.post("/register", (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName || !phone) {
    return res.status(400).json({ message: "All fields are required!" });
  }

  const sql =
    "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword) VALUES (?, ?, ?, ?)";
  db.query(sql, [fullName, email, phone, password], (err, result) => {
    if (err) {
      console.error("❌ Registration error:", err);
      return res.status(500).json({ message: "Registration failed." });
    }
    res.status(201).json({ message: "Registration successful!" });
  });
});

// Google Login Route
app.get(
  "/auth/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

// Google Callback Route
app.get(
  "/auth/google/callback",
  passport.authenticate("google", { failureRedirect: "/" }),
  (req, res) => {
    res.json({ message: "Login successful", user: req.user });
  }
);

// Logout Route
app.get("/logout", (req, res) => {
  req.logout((err) => {
    if (err) {
      console.error("❌ Logout error:", err);
      return res.status(500).json({ message: "Logout failed" });
    }
    req.session.destroy(() => {
      res.clearCookie("connect.sid");
      res.json({ message: "Logged out" });
    });
  });
});

// Start Server
app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});