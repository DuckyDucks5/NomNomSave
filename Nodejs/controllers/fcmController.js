const userModel = require("../models/userModel");

exports.saveFCMToken = (req,res) => {
    const userId = req.user.userId;
    const { fcmToken } = req.body;

    if(!fcmToken){
        return res.status(400).json({error: "fcmtoken null"});
    }

    userModel.updateFCMToken(userId, fcmToken, (err, result) => {
        if(err){
            return res.status(500).json({ error: err.message });
        }

        res.json({success: true, message: "FCM disimpen yey"});
    })
}
