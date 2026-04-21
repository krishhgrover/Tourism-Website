# 🌍 Wanderlust Tours — Full Stack Travel Website

A professional, aesthetically refined full-stack tourist website built with **React.js**, **Node.js/Express**, and **MySQL**.

---

Project Structure

```
wanderlust/
├── backend/                  # Node.js + Express API
│   ├── middleware/
│   │   └── auth.js           # JWT authentication middleware
│   ├── routes/
│   │   ├── auth.js           # Register, login, profile
│   │   ├── packages.js       # Tour packages + destinations
│   │   ├── transport.js      # Transport search
│   │   ├── booking.js        # Booking management
│   │   ├── payment.js        # Payment processing
│   │   ├── visa.js           # Visa requirements + applications
│   │   └── ai.js             # AI recommender (Anthropic Claude)
│   ├── db.js                 # MySQL connection pool
│   ├── server.js             # Express app entry point
│   ├── package.json
│   └── .env.example          # Environment variable template
│
├── frontend/                 # React.js SPA
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── context/
│   │   │   └── AuthContext.js
│   │   ├── components/
│   │   │   ├── Navbar.js
│   │   │   └── Footer.js
│   │   ├── pages/
│   │   │   ├── Home.js
│   │   │   ├── TourPackages.js
│   │   │   ├── Transport.js
│   │   │   ├── AIRecommender.js
│   │   │   ├── Booking.js
│   │   │   ├── Payment.js
│   │   │   ├── Visa.js
│   │   │   └── AccountDetails.js
│   │   ├── styles/
│   │   │   └── global.css
│   │   ├── App.js
│   │   └── index.js
│   └── package.json
│
└── database/
    └── schema.sql            # MySQL schema + seed data
```

---

✅ Prerequisites

Before you start, ensure you have installed:

| Tool | Version | Download |
|------|---------|----------|
| Node.js | v18+ | https://nodejs.org |
| npm | v9+ | (bundled with Node.js) |
| MySQL | v8.0+ | https://dev.mysql.com/downloads |
| Git | any | https://git-scm.com |

---
🚀 Step-by-Step Setup Guide

STEP 1 — Clone / Copy the Project

```bash
# If using Git:
git clone https://github.com/your-repo/wanderlust.git
cd wanderlust

# Or if you downloaded the zip, extract it and cd into the folder:
cd wanderlust
```
---

STEP 2 — Set Up MySQL Database

2a. Start MySQL and login
```bash
# On macOS (Homebrew):
brew services start mysql
mysql -u root -p

# On Windows:
# Open MySQL Workbench or run:
mysql -u root -p

# On Linux:
sudo systemctl start mysql
mysql -u root -p
```

2b. Run the database schema
```bash
# From terminal (recommended):
mysql -u root -p < database/schema.sql

# OR inside MySQL shell:
source /path/to/wanderlust/database/schema.sql;
```

This creates the `wanderlust_db` database with all 8 tables and sample data including:
- 8 destinations (Bali, Santorini, Kyoto, etc.)
- 8 tour packages (with pricing, ratings, inclusions)
- Visa requirements for 8 popular destination-nationality combos

2c. Verify the setup
```sql
USE wanderlust_db;
SHOW TABLES;
SELECT title, price_per_person FROM tour_packages;
```

---

STEP 3 — Configure Backend Environment

```bash
cd backend
cp .env.example .env
```

Now open `.env` in your editor and fill in your values:

```env
# Server
PORT=5000
NODE_ENV=development

# Database — change these to match your MySQL setup
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_actual_mysql_password_here
DB_NAME=wanderlust_db

# JWT Secret — change this to a long random string
JWT_SECRET=change_this_to_a_very_long_random_secret_string_123

# Anthropic AI Key (for AI Recommender feature)
# Get your key from: https://console.anthropic.com
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Frontend origin (for CORS)
CLIENT_URL=http://localhost:3000
```

> **💡 Note:** The AI Recommender works without an Anthropic API key — it falls back to curated example recommendations automatically.

---

STEP 4 — Install Backend Dependencies

```bash
# Make sure you're in the backend/ folder
cd backend

npm install
```

