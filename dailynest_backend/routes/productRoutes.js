const express = require("express");

const {
  addProduct,
  getAllProducts,
  getProductById,
  updateProduct,
  deleteProduct,
  updateProductStock,
} = require("../controllers/productController");

const router = express.Router();

// Add product
router.post("/", addProduct);

// Get all products
router.get("/", getAllProducts);

// Get single product
router.get("/:id", getProductById);

// Update product
router.put("/:id", updateProduct);

// Update product stock
router.put("/:id/stock", updateProductStock);

// Delete product
router.delete("/:id", deleteProduct);

module.exports = router;