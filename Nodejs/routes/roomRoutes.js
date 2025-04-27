const express = require("express");
const router = express.Router();
const roomController = require("../controllers/roomController");

router.post("/create-room", roomController.createRoom);
router.post("/join-room", roomController.joinRoom);
router.get("/view-room/:teamId", roomController.viewRoom);
router.put("/update-room/:teamId", roomController.updateRoom);
router.delete("/leave-room/:teamId/:userId", roomController.leaveRoom);
router.delete("/delete-room/:teamId", roomController.deleteRoom);

module.exports = router;
