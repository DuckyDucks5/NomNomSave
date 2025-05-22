const db = require("./db");

const userModel = {
  createUser: (fullName, email, phone, password, callback) => {
    const sql =
      "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword, UserProfileIndex) VALUES (?, ?, ?, ?, 1)";
    db.query(sql, [fullName, email, phone, password], callback);
  },

  getUserByEmail: (email, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail = ?";
    db.query(sql, [email], callback);
  },

  getUserByEmailPassword: (email, password, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail = ? AND UserPassword = ?";
    db.query(sql, [email, password], callback);
  },

  saveUser: (userData, callback) => {
    const sql =
      "INSERT INTO msuser (UserName, UserEmail) VALUES (?, ?) ON DUPLICATE KEY UPDATE UserEmail=UserEmail";
    db.query(sql, [userData.displayName, userData.emails[0].value], callback);
  },

  forgotPassword: (userEmail, callback) => {
    const sql =
    "SELECT * FROM msuser WHERE UserEmail = ?";
    db.query(sql, [userEmail], callback);
  },

  updateResetToken: (userId, token, expiry, callback) => {
    const sql =
    "UPDATE msuser SET ResetToken = ?, ResetTokenExpiry = ? WHERE UserID = ?";
    db.query(sql, [token, expiry, userId], callback);
  },

  updatePassword: (userId, password, callback) =>{
    const sql =
    "UPDATE msuser SET UserPassword = ?, ResetToken = NULL, ResetTokenExpiry = NULL WHERE UserID = ?";
    db.query(sql, [password,userId], callback);
  },

  verifyResetToken: (token, callback) => {
    const sql = 
    "SELECT * FROM msuser WHERE ResetToken =? AND ResetTokenExpiry > ?";
    db.query(sql, [token, Date.now()], callback);
  },

  updateProfile: (userId, username, email, phonenumber, profileImageIndex, callback) => {
    const sql = `
    UPDATE msuser SET UserName = ?, UserEmail = ?, UserPhoneNumber = ?, UserProfileIndex = ? WHERE UserID = ?
    `;
    db.query(sql, [username, email, phonenumber, profileImageIndex, userId], callback);
  }

  

};

module.exports = userModel;
