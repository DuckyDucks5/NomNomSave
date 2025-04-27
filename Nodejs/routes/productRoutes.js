const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");


router.post("/add-product", productController.addProduct);
router.get("/view-product/:teamId", productController.viewRoom);
router.get("/overview-product/:userId", productController.overviewProduct);
router.put("/update-product/:productId", productController.updateProduct);
router.delete("/delete-product/:productId", productController.deleteProduct);

module.exports = router;