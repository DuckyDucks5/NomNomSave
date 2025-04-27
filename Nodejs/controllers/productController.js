const productModel = require("../models/productModel");


exports.addProduct = (req,res) => {
    const {userId, teamId, ProductName, ExpiredDate} = req.body;

    productModel.addProduct(userId, teamId, ProductName, ExpiredDate, (err, result) => {
        if(err){
            return res.status(500).json({ error: err.message });
        }

        res.status(200).json({message: "Product Successfully Added"});
    })
}

exports.viewProduct = (req,res) => {
    const {teamId} = req.params.teamId;

    productModel.viewProduct(teamId, (err, result) => {
        if(err){
            return res.status(500).json({ error: err.message });
        }

        if(result.length === 0){
            return res.status(404).json({message: "No Product Yet!"});
          }
    
          res.status(200).json(result);
    })
}

exports.overviewProduct = (req, res) => {
    const userId = req.params.userId;

    productModel.overviewProduct(userId, (err, result) => {
        if(err){
            return res.status(500).json({ error: err.message });
        }

        if(result.length === 0){
            return res.status(404).json({message: "No Product Yet!"});
          }
    
          res.status(200).json(result);
    })
}

exports.updateProduct = (req, res) => {
    const productId = req.params.productId;
    const {ProductName, ExpiredDate} = req.body;
  
    productModel.updateProduct(productId, ProductName, ExpiredDate, (err, result) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
  
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Product not found." });
      }
  
      res.status(200).json({ message: "Product updated successfully!" });
    });
  };

  exports.deleteProduct =(req, res) => {
    const productId = req.params.productId;

    productModel.deleteProduct(productId, (err, result) => {
        if(err){
            return res.status(500).json({error: err.message});
          }
    
          if(result.affectedRows === 0){
            return res.status(404).json({message: "Product not found."});
          }
    
          res.status(200).json({message: "Product deleted successfully."});
    })
  }