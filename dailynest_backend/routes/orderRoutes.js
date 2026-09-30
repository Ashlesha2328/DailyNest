const express = require("express");

const {
  createOrder,
  getUserOrders,
  getAllOrders,
  getOrderById,
  updateOrderStatus,
} = require("../controllers/orderController");

const router = express.Router();

// =====================================================
// CREATE ORDER
// =====================================================

router.post("/", createOrder);

// =====================================================
// GET ALL ORDERS - ADMIN
// IMPORTANT: This must come BEFORE /:id
// =====================================================

router.get("/all", getAllOrders);

// =====================================================
// GET USER ORDERS
// =====================================================

router.get("/user/:user_id", getUserOrders);

// =====================================================
// GET SINGLE ORDER
// =====================================================

router.get("/:id", getOrderById);

// =====================================================
// UPDATE ORDER STATUS
// =====================================================

router.put("/:id/status", updateOrderStatus);

module.exports = router;