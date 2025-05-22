const express = require("express");
const router = express.Router();
const roomController = require("../controllers/roomController");
const authenticateToken = require("../middleware/authenticateToken");

router.post("/create-room", roomController.createRoom);
router.post("/join-room", roomController.joinRoom);
router.get("/view-room/:userId", roomController.viewRoom);
router.put("/update-room/:teamId", roomController.updateRoom);
router.delete("/leave-room/:teamId/:userId", roomController.leaveRoom);
router.delete("/delete-room/:teamId", roomController.deleteRoom);
router.get("/get-room-name/:roomCode", roomController.getRoomNameByCode);
router.get("/get-member-room/:teamId", roomController.getMemberRoom);
router.get("/overview-product-room/:teamId", roomController.overviewProduct);

module.exports = router;