This installs: express, mysql2, bcryptjs, jsonwebtoken, cors, helmet, dotenv, morgan, express-validator, express-rate-limit, uuid

---

STEP 5 — Start the Backend Server

```bash
# Development mode (auto-restarts on changes):
npm run dev

# Production mode:
npm start
```

You should see:
```
✅  MySQL connected successfully
🚀  Wanderlust API running on http://localhost:5000
📖  Health: http://localhost:5000/api/health
```

Test the API is working:
```bash
curl http://localhost:5000/api/health
# Expected: {"success":true,"message":"Wanderlust API is running 🌍","version":"1.0.0"}

curl http://localhost:5000/api/packages
# Expected: JSON with 8 tour packages
```

---

STEP 6 — Install Frontend Dependencies

```bash
# Open a NEW terminal window
cd wanderlust/frontend

npm install
```

This installs: react, react-dom, react-router-dom, axios, and all Create React App dependencies.

---
STEP 7 — Start the Frontend

```bash
npm start
```

The browser will automatically open at **http://localhost:3000**

> The `"proxy": "http://localhost:5000"` in `frontend/package.json` automatically proxies all `/api/*` requests to the backend. No extra configuration needed.

---

STEP 8 — Verify Everything Works

Open your browser and check each page:

| Page | URL | What to verify |
|------|-----|----------------|
| Home | http://localhost:3000/ | Hero image loads, featured packages appear |
| Packages | http://localhost:3000/packages | Package cards load with images and pricing |
| Transport | http://localhost:3000/transport | Transport type tabs and search form work |
| AI Guide | http://localhost:3000/ai-recommender | Multi-step form progresses correctly |
| Booking | http://localhost:3000/booking | Form appears, redirects to login if not signed in |
| Payment | http://localhost:3000/payment | Payment method tabs switch correctly |
| Visa | http://localhost:3000/visa | Click a popular destination to see requirements |
| Account | http://localhost:3000/account | Login/Register form appears |

---
 🧪 Testing the Full Flow

Test User Registration & Login
1. Go to **http://localhost:3000/account**
2. Click **Create Account** tab
3. Fill in name, email (e.g. `test@example.com`), phone, password
4. Click **Create Account** — you'll be logged in automatically

Test Booking Flow
1. Go to **Packages** → Click **Book This Package**
2. Fill in travel dates and traveler details
3. Click **Confirm Booking**
4. You'll receive a booking reference — click **Proceed to Payment**
5. Select a payment method and click **Pay**

Test AI Recommender
1. Go to **AI Guide**
2. Enter budget (e.g. `2000`), duration (e.g. `7`), select interests
3. Click **Get My Recommendations**
4. If Anthropic API key is set, Claude generates real recommendations; otherwise the fallback is used

Test Visa Search
1. Go to **Visa**
2. Click any popular destination (e.g. **Japan**)
3. See requirements, then click **Apply for Visa**

---

📡 API Reference

Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Create new account |
| POST | `/api/auth/login` | Login, returns JWT token |
| GET | `/api/auth/profile` | Get user profile (🔒 auth required) |
| PUT | `/api/auth/profile` | Update profile (🔒 auth required) |
| PUT | `/api/auth/change-password` | Change password (🔒 auth required) |

Packages
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/packages` | List all packages (supports filters) |
| GET | `/api/packages/:id` | Single package with reviews |
| GET | `/api/packages/meta/destinations` | All destinations |
| POST | `/api/packages/:id/reviews` | Submit review (🔒 auth required) |

**Query params:** `category`, `min_price`, `max_price`, `duration`, `featured`, `search`, `sort`, `order`

Bookings
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/bookings` | Create booking (🔒) |
| GET | `/api/bookings/my` | User's bookings (🔒) |
| GET | `/api/bookings/:ref` | Single booking by reference (🔒) |
| PUT | `/api/bookings/:id/cancel` | Cancel booking (🔒) |

Payments
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/payments` | Process payment (🔒) |
| GET | `/api/payments/history` | Payment history (🔒) |

Visa
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/visa/requirements` | Visa requirements (filter by country + nationality) |
| GET | `/api/visa/countries` | All available countries |
| GET | `/api/visa/my-applications` | User's applications (🔒) |
| POST | `/api/visa/apply` | Submit application (🔒) |

