const db = require("./db");

const userModel = {
  createUser: (fullName, email, phone, password, callback) => {
    const sql =
      "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword, UserProfileIndex) VALUES (?, ?, ?, ?, 1)";
    db.query(sql, [fullName, email, phone, password], callback);
  },

  updateLogInStatus: (userId, callback) => {
    const sql = "UPDATE msuser SET IsLoggedIn = true WHERE UserID = ?";
    db.query(sql, [userId], callback)
  },

  updateLogOutStatus: (userId, callback) => {
    const sql = "UPDATE msuser SET IsLoggedIn = false WHERE UserID = ?";
    db.query(sql, [userId], callback)
  },
  
  getUserByEmail: (email, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail = ?";
    db.query(sql, [email], callback);
  },

  setEmailVerified: (email, callback) => {
    const sql = "UPDATE msuser SET IsVerified = true WHERE UserEmail = ?";
    db.query(sql, [email], callback);
  },

  getUserByEmailPassword: (email, password, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail = ? AND UserPassword = ?";
    db.query(sql, [email, password], callback);
  },

  findUserEmail: (email, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail  =? ";
    db.query(sql, [email], callback);
  },

  viewProfile: (userId, callback) => {
    const sql = `SELECT UserName, UserEmail, UserPhoneNumber, UserProfileIndex FROM msuser WHERE UserID = ?`;
    db.query(sql, [userId], callback);
  },

  updateProfile: (
    userId,
    username,
    email,
    phonenumber,
    profileImageIndex,
    callback
  ) => {
    const sql = `
    UPDATE msuser 
    SET UserName = ?, UserEmail = ?, UserPhoneNumber = ?, UserImageIndex = ? 
    WHERE UserID = ?
  `;
    db.query(
      sql,
      [username, email, phonenumber, profileImageIndex, userId],
      callback
    );
  },

  saveUser: (userData, callback) => {
    const sql =
      "INSERT INTO msuser (UserName, UserEmail) VALUES (?, ?) ON DUPLICATE KEY UPDATE UserEmail=UserEmail";
    db.query(sql, [userData.displayName, userData.emails[0].value], callback);
  },

  forgotPassword: (userEmail, callback) => {
    const sql = "SELECT * FROM msuser WHERE UserEmail = ?";
    db.query(sql, [userEmail], callback);
  },

  updateResetToken: (userEmail, token, expiry, callback) => {
    const sql =
      "UPDATE msuser SET ResetToken = ?, ResetTokenExpiry = ? WHERE UserEmail = ?";
    db.query(sql, [token, expiry, userEmail], callback);
  },

  updatePassword: (userEmail, password, callback) => {
    const sql =
      "UPDATE msuser SET UserPassword = ?, ResetToken = NULL, ResetTokenExpiry = NULL WHERE UserEmail = ?";
    db.query(sql, [password, userEmail], callback);
  },

  verifyResetToken: (token, callback) => {
    const sql =
      "SELECT * FROM msuser WHERE ResetToken =? AND ResetTokenExpiry > ?";
    db.query(sql, [token, Date.now()], callback);
  },

  updateProfile: (
    userId,
    username,
    email,
    phonenumber,
    profileImageIndex,
    callback
  ) => {
    const sql = `
    UPDATE msuser SET UserName = ?, UserEmail = ?, UserPhoneNumber = ?, UserProfileIndex = ? WHERE UserID = ?
    `;
    db.query(
      sql,
      [username, email, phonenumber, profileImageIndex, userId],
      callback
    );
  },

  updateFCMToken: (userId, fcmToken, callback) => {
    const sql = `
      UPDATE msuser SET fcmToken = ? WHERE UserID = ?`;
    db.query(sql, [fcmToken, userId], callback);
  },

  deleteMember: (teamId, userId, callback) => {
    const sql = `
      DELETE FROM mscollaboration WHERE TeamTeamID = ? AND UserUserID = ?`;
    db.query(sql, [teamId, userId], callback);
  }

};

module.exports = userModel;
