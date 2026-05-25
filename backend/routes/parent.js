const express = require("express");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ── In-memory store ────────────────────────────────────────────────────────
// Keyed by userId (from JWT)
const parentStore = {}; // { userId -> parentObject }

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/parent/create
// Headers: Authorization: Bearer <token>
// Body: { name, phone, email, address, city, state, emergencyContact,
//         relationship, bloodGroup, preferredHospital }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/create", authMiddleware, (req, res) => {
  const userId = req.user.id;

  const {
    name,
    phone,
    email,
    address,
    city,
    state,
    emergencyContact,
    relationship,
    bloodGroup,
    preferredHospital,
  } = req.body;

  if (!name || !phone || !address || !city || !state || !emergencyContact || !relationship) {
    return res.status(400).json({ success: false, message: "Required fields missing" });
  }

  const parent = {
    id: userId,
    name,
    phone,
    email:             email || null,
    address,
    city,
    state,
    emergencyContact,
    relationship,
    bloodGroup:        bloodGroup || null,
    preferredHospital: preferredHospital || null,
    isVerified:        false,
    createdAt:         new Date().toISOString(),
  };

  parentStore[userId] = parent;

  res.status(201).json({
    success: true,
    message: "Parent profile created",
    data: parent,
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/parent/profile
// Headers: Authorization: Bearer <token>
// ─────────────────────────────────────────────────────────────────────────────
router.get("/profile", authMiddleware, (req, res) => {
  const userId = req.user.id;
  const parent = parentStore[userId];

  if (!parent) {
    return res.status(404).json({ success: false, message: "Parent profile not found", data: null });
  }

  res.json({ success: true, message: "Profile fetched", data: parent });
});

module.exports = router;