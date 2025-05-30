const cron = require("node-cron");
const moment = require("moment");
const product = require("../models/productModel");
const pushNotif = require("../jobs/pushNotif");
const productModel = require("../models/productModel");
const db = require("../models/db");

// require("dotenv").config();
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
// ...existing code...

cron.schedule('0 0 * * *', async () => {
    const today = moment().format('YYYY-MM-DD');
    console.log(`[CRON] Running status update at ${today}`);

    product.updateExpiredStatus(today, (err, result) => {
        if (err) {
            return console.error("[CRON ERROR] Failed to update expired products:", err);
        }

        console.log(`[CRON] Updated ${result.affectedRows} product(s) to EXPIRED`);
    });
});


cron.schedule('* * * * *', async () => {
    const today = moment().format('YYYY-MM-DD');
    console.log(`[CRON] Running notification send at ${today}`);

    const upcomingDates = [
        moment().add(7, 'days').format('YYYY-MM-DD'),
        moment().add(3, 'days').format('YYYY-MM-DD'),
        moment().add(1, 'days').format('YYYY-MM-DD'),
        today
    ];

    for (const date of upcomingDates) {
        try {
            const products = await productModel.searchProductByExpiredDate(date);

            for (const p of products) {
                console.log("masuk expired jobs")
                const daysLeft = moment(p.ExpiredDate).diff(moment().startOf('day'), 'days');
                const msg = (daysLeft === 0)
                    ? `Your ${p.ProductName} has expired! ❌`
                    : `Your ${p.ProductName} in ${p.TeamName} room will expire in ${daysLeft} days! ⏳`;

                if (p.fcmToken) {
                    try {
                        await pushNotif.sendToUser(p.fcmToken, msg);
                        await new Promise(res => setTimeout(res, 300));
                    } catch (err) {
                        console.error("Error sending notification to user:", err.message);
                    }
                }
            }
        } catch (err) {
            console.error("Error fetching products for date:", date, err.message);
        }
    }
});
