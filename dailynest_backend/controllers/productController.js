const pool = require("../config/db");

// =====================================================
// ADD PRODUCT
// =====================================================

const addProduct = async (req, res) => {
  try {
    const {
      name,
      description,
      category,
      brand,
      sku,
      price,
      mrp,
      discount,
      stock,
      image_url,
      is_available,
      is_subscription_eligible,
    } = req.body;

    if (!name || !category || price == null || mrp == null) {
      return res.status(400).json({
        message: "Name, category, price and MRP are required",
      });
    }

    const result = await pool.query(
      `INSERT INTO products
      (
        name,
        description,
        category,
        brand,
        sku,
        price,
        mrp,
        discount,
        stock,
        image_url,
        is_available,
        is_subscription_eligible
      )
      VALUES
      ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
      RETURNING *`,
      [
        name,
        description || null,
        category,
        brand || null,
        sku || null,
        price,
        mrp,
        discount || 0,
        stock || 0,
        image_url || null,
        is_available !== false,
        is_subscription_eligible !== false,
      ]
    );

    res.status(201).json({
      message: "Product added successfully",
      product: result.rows[0],
    });
  } catch (error) {
    console.error("Add product error:", error.message);

    res.status(500).json({
      message: "Unable to add product",
    });
  }
};

// =====================================================
// GET ALL PRODUCTS
// =====================================================

const getAllProducts = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM products
       ORDER BY created_at DESC`
    );

    res.status(200).json({
      message: "Products fetched successfully",
      products: result.rows,
    });
  } catch (error) {
    console.error("Get products error:", error.message);

    res.status(500).json({
      message: "Unable to fetch products",
    });
  }
};

// =====================================================
// GET SINGLE PRODUCT
// =====================================================

const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT *
       FROM products
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.status(200).json({
      message: "Product fetched successfully",
      product: result.rows[0],
    });
  } catch (error) {
    console.error("Get product error:", error.message);

    res.status(500).json({
      message: "Unable to fetch product",
    });
  }
};

// =====================================================
// UPDATE PRODUCT
// =====================================================

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      description,
      category,
      brand,
      sku,
      price,
      mrp,
      discount,
      stock,
      image_url,
      is_available,
      is_subscription_eligible,
    } = req.body;

    const result = await pool.query(
      `UPDATE products
       SET
         name = $1,
         description = $2,
         category = $3,
         brand = $4,
         sku = $5,
         price = $6,
         mrp = $7,
         discount = $8,
         stock = $9,
         image_url = $10,
         is_available = $11,
         is_subscription_eligible = $12,
         updated_at = CURRENT_TIMESTAMP
       WHERE id = $13
       RETURNING *`,
      [
        name,
        description || null,
        category,
        brand || null,
        sku || null,
        price,
        mrp,
        discount || 0,
        stock || 0,
        image_url || null,
        is_available !== false,
        is_subscription_eligible !== false,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.status(200).json({
      message: "Product updated successfully",
      product: result.rows[0],
    });
  } catch (error) {
    console.error("Update product error:", error.message);

    res.status(500).json({
      message: "Unable to update product",
    });
  }
};

// =====================================================
// DELETE PRODUCT
// =====================================================

const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM products
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.status(200).json({
      message: "Product deleted successfully",
      product: result.rows[0],
    });
  } catch (error) {
    console.error("Delete product error:", error.message);

    res.status(500).json({
      message: "Unable to delete product",
    });
  }
};

const updateProductStock = async (req, res) => {
  try {
    const { id } = req.params;
    const { stock } = req.body;

    if (stock === undefined || stock === null) {
      return res.status(400).json({
        message: "Stock is required",
      });
    }

    const stockValue = Number(stock);

    if (!Number.isInteger(stockValue) || stockValue < 0) {
      return res.status(400).json({
        message: "Stock must be a valid non-negative integer",
      });
    }

    const result = await pool.query(
      `UPDATE products
       SET stock = $1,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [stockValue, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.status(200).json({
      message: "Product stock updated successfully",
      product: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Update product stock error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to update product stock",
    });
  }
};

module.exports = {
  addProduct,
  getAllProducts,
  getProductById,
  updateProduct,
  deleteProduct,
  updateProductStock
};