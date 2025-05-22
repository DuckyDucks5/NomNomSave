const db = require("./db");

const productModel = {
    addProduct:(userId, teamId, ProductName, ExpiredDate, ProductCategoryId, callback) => {
        const sql = 
            "INSERT INTO msproduct (ProductName, ExpiredDate, UserUserID, TeamTeamID,  ProductCategoryId) VALUES (?, ?, ?, ?, ?)";
            db.query(sql, [ProductName, ExpiredDate, userId, teamId, ProductCategoryId], callback);
    },

    changeCategory: (ProductCategory, callback) => {
        const sql = "SELECT CategoryID FROM mscategory WHERE CategoryName = ?";
        db.query(sql, [ProductCategory], callback);
    },

    viewProduct: (teamId, callback) => {
        const sql = 
        "SELECT ProductName, DATE_FORMAT(ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, ProductCategory, UserUserID FROM msproduct WHERE TeamTeamID = ?";
        db.query(sql, [teamId], callback);
    },

    overviewProduct: (userId, callback) => {
        const sql =
        `SELECT mp.ProductID, mp.ProductName, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, mt.TeamName FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID WHERE mp.UserUserID = ? ORDER BY ExpiredDate ASC LIMIT 3`;
        db.query(sql, [userId], callback);
    },

    recentlyAdded:  (userId, callback) => {
        const sql =
        `SELECT mp.ProductID, mp.ProductName, mt.TeamName, mu.UserName FROM msteam mt JOIN msproduct mp ON mp.TeamTeamID = mt.TeamID JOIN msuser mu ON mu.UserID = mp.UserUserID WHERE mp.UserUserID = 13 ORDER BY mp.ProductID DESC LIMIT 3`;
        db.query(sql, [userId], callback);
    },

    deleteProduct: (productId, callback) =>{
        const sql =
        "DELETE FROM msproduct WHERE ProductID = ?";
        db.query(sql, [productId],  callback);
    },

    updateProduct: (productId, productName, ExpiredDate, ProductCategory, callback) => {
        const sql = 
        "UPDATE msproduct SET ProductName =?, ExpiredDate =?, ProductCategory =? WHERE ProductID =?";
        db.query(sql, [productName, ExpiredDate,ProductCategory, productId], callback);
    },

    historyProduct: (userId, callback)=>{
        const sql = 
        "SELECT ProductName, CONCAT(DATEDIFF(CURDATE(), ExpiredDate), ' Days') AS DaysExpired FROM msproduct WHERE ExpiredDate < CURDATE()";
        db.query(sql, [userId], callback);
    },

    searchProduct: (partialSearch, userId, callback) =>{
        const sql = 
        "SELECT ProductName FROM msproduct WHERE ProductName LIKE ? AND UserUserId =?";
        db.query(sql, [`%${partialSearch}%`, userId], callback);
    },

}

module.exports = productModel;