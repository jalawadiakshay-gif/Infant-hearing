const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "baalshravya_dev_secret";

/**
 * Middleware that verifies the Bearer token on protected routes.
 * Attaches decoded payload to req.user on success.
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ success: false, message: "Unauthorized: No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, phone, iat, exp }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: "Unauthorized: Invalid or expired token" });
  }
}

module.exports = authMiddleware;