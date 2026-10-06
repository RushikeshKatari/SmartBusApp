# SmartBus Production Deployment Guide

This guide walks through deploying the SmartBus architecture to production:
```
Flutter Web (Vercel)  ──HTTPS/API──>  Spring Boot API (Render)  ──JDBC──>  PostgreSQL (Supabase)
```

---

## Architecture Overview

| Component | Technology | Target Host | Purpose |
|---|---|---|---|
| **Frontend** | Flutter Web 3.x | **Vercel** | Responsive web client for Students, In-charges, Admins, HOD, and Managers |
| **Backend** | Spring Boot 3.4 (Java 21) | **Render** | REST API, JWT auth, emergency handling, fleet routing, and WebSocket tracking |
| **Database** | PostgreSQL 15+ | **Supabase** | Managed PostgreSQL database with Flyway schema migrations (`V1` to `V11`) |

---

## Step 1: Database Setup (Supabase)

1. Create an account and new project at [supabase.com](https://supabase.com).
2. Go to **Project Settings** -> **Database**.
3. Under **Connection string**, select **URI** and copy the connection details:
   - Host: `db.<project-ref>.supabase.co`
   - Port: `5432` (or `6543` for connection pooling)
   - User: `postgres`
   - Password: `<your-db-password>`
4. The Spring Boot backend uses Flyway to automatically apply all 11 database migrations upon starting:
   - `V1`: Core users, roles, sessions, student profiles
   - `V2`: App manager config & billing
   - `V3`: Fleet schema (buses, stops, routes)
   - `V4`: Operations & attendance records
   - `V5`: QR expiry
   - `V6`-`V9`: Emergency reports, academic sections, HOD approvals
   - `V10`: Seed routes and demo accounts
   - `V11`: Breakdown reassignment tables

---

## Step 2: Backend Deployment (Render)

1. Create a free account at [render.com](https://render.com).
2. Click **New +** -> **Web Service**.
3. Connect your GitHub repository (`SmartBusApp`).
4. Select **Docker** environment:
   - **Root Directory**: `backend` (or leave empty if using root Dockerfile path `backend/Dockerfile`)
   - **Docker Command**: `docker build -f backend/Dockerfile .`
   - **Instance Type**: Free or Starter
5. Under **Advanced** -> **Health Check Path**, enter:
   ```
   /health
   ```
6. Add the following **Environment Variables** in Render Dashboard:
   | Key | Example Value | Description |
   |---|---|---|
   | `DATABASE_URL` | `jdbc:postgresql://db.<ref>.supabase.co:5432/postgres?sslmode=require` | Supabase JDBC URL |
   | `DATABASE_USERNAME` | `postgres` | Supabase DB username |
   | `DATABASE_PASSWORD` | `<your-db-password>` | Supabase DB password |
   | `JWT_SECRET` | `<32-char-random-string>` | JWT HMAC-SHA256 signature key |
   | `CORS_ORIGINS` | `https://<your-vercel-app>.vercel.app` | Allowed Vercel frontend origin |
   | `BOOTSTRAP_MANAGER_USERNAME` | `superadmin` | Initial manager user |
   | `BOOTSTRAP_MANAGER_PASSWORD` | `<strong-password>` | Initial manager password |
   | `BOOTSTRAP_HOD_USERNAME` | `hod` | Initial HOD user |
   | `BOOTSTRAP_HOD_PASSWORD` | `<strong-password>` | Initial HOD password |

7. Click **Create Web Service**. Once deployed, Render will provide your public URL:
   `https://<your-service-name>.onrender.com`
8. Verify health status by visiting `https://<your-service-name>.onrender.com/health` in your browser. It should return:
   ```json
   { "status": "UP", "service": "smartbus-backend" }
   ```

---

## Step 3: Frontend Deployment (Vercel)

### Option A: Deploy Pre-built `build/web` (Recommended)

1. Build the production web bundle locally with your Render backend URL:
   ```bash
   flutter build web --release \
     --dart-define=API_BASE_URL=https://<your-service-name>.onrender.com
   ```
2. Deploy via the Vercel CLI:
   ```bash
   npm install -g vercel
   vercel build/web --prod
   ```

### Option B: Automatic Continuous Deployment via GitHub (Vercel)

1. Connect your repository on [vercel.com](https://vercel.com).
2. Framework Preset: **Other**.
3. **Build Command**:
   ```bash
   if [ ! -d "flutter" ]; then git clone https://github.com/flutter/flutter.git -b stable --depth 1; fi && export PATH="$PATH:`pwd`/flutter/bin" && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
   ```
4. **Output Directory**: `build/web`
5. Under **Environment Variables**, set:
   - `API_BASE_URL` = `https://<your-service-name>.onrender.com`
6. `vercel.json` in the root repository automatically handles Single Page Application (SPA) routing rewrites so directly opening or refreshing `/routes`, `/login`, or `/profile` will not produce 404 errors.

---

## Step 4: Verification & Smoke Test Checklist

- [ ] **Render Health Check**: `GET https://<your-backend>.onrender.com/health` returns `200 OK`.
- [ ] **Flyway Database Tables**: Check Supabase Table Editor — all tables (`app_user`, `bus`, `route`, `stop`, `attendance_record`, etc.) are created.
- [ ] **Vercel Web App**: Opens over HTTPS (`https://<your-app>.vercel.app`).
- [ ] **Unified Login**: Login using demo or database credentials:
  - Student: `student` / `student123`
  - In-charge: `incharge` / `incharge123`
  - Admin: `admin` / `admin123`
  - HOD: `hod` / `hod123`
  - Manager: `superadmin` / `admin123`
- [ ] **CORS**: Verify browser console displays no CORS errors during login or data fetching.
- [ ] **Page Refresh**: Refreshing the browser while logged into any portal keeps the route active without 404.
- [ ] **Logout**: Clicking Logout returns smoothly to the unified login screen.

---

## Rollback Procedure

- **Frontend (Vercel)**: Navigate to **Deployments** in Vercel Dashboard, select the previous working deployment, and click **Promote to Production** (takes ~2 seconds).
- **Backend (Render)**: Navigate to **Deploys** in Render Dashboard and click **Rollback to this deploy**.
