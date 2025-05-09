const calendarModel = require("../models/calendarModel")

exports.calendarProduct = (req, res) => {
    const userId = req.user.userId;
    const date = req.query.date;
  
    calendarModel.calendarProduct(userId, date,(err, result) =>{
      if(err){
        return res.status(500).json({error: err.message});
      }
  
      if(result.length === 0){
        return res.status(404).json({message: "No Upcoming Expired Product!"});
      }
  
      const todayList = [];
      const upcomingList = [];
  
      result.forEach(product => {
        const productDate = product.ExpiredDate.toISOString().slice(0,10);
  
        if(productDate === date){
          todayList.push({
            name: product.ProductName,
            room: product.RoomName,
            date: productDate
          })
        }
        else{
          upcomingList.push({
            name: product.ProductName,
            room: product.RoomName,
            date: productDate
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
    const userId = req.user.userId;
    const month = req.query.month;
    const year = req.query.year;

    calendarModel.dotCalendar(userId, month, year, (err, result) => {
        if(err){
            return res.status(500).json({error: err.message});
        }

        const markedDates = result.map(row => row.ExpiredDate.toISOString().slice(0,10));
        res.status(200).json({markedDates});
    }) 
  
  }