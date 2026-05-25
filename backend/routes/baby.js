const express = require("express");
const { v4: uuidv4 } = require("uuid");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ── In-memory store ────────────────────────────────────────────────────────
// Keyed by userId → array of babies
const babyStore = {}; // { userId -> [babyObject, ...] }

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/baby/create
// Headers: Authorization: Bearer <token>
// Body: { name, gender, birthWeight, gestationalAge, nicuAdmission,
//         deliveryMode, medicalNotes, dob }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/create", authMiddleware, (req, res) => {
  const userId = req.user.id;

  const {
    name,
    gender,
    birthWeight,
    gestationalAge,
    nicuAdmission,
    deliveryMode,
    medicalNotes,
    dob,
  } = req.body;

  if (!name || !gender || birthWeight == null || gestationalAge == null || !deliveryMode || !dob) {
    return res.status(400).json({ success: false, message: "Required fields missing" });
  }

  const baby = {
    id:             uuidv4(),
    parentId:       userId,
    name,
    gender,
    birthWeight:    parseFloat(birthWeight),
    gestationalAge: parseInt(gestationalAge, 10),
    nicuAdmission:  Boolean(nicuAdmission),
    deliveryMode,
    medicalNotes:   medicalNotes || null,
    dob,
    createdAt:      new Date().toISOString(),
  };

  if (!babyStore[userId]) {
    babyStore[userId] = [];
  }
  babyStore[userId].push(baby);

  res.status(201).json({
    success: true,
    message: "Baby profile created",
    data: baby,
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/baby/list
// Headers: Authorization: Bearer <token>
// ─────────────────────────────────────────────────────────────────────────────
router.get("/list", authMiddleware, (req, res) => {
  const userId = req.user.id;
  const babies = babyStore[userId] || [];

  // Flutter expects a plain array (not wrapped in data) — see baby_api_service.dart
  res.json(babies);
});

module.exports = router;