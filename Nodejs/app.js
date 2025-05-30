// require('dotenv').config();
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
// ...existing code...
require('./jobs/expiredJob');

const express = require("express");
const passport = require("passport");
const session = require("express-session");
const cors = require("cors");
const bodyParser = require("body-parser");
const cookieParser = require('cookie-parser');

const authRoutes = require("./routes/authRoutes");
const roomRoutes = require("./routes/roomRoutes");
const userRoutes = require("./routes/userRoutes");
const calendarRoutes = require("./routes/calendarRoutes");
const productRoutes = require("./routes/productRoutes");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(cookieParser());

// Session Configuration
app.use(
  session({
    secret: "secret",
    resave: false,
    saveUninitialized: true,
  })
);

app.use(passport.initialize());
app.use(passport.session());

// Routes
app.use("/", authRoutes);
app.use("/", roomRoutes);
app.use("/", userRoutes);
app.use("/", productRoutes);
app.use("/", calendarRoutes);

// Start Server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log("Cron jobs initialized...");
});