const roomModel = require('../models/roomModel');

const isUserInRoom = (userId, teamId, callback) => {
  roomModel.checkUserInRoom(userId, teamId, (err, result) => {
    if (err) {
      return callback(err, null);
    }

    if (result.length === 0) {
      return callback(null, false);
    }

    return callback(null, true);
  });
};

module.exports = { isUserInRoom };