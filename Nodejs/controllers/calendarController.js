const calendarModel = require("../models/calendarModel")

function formatDateToLocalDDMMYYYY(date) {
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  const day = local.getDate().toString().padStart(2, '0');
  const month = (local.getMonth() + 1).toString().padStart(2, '0');
  const year = local.getFullYear();
  return `${day}/${month}/${year}`;
}


exports.calendarProduct = (req, res) => {
  const userId = req.user.userId;
  const date = req.query.date;
  //const dateObj = new Date();
  //const timezoneOffsetMillis = dateObj.getTimezoneOffset() * 60000;
  //const localDate = new Date(dateObj.getTime() - timezoneOffsetMillis).toISOString().slice(0, 10);

    calendarModel.calendarProduct(userId, date, (err, result) =>{
      if(err){
        return res.status(500).json({error: err.message});
      }
  
      if(result.length === 0){
        return res.status(404).json({message: "No Upcoming Expired Product!"});
      }
  
      const todayList = [];
      const upcomingList = [];
  
      result.forEach(product => {
        const productDate = new Date(product.ExpiredDate);
        const utcMillis = productDate.getTime();
        const timezoneOffsetMillis = productDate.getTimezoneOffset() * 60000;
        const localDateStr = new Date(utcMillis - timezoneOffsetMillis).toISOString().slice(0, 10);
  
        const formattedDate = formatDateToLocalDDMMYYYY(productDate);
        if(localDateStr === date){
          todayList.push({
            name: product.ProductName,
            room: product.RoomName,
            date: formattedDate
          })
        }
        else{
          upcomingList.push({
            name: product.ProductName,
            room: product.RoomName,
            date: formattedDate
          })
        }
      });
  
      res.status(200).json({
        today: todayList,
        upcoming: upcomingList
      })
    })
  }

  exports.dotCalendar = (req, res) => {
    const userId = req.params.userId;
    //const date = req.query.date;
    const month = req.query.month;
    const year = req.query.year;

    console.log("user= " + userId);
    console.log("month= " + month);
    console.log("year= " + year);
    //console.log("date= " + date);

    calendarModel.dotCalendar(userId, month, year,  (err, result) => {
        if(err){
            return res.status(500).json({error: err.message});
        }

        if(result.length === 0){
          return res.status(404).json({message: "No Dates!"})
        }

       const markedDates = result.map(row => {
      const dateObj = new Date(row.ExpiredDate);
      // Ambil bagian YYYY-MM-DD langsung tanpa zona waktu
      return dateObj.toISOString().split("T")[0];
        });
        res.status(200).json({ markedDates });
    }) 
  
  } 