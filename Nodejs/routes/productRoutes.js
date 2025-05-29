const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");
const authenticateToken = require("../middleware/authenticateToken");


router.post("/add-product", authenticateToken, productController.addProduct);
router.post("/search-product", authenticateToken, productController.searchProduct);
router.get("/view-product/:teamId", authenticateToken, productController.viewProduct);
router.get("/overview-product-home/:userId", authenticateToken, productController.overviewProduct);
router.get("/recently-added-product/:userId", authenticateToken, productController.recentlyAddedProduct);
router.get("/history-product/:userId", authenticateToken, productController.historyProduct);
router.put("/update-product/:productId", authenticateToken, productController.updateProduct);
router.delete("/delete-product/:productId", authenticateToken, productController.deleteProduct);
router.get("/count-products/:teamId", authenticateToken, productController.countCategory);
router.get("/view-product-category/:userId/:categoryId/:teamId", authenticateToken, productController.viewProductCategory);
router.put("/mark-consumed/:productId", authenticateToken, productController.markConsumed);

router.put("/mark-expired", authenticateToken, productController.markExpired);

module.exports = router;