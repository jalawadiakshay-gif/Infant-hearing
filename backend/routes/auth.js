const express = require("express");
const bcrypt  = require("bcryptjs");
const jwt     = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "baalshravya_dev_secret";

// ── In-memory stores (replace with DB in production) ─────────────────────────
// Keyed by phone number
const otpStore   = {}; // { phone -> { otp, expiresAt } }
const userStore  = {}; // { id -> { id, phone, fullName, email, passwordHash } }
const phoneIndex = {}; // { phone -> userId }
const emailIndex = {}; // { email -> userId }

// ── Helpers ───────────────────────────────────────────────────────────────────
function generateToken(user) {
  return jwt.sign(
    { id: user.id, phone: user.phone },
    JWT_SECRET,
    { expiresIn: "30d" }
  );
}

function generateOtp() {
  // Fixed demo OTP so the Flutter app always works during development
  return "123456";
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/auth/send-otp
// Body: { phone: "9876543210" }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/send-otp", (req, res) => {
  const { phone } = req.body;

  if (!phone) {
    return res.status(400).json({ success: false, message: "Phone number is required" });
  }

  const otp = generateOtp();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

  otpStore[phone] = { otp, expiresAt };

  console.log(`[OTP] Phone: ${phone}  OTP: ${otp}`); // In production send via SMS

  res.json({
    success: true,
    message: "OTP sent successfully",
    // Remove 'otp' field in production; kept here for development
    otp,
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/auth/verify-otp
// Body: { phone: "9876543210", otp: "123456" }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/verify-otp", (req, res) => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    return res.status(400).json({ success: false, message: "Phone and OTP are required" });
  }

  const record = otpStore[phone];

  if (!record) {
    return res.status(400).json({ success: false, message: "OTP not sent for this phone number" });
  }

  if (Date.now() > record.expiresAt) {
    delete otpStore[phone];
    return res.status(400).json({ success: false, message: "OTP has expired. Please request a new one." });
  }

  if (record.otp !== otp) {
    return res.status(400).json({ success: false, message: "Invalid OTP" });
  }

  // OTP is valid — clean up
  delete otpStore[phone];

  // Auto-create user account if one doesn't exist yet
  let userId = phoneIndex[phone];
  if (!userId) {
    userId = uuidv4();
    userStore[userId] = { id: userId, phone, fullName: "", email: null, passwordHash: null };
    phoneIndex[phone] = userId;
  }

  const user = userStore[userId];
  const token = generateToken(user);

  res.json({
    success: true,
    message: "OTP verified successfully",
    token,
    user: { id: user.id, phone: user.phone, fullName: user.fullName },
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/auth/register
// Body: { fullName, email, password, phone }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/register", async (req, res) => {
  const { fullName, email, password, phone } = req.body;

  if (!fullName || !email || !password || !phone) {
    return res.status(400).json({ success: false, message: "All fields are required" });
  }

  if (emailIndex[email]) {
    return res.status(409).json({ success: false, message: "Email already registered" });
  }

  if (phoneIndex[phone]) {
    return res.status(409).json({ success: false, message: "Phone already registered" });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const id = uuidv4();

  userStore[id] = { id, phone, fullName, email, passwordHash };
  phoneIndex[phone] = id;
  emailIndex[email] = id;

  const token = generateToken(userStore[id]);

  res.status(201).json({
    success: true,
    message: "Registration successful",
    token,
    user: { id, phone, fullName, email },
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/auth/login
// Body: { email, password }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "Email and password are required" });
  }

  const userId = emailIndex[email];
  if (!userId) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }

  const user = userStore[userId];
  if (!user.passwordHash) {
    return res.status(401).json({ success: false, message: "This account uses OTP login" });
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }

  const token = generateToken(user);

  res.json({
    success: true,
    message: "Login successful",
    token,
    user: { id: user.id, phone: user.phone, fullName: user.fullName, email: user.email },
  });
});

module.exports = router;