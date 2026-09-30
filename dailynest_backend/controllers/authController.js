const pool = require("../config/db");
const bcrypt = require("bcryptjs");

// =====================================================
// REGISTER USER
// =====================================================

const registerUser = async (req, res) => {
  try {
    const { name, email, mobile, password } = req.body;

    // Validate required fields
    if (!name || !email || !mobile || !password) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    // Check if email or mobile already exists
    const existingUser = await pool.query(
      "SELECT id FROM users WHERE email = $1 OR mobile = $2",
      [email, mobile]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        message: "Email or mobile already registered",
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Insert new user
    const result = await pool.query(
      `INSERT INTO users
       (name, email, mobile, password_hash)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, mobile, created_at`,
      [name, email, mobile, passwordHash]
    );

    const user = result.rows[0];

    // =================================================
    // GENERATE REGISTRATION OTP
    // =================================================

    const otp = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    // OTP expires after 5 minutes
    const expiresAt = new Date(
      Date.now() + 5 * 60 * 1000
    );

    // Save OTP in database
    await pool.query(
      `INSERT INTO otp_verifications
       (user_id, otp, expires_at, is_verified)
       VALUES ($1, $2, $3, false)`,
      [user.id, otp, expiresAt]
    );

    // Development/testing only
    console.log(
      `Registration OTP for ${user.mobile}: ${otp}`
    );

    // Send response
    res.status(201).json({
      message: "Registration successful. OTP generated.",
      expiresIn: "5 minutes",
      otp: otp,
      user: user,
    });

  } catch (error) {
    console.error(
      "Registration error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// LOGIN USER
// =====================================================

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate fields
    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    // Find user by email
    const result = await pool.query(
      `SELECT
        id,
        name,
        email,
        mobile,
        password_hash
       FROM users
       WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    const user = result.rows[0];

    // Compare password
    const isPasswordValid = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!isPasswordValid) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    // =================================================
    // GENERATE LOGIN OTP
    // =================================================

    const otp = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    // OTP expires after 5 minutes
    const expiresAt = new Date(
      Date.now() + 5 * 60 * 1000
    );

    // Save OTP
    await pool.query(
      `INSERT INTO otp_verifications
       (user_id, otp, expires_at, is_verified)
       VALUES ($1, $2, $3, false)`,
      [user.id, otp, expiresAt]
    );

    // Development/testing only
    console.log(
      `Login OTP for ${user.mobile}: ${otp}`
    );

    // Send response
    res.status(200).json({
      message: "Login successful. OTP generated.",
      expiresIn: "5 minutes",
      otp: otp,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
      },
    });

  } catch (error) {
    console.error(
      "Login error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// GENERATE / RESEND OTP
// =====================================================

const generateOtp = async (req, res) => {
  try {
    const { email, mobile } = req.body;

    // Validate fields
    if (!email || !mobile) {
      return res.status(400).json({
        message: "Email and mobile are required",
      });
    }

    // Find registered user
    const userResult = await pool.query(
      `SELECT
        id,
        name,
        email,
        mobile
       FROM users
       WHERE email = $1
       AND mobile = $2`,
      [email, mobile]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const user = userResult.rows[0];

    // Generate exactly 6-digit OTP
    const otp = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    // OTP expires after 5 minutes
    const expiresAt = new Date(
      Date.now() + 5 * 60 * 1000
    );

    // Save new OTP
    await pool.query(
      `INSERT INTO otp_verifications
       (user_id, otp, expires_at, is_verified)
       VALUES ($1, $2, $3, false)`,
      [user.id, otp, expiresAt]
    );

    // Development/testing only
    console.log(
      `Resend OTP for ${user.mobile}: ${otp}`
    );

    res.status(200).json({
      message: "OTP generated successfully",
      expiresIn: "5 minutes",
      otp: otp,
    });

  } catch (error) {
    console.error(
      "OTP generation error:",
      error.message
    );

    res.status(500).json({
      message: "Server error",
    });
  }
};


// =====================================================
// VERIFY OTP
// =====================================================

const verifyOtp = async (req, res) => {
  try {
    const { email, mobile, otp } = req.body;

    // Validate fields
    if (!email || !mobile || !otp) {
      return res.status(400).json({
        message: "Email, mobile and OTP are required",
      });
    }

    // Validate OTP format
    if (!/^[0-9]{6}$/.test(otp)) {
      return res.status(400).json({
        message: "OTP must be a 6-digit number",
      });
    }

    // =================================================
    // FIND USER
    // =================================================

    const userResult = await pool.query(
      `SELECT
        id,
        name,
        email,
        mobile
       FROM users
       WHERE email = $1
       AND mobile = $2`,
      [email, mobile]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const user = userResult.rows[0];

    // =================================================
    // FIND LATEST OTP
    // =================================================

    const otpResult = await pool.query(
      `SELECT
        id,
        otp,
        expires_at,
        is_verified
       FROM otp_verifications
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [user.id]
    );

    if (otpResult.rows.length === 0) {
      return res.status(400).json({
        message: "OTP not found",
      });
    }

    const otpRecord = otpResult.rows[0];

    // =================================================
    // CHECK IF OTP ALREADY USED
    // =================================================

    if (otpRecord.is_verified === true) {
      return res.status(400).json({
        message: "OTP has already been used",
      });
    }

    // =================================================
    // CHECK OTP
    // =================================================

    if (otpRecord.otp !== otp) {
      return res.status(400).json({
        message: "Invalid OTP",
      });
    }

    // =================================================
    // CHECK OTP EXPIRY
    // =================================================

    if (
      new Date() >
      new Date(otpRecord.expires_at)
    ) {
      return res.status(400).json({
        message: "OTP expired",
      });
    }

    // =================================================
    // MARK OTP AS VERIFIED
    // =================================================

    await pool.query(
      `UPDATE otp_verifications
       SET is_verified = TRUE
       WHERE id = $1`,
      [otpRecord.id]
    );

    // =================================================
    // SUCCESS RESPONSE
    // =================================================

    res.status(200).json({
      message: "OTP verified successfully",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
      },
    });

  } catch (error) {
    console.error(
      "OTP verification error:",
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
  registerUser,
  loginUser,
  generateOtp,
  verifyOtp,
};