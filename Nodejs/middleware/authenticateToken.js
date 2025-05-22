const jwt = require('jsonwebtoken');

const JWT_SECRET = "nomnomsaveenvsecretanjay";

function authenticateToken(req, res, next){
    const token = req.cookies.token;

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