const pool = require("../config/db");

// =====================================================
// GET ALL CUSTOMERS
// =====================================================

const getAllCustomers = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        id,
        name,
        email,
        mobile,
        created_at
       FROM users
       ORDER BY created_at DESC`
    );

    res.status(200).json({
      message: "Customers fetched successfully",
      customers: result.rows,
    });
  } catch (error) {
    console.error(
      "Get all customers error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch customers",
    });
  }
};

module.exports = {
  getAllCustomers,
};