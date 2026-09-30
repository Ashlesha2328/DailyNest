const express = require("express");

const {
  registerUser,
  loginUser,
  generateOtp,
  verifyOtp,
} = require("../controllers/authController");

const router = express.Router();

// Register
router.post("/register", registerUser);

// Login
router.post("/login", loginUser);

// Generate OTP
router.post("/generate-otp", generateOtp);

// Verify OTP
router.post("/verify-otp", verifyOtp);

module.exports = router;