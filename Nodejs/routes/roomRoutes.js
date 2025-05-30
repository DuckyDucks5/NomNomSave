const express = require("express");
const router = express.Router();
const roomController = require("../controllers/roomController");
const authenticateToken = require("../middleware/authenticateToken");


router.post("/create-room", authenticateToken, roomController.createRoom);
router.post("/join-room", authenticateToken,  roomController.joinRoom);
router.get("/view-room/:userId", authenticateToken,  roomController.viewRoom);
router.put("/update-room/:teamId", authenticateToken,  roomController.updateRoom);
router.delete("/leave-room/:teamId/:userId", authenticateToken,  roomController.leaveRoom);
router.delete("/delete-room/:teamId", authenticateToken,  roomController.deleteRoom);
router.get("/get-room-name/:roomCode", authenticateToken,  roomController.getRoomNameByCode);
router.get("/get-member-room/:teamId", authenticateToken,  roomController.getMemberRoom);
router.get("/overview-product-room/:teamId", authenticateToken,  roomController.overviewProduct);

module.exports = router;