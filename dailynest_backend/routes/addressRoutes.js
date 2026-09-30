const express = require("express");

const {
  addAddress,
  getAddresses,
  deleteAddress,
  setDefaultAddress,
} = require("../controllers/addressController");

const router = express.Router();

// =====================================================
// ADD DELIVERY ADDRESS
// POST /api/addresses
// =====================================================

router.post("/", addAddress);


// =====================================================
// GET USER ADDRESSES
// GET /api/addresses/:user_id
// =====================================================

router.get("/:user_id", getAddresses);


// =====================================================
// DELETE ADDRESS
// DELETE /api/addresses/:id
// =====================================================

router.delete("/:id", deleteAddress);


// =====================================================
// SET DEFAULT ADDRESS
// PUT /api/addresses/:id/default
// =====================================================

router.put("/:id/default", setDefaultAddress);


module.exports = router;