const pool = require("../config/db");

// =====================================================
// ADD DELIVERY ADDRESS
// =====================================================

const addAddress = async (req, res) => {
  try {
    const {
      user_id,
      full_name,
      mobile,
      house_flat_building,
      area_locality,
      city,
      pincode,
      address_type,
      is_default,
    } = req.body;

    // =================================================
    // VALIDATE REQUIRED FIELDS
    // =================================================

    if (
      !user_id ||
      !full_name ||
      !mobile ||
      !house_flat_building ||
      !area_locality ||
      !city ||
      !pincode
    ) {
      return res.status(400).json({
        message: "All address fields are required",
      });
    }

    // =================================================
    // VALIDATE MOBILE
    // =================================================

    if (!/^[6-9][0-9]{9}$/.test(mobile)) {
      return res.status(400).json({
        message: "Please enter a valid 10-digit mobile number",
      });
    }

    // =================================================
    // VALIDATE PINCODE
    // =================================================

    if (!/^[0-9]{6}$/.test(pincode)) {
      return res.status(400).json({
        message: "Please enter a valid 6-digit pincode",
      });
    }

    // =================================================
    // CHECK USER EXISTS
    // =================================================

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

    // =================================================
    // ADDRESS TYPE
    // =================================================

    const finalAddressType =
      address_type || "Home";

    // =================================================
    // DEFAULT ADDRESS
    // =================================================

    const makeDefault =
      is_default === true ||
      is_default === "true";

    // If this address is default,
    // remove default from previous addresses
    if (makeDefault) {
      await pool.query(
        `UPDATE addresses
         SET is_default = FALSE,
             updated_at = CURRENT_TIMESTAMP
         WHERE user_id = $1`,
        [user_id]
      );
    }

    // =================================================
    // INSERT ADDRESS
    // =================================================

    const result = await pool.query(
      `INSERT INTO addresses
       (
         user_id,
         full_name,
         mobile,
         house_flat_building,
         area_locality,
         city,
         pincode,
         address_type,
         is_default
       )
       VALUES
       (
         $1, $2, $3, $4, $5,
         $6, $7, $8, $9
       )
       RETURNING *`,
      [
        user_id,
        full_name,
        mobile,
        house_flat_building,
        area_locality,
        city,
        pincode,
        finalAddressType,
        makeDefault,
      ]
    );

    res.status(201).json({
      message: "Address saved successfully",
      address: result.rows[0],
    });

  } catch (error) {
    console.error(
      "Add address error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// GET USER ADDRESSES
// =====================================================

const getAddresses = async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!user_id) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    // Check user exists
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

    // Get addresses
    const result = await pool.query(
      `SELECT *
       FROM addresses
       WHERE user_id = $1
       ORDER BY is_default DESC, created_at DESC`,
      [user_id]
    );

    res.status(200).json({
      message: "Addresses fetched successfully",
      addresses: result.rows,
    });

  } catch (error) {
    console.error(
      "Get addresses error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// DELETE ADDRESS
// =====================================================

const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        message: "Address ID is required",
      });
    }

    // Check address exists
    const addressResult = await pool.query(
      `SELECT *
       FROM addresses
       WHERE id = $1`,
      [id]
    );

    if (addressResult.rows.length === 0) {
      return res.status(404).json({
        message: "Address not found",
      });
    }

    // Delete address
    await pool.query(
      `DELETE FROM addresses
       WHERE id = $1`,
      [id]
    );

    res.status(200).json({
      message: "Address deleted successfully",
    });

  } catch (error) {
    console.error(
      "Delete address error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// SET DEFAULT ADDRESS
// =====================================================

const setDefaultAddress = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        message: "Address ID is required",
      });
    }

    // Get address
    const addressResult = await pool.query(
      `SELECT id, user_id
       FROM addresses
       WHERE id = $1`,
      [id]
    );

    if (addressResult.rows.length === 0) {
      return res.status(404).json({
        message: "Address not found",
      });
    }

    const address = addressResult.rows[0];

    // Remove default from user's other addresses
    await pool.query(
      `UPDATE addresses
       SET is_default = FALSE,
           updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $1`,
      [address.user_id]
    );

    // Make selected address default
    const result = await pool.query(
      `UPDATE addresses
       SET is_default = TRUE,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    res.status(200).json({
      message: "Default address updated successfully",
      address: result.rows[0],
    });

  } catch (error) {
    console.error(
      "Set default address error:",
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
  addAddress,
  getAddresses,
  deleteAddress,
  setDefaultAddress,
};