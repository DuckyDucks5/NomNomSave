const express = require("express");
const router = express.Router();
const productController = require("../controllers/productController");
const authenticateToken = require("../middleware/authenticateToken");

router.post("/add-product", authenticateToken, productController.addProduct);
router.post("/search-product", authenticateToken, productController.searchProduct);
router.get("/view-product/:teamId", authenticateToken, productController.viewProduct);
router.get("/overview-product", authenticateToken, productController.overviewProduct);
router.get("/history-product", authenticateToken, productController.historyProduct);
router.put("/update-product/:productId", authenticateToken, productController.updateProduct);
router.delete("/delete-product/:productId", authenticateToken, productController.deleteProduct);


module.exports = router;

