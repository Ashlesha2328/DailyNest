const express = require("express");

const {
  addToCart,
  getCart,
  updateCartQuantity,
  deleteCartItem,
  clearCart,
} = require("../controllers/cartControllers");

const router = express.Router();

// Add product to cart
router.post("/", addToCart);

// Get user's cart
router.get("/:user_id", getCart);

// Update cart quantity
router.put("/:id", updateCartQuantity);

// Clear user's cart
router.delete("/user/:user_id", clearCart);

// Delete cart item
router.delete("/:id", deleteCartItem);


module.exports = router;