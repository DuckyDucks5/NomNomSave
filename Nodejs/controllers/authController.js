const { OAuth2Client } = require('google-auth-library');
const userModel = require("../models/userModel.js");
const roomModel = require("../models/roomModel.js");
const passport = require("passport");
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const db = require("../models/db.js");
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

require("dotenv").config();

// -------------------- GOOGLE SIGN-IN (Manual) --------------------
exports.googleSignIn = async (req, res) => {
  const { idToken } = req.body;

  if (!idToken) {
    return res.status(400).json({ message: 'Missing idToken' });
  }

  try {
    // Verifikasi ID Token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const userEmail = payload.email;
    const userName = payload.name;

    // Cek apakah user sudah ada
    const [existingUser] = await new Promise((resolve, reject) => {
      db.query(
        'SELECT * FROM msuser WHERE userEmail = ?',
        [userEmail],
        (err, results) => {
          if (err) reject(err);
          else resolve(results);
        }
      );
    });

    if (existingUser) {
      // User sudah ada, langsung login
      return res.status(200).json({
        message: 'Login success',
        user: {
          userID: existingUser.userID,
          userName: existingUser.userName,
          userEmail: existingUser.userEmail,
          userPhoneNumber: existingUser.userPhoneNumber,
        },
      });
    }

    // User baru → Insert
    const insertResult = await new Promise((resolve, reject) => {
      db.query(
        'INSERT INTO msuser (userName, userEmail, userPassword, userPhoneNumber) VALUES (?, ?, ?, ?)',
        [userName, userEmail, '', ''],
        (err, result) => {
          if (err) reject(err);
          else resolve(result);
        }
      );
    });

    return res.status(201).json({
      message: 'User registered and logged in',
      user: {
        userID: insertResult.insertId,
        userName: userName,
        userEmail: userEmail,
        userPhoneNumber: '',
      },
    });

  } catch (error) {
    console.error("Google Sign-In Error:", error);
    return res.status(401).json({ message: 'Invalid Google token', error });
  }
};

// -------------------- EMAIL/PASSWORD LOGIN --------------------
exports.login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  userModel.getUserByEmailPassword(email, password, (err, userResults) => {
    if (err) {
      console.error("Database query error:", err);
      return res.status(500).json({ message: "Server error occurred" });
    }

    if (userResults.length === 0) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const user = userResults[0];
    const JWT_SECRET = "nomnomsaveenvsecretanjay";
    const token = jwt.sign({userId: user.UserID, email: user.UserEmail}, JWT_SECRET);
        
    res.cookie("token", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      //sameSite: "strict"
    })

    roomModel.getUserRooms(user.UserID, (err, roomResults) => {
      if (err) {
        return res.status(500).json({ message: "Server error while fetching rooms" });
      }

      const hasRoom = roomResults.length > 0;

      return res.status(200).json({
        message: "Login successful",
        user,
        hasRoom,
        room: roomResults
      });
    });
  });
};

exports.logout = (req, res) =>{
  res.clearCookie("token", {
    httpOnly: true, 
    secure: process.env.NODE_ENV === "production",
    //sameSite: "strict"
  })
  res.status(200).json({message: "Log Out Successfull."});
}


// -------------------- REGISTER USER --------------------
exports.register = (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName || !phone) {
    return res.status(400).json({ message: "All fields are required!" });
  }

  userModel.createUser(fullName, email, phone, password, (err) => {
    if (err) {
      console.error("Registration error:", err);
      return res.status(500).json({ message: "Registration failed." });
    }
    res.status(201).json({ message: "Registration successful!" });
  });
};

//----------------------------------------------
exports.forgotPassword= (req, res) => {
  const {email} = req.body;

  const token = crypto.randomBytes(32).toString('hex');
  const tokenExpiry = Date.now() + 1800000;

  userModel.forgotPassword(email, (err, result) =>{
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.length === 0){
      return res.status(400).json({message: "Email Not Found!"});
    }

    const userId = result[0].UserID;

    userModel.updateResetToken(userId, token, tokenExpiry, (err2) => {
      if(err2){
        return res.status(500).json({error: err2.message});
      }

      const resetLink = `http://localhost:3000/reset-password/${token}`;
      
      const transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
          user: 'nomnomsavenoreply@gmail.com',
          pass: 'tcgw phrt swgo vruw'
        },
      });

      const mailOptions = {
        to: email,
        subject: 'Password Reset',
        html: `<p>Click <a href="${resetLink}">here</a> to reset your password. This link expires in 30 minutes.</p>`,
      };

      transporter.sendMail(mailOptions, (err3) => {
        if(err3){
          return res.status(500).json({error: err3.message});
        }

        res.status(200).json({ message: "Password reset link sent to your email." });
      })
    })

  })

}

exports.resetPassword = (req, res) => {
  const token = req.params.token;
  const {newPassword }= req.body;

  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({ message: "Password must be at least 6 characters long." });
  }

  userModel.verifyResetToken(token, (err, result) => {
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.length === 0){
      return res.status(400).json({message: "Invalid or Expired token,"});
    }

    const userId = result[0].UserID;
    
    userModel.updatePassword(userId, newPassword, (err2) => {
      if(err2){
        return res.status(500).json({error: err.message});
      }

      res.status(200).json({ message: "Password has been reset successfully." });
    })
  })
}

//---------------------------------
exports.updateProfile = (req, res) => {
  const userId = req.user.userId;
  const { username, userEmail, userPhoneNumber, profileImageIndex } = req.body;

  userModel.updateProfile(userId, username, userEmail, userPhoneNumber, profileImageIndex, (err, result) => {
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.affectedRows === 0){
      return res.status(404).json({message: "User not found!"});
    }

    res.status(200).json({message: "Profile Successfully Updated!"});
  })
}
