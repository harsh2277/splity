# Splity Backend

Express API for Splity. Supabase handles authentication, and Neon Postgres stores app data.

## Setup

1. Create `backend/.env` from `backend/.env.example`.
2. Install dependencies:

   ```bash
   npm install
   ```

3. Run migrations:

   ```bash
   npm run migrate
   ```

4. Start the API:

   ```bash
   npm run dev
   ```

## Auth

All `/api/*` routes except `/api/health` require:

```text
Authorization: Bearer <supabase_access_token>
```

The backend verifies the token with Supabase, then maps the Supabase user to a Neon `profiles` row.

## Main Routes

- `GET /api/health`
- `GET /api/me`
- `PATCH /api/me`
- `GET /api/groups`
- `POST /api/groups`
- `POST /api/groups/join`
- `GET /api/groups/:groupId`
- `GET /api/groups/:groupId/members`
- `POST /api/groups/:groupId/members`
- `GET /api/expenses`
- `POST /api/expenses`
- `PATCH /api/expenses/:expenseId/status`
- `GET /api/settlements`
- `POST /api/settlements`
