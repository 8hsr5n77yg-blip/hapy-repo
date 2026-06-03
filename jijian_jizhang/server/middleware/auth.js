const pool = require('../db');

async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: '未登录，请先登录' });
  }

  const [rows] = await pool.query('SELECT id, phone FROM users WHERE token = ?', [token]);
  if (rows.length === 0) {
    return res.status(401).json({ error: '登录已过期，请重新登录' });
  }

  req.userId = rows[0].id;
  req.userPhone = rows[0].phone;
  next();
}

module.exports = authMiddleware;
