const db = require("./db");

const userModel = {
  createUser: (fullName, email, phone, password, callback) => {
    const sql =
      "INSERT INTO msuser (UserName, UserEmail, UserPhoneNumber, UserPassword) VALUES (?, ?, ?, ?)";
    db.query(sql, [fullName, email, phone, password], callback);
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
};

module.exports = userModel;
