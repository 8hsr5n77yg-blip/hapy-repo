const express = require('express');
const pool = require('../db');
const authMiddleware = require('../middleware/auth');
const { mysqlNow } = require('../utils');

const router = express.Router();
router.use(authMiddleware);

// GET /api/accounts
router.get('/', async (req, res) => {
  const [rows] = await pool.query(
    'SELECT * FROM accounts WHERE user_id = ? ORDER BY created_at ASC',
    [req.userId]
  );
  res.json(rows);
});

// POST /api/accounts
router.post('/', async (req, res) => {
  const { name, type, initialBalance, icon } = req.body;
  if (!name || !type) {
    return res.status(400).json({ error: '请填写账户名称和类型' });
  }

  const balance = parseFloat(initialBalance) || 0;
  const now = mysqlNow();

  const [result] = await pool.query(
    `INSERT INTO accounts (user_id, name, type, balance, initial_balance, icon, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [req.userId, name, type, balance, balance, icon || 'wallet', now, now]
  );

  const [rows] = await pool.query('SELECT * FROM accounts WHERE id = ?', [result.insertId]);
  res.status(201).json(rows[0]);
});

// PUT /api/accounts/:id
router.put('/:id', async (req, res) => {
  const { name, type, initialBalance, icon } = req.body;
  const accountId = parseInt(req.params.id);

  const [existing] = await pool.query(
    'SELECT * FROM accounts WHERE id = ? AND user_id = ?',
    [accountId, req.userId]
  );
  if (existing.length === 0) {
    return res.status(404).json({ error: '账户不存在' });
  }

  const now = mysqlNow();
  await pool.query(
    `UPDATE accounts SET name = ?, type = ?, initial_balance = ?, icon = ?, updated_at = ? WHERE id = ?`,
    [name, type, parseFloat(initialBalance) || 0, icon || 'wallet', now, accountId]
  );

  const [rows] = await pool.query('SELECT * FROM accounts WHERE id = ?', [accountId]);
  res.json(rows[0]);
});

// DELETE /api/accounts/:id
router.delete('/:id', async (req, res) => {
  const accountId = parseInt(req.params.id);

  // 检查是否有关联交易
  const [txCount] = await pool.query(
    'SELECT COUNT(*) as cnt FROM transactions WHERE account_id = ? AND user_id = ?',
    [accountId, req.userId]
  );

  await pool.query('DELETE FROM accounts WHERE id = ? AND user_id = ?', [accountId, req.userId]);
  res.json({ success: true, deletedTransactions: txCount[0].cnt });
});

module.exports = router;
