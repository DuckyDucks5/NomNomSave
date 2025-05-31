const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const authenticateToken = require("../middleware/authenticateToken");

router.post("/login", authController.login);
router.post("/logout", authenticateToken, authController.logout);
router.post("/register", authController.register);
router.get("/verify-email", authController.verifyEmail);


module.exports = router;