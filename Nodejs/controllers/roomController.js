const roomModel = require("../models/roomModel");

// Utility function to generate room code
function generateRoomCode() {
  return Math.random().toString(36).substring(2, 7).toUpperCase();
}

exports.createRoom = (req, res) => {
  const userId = req.user.userId;
  const { teamName, teamDesc, profileImageIndex} = req.body;
  console.log("profile image index " + profileImageIndex);

  roomModel.getUserRooms(userId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    console.log("result" + result);

    if (result.length >= 7) {
      return res.status(400).json({ message: "User already in 7 rooms." });
    }

    const roomCode = generateRoomCode();
    roomModel.createRoom(teamName, roomCode, teamDesc, profileImageIndex, (err, result) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      const teamId = result.insertId;

      roomModel.addUserToRoom(userId, teamId, (err) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }
        res.status(201).json({ message: "Room Created Successfully", teamId, roomCode });
      });
    });
  });
};

exports.getRoomNameByCode = (req, res) => {
  const { roomCode } = req.params;  
  
  roomModel.getRoomNameByCode(roomCode, (err, result) => {
    if (err) {  
      return res.status(500).json({ error: err.message });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "Room not found." });
    }
    res.status(200).json({ roomName: result[0].TeamName });
  });
}

exports.joinRoom = (req, res) => {
  const { userId, roomCode } = req.body;

  roomModel.getRoomByCode(roomCode, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(404).json({ message: "Invalid Room Code." });
    }

    const teamId = result[0].TeamID;

    roomModel.checkUserInRoom(userId, teamId, (err, existResult) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      if (existResult.length > 0) {
        return res.status(400).json({ message: "User is already in this room." });
      }

      roomModel.getUserRooms(userId, (err, roomResult) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }

        if (roomResult.length >= 7) {
          return res.status(400).json({ message: "User already in 7 rooms." });
        }

        roomModel.addUserToRoom(userId, teamId, (err) => {
          if (err) {
            return res.status(500).json({ error: err.message });
          }

          res.status(200).json({ message: "Joined room successfully!" });
        });
      });
    });
  });
};

exports.viewRoom = (req, res) => {
  const  userId  = req.user.userId;

  roomModel.getRoomDetails(userId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(404).json({ message: "Room not found." });
    }

    res.status(200).json(result);
  });
};

exports.updateRoom = (req, res) => {
  const { teamName, teamDesc, profileImageIndex} = req.body;
  const teamId = req.params.teamId;

  roomModel.updateRoom(teamName, teamDesc, profileImageIndex, teamId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Room not found." });
    }

    res.status(200).json({ message: "Room updated successfully!" });
  });
};

exports.leaveRoom = (req, res) => {
  const { userId, teamId } = req.params;

  roomModel.removeUserFromRoom(userId, teamId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "User not found in this room." });
    }

    res.status(200).json({ message: "Left room successfully!" });
  });
};

exports.deleteRoom = (req, res) => {
  const teamId = req.params.teamId;

  roomModel.deleteRoom(teamId, (err) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    roomModel.deleteRoomById(teamId, (err) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      res.status(200).json({ message: "Room deleted successfully." });
    });
  });
};

exports.getMemberRoom = (req, res) => {
  const { teamId } = req.params;
  
  roomModel.getMemberRoom(teamId, (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(404).json({ message: "No members found in this room." });
    }

    res.status(200).json(result);
  });
}

exports.overviewProduct = (req, res) => {
  const {teamId} = req.params;

  roomModel.overviewProductinRoom(teamId, (err, result) => {
     if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (result.length === 0) {
      return res.status(404).json({ message: "No product in this room" });
    }

    res.status(200).json(result);
  });
}