const express = require('express');
const { v4: uuidv4 } = require('uuid');
const pool = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/send-code
router.post('/send-code', async (req, res) => {
  const { phone } = req.body;
  if (!phone || !/^1[3-9]\d{9}$/.test(phone)) {
    return res.status(400).json({ error: '请输入正确的手机号' });
  }

  // 固定验证码 123456
  console.log(`[SMS] 验证码发送到 ${phone}: 123456`);
  res.json({ success: true, message: '验证码已发送' });
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { phone, code } = req.body;
  if (!phone || !code) {
    return res.status(400).json({ error: '请输入手机号和验证码' });
  }

  // 固定验证码校验
  if (code !== '123456') {
    return res.status(400).json({ error: '验证码错误' });
  }

  const token = uuidv4();

  // 用户不存在则创建，存在则更新 token
  await pool.query(
    `INSERT INTO users (phone, token, last_login_at)
     VALUES (?, ?, NOW())
     ON DUPLICATE KEY UPDATE token = VALUES(token), last_login_at = NOW()`,
    [phone, token]
  );

  const [rows] = await pool.query('SELECT id, phone FROM users WHERE phone = ?', [phone]);
  const user = rows[0];

  res.json({
    success: true,
    token,
    user: { id: user.id, phone: user.phone },
  });
});

// GET /api/auth/me — 验证 token 并返回用户信息（用于自动登录）
router.get('/me', authMiddleware, async (req, res) => {
  res.json({ id: req.userId, phone: req.userPhone });
});

module.exports = router;
