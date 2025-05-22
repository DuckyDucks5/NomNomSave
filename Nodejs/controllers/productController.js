const productModel = require("../models/productModel");
const roomModel = require("../models/roomModel");

exports.addProduct = (req, res) => {
  const { userId, teamName, ProductName, ExpiredDate, ProductCategory } = req.body;

  // Validate teamId
  roomModel.getRoombyName(teamName, (err, results) => {
    if (err) {
      return res.status(500).json({ error: "Error retrieving team ID" });
    }

    if (results.length === 0) {
      return res.status(400).json({ error: "Invalid team name" });
    }

    const teamId = results[0].TeamID;

    // Validate ProductCategory
    productModel.changeCategory(ProductCategory, (err, results) => {
      if (err) {
        return res.status(500).json({ error: "Error retrieving category ID" });
      }

      if (results.length === 0) {
        return res.status(400).json({ error: "Invalid category name" });
      }

      const ProductCategoryId = results[0].CategoryID;

      // Add product to the database
      productModel.addProduct(userId, teamId, ProductName, ExpiredDate, ProductCategoryId, (err, result) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }

        return res.status(200).json({ message: "Product successfully added" });
      });
    });
  });
};


exports.viewProduct = (req,res) => {
  const teamId = req.params.teamId;
  const userId = req.user.userId;

  isUserInRoom(userId, teamId, (err, isMember) => {
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(!isMember){
      return res.status(403).json({message: "You are not a member!"});
    }

    productModel.viewProduct(teamId, (err, result) => {
      if(err){
          return res.status(500).json({ error: err.message });
      }
  
      if(result.length === 0){
          return res.status(404).json({message: "No Product Yet!"});
        }
  
        res.status(200).json(result);
  })
  });
}


exports.overviewProduct = (req, res) => {
  const { userId } = req.params;

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

exports.recentlyAddedProduct = (req, res) => {
  const { userId } = req.params;

    productModel.recentlyAdded(userId, (err, result) => {
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
  const {ProductName, ExpiredDate, ProductCategory} = req.body;

  productModel.updateProduct(productId, ProductName, ExpiredDate, ProductCategory, (err, result) => {
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

exports.historyProduct = (req, res) => {
  const userId = req.user.userId;

  productModel.historyProduct(userId, (err, result) => {
    if(err){
      return res.status(500).json({error: err.message});
    }

    if(result.length === 0){
      return res.status(404).json({message: "No Product Yet!"});
    }

    res.status(200).json(result);
  })
}

exports.searchProduct =(req,res) =>{
const userId = req.user.userId;
const partialSearch = req.body.partialSearch;

productModel.searchProduct(partialSearch, userId, (err, result) => {

  if(err){
    return res.status(500).json({error: err.message});
  }

  if(result.length === 0){
    return res.status(404).json({message: `No product with "${partialSearch}"!`});
  }

  res.status(200).json(result);
}
)
}