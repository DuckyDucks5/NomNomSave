const admin = require("../config/firebase");
// require("dotenv").config(); // Load environment variables from .env file

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
// ...existing code...

async function sendToUser(fcmToken, message){
    const payload = {
    token: fcmToken, 
        notification: {
            title: "Heads Up NomNomers 🐣",
            body: message,
        }

    }

    try{
        const response = await admin.messaging().send(payload);
        console.log("FCM Response:", response);
        return response;
    }
    catch(err){
        console.error('error from fcmcontroller:', err);
        throw err;
    }
}



module.exports = { sendToUser };