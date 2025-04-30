const { OAuth2Client } = require('google-auth-library');
const userModel = require("../models/userModel.js");

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// -------------------- GOOGLE SIGN-IN (Manual) --------------------
exports.googleSignIn = async (req, res) => {
  const { idToken } = req.body;

  if (!idToken) {
    return res.status(400).json({ message: "ID token is required" });
  }

  try {
    // 1. Verify ID token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const { email, name } = payload;

    if (!email) {
      return res.status(400).json({ message: "Invalid Google account: no email" });
    }

    // 2. Check if user exists
    userModel.getUserByEmail(email, (err, results) => {
      if (err) {
        console.error("Database query error:", err);
        return res.status(500).json({ message: "Server error occurred" });
      }

      if (results.length > 0) {
        // User exists
        return res.status(200).json({
          message: "Login successful",
          user: results[0],
        });
      } else {
        // User doesn't exist, create one
        userModel.createUser(name, email, "", "", (err2) => {
          if (err2) {
            console.error("Error creating user from Google:", err2);
            return res.status(500).json({ message: "Failed to create user." });
          }

          userModel.getUserByEmail(email, (err3, newUser) => {
            if (err3) {
              console.error("Database query error after creating user:", err3);
              return res.status(500).json({ message: "Server error occurred" });
            }

            res.status(200).json({
              message: "Login successful",
              user: newUser[0],
            });
          });
        });
      }
    });

  } catch (error) {
    console.error("Google ID Token verification error:", error);
    return res.status(401).json({ message: "Invalid Google ID Token" });
  }
};

// -------------------- EMAIL/PASSWORD LOGIN --------------------
exports.login = (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  userModel.getUserByEmailPassword(email, password, (err, results) => {
    if (err) {
      console.error("Database query error:", err);
      return res.status(500).json({ message: "Server error occurred" });
    }

    if (results.length > 0) {
      res.status(200).json({ message: "Login successful", user: results[0] });
    } else {
      res.status(401).json({ message: "Invalid email or password" });
    }
  });
};

// -------------------- REGISTER USER --------------------
exports.register = (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName || !phone) {
    return res.status(400).json({ message: "All fields are required!" });
  }

  userModel.createUser(fullName, email, phone, password, (err) => {
    if (err) {
      console.error("Registration error:", err);
      return res.status(500).json({ message: "Registration failed." });
    }
    res.status(201).json({ message: "Registration successful!" });
  });
};
