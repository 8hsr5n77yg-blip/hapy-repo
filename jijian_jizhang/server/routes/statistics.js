const express = require('express');
const pool = require('../db');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// GET /api/statistics/summary?month=YYYY-MM
router.get('/summary', async (req, res) => {
  const { month } = req.query;
  if (!month) return res.status(400).json({ error: '请指定月份' });

  const [y, m] = month.split('-').map(Number);
  const startDate = `${month}-01`;
  const endDay = new Date(y, m, 0).getDate();
  const endDate = `${month}-${String(endDay).padStart(2, '0')}`;

  const [rows] = await pool.query(
    `SELECT type, SUM(amount) as total
     FROM transactions
     WHERE user_id = ? AND date BETWEEN ? AND ?
     GROUP BY type`,
    [req.userId, startDate, endDate]
  );

  let income = 0, expense = 0;
  for (const row of rows) {
    if (row.type === 'income') income = parseFloat(row.total) || 0;
    else expense = parseFloat(row.total) || 0;
  }
  res.json({ income, expense, balance: income - expense });
});

// GET /api/statistics/category?month=YYYY-MM&type=expense
router.get('/category', async (req, res) => {
  const { month, type } = req.query;
  if (!month || !type) return res.status(400).json({ error: '请指定月份和类型' });

  const [y, m] = month.split('-').map(Number);
  const startDate = `${month}-01`;
  const endDay = new Date(y, m, 0).getDate();
  const endDate = `${month}-${String(endDay).padStart(2, '0')}`;

  const [rows] = await pool.query(
    `SELECT c.id, c.name, c.icon, SUM(t.amount) as total
     FROM transactions t
     JOIN categories c ON t.category_id = c.id
     WHERE t.user_id = ? AND t.type = ? AND t.date BETWEEN ? AND ?
     GROUP BY t.category_id
     ORDER BY total DESC`,
    [req.userId, type, startDate, endDate]
  );
  res.json(rows);
});

// GET /api/statistics/trend
router.get('/trend', async (req, res) => {
  const now = new Date();
  const trend = [];

  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const yearMonth = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const startDate = `${yearMonth}-01`;
    const endDay = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
    const endDate = `${yearMonth}-${String(endDay).padStart(2, '0')}`;

    const [rows] = await pool.query(
      `SELECT type, SUM(amount) as total
       FROM transactions
       WHERE user_id = ? AND date BETWEEN ? AND ?
       GROUP BY type`,
      [req.userId, startDate, endDate]
    );

    let income = 0, expense = 0;
    for (const row of rows) {
      if (row.type === 'income') income = parseFloat(row.total) || 0;
      else expense = parseFloat(row.total) || 0;
    }
    trend.push({ month: `${d.getMonth() + 1}月`, yearMonth, income, expense });
  }
  res.json(trend);
});

module.exports = router;
