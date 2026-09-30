const express = require("express");

const {
  getAllCustomers,
} = require("../controllers/userController");

const router = express.Router();

router.get("/customers", getAllCustomers);

module.exports = router;