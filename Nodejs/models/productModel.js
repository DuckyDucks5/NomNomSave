const db = require("./db");

const productModel = {
    addProduct:(userId, teamId, ProductName, ExpiredDate, callback) => {
        const sql = 
            "INSERT INTO msproduct (ProductName, ExpiredDate, UserUserID, TeamTeamID) VALUES (?, ?, ?, ?)";
            db.query(sql, [ProductName, ExpiredDate, userId, teamId], callback);
    },

    viewProduct: (teamId, callback) => {
        const sql = 
        "SELECT ProductName, DATE_FORMAT(ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, UserUserID FROM msproduct WHERE TeamTeamID = ?";
        db.query(sql, [teamId], callback);
    }, 

    overviewProduct: (userId, callback) => {
        const sql =
        "SELECT mp.ProductID, mp.ProductName, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, mt.TeamName FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID  WHERE UserUserID =? ORDER BY ExpiredDate ASC LIMIT 3";
        db.query(sql, [userId], callback);
    },

    deleteProduct: (productId, callback) =>{
        const sql =
        "DELETE FROM msproduct WHERE ProductID = ?";
        db.query(sql, [productId],  callback);
    },

    updateProduct: (productId, productName, ExpiredDate, callback) => {
        const sql = 
        "UPDATE msproduct SET ProductName =?, ExpiredDate =? WHERE ProductID =?";
        db.query(sql, [ProductName, ExpiredDate, productId], callback);
    }

}

module.exports = productModel;