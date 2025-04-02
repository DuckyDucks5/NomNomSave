const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Koneksi ke Database MySQL (XAMPP)
const db = mysql.createConnection({
  host: "localhost",
  user: "root", // User default di XAMPP
  password: "", // Password default kosong
  database: "nomnomsave", // Ganti sesuai dengan nama database yang ada di phpMyAdmin
});

// Cek koneksi ke database
db.connect((err) => {
  if (err) {
    console.error("❌ Database connection failed:", err);
    return;
  }
  console.log("✅ Connected to MySQL database");
});


// Tambahkan rute untuk menangani GET /
app.get('/', (req, res) => {
  res.send('Server is running! 🚀');
});

// API untuk login
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email dan password harus diisi" });
  }

  const sql = "SELECT * FROM msuser WHERE UserEmail = ? AND UserPassword = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) {
      console.error("❌ Database query error:", err);
      return res.status(500).json({ message: "Terjadi kesalahan pada server" });
    }

    if (results.length > 0) {
      res.status(200).json({ message: "Login berhasil", user: results[0] });
    } else {
      res.status(401).json({ message: "Email atau password salah" });
    }
  });
});


// Jalankan server
app.listen(port, () => {
  console.log(`🚀 Server berjalan di http://localhost:${port}`);
});

app.post("/register", (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName || !phone) {
    return res.status(400).json({ message: "Semua field harus diisi!" });
  }

  const sql = "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword) VALUES (?, ?, ?, ?)";
  db.query(sql, [fullName, email, phone, password], (err, result) => {
    if (err) {
      console.error("❌ Error saat registrasi:", err);
      return res.status(500).json({ message: "Terjadi kesalahan saat registrasi." });
    }
    res.status(201).json({ message: "Registrasi berhasil!" });
  });
});

function generateRoomCode(){
  return Math.random().toString(36).substring(2,7).toUpperCase();
}

app.post("/create-room", (req,res) =>{
  const { teamName, teamDesc, userId } = req.body;
  db.query(
    "SELECT COUNT(*) AS teamCount from mscollaboration WHERE UserUserID = ?",
    [userId], (err, result) =>{
      if(err){
        return res.status(500).json({error: err.message});
      }

      if(result[0].teamCount >= 7){
        return res.status(400).json({message: "User already in 7 rooms."});
      }

      const roomCode = generateRoomCode();

      db.query(
        "INSERT INTO msteam (TeamName, TeamCreateDate, RoomCode, TeamDescription) VALUES (?, CURDATE(), ?, ?)",
        [teamName, roomCode, teamDesc], (err, result) =>{
          if(err){
            return res.status(500).json({error: err.message});
          }

          const teamId = result.insertId;

          db.query(
            "INSERT INTO mscollaboration (UserUserID, TeamTeamID) VALUES (?,?)",
            [userId, teamId], (err) =>{
              if(err){
                return res.status(500).json({error: err.message});
              }

              res.status(201).json({
                message: "Room Created Succesfully",
                teamId, roomCode,
              });
            }
          )
        }
      )
    }
  )
})

app.post("/join-room", (req,res) =>{
  const {userId, roomCode} = req.body;
  //roomCode = roomCode.toUpperCase();

  db.query(
    "SELECT TeamID FROM msteam WHERE RoomCode = ?",
    [roomCode], (err, result) =>{
      if(err){
        return res.status(500).json({error: err.message});
      }

      if(result.length === 0){
        return res.status(404).json({message: "Invalid Room Code."});
      }

      const teamId = result[0].TeamID;

     db.query(
      "SELECT * FROM mscollaboration WHERE UserUserID =? AND TeamTeamID =?", 
      [userId, teamId], (err, existResult) =>{
        if(err){
          return res.status(500).json({error: err.message});
        }

        if(existResult.length > 0){
          return res.status(400).json({message: "User is already in this room."});
        }

        db.query(
          "SELECT COUNT(*) AS roomCount FROM mscollaboration WHERE UserUserID =?",
          [userId], (err,roomResult) => {
            if(err){
              return res.status(500).json({error: err.message});
            }
  
            if(roomResult[0].roomCount  >= 7){
              return res.status(400).json({message: "User already in 7 rooms."});
            }
            
            db.query(
              "Insert INTO mscollaboration (UserUserID, TeamTeamID) VALUES (?,?)",
              [userId, teamId], (err) =>{
                if(err){
                  return res.status(500).json({error: err.message});
                }
  
                res.status(200).json({message:"Joined room succesfully!"});
              }
            )
          }
        )
      }
     )

    }

  )
})

app.post("/view-room", (req, res)=>{
  const {userId} = req.body;

  db.query(
    "SELECT mt.TeamName, mt.TeamDescription FROM mscollaboration mc JOIN msteam mt ON mc.TeamTeamID = mt.TeamID WHERE mc.UserUserID = ?",
    [userId], (err,result) => {
      if(err){
        return res.status(500).json({error: err.message});
      }

      if(result.length === 0){
        return req.status(404).json({message: "User has not joined any room."});
      }

      res.status(200).json(result);
    }
  )
})

app.get("/user-rooms/:teamId", (req, res) => {
  const teamId = req.params.teamId;

  db.query(
    "SELECT mu.UserName, mu.UserEmail FROM mscollaboration mc JOIN msuser mu ON mc.UserUserID = mu.UserID WHERE mc.TeamTeamID = ?",
    [teamId], (err, result) =>{
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.length === 0){
      return res.status(404).json({message: "No members yet."});
    }

    res.status(200).json(result);
  })
})

app.delete("/delete-room/:teamId", (req, res) =>{
  const teamId = req.params.teamId;

  db.query(
    "DELETE FROM mscollaboration WHERE TeamTeamID = ?",
    [teamId], (err) =>{
      if(err){
        return res.status(500).json({error: err.message});
      }

      db.query(
        "DELETE FROM msteam WHERE TeamID =?",
        [teamId], (err, result) =>{
          if(err){
            return res.status(500).json({error: err.message});
          }

          if(result.affectedRows === 0){
            return res.status(404).json({message: "Room not found."});
          }

          res.status(200).json({message: "Room deleted successfully."});
        }
      )
    }
  )
})

app.delete("/leave-room/:teamId/:userId", (req, res)=>{
  const {teamId, userId} = req.params;

  db.query("DELETE FROM mscollaboration WHERE TeamTeamID =? AND UserUserID =?",
  [teamId, userId], (err, result)=>{
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.affectedRows === 0){
      return res.status(404).json({message: "User not found."});
    }

    res.status(200).json({message: "You has left succesfully"})
  }
  )
})

app.put("/update-room/:teamId", (req, res) =>{
  const teamId = req.params.teamId;
  const {teamName, teamDesc} = req.body;

  db.query(
    "UPDATE msteam SET TeamName =?, TeamDescription =? WHERE TeamID =?",
    [teamName, teamDesc, teamId], (err, result)=>{
      if(err){
        return res.status(500).json({error: err.message});
      }

      if(result.affectedRows === 0){
        return res.status(404).json({message: "Room Not Found."});
      }

      res.status(200).json({message: "Room updated succesfully!"});
    }
  )
})