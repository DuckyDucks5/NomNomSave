const db = require("./db");

const calendarModel = {

    calendarProduct: (userId, date, callback) => {
        const sql = `
        SELECT 
        p.ProductName, p.ExpiredDate, 
        mt.TeamName AS RoomName, p.ProductStatus 
        FROM msproduct p JOIN msteam mt ON p.TeamTeamID = mt.TeamID
        JOIN mscollaboration mc ON p.TeamTeamID = mc.TeamTeamID  
        WHERE mc.UserUserID = ? 
        AND DATE(p.ExpiredDate) >= ?
        ORDER BY p.ExpiredDate;
        `;
        db.query(sql, [userId, date], callback);
    },

    dotCalendar: (userId, month, year, callback) => {
        const sql = `
        SELECT DISTINCT DATE (mp.ExpiredDate) AS ExpiredDate FROM msproduct mp
        JOIN msteam t ON mp.TeamTeamID = t.TeamID
        JOIN mscollaboration mc ON mp.TeamTeamID = mc.TeamTeamID 
        WHERE mc.UserUserID = ? AND MONTH(mp.ExpiredDate) = ? AND YEAR(mp.ExpiredDate) = ?
        ORDER BY ExpiredDate;
        `;
        db.query(sql, [userId, month, year], callback);
    }
}

module.exports = calendarModel;