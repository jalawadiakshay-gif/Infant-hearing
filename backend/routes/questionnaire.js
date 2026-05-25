const express = require("express");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ── In-memory store ────────────────────────────────────────────────────────
// Keyed by userId → latest questionnaire result
const resultStore = {}; // { userId -> resultObject }

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/questionnaire/submit
// Headers: Authorization: Bearer <token>
// Body: { babyAgeMonths, answers, totalScore, riskPercentage, result }
// ─────────────────────────────────────────────────────────────────────────────
router.post("/submit", authMiddleware, (req, res) => {
  const userId = req.user.id;

  const { babyAgeMonths, answers, totalScore, riskPercentage, result } = req.body;

  if (!answers || result == null) {
    return res.status(400).json({ success: false, message: "answers and result are required" });
  }

  const record = {
    userId,
    babyAgeMonths: babyAgeMonths ?? 0,
    answers,
    totalScore:    totalScore    ?? 0,
    riskPercentage: riskPercentage ?? 0,
    result,
    submittedAt:   new Date().toISOString(),
  };

  resultStore[userId] = record;

  res.json({
    success: true,
    message: "Questionnaire submitted successfully",
    data: record,
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/questionnaire/result
// Headers: Authorization: Bearer <token>
// ─────────────────────────────────────────────────────────────────────────────
router.get("/result", authMiddleware, (req, res) => {
  const userId = req.user.id;
  const record = resultStore[userId];

  if (!record) {
    return res.status(404).json({ success: false, message: "No questionnaire result found", data: null });
  }

  res.json({ success: true, message: "Result fetched", data: record });
});

module.exports = router;