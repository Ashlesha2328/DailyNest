const pool = require("../config/db");

// Get all delivery partners
const getAllDeliveryPartners = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT
        id,
        name,
        mobile,
        status,
        assigned_orders,
        is_active,
        created_at,
        updated_at
       FROM delivery_partners
       ORDER BY created_at DESC`
    );

    res.status(200).json({
      message: "Delivery partners fetched successfully",
      partners: result.rows,
    });
  } catch (error) {
    console.error(
      "Get delivery partners error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to fetch delivery partners",
    });
  }
};


// Add delivery partner
const addDeliveryPartner = async (req, res) => {
  try {
    const {
      name,
      mobile,
      status = "Available",
    } = req.body;

    if (!name || !mobile) {
      return res.status(400).json({
        message: "Name and mobile are required",
      });
    }

    const result = await pool.query(
      `INSERT INTO delivery_partners
       (name, mobile, status)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [name, mobile, status]
    );

    res.status(201).json({
      message: "Delivery partner added successfully",
      partner: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Add delivery partner error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to add delivery partner",
    });
  }
};


// Update delivery partner
const updateDeliveryPartner = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      mobile,
      status,
      is_active,
    } = req.body;

    const result = await pool.query(
      `UPDATE delivery_partners
       SET
         name = COALESCE($1, name),
         mobile = COALESCE($2, mobile),
         status = COALESCE($3, status),
         is_active = COALESCE($4, is_active),
         updated_at = CURRENT_TIMESTAMP
       WHERE id = $5
       RETURNING *`,
      [
        name,
        mobile,
        status,
        is_active,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Delivery partner not found",
      });
    }

    res.status(200).json({
      message: "Delivery partner updated successfully",
      partner: result.rows[0],
    });
  } catch (error) {
    console.error(
      "Update delivery partner error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to update delivery partner",
    });
  }
};


// Delete delivery partner
const deleteDeliveryPartner = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `DELETE FROM delivery_partners
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Delivery partner not found",
      });
    }

    res.status(200).json({
      message: "Delivery partner deleted successfully",
    });
  } catch (error) {
    console.error(
      "Delete delivery partner error:",
      error.message
    );

    res.status(500).json({
      message: "Unable to delete delivery partner",
    });
  }
};


module.exports = {
  getAllDeliveryPartners,
  addDeliveryPartner,
  updateDeliveryPartner,
  deleteDeliveryPartner,
};