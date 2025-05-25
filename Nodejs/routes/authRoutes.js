const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

router.post("/login", authController.login);
router.post("/logout", authController.logout);
router.post("/register", authController.register);
router.get("/verify-email", authController.verifyEmail);


module.exports = router;