AI
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/ai/recommend` | Get AI travel recommendations |

**Body:** `{ budget, duration, interests, climate, travel_style, group_type, from_country }`

Transport
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/transport` | Search transport options |
| GET | `/api/transport/types` | Summary by transport type |

---

🛠 Development Tips

Running both servers simultaneously
```bash
# Terminal 1 — Backend
cd backend && npm run dev

# Terminal 2 — Frontend
cd frontend && npm start
```

Or use **concurrently** in the root:
```bash
npm install -g concurrently
concurrently "cd backend && npm run dev" "cd frontend && npm start"
```

Resetting the database
```bash
mysql -u root -p wanderlust_db < database/schema.sql
```

Environment variables not loading?
Make sure your `.env` file is in the `backend/` folder (not the project root), and there are no spaces around the `=` sign.

---

🏗 Production Deployment

Build the React frontend
```bash
cd frontend
npm run build
```

Serve static files from Express (optional)
Add this to `backend/server.js` before the 404 handler:
```js
const path = require('path');
app.use(express.static(path.join(__dirname, '../frontend/build')));
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/build/index.html'));
});
```

### Environment for production
```env
NODE_ENV=production
JWT_SECRET=a_very_long_secure_random_string_for_production
CLIENT_URL=https://yourdomain.com
```

Recommended hosting options
- **Backend + DB:** Railway, Render, DigitalOcean, AWS EC2
- **Frontend:** Vercel, Netlify, Cloudflare Pages
- **Database:** PlanetScale, Railway MySQL, AWS RDS

---

🎨 Design System

The website uses a **Refined Luxury** aesthetic with warm earth tones:

| Token | Value | Usage |
|-------|-------|-------|
| `--forest` | `#1a3a2a` | Primary color — buttons, navbar, headings |
| `--gold` | `#c8a96e` | Accent — highlights, tags, CTAs |
| `--terra` | `#c4603a` | Tertiary — sale badges, warnings |
| `--cream` | `#faf7f2` | Page background |
| `--muted` | `#7a7060` | Secondary text |

**Fonts:**
- Display: *Cormorant Garamond* (serif) — headings, prices
- Body: *Jost* (sans-serif) — all UI text

---
📋 Pages Summary

| # | Page | Route | Key Features |
|---|------|--------|-------------|
| 1 | **Home** | `/` | Hero search, featured packages, destination grid, testimonials |
| 2 | **Tour Packages** | `/packages` | Filter by category/price/rating, search, package cards |
| 3 | **Transport** | `/transport` | Flights/trains/buses/cruises/cars, search & compare |
| 4 | **AI Recommender** | `/ai-recommender` | 3-step form, Claude AI-powered personalized recommendations |
| 5 | **Booking** | `/booking` | Date/guest selection, traveler info, price summary |
| 6 | **Payment** | `/payment` | Card/UPI/netbanking/wallet/EMI, simulated payment gateway |
| 7 | **Visa** | `/visa` | Requirements lookup, application form, document checklist |
| 8 | **Account** | `/account` | Login/register, profile, booking history, password change |

---

🐛 Troubleshooting

**MySQL connection refused?**
- Check MySQL is running: `brew services list` (macOS) or `sudo systemctl status mysql` (Linux)
- Verify credentials in `.env` match your MySQL user

**Port 5000 already in use?**
- Change `PORT=5001` in `.env`
- Update the proxy in `frontend/package.json` to `http://localhost:5001`

**CORS errors in browser?**
- Ensure `CLIENT_URL=http://localhost:3000` in your backend `.env`
- Make sure the backend is running before the frontend

**Packages not loading?**
- Confirm seed data ran: `SELECT COUNT(*) FROM tour_packages;` should return 8

**AI Recommender not working?**
- Add your Anthropic API key to `.env`
- Without it, the fallback example recommendations still display correctly

---

📄 License

MIT — Free for personal and commercial use.

---

Built with ❤️ using React · Node.js · Express · MySQL 
