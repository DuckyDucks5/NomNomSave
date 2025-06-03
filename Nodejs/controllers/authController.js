const userModel = require("../models/userModel.js");
const roomModel = require("../models/roomModel.js");
const passport = require("passport");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const jwt = require("jsonwebtoken");
const db = require("../models/db.js");
const { error } = require("console");
const { json } = require("body-parser");
const { messaging } = require("firebase-admin");

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

function generateVerificationCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

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

    if (user.IsVerified === "0" || user.IsVerified === 0) {
      return res.status(401).json({ message: "Please verify your account!" });
    }

    const JWT_SECRET = process.env.JWT_SECRET;
    const token = jwt.sign(
      { userId: user.UserID, email: user.UserEmail },
      JWT_SECRET
    );

    res.cookie("token", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      //sameSite: "strict"
    });

    userModel.updateLogInStatus(user.UserID, (updateErr) => {
      if (updateErr) {
        console.error("Failed to update login status:", updateErr);
      }

      roomModel.getUserRooms(user.UserID, (err, roomResults) => {
        if (err) {
          return res
            .status(500).json({ message: "Server error while fetching rooms" });
        }

        const hasRoom = roomResults.length > 0;

        return res.status(200).json({
          message: "Login successful",
          user,
          hasRoom,
          room: roomResults,
          token,
        });
      });
    });
  });
};

exports.logout = (req, res) => {
  const userId = req.user.userId;
  userModel.updateLogOutStatus(userId, (err) => {
      if (err) {
        console.error("Failed to update logout status:", err);
      }

      res.clearCookie("token", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        //sameSite: "strict"
      });
      return res.status(200).json({ message: "Log Out Successful." });
    });
};

// -------------------- REGISTER USER --------------------
exports.register = (req, res) => {
  const { email, password, fullName, phone } = req.body;

  if (!email || !password || !fullName) {
    return res.status(400).json({ message: "All fields are required!" });
  }

  if (password.length < 6) {
    return res
      .status(400)
      .json({ message: "Password must be at least 6 characters long." });
  }

  if (!fullName || fullName.length < 3 || fullName.length >= 15) {
    return res
      .status(400)
      .json({ message: "Full name must be at least 3 characters long." });
  }

  const isValidEmail = (email) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  if (!isValidEmail(email)) {
    return res.status(400).json({ message: "Invalid email format" });
  }

  userModel.findUserEmail(email, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length > 0) {
      return res.status(400).json({ message: "Email already registered!" });
    }

    userModel.createUser(fullName, email, phone, password, (err, user) => {
      if (err) {
        console.error("Registration error:", err);
        return res.status(500).json({ message: "Registration failed." });
      }

      const verifyLink = `https://nomnomsave-be-se-production.up.railway.app/verify-email?email=${encodeURIComponent(
        email
      )}`;

      const transporter = nodemailer.createTransport({
        service: "Gmail",
        auth: {
          user: "nomnomsavenoreply@gmail.com",
          pass: "tcgw phrt swgo vruw",
        },
      });

      const mailOptions = {
        to: email,
        subject: "Verify Your Email!",
        html: `<p>Hi ${fullName},</p><p>Please verify your email by clicking the link below:</p><a href="${verifyLink}">Verify Email</a><p>This helps us ensure it's really you!</p>`,
      };

      transporter.sendMail(mailOptions, (err) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }

        res
          .status(201)
          .json({
            message:
              "Registration successful! Please check your email to verify your account.",
          });
      });
    });
  });
};

