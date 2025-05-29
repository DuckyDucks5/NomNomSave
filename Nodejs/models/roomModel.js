
const db = require("./db");

const roomModel = {
  createRoom: (teamName, roomCode, teamDesc, profileImageIndex, callback) => {
    const sql =
      "INSERT INTO msteam (TeamName, TeamCreateDate, RoomCode, TeamDescription, TeamProfileIndex) VALUES (?, CURDATE(), ?, ?, ?)";
    db.query(sql, [teamName, roomCode, teamDesc, profileImageIndex], callback);
  },

  addUserToRoom: (userId, teamId, callback) => {
    const sql =
      "INSERT INTO mscollaboration (UserUserID, TeamTeamID) VALUES (?,?)";
    db.query(sql, [userId, teamId], callback);
  },

  getRoombyName: (teamName, callback) => {
    const sql =
      "SELECT TeamID FROM msteam WHERE TeamName = ? ";
    db.query(sql, [teamName], callback);
  },

  getRoomByCode: (roomCode, callback) => {
    const sql = "SELECT TeamID FROM msteam WHERE RoomCode = ?";
    db.query(sql, [roomCode], callback);
  },

  getRoomNameByCode: (roomCode, callback) => {
    const sql = "SELECT TeamName FROM msteam WHERE RoomCode = ?";
    db.query(sql, [roomCode], callback);
  },

  getUserRooms: (userId, callback) => {
    const sql =
      "SELECT mt.TeamName, mt.TeamDescription FROM mscollaboration mc JOIN msteam mt ON mc.TeamTeamID = mt.TeamID WHERE mc.UserUserID = ?";
    db.query(sql, [userId], callback);
  },

  checkDuplicateRoom: (teamName, callback) => {
    const sql = "SELECT TeamID FROM msteam WHERE TeamName = ?";
    db.query(sql, [teamName], callback);
  },

  getMemberRoom: (teamId, callback) => {
    const sql =
      "SELECT mu.UserName, mu.UserProfileIndex, mu.UserID FROM mscollaboration mc JOIN msuser mu ON mc.UserUserID = mu.UserID WHERE mc.TeamTeamID = ?";
    db.query(sql, [teamId], callback);
  },

  updateRoom: (teamName, teamDesc, profileImageIndex, teamId, callback) => {
    const sql = "UPDATE msteam SET TeamName =?, TeamDescription =?, TeamProfileIndex =? WHERE TeamID =?";
    db.query(sql, [teamName, teamDesc, profileImageIndex, teamId], callback);
  },

  deleteRoom: (teamId, callback) => {
    const sql = "DELETE FROM mscollaboration WHERE TeamTeamID = ?";
    db.query(sql, [teamId], callback);
  },

  deleteRoomById: (teamId, callback) => {
    const sql = "DELETE FROM msteam WHERE TeamID =?";
    db.query(sql, [teamId], callback);
  },

  getRoomDetails: (userId, callback) => {
    const sql = `
      Select mt.TeamID, mt.TeamName, mt.TeamDescription, mt.TeamCreateDate, mt.RoomCode, mt.TeamProfileIndex 
      FROM msteam mt JOIN mscollaboration mc 
      ON mt.TeamID = mc.TeamTeamID
      JOIN msuser mu ON mu.UserID = mc.UserUserID
      WHERE mu.UserID = ?`;
    db.query(sql, [userId], callback);
  },

  checkUserInRoom: (userId, teamId, callback) =>{
    const sql =
    "SELECT u.UserID FROM msuser u JOIN mscollaboration c ON c.UserUserID = u.UserID JOIN msteam t ON t.TeamID = c.TeamTeamID WHERE c.UserUserID = ? AND c.TeamTeamID = ?";
    db.query(sql, [userId, teamId], callback);
  },

  removeUserFromRoom: (userId, teamId, callback) => {
    const sql = "DELETE FROM mscollaboration WHERE UserUserID = ? AND TeamTeamID = ?";
    db.query(sql, [userId, teamId], callback);
  },

  overviewProductinRoom: (teamId, callback) => {
    const sql = "SELECT p.ProductName, DATE_FORMAT(p.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, p.UserUserID, u.UserName FROM msproduct p JOIN msuser u ON p.UserUserID = u.UserID WHERE p.TeamTeamID = ? ORDER BY p.ProductID DESC LIMIT 2";
    db.query(sql, [teamId], callback);
  }

};

module.exports = roomModel;
