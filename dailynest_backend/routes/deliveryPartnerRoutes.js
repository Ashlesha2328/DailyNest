const express = require("express");

const {
  getAllDeliveryPartners,
  addDeliveryPartner,
  updateDeliveryPartner,
  deleteDeliveryPartner,
} = require("../controllers/deliveryPartnerController");

const router = express.Router();

// Get all delivery partners
router.get("/", getAllDeliveryPartners);

// Add delivery partner
router.post("/", addDeliveryPartner);

// Update delivery partner
router.put("/:id", updateDeliveryPartner);

// Delete delivery partner
router.delete("/:id", deleteDeliveryPartner);

module.exports = router;