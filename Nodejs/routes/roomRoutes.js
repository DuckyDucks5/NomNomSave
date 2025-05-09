const express = require("express");
const router = express.Router();
const roomController = require("../controllers/roomController");
const authenticateToken = require("../middleware/authenticateToken");

router.post("/create-room", authenticateToken, roomController.createRoom);
router.post("/join-room", authenticateToken, roomController.joinRoom);
router.get("/view-room/:teamId", authenticateToken, roomController.viewRoom);
router.put("/update-room/:teamId", authenticateToken, roomController.updateRoom);
router.delete("/leave-room/:teamId", authenticateToken, roomController.leaveRoom);
router.delete("/delete-room/:teamId",authenticateToken, roomController.deleteRoom);

module.exports = router;