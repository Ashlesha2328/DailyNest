const pool = require("../config/db");

// =====================================
// GET ALL CATEGORIES
// =====================================

const getAllCategories = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        id,
        name,
        parent_category,
        is_active,
        created_at,
        updated_at
       FROM categories
       ORDER BY id ASC`
    );

    res.status(200).json({
      message: "Categories fetched successfully",
      categories: result.rows,
    });
  } catch (error) {
    console.error(
      "Get categories error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch categories",
    });
  }
};

// =====================================
// ADD CATEGORY
// =====================================

const addCategory = async (req, res) => {
  try {
    const {
      name,
      parent_category,
    } = req.body;

    if (!name || name.trim() === "") {
      return res.status(400).json({
        message: "Category name is required",
      });
    }

    const result = await pool.query(
      `INSERT INTO categories
        (name, parent_category, is_active)
       VALUES ($1, $2, TRUE)
       RETURNING *`,
      [
        name.trim(),
        parent_category || null,
      ]
    );

    res.status(201).json({
      message: "Category added successfully",
      category: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Add category error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to add category",
    });
  }
};

// =====================================
// UPDATE CATEGORY
// =====================================

const updateCategory = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      name,
      parent_category,
    } = req.body;

    if (!name || name.trim() === "") {
      return res.status(400).json({
        message: "Category name is required",
      });
    }

    const result = await pool.query(
      `UPDATE categories
       SET
         name = $1,
         parent_category = $2,
         updated_at = CURRENT_TIMESTAMP
       WHERE id = $3
       RETURNING *`,
      [
        name.trim(),
        parent_category || null,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Category not found",
      });
    }

    res.status(200).json({
      message: "Category updated successfully",
      category: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Update category error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to update category",
    });
  }
};

// =====================================
// DELETE CATEGORY
// =====================================

const deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM categories
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Category not found",
      });
    }

    res.status(200).json({
      message: "Category deleted successfully",
    });
  } catch (error) {
    console.error(
      "Delete category error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to delete category",
    });
  }
};

// =====================================
// TOGGLE CATEGORY ACTIVE STATUS
// =====================================

const updateCategoryStatus = async (
  req,
  res
) => {
  try {
    const { id } = req.params;
    const { is_active } = req.body;

    const result = await pool.query(
      `UPDATE categories
       SET
         is_active = $1,
         updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [
        is_active,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Category not found",
      });
    }

    res.status(200).json({
      message:
          "Category status updated successfully",
      category: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Update category status error:",
      error.message
    );

    res.status(500).json({
      message:
          "Unable to update category status",
    });
  }
};

module.exports = {
  getAllCategories,
  addCategory,
  updateCategory,
  deleteCategory,
  updateCategoryStatus,
};