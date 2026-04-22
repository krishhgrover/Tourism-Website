const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db       = require('../db');
const auth     = require('../middleware/auth');

const router = express.Router();

// ── REGISTER ──────────────────────────────────────────────
router.post('/register', [
  body('full_name').trim().notEmpty().withMessage('Full name is required'),
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
], async (req, res) => {

  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }

  const { full_name, email, password, phone } = req.body;

  try {
    // Check existing user
    const [existing] = await db.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existing.length) {
      return res.status(409).json({
        success: false,
        message: 'Email already registered.'
      });
    }

    // Hash password
    const hash = await bcrypt.hash(password, 12);

    // Insert user into DB (:contentReference[oaicite:0]{index=0})
    const [result] = await db.query(
      'INSERT INTO users (full_name, email, password_hash, phone) VALUES (?, ?, ?, ?)',
      [full_name, email, hash, phone || null]
    );

    // Create user object
    const user = {
      id: result.insertId,
      full_name,
      email
    };

    // Generate token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
    );

    res.status(201).json({
      success: true,
      message: 'Account created!',
      token,
      user
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
  console.log("JWT_SECRET:", process.env.JWT_SECRET);
});


// ── LOGIN ─────────────────────────────────────────────────
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
], async (req, res) => {

  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (!rows.length) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials.'
      });
    }

    const user = rows[0];

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials.'
      });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
    );

    const { password_hash, ...safeUser } = user;

    res.json({
      success: true,
      token,
      user: safeUser
    });

  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
});


// ── GET PROFILE ───────────────────────────────────────────
router.get('/profile', auth, async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT id, full_name, email, phone, avatar_url, passport_number, nationality, date_of_birth, created_at FROM users WHERE id = ?',
      [req.user.id]
    );

    if (!rows.length) {
      return res.status(404).json({
        success: false,
        message: 'User not found.'
      });
    }

    res.json({ success: true, user: rows[0] });

  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
});


// ── UPDATE PROFILE ────────────────────────────────────────
router.put('/profile', auth, async (req, res) => {
  const { full_name, phone, passport_number, nationality, date_of_birth } = req.body;

  try {
    await db.query(
      'UPDATE users SET full_name=?, phone=?, passport_number=?, nationality=?, date_of_birth=? WHERE id=?',
      [full_name, phone, passport_number, nationality, date_of_birth || null, req.user.id]
    );

    res.json({ success: true, message: 'Profile updated.' });

  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
});


// ── CHANGE PASSWORD ───────────────────────────────────────
router.put('/change-password', auth, [
  body('current_password').notEmpty(),
  body('new_password').isLength({ min: 6 }),
], async (req, res) => {

  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }

  const { current_password, new_password } = req.body;

  try {
    const [rows] = await db.query(
      'SELECT password_hash FROM users WHERE id = ?',
      [req.user.id]
    );

    const match = await bcrypt.compare(current_password, rows[0].password_hash);

    if (!match) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect.'
      });
    }

    const hash = await bcrypt.hash(new_password, 12);

    await db.query(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [hash, req.user.id]
    );

    res.json({
      success: true,
      message: 'Password changed successfully.'
    });

  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
});

module.exports = router;