const pool = require("../config/db");

// =====================================================
// ADD TO CART
// =====================================================

const addToCart = async (req, res) => {
  try {
    const {
      user_id,
      product_id,
      product_name,
      product_image,
      price,
      quantity,
    } = req.body;

    if (
      !user_id ||
      !product_id ||
      !product_name ||
      price === undefined
    ) {
      return res.status(400).json({
        message: "Required cart fields are missing",
      });
    }

    const qty = quantity || 1;

    if (qty < 1) {
      return res.status(400).json({
        message: "Quantity must be at least 1",
      });
    }

    // Check user
    const userResult = await pool.query(
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

    // Check if product already exists in cart
    const existingResult = await pool.query(
      `SELECT *
       FROM cart_items
       WHERE user_id = $1
       AND product_id = $2`,
      [user_id, product_id]
    );

    if (existingResult.rows.length > 0) {
      const existingItem = existingResult.rows[0];

      const newQuantity =
        existingItem.quantity + qty;

      const result = await pool.query(
        `UPDATE cart_items
         SET quantity = $1,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $2
         RETURNING *`,
        [newQuantity, existingItem.id]
      );

      return res.status(200).json({
        message: "Cart quantity updated",
        cartItem: result.rows[0],
      });
    }

    // Add new cart item
    const result = await pool.query(
      `INSERT INTO cart_items
       (
         user_id,
         product_id,
         product_name,
         product_image,
         price,
         quantity
       )
       VALUES
       (
         $1, $2, $3, $4, $5, $6
       )
       RETURNING *`,
      [
        user_id,
        product_id,
        product_name,
        product_image || null,
        price,
        qty,
      ]
    );

    res.status(201).json({
      message: "Product added to cart",
      cartItem: result.rows[0],
    });

  } catch (error) {
    console.error(
      "Add to cart error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// GET USER CART
// =====================================================

const getCart = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    const result = await pool.query(
      `SELECT *
       FROM cart_items
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [user_id]
    );

    // Calculate total
    let total = 0;

    result.rows.forEach((item) => {
      total +=
        Number(item.price) *
        Number(item.quantity);
    });

    res.status(200).json({
      message: "Cart fetched successfully",
      cart: result.rows,
      total: total.toFixed(2),
      itemCount: result.rows.length,
    });

  } catch (error) {
    console.error(
      "Get cart error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// UPDATE CART QUANTITY
// =====================================================

const updateCartQuantity = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    if (!id || quantity === undefined) {
      return res.status(400).json({
        message: "Cart item ID and quantity are required",
      });
    }

    if (quantity < 1) {
      return res.status(400).json({
        message: "Quantity must be at least 1",
      });
    }

    const existingResult = await pool.query(
      `SELECT id
       FROM cart_items
       WHERE id = $1`,
      [id]
    );

    if (existingResult.rows.length === 0) {
      return res.status(404).json({
        message: "Cart item not found",
      });
    }

    const result = await pool.query(
      `UPDATE cart_items
       SET quantity = $1,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [quantity, id]
    );

    res.status(200).json({
      message: "Cart quantity updated",
      cartItem: result.rows[0],
    });

  } catch (error) {
    console.error(
      "Update cart quantity error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// DELETE CART ITEM
// =====================================================

const deleteCartItem = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        message: "Cart item ID is required",
      });
    }

    const existingResult = await pool.query(
      `SELECT id
       FROM cart_items
       WHERE id = $1`,
      [id]
    );

    if (existingResult.rows.length === 0) {
      return res.status(404).json({
        message: "Cart item not found",
      });
    }

    await pool.query(
      `DELETE FROM cart_items
       WHERE id = $1`,
      [id]
    );

    res.status(200).json({
      message: "Cart item removed successfully",
    });

  } catch (error) {
    console.error(
      "Delete cart item error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// CLEAR CART
// =====================================================

const clearCart = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    await pool.query(
      `DELETE FROM cart_items
       WHERE user_id = $1`,
      [user_id]
    );

    res.status(200).json({
      message: "Cart cleared successfully",
    });

  } catch (error) {
    console.error(
      "Clear cart error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// EXPORT
// =====================================================

module.exports = {
  addToCart,
  getCart,
  updateCartQuantity,
  deleteCartItem,
  clearCart,
};