const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");
const authenticateToken = require("../middleware/authenticateToken");

router.post("/add-product", productController.addProduct);
router.post("/search-product", authenticateToken, productController.searchProduct);
router.get("/view-product/:teamId", productController.viewProduct);
router.get("/overview-product-home/:userId", productController.overviewProduct);
router.get("/recently-added-product/:userId", productController.recentlyAddedProduct);
router.get("/history-product", productController.historyProduct);
router.put("/update-product/:productId", authenticateToken, productController.updateProduct);
router.delete("/delete-product/:productId", authenticateToken, productController.deleteProduct);


module.exports = router;