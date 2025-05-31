const db = require("./db");

const productModel = {
  addProduct: (
    userId,
    teamId,
    ProductName,
    ExpiredDate,
    ProductCategoryId,
    callback
  ) => {
    const sql =
      "INSERT INTO msproduct (ProductName, ExpiredDate, UserUserID, TeamTeamID,  ProductCategoryId, ProductStatus) VALUES (?, ?, ?, ?, ?, 1)";
    db.query(
      sql,
      [ProductName, ExpiredDate, userId, teamId, ProductCategoryId],
      callback
    );
  },

  changeCategory: (ProductCategory, callback) => {
    const sql = "SELECT CategoryID FROM mscategory WHERE CategoryName = ?";
    db.query(sql, [ProductCategory], callback);
  },

  recentlyAdded: (userId, callback) => {
    const sql = `SELECT mp.ProductID, mp.ProductName, mt.TeamName, mu.UserName, mt.TeamID 
    FROM msteam mt JOIN msproduct mp ON mp.TeamTeamID = mt.TeamID 
    JOIN msuser mu ON mu.UserID = mp.UserUserID
    WHERE mp.UserUserID = ? ORDER BY mp.ProductID DESC LIMIT 3`;
    db.query(sql, [userId], callback);
  },

  viewProductInTeam: (teamId, callback) => {
    const sql =
      "SELECT ProductName, DATE_FORMAT(ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, ProductCategory, UserUserID FROM msproduct WHERE TeamTeamID = ?";
    db.query(sql, [teamId], callback);
  },

  viewProductAll: (userId, callback) => {
    const sql = `SELECT mp.ProductID, mp.ProductName, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, mt.TeamName 
        FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID
        JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID  
        WHERE mc.UserUserID = ? 
        `;
    db.query(sql, [userId], callback);
  },

  viewProductCategory: (userId, categoryId, teamId, callback) => {
    const sql = `SELECT mp.ProductID, mp.ProductName, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, 
    DATEDIFF(mp.ExpiredDate, CURDATE()) AS daysLeft, mt.TeamName, mp.ProductStatus, mu.UserName
        FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID
        JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID
        JOIN msuser mu ON mu.UserID = mc.UserUserID 
        WHERE mc.UserUserID =? AND mp.ProductCategoryId = ? AND mp.TeamTeamID =? AND mp.ProductStatus = 1
        ORDER BY ExpiredDate ASC`;
    db.query(sql, [userId, categoryId, teamId], callback);
  },

  overviewProduct: (userId, callback) => {
    const sql = `SELECT mp.ProductID, mp.ProductName, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS FormattedExpiredDate, mt.TeamName, mp.ProductCategoryId,
        mcg.CategoryName, mp.TeamTeamID
        FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID
        JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID 
        JOIN mscategory mcg ON mp.ProductCategoryId = mcg.CategoryID 
        WHERE mc.UserUserID = ? AND mp.ProductStatus = 1
        ORDER BY ExpiredDate ASC LIMIT 3`;
    db.query(sql, [userId], callback);
  },

  deleteProduct: (productId, callback) => {
    const sql = "DELETE FROM msproduct WHERE ProductID = ?";
    db.query(sql, [productId], callback);
  },

  updateProduct: (
    UserID,
    productId,
    productName,
    ExpiredDate,
    ProductCategoryId,
    callback
  ) => {
    const sql =
      "UPDATE msproduct SET ProductName =?, ExpiredDate =?, ProductCategoryId =?, UserUserID =?, ProductStatus = 1 WHERE ProductID =?";
    db.query(
      sql,
      [productName, ExpiredDate, ProductCategoryId, UserID, productId],
      callback
    );
  },

  historyProduct: (userId, callback) => {
    const sql = `SELECT mp.ProductName, mp.ProductStatus, DATE_FORMAT(mp.ExpiredDate, '%d %M %Y') AS ExpiredDate, mt.TeamName 
        FROM msproduct mp 
        JOIN msteam mt ON mp.TeamTeamID = mt.TeamID
        JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID
        WHERE mc.UserUserID =? AND mp.ProductStatus IN(2,3)
        ORDER BY mp.ExpiredDate DESc;`;
    db.query(sql, [userId], callback);
  },

  searchProduct: (partialSearch, userId, callback) => {
    const sql =
      "SELECT ProductName FROM msproduct WHERE ProductName LIKE ? AND UserUserId =?";
    db.query(sql, [`%${partialSearch}%`, userId], callback);
  },

  searchProductByExpiredDate: (userId, expireDate) => {
    return new Promise((resolve, reject) => {
      const sql = `
          SELECT mp.ProductID, mp.ProductName, mp.ExpiredDate, mp.UserUserID, mu.fcmToken, mt.TeamName
          FROM msproduct mp JOIN msteam mt ON mp.TeamTeamID = mt.TeamID
          JOIN  msuser mu ON mp.UserUserID = mu.UserID
          JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID  
          WHERE mc.UserUserID = ? AND DATE(mp.ExpiredDate) = ?
            `;
      db.query(sql, [userId, expireDate], (err, results) => {
        if (err) reject(err);
        else resolve(results);
      });
    });
  },

  updateExpiredStatus: (today, callback) => {
    const sql = `
      UPDATE msproduct SET ProductStatus = 2
      WHERE ProductStatus = 1 AND ExpiredDate < ?
  `;
    db.query(sql, [today], callback);
  },

  updateConsumedProduct: (productId, callback) => {
    const sql = `
        UPDATE msproduct SET ProductStatus = 3
        WHERE ProductID = ? AND ProductStatus = 1
        `;
    db.query(sql, [productId], callback);
  },

  countProducts: (teamId, callback) => {
    const sql = `SELECT 
    c.CategoryID, 
    c.CategoryName, 
    COUNT(p.ProductCategoryId) AS ProductCount
FROM 
    msproduct p
JOIN 
    mscategory c ON p.ProductCategoryId = c.CategoryID
WHERE 
    p.TeamTeamID = ? 
    AND p.ProductStatus = 1
GROUP BY 
    c.CategoryID, c.CategoryName
ORDER BY 
    c.CategoryName;
`;
    db.query(sql, [teamId], callback);
  },

  // updateExpiredStatus: (callback) => {
  //   const sql = `
  //   UPDATE msproduct
  //   SET ProductStatus = 2
  //   WHERE ExpiredDate < NOW() AND ProductStatus = 1;
  // `;
  //   db.query(sql, callback);
  // },
};

module.exports = productModel;
