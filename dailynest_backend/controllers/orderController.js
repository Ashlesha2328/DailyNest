const pool = require("../config/db");

// =====================================================
// CREATE ORDER
// =====================================================

const createOrder = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      user_id,
      subtotal,
      delivery_charge,
      tax,
      discount,
      total_amount,
      payment_method,
      delivery_address,
      delivery_date,
      delivery_slot,
      items,
    } = req.body;

    // =========================
    // VALIDATION
    // =========================

    if (
      !user_id ||
      subtotal === undefined ||
      total_amount === undefined ||
      !items ||
      !Array.isArray(items) ||
      items.length === 0
    ) {
      return res.status(400).json({
        message: "Required order details are missing",
      });
    }

    if (!payment_method) {
      return res.status(400).json({
        message: "Payment method is required",
      });
    }

    // =========================
    // CHECK USER
    // =========================

    const userResult = await client.query(
      `SELECT id
       FROM users
       WHERE id = $1`,
      [user_id]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // =========================
    // START TRANSACTION
    // =========================

    await client.query("BEGIN");

    // =========================
    // CREATE ORDER
    // =========================

    const orderResult = await client.query(
      `INSERT INTO orders
       (
         user_id,
         subtotal,
         delivery_charge,
         tax,
         discount,
         total_amount,
         payment_method,
         order_status,
         delivery_address,
         delivery_date,
         delivery_slot
       )
       VALUES
       (
         $1, $2, $3, $4, $5, $6,
         $7, 'Placed', $8, $9, $10
       )
       RETURNING *`,
      [
        user_id,
        subtotal,
        delivery_charge || 0,
        tax || 0,
        discount || 0,
        total_amount,
        payment_method,
        delivery_address || null,
        delivery_date || null,
        delivery_slot || null,
      ]
    );

    const order = orderResult.rows[0];

    // =========================
    // ADD ORDER ITEMS
    // =========================

    for (const item of items) {
      if (
        !item.product_id ||
        !item.product_name ||
        item.price === undefined ||
        !item.quantity
      ) {
        throw new Error("Invalid product information");
      }

      await client.query(
        `INSERT INTO order_items
         (
           order_id,
           product_id,
           product_name,
           product_image,
           price,
           quantity
         )
         VALUES
         (
           $1, $2, $3, $4, $5, $6
         )`,
        [
          order.id,
          item.product_id,
          item.product_name,
          item.product_image || null,
          item.price,
          item.quantity,
        ]
      );
    }

    // =========================
    // CLEAR USER CART
    // =========================

    await client.query(
      `DELETE FROM cart_items
       WHERE user_id = $1`,
      [user_id]
    );

    // =========================
    // COMMIT
    // =========================

    await client.query("COMMIT");

    // =========================
    // RESPONSE
    // =========================

    res.status(201).json({
      message: "Order placed successfully",
      order: order,
    });
  } catch (error) {
    await client.query("ROLLBACK");

    console.error(
      "Create order error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to place order",
    });
  } finally {
    client.release();
  }
};


// =====================================================
// GET USER ORDERS
// =====================================================

const getUserOrders = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    // =========================
    // GET ORDERS
    // =========================

    const ordersResult = await pool.query(
      `SELECT *
       FROM orders
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [user_id]
    );

    const orders = ordersResult.rows;

    // =========================
    // GET ITEMS
    // =========================

    for (const order of orders) {
      const itemsResult = await pool.query(
        `SELECT *
         FROM order_items
         WHERE order_id = $1
         ORDER BY created_at ASC`,
        [order.id]
      );

      order.items = itemsResult.rows;
    }

    // =========================
    // RESPONSE
    // =========================

    res.status(200).json({
      message: "Orders fetched successfully",
      orders: orders,
    });
  } catch (error) {
    console.error(
      "Get user orders error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch orders",
    });
  }
};


// =====================================================
// GET ALL ORDERS - ADMIN
// =====================================================

const getAllOrders = async (req, res) => {
  try {
    // =========================
    // GET ALL ORDERS
    // =========================

    const ordersResult = await pool.query(
      `SELECT
         o.*,
         u.name AS customer_name,
         u.email AS customer_email,
         u.mobile AS customer_mobile
       FROM orders o
       LEFT JOIN users u
         ON o.user_id = u.id
       ORDER BY o.created_at DESC`
    );

    const orders = ordersResult.rows;

    // =========================
    // GET ITEMS FOR EACH ORDER
    // =========================

    for (const order of orders) {
      const itemsResult = await pool.query(
        `SELECT
           id,
           order_id,
           product_id,
           product_name,
           product_image,
           price,
           quantity,
           created_at
         FROM order_items
         WHERE order_id = $1
         ORDER BY created_at ASC`,
        [order.id]
      );

      order.items = itemsResult.rows;
    }

    // =========================
    // RESPONSE
    // =========================

    res.status(200).json({
      message: "All orders fetched successfully",
      orders: orders,
    });
  } catch (error) {
    console.error(
      "Get all orders error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch all orders",
    });
  }
};


// =====================================================
// GET SINGLE ORDER
// =====================================================

const getOrderById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        message: "Order ID is required",
      });
    }

    // =========================
    // GET ORDER
    // =========================

    const orderResult = await pool.query(
      `SELECT *
       FROM orders
       WHERE id = $1`,
      [id]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    const order = orderResult.rows[0];

    // =========================
    // GET ORDER ITEMS
    // =========================

    const itemsResult = await pool.query(
      `SELECT *
       FROM order_items
       WHERE order_id = $1
       ORDER BY created_at ASC`,
      [id]
    );

    order.items = itemsResult.rows;

    // =========================
    // RESPONSE
    // =========================

    res.status(200).json({
      message: "Order fetched successfully",
      order: order,
    });
  } catch (error) {
    console.error(
      "Get order error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch order",
    });
  }
};


// =====================================================
// UPDATE ORDER STATUS
// =====================================================

const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { order_status } = req.body;

    // =========================
    // VALIDATION
    // =========================

    if (!id || !order_status) {
      return res.status(400).json({
        message:
          "Order ID and order status are required",
      });
    }

    // =========================
    // ALLOWED STATUSES
    // =========================

    const allowedStatuses = [
      "Placed",
      "Processing",
      "Out for Delivery",
      "Delivered",
      "Cancelled",
    ];

    if (!allowedStatuses.includes(order_status)) {
      return res.status(400).json({
        message: "Invalid order status",
      });
    }

    // =========================
    // UPDATE STATUS
    // =========================

    const result = await pool.query(
      `UPDATE orders
       SET order_status = $1
       WHERE id = $2
       RETURNING *`,
      [
        order_status,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Order not found",
      });
    }

    // =========================
    // RESPONSE
    // =========================

    res.status(200).json({
      message: "Order status updated successfully",
      order: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Update order status error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to update order status",
    });
  }
};


// =====================================================
// EXPORT
// =====================================================

module.exports = {
  createOrder,
  getUserOrders,
  getAllOrders,
  getOrderById,
  updateOrderStatus,
};