exports.verifyEmail = (req, res) => {
  const { email } = req.query;

  userModel.setEmailVerified(email, (err) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    res
      .status(200)
      .send("<h2>Email successfully verified!</h2><p>You may now log in.</p>");
  });
};
//----------------------------------------------
exports.forgotPassword = (req, res) => {
  const { email } = req.body;

  const token = generateVerificationCode();
  const tokenExpiry = Date.now() + 1800000;

  userModel.forgotPassword(email, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(400).json({ message: "Email Not Found!" });
    }

    const userId = result[0].UserID;

    userModel.updateResetToken(userId, token, tokenExpiry, (err2) => {
      if (err2) {
        return res.status(500).json({ error: err2.message });
      }

      const transporter = nodemailer.createTransport({
        service: "Gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS, // Use environment variables for sensitive data
        },
      });

      const mailOptions = {
        to: email,
        subject: "Password Reset",
        html: `<p>Your password reset code is: <strong>${token}</strong>. It will expire in 30 minutes.</p>`,
      };

      transporter.sendMail(mailOptions, (err3) => {
        if (err3) {
          return res.status(500).json({ error: err3.message });
        }

        res
          .status(200)
          .json({ message: "Verification code sent to your email." });
      });
    });
  });
};

exports.resendVerifiyCode = (req, res) => {
  const { email } = req.body;

  userModel.findUserEmail(email, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(404).json({ error: "Email not found!" });
    }

    const user = result[0];
    const now = Date.now();

    if (
      user.LastVerificationSentAt &&
      now - user.LastVerificationSentAt < 30000
    ) {
      const waitTime = Math.ceil(
        (30000 - (now - user.LastVerificationSentAt)) / 1000
      );
      return res
        .status(429)
        .json({ error: `Please wait ${waitTime} seconds before resending.` });
    }

    const token = generateVerificationCode();
    const tokenExpiry = Date.now() + 1800000;

    // const userId = result[0].UserID;

    userModel.updateResetToken(email, token, tokenExpiry, (err2) => {
      if (err2) {
        return res.status(500).json({ error: err2.message });
      }

      const transporter = nodemailer.createTransport({
        service: "Gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS, // Use environment variables for sensitive data
        },
      });

      const mailOptions = {
        to: email,
        subject: "Password Reset",
        html: `<p>Your password reset code is: <strong>${token}</strong>. It will expire in 30 minutes.</p>`,
      };

      transporter.sendMail(mailOptions, (err3) => {
        if (err3) {
          return res.status(500).json({ error: err3.message });
        }

        res
          .status(200)
          .json({ message: "Verification code sent to your email." });
      });
    });
  });
};

exports.verifyResetCode = (req, res) => {
  const { email, code } = req.body;

  userModel.forgotPassword(email, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(400).json({ message: "Email is not found." });
    }

    const user = result[0];
    const now = Date.now();

    if (user.ResetToken !== code) {
      return res.status(400).json({ message: "Invalid code!" });
    }

    if (user.ResetTokenExpiry < now) {
      return res.status(400).json({ message: "Code expired!" });
    }

    res.status(200).json({ message: "Success!" });
  });
};

exports.resetPassword = (req, res) => {
  const { email, newPassword } = req.body;

  if (!newPassword || newPassword.length < 6) {
    return res
      .status(400)
      .json({ message: "Password must be at least 6 characters long." });
  }

  userModel.updatePassword(email, newPassword, (err) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    userModel.updateResetToken(email, null, null, (err2) => {
      if (err2) {
        return res.status(500).json({ error: err2.message });
      }
    });

    res.status(200).json({ message: "Password has been reset successfully." });
  });
};

//---------------------------------
exports.viewProfile = (req, res) => {
  const userId = req.user.userId;

  console.log("userID: " + userId);

  userModel.viewProfile(userId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(400).json({ message: "User Not Found!" });
    }
    console.log("Profile Result: ", result);
    res.status(200).json(result);
  });
};

exports.updateProfile = (req, res) => {
  const userId = req.user.userId;
  const { UserName, UserEmail, UserPhoneNumber, ProfileImageIndex } = req.body;

  userModel.updateProfile(
    userId,
    UserName,
    UserEmail,
    UserPhoneNumber,
    ProfileImageIndex,
    (err, result) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "User not found!" });
      }

      res.status(200).json({ message: "Profile Successfully Updated!" });
    }
  );
};

exports.deleteMember = (req, res) => {
  const { teamId, userId } = req.params;

  userModel.deleteMember(teamId, userId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Member not found!" });
    }

    res.status(200).json({ message: "Member successfully deleted!" });
  });
};
