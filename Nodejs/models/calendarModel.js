const db = require("./db");

const calendarModel = {

    calendarProduct: (userId, date, callback) => {
        const sql = `
        SELECT 
        p.ProductName, p.ExpiredDate, 
        t.TeamName AS RoomName 
        FROM msproduct p 
        JOIN msteam t ON p.TeamTeamID = t.TeamID 
        WHERE p.UserUserID = ? AND(DATE(p.ExpiredDate) = ? 
        OR DATE(p.ExpiredDate) BETWEEN DATE(?) + INTERVAL 1 DAY AND DATE(?) + INTERVAL 3 DAY)
        ORDER BY p.ExpiredDate
        `;
        db.query(sql, [userId, date, date, date], callback);
    },

    dotCalendar: (userId, month, year, callback) => {
        const sql = `
        SELECT DISTINCT DATE (ExpiredDate) AS ExpiredDate FROM msproduct
        WHERE UserUserID = ? AND MONTH(ExpiredDate) = ? AND YEAR(ExpiredDate) = ?
        ORDER BY ExpiredDate;
        `;
        db.query(sql, [userId, month, year], callback);
    }
}

module.exports = calendarModel;