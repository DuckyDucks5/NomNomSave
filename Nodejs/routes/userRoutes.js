const express = require("express");
const router = express.Router();
const userController = require("../controllers/authController");
const fcmcontroller = require("../controllers/fcmController");
const  authenticateToken = require("../middleware/authenticateToken");

router.post("/forgot-password", userController.forgotPassword);
router.post("/save-fcm-token", authenticateToken, fcmcontroller.saveFCMToken);
router.post("/reset-password", userController.resetPassword);
router.post("/verify-code", userController.verifyResetCode);
router.post("/resend-verify-code", userController.resendVerifiyCode);


router.get("/view-profile/:userId", authenticateToken, userController.viewProfile);

router.put("/update-profile/:userId", authenticateToken, userController.updateProfile);

router.delete("/delete-member/:teamId/:userId", authenticateToken, userController.deleteMember);


// Add any user-specific routes here in future if needed.
module.exports = router;
