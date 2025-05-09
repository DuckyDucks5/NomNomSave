const express = require("express");
const router = express.Router();
const userController = require("../controllers/authController");
const  authenticateToken = require("../middleware/authenticateToken");

router.post("/forgot-password", authenticateToken, userController.forgotPassword);
router.post("/reset-password/:token", authenticateToken, userController.resetPassword);

module.exports = router;
