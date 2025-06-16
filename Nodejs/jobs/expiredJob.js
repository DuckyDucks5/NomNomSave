const cron = require("node-cron");
const moment = require("moment-timezone");
const product = require("../models/productModel");
const pushNotif = require("../jobs/pushNotif");
const productModel = require("../models/productModel");
const db = require("../models/db");

// require("dotenv").config();
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
// ...existing code...

cron.schedule('0 17 * * *', async () => {
    const today = moment().tz('Asia/Jakarta').format('YYYY-MM-DD');
    console.log(`[CRON] Running status update at ${today}`);

    console.log("Server time:", new Date().toString());
    console.log("Jakarta time:", moment().tz('Asia/Jakarta').format());

    product.updateExpiredStatus(today, (err, result) => {
        if (err) {
            return console.error("[CRON ERROR] Failed to update expired products:", err);
        }

        console.log(`[CRON] Updated ${result.affectedRows} product(s) to EXPIRED`);
    });
});


cron.schedule('*/2 * * * *', async () => {
  const today = moment().tz('Asia/Jakarta').format('YYYY-MM-DD');
  console.log(`[CRON] Running notification send at ${today}`);

  console.log("Server time:", new Date().toString());
  console.log("Jakarta time:", moment().tz('Asia/Jakarta').format());

  const upcomingDates = [
    moment().tz('Asia/Jakarta').add(7, 'days').format('YYYY-MM-DD'),
    moment().tz('Asia/Jakarta').add(3, 'days').format('YYYY-MM-DD'),
    moment().tz('Asia/Jakarta').add(1, 'days').format('YYYY-MM-DD'),
    today
  ];

  db.query("SELECT UserID, fcmToken FROM msuser WHERE fcmToken IS NOT NULL AND IsLoggedIn = TRUE", async (err, users) => {
    if (err) return console.error("[CRON ERROR] Failed to fetch users:", err);

    if(users.length === 0){
        console.log(`[CRON] No User to notify`);
        return;
    }
    for (const user of users) {
      const userId = user.UserID;
      console.log(`UserID: ${userId}`);

      for (const date of upcomingDates) {
        try {
          console.log(`Dates: ${date}`)
          const products = await productModel.searchProductByExpiredDate(userId, date);

          if(products.length === 0){
            console.log(`[CRON] No product to notify for ${date}` );
            continue;
          }
          
          for (const p of products) {
            const nowJakarta = moment().tz('Asia/Jakarta').startOf('day');
            const expiredJakarta = moment(p.ExpiredDate).tz('Asia/Jakarta').startOf('day');
            const daysLeft = expiredJakarta.diff(nowJakarta, 'days');

            const msg = (daysLeft === 0)
              ? `Your ${p.ProductName} will expire today! 😱💔😰`
              : `Your ${p.ProductName} in ${p.TeamName} room will expire in ${daysLeft} days! ⏳`;

            if (user.fcmToken) {
              await pushNotif.sendToUser(user.fcmToken, msg);
              await new Promise(res => setTimeout(res, 300));
            }
          }
        } catch (err) {
          console.error(`[CRON ERROR] Failed for user ${userId} on date ${date}:`, err.message);
        }
      }
    }
  });
});