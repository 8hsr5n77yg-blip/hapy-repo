const express = require('express');
const pool = require('../db');
const authMiddleware = require('../middleware/auth');
const { mysqlNow } = require('../utils');

const router = express.Router();
router.use(authMiddleware);

// GET /api/transactions?month=YYYY-MM
router.get('/', async (req, res) => {
  const { month } = req.query;
  if (!month) {
    return res.status(400).json({ error: '请指定月份' });
  }

  const [y, m] = month.split('-').map(Number);
  const startDate = `${month}-01`;
  const endDay = new Date(y, m, 0).getDate();
  const endDate = `${month}-${String(endDay).padStart(2, '0')}`;

  const [rows] = await pool.query(
    `SELECT t.*, c.name as category_name, c.icon as category_icon, a.name as account_name
     FROM transactions t
     JOIN categories c ON t.category_id = c.id
     JOIN accounts a ON t.account_id = a.id
     WHERE t.user_id = ? AND t.date BETWEEN ? AND ?
     ORDER BY t.date DESC, t.time DESC`,
    [req.userId, startDate, endDate]
  );
  res.json(rows);
});

// GET /api/transactions/export
router.get('/export', async (req, res) => {
  const [rows] = await pool.query(
    `SELECT t.type, t.amount, c.name as category_name, t.date, t.time,
            a.name as account_name, t.note
     FROM transactions t
     JOIN categories c ON t.category_id = c.id
     JOIN accounts a ON t.account_id = a.id
     WHERE t.user_id = ?
     ORDER BY t.date DESC, t.time DESC`,
    [req.userId]
  );
  res.json(rows);
});

// DELETE /api/transactions/clear
router.delete('/clear', async (req, res) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    await conn.query('DELETE FROM transactions WHERE user_id = ?', [req.userId]);
    const now = mysqlNow();
    await conn.query(
      'UPDATE accounts SET balance = initial_balance, updated_at = ? WHERE user_id = ?',
      [now, req.userId]
    );

    await conn.commit();
    res.json({ success: true });
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
});

// GET /api/transactions/:id
router.get('/:id', async (req, res) => {
  const [rows] = await pool.query(
    `SELECT t.*, c.name as category_name, c.icon as category_icon, a.name as account_name
     FROM transactions t
     JOIN categories c ON t.category_id = c.id
     JOIN accounts a ON t.account_id = a.id
     WHERE t.id = ? AND t.user_id = ?`,
    [req.params.id, req.userId]
  );
  if (rows.length === 0) return res.status(404).json({ error: '记录不存在' });
  res.json(rows[0]);
});

// POST /api/transactions
router.post('/', async (req, res) => {
  const { type, amount, categoryId, accountId, date, time, note } = req.body;
  if (!type || !amount || !categoryId || !accountId || !date || !time) {
    return res.status(400).json({ error: '请填写完整信息' });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const now = mysqlNow();
    const [result] = await conn.query(
      `INSERT INTO transactions (user_id, type, amount, category_id, account_id, date, time, note, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.userId, type, amount, categoryId, accountId, date, time, note || '', now, now]
    );

    const delta = type === 'expense' ? -amount : amount;
    await conn.query(
      'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ? AND user_id = ?',
      [delta, now, accountId, req.userId]
    );

    await conn.commit();

    const [rows] = await pool.query(
      `SELECT t.*, c.name as category_name, c.icon as category_icon, a.name as account_name
       FROM transactions t
       JOIN categories c ON t.category_id = c.id
       JOIN accounts a ON t.account_id = a.id
       WHERE t.id = ?`,
      [result.insertId]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
});

// PUT /api/transactions/:id
router.put('/:id', async (req, res) => {
  const txId = parseInt(req.params.id);
  const { type, amount, categoryId, accountId, date, time, note } = req.body;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [oldRows] = await conn.query(
      'SELECT * FROM transactions WHERE id = ? AND user_id = ?',
      [txId, req.userId]
    );
    if (oldRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: '记录不存在' });
    }
    const oldTx = oldRows[0];

    const now = mysqlNow();
    await conn.query(
      `UPDATE transactions SET type = ?, amount = ?, category_id = ?, account_id = ?, date = ?, time = ?, note = ?, updated_at = ?
       WHERE id = ?`,
      [type, amount, categoryId, accountId, date, time, note || '', now, txId]
    );

    const oldDelta = oldTx.type === 'expense' ? parseFloat(oldTx.amount) : -parseFloat(oldTx.amount);
    const newDelta = type === 'expense' ? -parseFloat(amount) : parseFloat(amount);

    if (oldTx.account_id === accountId) {
      const netDelta = newDelta - oldDelta;
      await conn.query(
        'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ? AND user_id = ?',
        [netDelta, now, accountId, req.userId]
      );
    } else {
      await conn.query(
        'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ? AND user_id = ?',
        [-oldDelta, now, oldTx.account_id, req.userId]
      );
      await conn.query(
        'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ? AND user_id = ?',
        [newDelta, now, accountId, req.userId]
      );
    }

    await conn.commit();

    const [rows] = await pool.query(
      `SELECT t.*, c.name as category_name, c.icon as category_icon, a.name as account_name
       FROM transactions t
       JOIN categories c ON t.category_id = c.id
       JOIN accounts a ON t.account_id = a.id
       WHERE t.id = ?`,
      [txId]
    );
    res.json(rows[0]);
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
});

// DELETE /api/transactions/:id
router.delete('/:id', async (req, res) => {
  const txId = parseInt(req.params.id);

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [oldRows] = await conn.query(
      'SELECT * FROM transactions WHERE id = ? AND user_id = ?',
      [txId, req.userId]
    );
    if (oldRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: '记录不存在' });
    }
    const oldTx = oldRows[0];

    await conn.query('DELETE FROM transactions WHERE id = ?', [txId]);

    const delta = oldTx.type === 'expense' ? parseFloat(oldTx.amount) : -parseFloat(oldTx.amount);
    const now = mysqlNow();
    await conn.query(
      'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ? AND user_id = ?',
      [delta, now, oldTx.account_id, req.userId]
    );

    await conn.commit();
    res.json({ success: true });
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
});

module.exports = router;
