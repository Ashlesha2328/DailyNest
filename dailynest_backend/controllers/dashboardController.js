const pool = require("../config/db");

const getDashboardStats = async (req, res) => {
  try {
    const customersResult = await pool.query(
      "SELECT COUNT(*) FROM users"
    );

    const productsResult = await pool.query(
      "SELECT COUNT(*) FROM products"
    );

    const ordersResult = await pool.query(
      "SELECT COUNT(*) FROM orders"
    );

    const revenueResult = await pool.query(
      `SELECT COALESCE(SUM(total_amount), 0) AS total_revenue
       FROM orders
       WHERE order_status != 'Cancelled'`
    );

    res.status(200).json({
      message: "Dashboard stats fetched successfully",
      stats: {
        customers: parseInt(customersResult.rows[0].count),
        products: parseInt(productsResult.rows[0].count),
        orders: parseInt(ordersResult.rows[0].count),
        revenue: parseFloat(
          revenueResult.rows[0].total_revenue
        ),
      },
    });
  } catch (error) {
    console.error(
      "Dashboard stats error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch dashboard stats",
    });
  }
};

module.exports = {
  getDashboardStats,
};