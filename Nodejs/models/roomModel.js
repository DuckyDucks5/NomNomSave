const db = require("./db");

const roomModel = {
  createRoom: (teamName, roomCode, teamDesc, callback) => {
    const sql =
      "INSERT INTO msteam (TeamName, TeamCreateDate, RoomCode, TeamDescription) VALUES (?, CURDATE(), ?, ?)";
    db.query(sql, [teamName, roomCode, teamDesc], callback);
  },

  addUserToRoom: (userId, teamId, callback) => {
    const sql =
      "INSERT INTO mscollaboration (UserUserID, TeamTeamID) VALUES (?,?)";
    db.query(sql, [userId, teamId], callback);
  },

  getRoomByCode: (roomCode, callback) => {
    const sql = "SELECT TeamID FROM msteam WHERE RoomCode = ?";
    db.query(sql, [roomCode], callback);
  },

  getUserRooms: (userId, callback) => {
    const sql =
      "SELECT mt.TeamName, mt.TeamDescription FROM mscollaboration mc JOIN msteam mt ON mc.TeamTeamID = mt.TeamID WHERE mc.UserUserID = ?";
    db.query(sql, [userId], callback);
  },

  updateRoom: (teamName, teamDesc, teamId, callback) => {
    const sql = "UPDATE msteam SET TeamName =?, TeamDescription =? WHERE TeamID =?";
    db.query(sql, [teamName, teamDesc, teamId], callback);
  },

  deleteRoom: (teamId, callback) => {
    const sql = "DELETE FROM mscollaboration WHERE TeamTeamID = ?";
    db.query(sql, [teamId], callback);
  },

  deleteRoomById: (teamId, callback) => {
    const sql = "DELETE FROM msteam WHERE TeamID =?";
    db.query(sql, [teamId], callback);
  },
};

module.exports = roomModel;
