const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// **Google Sign-in manual** route (ID Token)
router.post("/auth/google", authController.googleSignIn);

// **Email & Password login**
router.post("/login", authController.login);

// **User Registration**
router.post("/register", authController.register);

module.exports = router;
