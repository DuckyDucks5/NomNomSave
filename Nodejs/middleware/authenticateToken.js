const jwt = require('jsonwebtoken');

const JWT_SECRET = "nomnomsaveenvsecretanjay";

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