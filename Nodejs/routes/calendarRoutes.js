const express = require("express");
const router = express.Router();
const calendarController = require("../controllers/calendarController");
const authenticateToken = require("../middleware/authenticateToken");

router.get("/calendar-product", authenticateToken, calendarController.calendarProduct); //http://localhost:3000/calendar-product?date=2025-06-23
router.get("/dot-calendar", authenticateToken, calendarController.dotCalendar); //http://localhost:3000/dot-calendar?month=5&year=2025


module.exports = router;