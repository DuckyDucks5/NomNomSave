const jwt = require('jsonwebtoken');
// require('dotenv').config(); // Load environment variables

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
// ...existing code...

const JWT_SECRET = process.env.JWT_SECRET;

function authenticateToken(req, res, next){

    const bearerToken = req.headers['authorization'];
    const token = bearerToken?.startsWith("Bearer ") ? bearerToken.split(' ')[1] : req.cookies.token;

    console.log("bearertoken : " + bearerToken);
    console.log("token : " + token);

    if(!token){
        return res.status(401).json({message: "Unauthorized, please log in"});
    }

    jwt.verify(token, JWT_SECRET, (err, user)=> {
        if(err){
            return res.status(403).json({ message: "Forbidden, token is invalid" });
        }

        req.user = user;
        next();
    })
}
module.exports = authenticateToken;