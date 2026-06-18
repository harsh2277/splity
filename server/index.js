const express = require('express');
const cors = require('cors');
const db = require('./db');
const { requireAuth } = require('./auth');
const { jwtVerify, createRemoteJWKSet, SignJWT } = require('jose');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 4000;

// Local secret key for HS256 local JWTs
const LOCAL_SECRET = new TextEncoder().encode(
  process.env.JWT_SECRET || 'fallback_secret_at_least_32_characters_long'
);

// Middleware
app.use(cors());
app.use(express.json());

// In-memory store for pending mobile OAuth logins
const authStates = {};

// Basic health check route
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

// Helper: Calculate group balance for a user
async function getUserBalanceInGroup(userId, groupId) {
  try {
    const paidResult = await db.query(
      `SELECT COALESCE(SUM(amount), 0) as paid FROM public.expenses WHERE payer_id = $1 AND group_id = $2`,
      [userId, groupId]
    );
    const paid = parseFloat(paidResult.rows[0].paid);

    const shareResult = await db.query(
      `SELECT COALESCE(SUM(es.amount), 0) as share 
       FROM public.expense_splits es
       JOIN public.expenses e ON es.expense_id = e.id
       WHERE es.user_id = $1 AND e.group_id = $2`,
      [userId, groupId]
    );
    const share = parseFloat(shareResult.rows[0].share);

    const balance = paid - share;
    if (balance > 0) {
      return `Owed ₹${balance.toFixed(2)}`;
    } else if (balance < 0) {
      return `Owe ₹${Math.abs(balance).toFixed(2)}`;
    } else {
      return 'Settled';
    }
  } catch (err) {
    console.error('Error calculating balance:', err);
    return 'Settled';
  }
}

// -------------------------------------------------------------------
// OAuth Callback & Polling (Mobile Integration)
// -------------------------------------------------------------------

// Endpoint to initiate social login inside the browser context,
// ensuring the state cookie is set in the system browser rather than the Dart HTTP client.
app.get('/api/auth/google-start', (req, res) => {
  const { stateId } = req.query;
  if (!stateId) {
    return res.status(400).send('Missing stateId query parameter.');
  }

  const callbackUrl = `http://127.0.0.1:4000/api/auth/callback?stateId=${stateId}`;

  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Connecting to Google...</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #0F172A;
            color: #F8FAFC;
          }
          .card {
            background: #1E293B;
            padding: 2.5rem;
            border-radius: 1.5rem;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 90%;
            width: 360px;
            border: 1px solid #334155;
          }
          .spinner {
            border: 4px solid rgba(255, 255, 255, 0.1);
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border-left-color: #38BDF8;
            animation: spin 1s linear infinite;
            margin: 0 auto 1.2rem auto;
          }
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
          h1 {
            margin: 0 0 0.8rem 0;
            font-size: 1.4rem;
            font-weight: 800;
          }
          p {
            color: #94A3B8;
            margin: 0;
            font-size: 0.95rem;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="spinner"></div>
          <h1>Connecting to Google...</h1>
          <p>Please wait while we set up a secure connection.</p>
        </div>
        <script>
          const initUrl = "${process.env.NEON_AUTH_BASE_URL}/sign-in/social";
          const callbackUrl = "${callbackUrl}";

          fetch(initUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Origin': window.location.origin
            },
            body: JSON.stringify({
              provider: 'google',
              callbackURL: callbackUrl
            })
          })
          .then(res => {
            if (!res.ok) throw new Error("Status: " + res.status);
            return res.json();
          })
          .then(data => {
            if (data.url) {
              window.location.href = data.url;
            } else {
              throw new Error("No redirect URL returned");
            }
          })
          .catch(err => {
            console.error(err);
            document.body.innerHTML = '<div class="card"><h1>Connection Failed</h1><p>Unable to initiate secure sign-in. Please try again.</p></div>';
          });
        </script>
      </body>
    </html>
  `);
});

// Callback endpoint for social login redirect from Neon Auth
// Returns a success screen immediately if we can resolve the verifier in the DB,
// or falls back to client-side cookie extraction in Chrome.
app.get('/api/auth/callback', async (req, res) => {
  const { stateId, neon_auth_session_verifier } = req.query;
  if (!stateId) {
    return res.status(400).send('Missing stateId query parameter.');
  }

  // If we received a session verifier from Neon Auth redirect, try database lookup first
  if (neon_auth_session_verifier) {
    try {
      console.log(`Callback received. Query parameters: { stateId: '${stateId}', neon_auth_session_verifier: '${neon_auth_session_verifier}' }`);
      
      const sqlQuery = `
        SELECT s.token, u.id, u.email, u.name, u.image 
        FROM neon_auth.session s
        JOIN neon_auth.user u ON s."userId" = u.id
        JOIN neon_auth.verification v ON 
          v.identifier = $1 
          AND s."createdAt" >= v."updatedAt" - INTERVAL '5 second'
          AND s."createdAt" <= v."updatedAt" + INTERVAL '5 second'
        LIMIT 1;
      `;
      
      const result = await db.query(sqlQuery, [neon_auth_session_verifier]);
      
      if (result.rows.length > 0) {
        const sessionRow = result.rows[0];
        console.log(`Found matching session in DB for user ${sessionRow.email}`);
        
        // Generate local JWT token
        const token = await new SignJWT({
          id: sessionRow.id,
          email: sessionRow.email,
          name: sessionRow.name,
          image: sessionRow.image
        })
          .setProtectedHeader({ alg: 'HS256' })
          .setIssuedAt()
          .setExpirationTime('30d')
          .sign(LOCAL_SECRET);

        // Fetch or initialize profile
        const profileResult = await db.query('SELECT * FROM public.profiles WHERE id = $1', [sessionRow.id]);
        let finalProfile;
        if (profileResult.rows.length === 0) {
          const defaultAvatar = sessionRow.image || '👨‍💻';
          const insertResult = await db.query(
            `INSERT INTO public.profiles (id, name, email, avatar) 
             VALUES ($1, $2, $3, $4) 
             RETURNING *`,
            [sessionRow.id, sessionRow.name || sessionRow.email.split('@')[0], sessionRow.email, defaultAvatar]
          );
          finalProfile = insertResult.rows[0];
        } else {
          finalProfile = profileResult.rows[0];
        }

        // Store the auth state for client polling
        authStates[stateId] = {
          jwt: token,
          user: {
            id: finalProfile.id,
            email: finalProfile.email,
            name: finalProfile.name,
            avatar: finalProfile.avatar,
            upiId: finalProfile.upi_id
          }
        };

        // Render premium success HTML page
        return res.send(`
          <!DOCTYPE html>
          <html>
            <head>
              <title>Login Successful</title>
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                body {
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  justify-content: center;
                  height: 100vh;
                  margin: 0;
                  background-color: #0F172A;
                  color: #F8FAFC;
                }
                .card {
                  background: #1E293B;
                  padding: 2.5rem;
                  border-radius: 1.5rem;
                  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
                  text-align: center;
                  max-width: 90%;
                  width: 360px;
                  border: 1px solid #334155;
                }
                .icon {
                  font-size: 3rem;
                  margin-bottom: 1rem;
                }
                h1 {
                  margin: 0 0 0.8rem 0;
                  font-size: 1.4rem;
                  font-weight: 800;
                  letter-spacing: -0.025em;
                }
                p {
                  color: #94A3B8;
                  margin: 0;
                  font-size: 0.95rem;
                  line-height: 1.5;
                }
              </style>
            </head>
            <body>
              <div class="card">
                <div class="icon">✅</div>
                <h1>Login Successful</h1>
                <p>Redirecting you back to the application...</p>
              </div>
              <script>
                // Trigger deep link redirect to bring the app to foreground
                setTimeout(() => {
                  window.location.href = "splity://auth-callback";
                }, 500);
              </script>
            </body>
          </html>
        `);
      } else {
        console.warn(`No matching session found in DB for verifier: ${neon_auth_session_verifier}`);
      }
    } catch (dbError) {
      console.error('Database session lookup or JWT signing failed:', dbError);
    }
  }

  // Fallback: fetch session token in client browser (original cookie method)
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Completing Sign-In...</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #0F172A;
            color: #F8FAFC;
          }
          .card {
            background: #1E293B;
            padding: 2.5rem;
            border-radius: 1.5rem;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 90%;
            width: 360px;
            border: 1px solid #334155;
          }
          .spinner {
            border: 4px solid rgba(255, 255, 255, 0.1);
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border-left-color: #38BDF8;
            animation: spin 1s linear infinite;
            margin: 0 auto 1.2rem auto;
          }
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
          h1 {
            margin: 0 0 0.8rem 0;
            font-size: 1.4rem;
            font-weight: 800;
            letter-spacing: -0.025em;
          }
          p {
            color: #94A3B8;
            margin: 0;
            font-size: 0.95rem;
            line-height: 1.5;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="spinner" id="loader"></div>
          <h1 id="status-title">Establishing Connection...</h1>
          <p id="status-desc">Please wait while we securely fetch your authentication token.</p>
        </div>
        <script>
          const stateId = "${stateId}";
          const tokenUrl = "${process.env.NEON_AUTH_BASE_URL}/token";

          // Fetch the JWT token from Neon Auth using Chrome's cookies
          fetch(tokenUrl, { credentials: 'include' })
            .then(res => {
              if (!res.ok) {
                throw new Error("Unable to retrieve session token (Status: " + res.status + ")");
              }
              return res.json();
            })
            .then(data => {
              // Post the token back to our Express server
              return fetch('/api/auth/token-submit', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ stateId, token: data.token })
              });
            })
            .then(res => {
              if (!res.ok) {
                throw new Error("Failed to register session with backend");
              }
              document.getElementById('loader').style.display = 'none';
              document.getElementById('status-title').innerText = "Login Successful";
              document.getElementById('status-desc').innerText = "You can close this tab now and go back to your Splity application.";
            })
            .catch(err => {
              console.error(err);
              document.getElementById('loader').style.display = 'none';
              document.getElementById('status-title').innerText = "Authentication Failed";
              document.getElementById('status-desc').innerText = err.message || "An error occurred during authentication. Please try again.";
            });
        </script>
      </body>
    </html>
  `);
});

// Endpoint for client-side JS to submit the retrieved token
app.post('/api/auth/token-submit', async (req, res) => {
  const { stateId, token } = req.body;
  if (!stateId || !token) {
    return res.status(400).json({ error: 'Missing stateId or token.' });
  }

  try {
    const JWKS = createRemoteJWKSet(new URL(`${process.env.NEON_AUTH_BASE_URL}/.well-known/jwks.json`));
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: new URL(process.env.NEON_AUTH_BASE_URL).origin
    });

    const profileResult = await db.query('SELECT * FROM public.profiles WHERE id = $1', [payload.id]);
    let finalProfile;
    if (profileResult.rows.length === 0) {
      const defaultAvatar = payload.image || '👨‍💻';
      const insertResult = await db.query(
        `INSERT INTO public.profiles (id, name, email, avatar) 
         VALUES ($1, $2, $3, $4) 
         RETURNING *`,
        [payload.id, payload.name || payload.email.split('@')[0], payload.email, defaultAvatar]
      );
      finalProfile = insertResult.rows[0];
    } else {
      finalProfile = profileResult.rows[0];
    }

    authStates[stateId] = {
      jwt: token,
      user: {
        id: finalProfile.id,
        email: finalProfile.email,
        name: finalProfile.name,
        avatar: finalProfile.avatar,
        upiId: finalProfile.upi_id
      }
    };

    res.json({ success: true });
  } catch (err) {
    console.error('Token submit error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/auth/poll/:stateId', (req, res) => {
  const { stateId } = req.params;
  const stateData = authStates[stateId];
  if (stateData) {
    delete authStates[stateId];
    return res.json({ status: 'success', ...stateData });
  }
  res.json({ status: 'pending' });
});

// -------------------------------------------------------------------
// 1. Profile Routes
// -------------------------------------------------------------------

app.get('/api/profile', requireAuth, async (req, res) => {
  const { id, name, email, image } = req.user;
  try {
    const result = await db.query('SELECT * FROM public.profiles WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      const defaultAvatar = image || '👨‍💻';
      const insertResult = await db.query(
        `INSERT INTO public.profiles (id, name, email, avatar) 
         VALUES ($1, $2, $3, $4) 
         RETURNING *`,
        [id, name || email.split('@')[0], email, defaultAvatar]
      );
      return res.json(insertResult.rows[0]);
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error fetching profile' });
  }
});

app.post('/api/profile', requireAuth, async (req, res) => {
  const { id, email } = req.user;
  const { name, upi_id, avatar } = req.body;

  if (!name) {
    return res.status(400).json({ error: 'Name is required' });
  }

  try {
    const result = await db.query(
      `INSERT INTO public.profiles (id, name, email, upi_id, avatar, updated_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       ON CONFLICT (id) DO UPDATE SET
         name = EXCLUDED.name,
         upi_id = EXCLUDED.upi_id,
         avatar = EXCLUDED.avatar,
         updated_at = NOW()
       RETURNING *`,
      [id, name, email, upi_id || null, avatar || '👨‍💻']
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error updating profile' });
  }
});

// -------------------------------------------------------------------
// 2. Group Routes
// -------------------------------------------------------------------

app.get('/api/groups', requireAuth, async (req, res) => {
  const userId = req.user.id;
  try {
    const result = await db.query(
      `SELECT g.*, 
       (SELECT count(*) FROM public.group_members WHERE group_id = g.id) as members_count
       FROM public.groups g
       JOIN public.group_members gm ON g.id = gm.group_id
       WHERE gm.user_id = $1
       ORDER BY g.created_at DESC`,
      [userId]
    );

    const groups = [];
    for (const row of result.rows) {
      const balance = await getUserBalanceInGroup(userId, row.id);
      groups.push({
        id: row.id,
        name: row.name,
        companyName: row.company_name || 'Home',
        type: row.type,
        inviteCode: row.invite_code,
        approvalRequired: row.approval_required,
        membersCount: parseInt(row.members_count),
        balance: balance,
        imageUrl: row.image_url
      });
    }

    res.json(groups);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error fetching groups' });
  }
});

app.post('/api/groups', requireAuth, async (req, res) => {
  const userId = req.user.id;
  const { name, companyName, type, approvalRequired, imageUrl } = req.body;

  if (!name || !type) {
    return res.status(400).json({ error: 'Name and type are required' });
  }

  try {
    const baseCode = name.replace(/\s+/g, '').toUpperCase().substring(0, 4);
    const randomSuffix = Math.floor(10 + Math.random() * 90);
    const inviteCode = `${baseCode}${randomSuffix}`;

    const groupResult = await db.query(
      `INSERT INTO public.groups (name, company_name, type, invite_code, approval_required, image_url, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [name, companyName || null, type, inviteCode, approvalRequired || false, imageUrl || null, userId]
    );

    const group = groupResult.rows[0];

    await db.query(
      `INSERT INTO public.group_members (group_id, user_id, role)
       VALUES ($1, $2, 'owner')`,
      [group.id, userId]
    );

    res.status(201).json({
      id: group.id,
      name: group.name,
      companyName: group.company_name || '',
      type: group.type,
      inviteCode: group.invite_code,
      approvalRequired: group.approval_required,
      membersCount: 1,
      balance: 'Settled',
      imageUrl: group.image_url
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error creating group' });
  }
});

app.post('/api/groups/join', requireAuth, async (req, res) => {
  const userId = req.user.id;
  const { code } = req.body;

  if (!code) {
    return res.status(400).json({ error: 'Invite code is required' });
  }

  try {
    const codeSanitized = code.trim().toUpperCase();
    const groupResult = await db.query(
      'SELECT * FROM public.groups WHERE invite_code = $1',
      [codeSanitized]
    );

    if (groupResult.rows.length === 0) {
      return res.status(404).json({ error: 'Group with this invite code not found' });
    }

    const group = groupResult.rows[0];

    const memberResult = await db.query(
      'SELECT * FROM public.group_members WHERE group_id = $1 AND user_id = $2',
      [group.id, userId]
    );

    if (memberResult.rows.length > 0) {
      return res.status(400).json({ error: 'You are already a member of this group' });
    }

    await db.query(
      `INSERT INTO public.group_members (group_id, user_id, role)
       VALUES ($1, $2, 'member')`,
      [group.id, userId]
    );

    const balance = await getUserBalanceInGroup(userId, group.id);
    const membersCountResult = await db.query(
      'SELECT count(*) FROM public.group_members WHERE group_id = $1',
      [group.id]
    );

    res.json({
      id: group.id,
      name: group.name,
      companyName: group.company_name || '',
      type: group.type,
      inviteCode: group.invite_code,
      approvalRequired: group.approval_required,
      membersCount: parseInt(membersCountResult.rows[0].count),
      balance: balance,
      imageUrl: group.image_url
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error joining group' });
  }
});

app.get('/api/groups/:id', requireAuth, async (req, res) => {
  const userId = req.user.id;
  const groupId = req.params.id;

  try {
    const groupResult = await db.query('SELECT * FROM public.groups WHERE id = $1', [groupId]);
    if (groupResult.rows.length === 0) {
      return res.status(404).json({ error: 'Group not found' });
    }
    const group = groupResult.rows[0];

    const memberCheck = await db.query(
      'SELECT * FROM public.group_members WHERE group_id = $1 AND user_id = $2',
      [groupId, userId]
    );
    if (memberCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied. You are not a member of this group' });
    }

    const membersResult = await db.query(
      `SELECT p.id, p.name, p.email, p.upi_id, p.avatar, gm.role 
       FROM public.group_members gm
       JOIN public.profiles p ON gm.user_id = p.id
       WHERE gm.group_id = $1`,
      [groupId]
    );

    const expensesResult = await db.query(
      `SELECT e.*, p.name as payer_name, p.avatar as payer_avatar
       FROM public.expenses e
       JOIN public.profiles p ON e.payer_id = p.id
       WHERE e.group_id = $1
       ORDER BY e.date DESC`,
      [groupId]
    );

    const balance = await getUserBalanceInGroup(userId, groupId);

    res.json({
      group: {
        id: group.id,
        name: group.name,
        companyName: group.company_name || '',
        type: group.type,
        inviteCode: group.invite_code,
        approvalRequired: group.approval_required,
        imageUrl: group.image_url,
        balance
      },
      members: membersResult.rows,
      expenses: expensesResult.rows.map(e => ({
        id: e.id,
        title: e.title,
        amount: `₹${parseFloat(e.amount).toFixed(2)}`,
        category: e.category,
        date: new Date(e.date).toLocaleDateString('en-IN', {
          day: 'numeric',
          month: 'short',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        }),
        isPersonal: e.is_personal,
        payer: {
          id: e.payer_id,
          name: e.payer_name,
          avatar: e.payer_avatar
        }
      }))
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error fetching group details' });
  }
});

// -------------------------------------------------------------------
// 3. Expense Routes
// -------------------------------------------------------------------

app.get('/api/expenses', requireAuth, async (req, res) => {
  const userId = req.user.id;
  const { groupId, isPersonal } = req.query;

  try {
    let queryText = `
      SELECT e.*, p.name as payer_name, p.avatar as payer_avatar, g.name as group_name
      FROM public.expenses e
      JOIN public.profiles p ON e.payer_id = p.id
      LEFT JOIN public.groups g ON e.group_id = g.id
    `;
    const params = [];

    if (groupId) {
      queryText += ` WHERE e.group_id = $1`;
      params.push(groupId);
    } else if (isPersonal === 'true') {
      queryText += ` WHERE e.payer_id = $1 AND e.is_personal = true`;
      params.push(userId);
    } else {
      queryText += ` 
        WHERE e.is_personal = true AND e.payer_id = $1
        OR e.group_id IN (
          SELECT group_id FROM public.group_members WHERE user_id = $1
        )
      `;
      params.push(userId);
    }

    queryText += ` ORDER BY e.date DESC`;
    const result = await db.query(queryText, params);

    const formattedExpenses = [];
    for (const e of result.rows) {
      let isOwed = false;
      const splitCheck = await db.query(
        `SELECT * FROM public.expense_splits WHERE expense_id = $1 AND user_id = $2`,
        [e.id, userId]
      );
      
      if (e.payer_id !== userId && splitCheck.rows.length > 0) {
        isOwed = true;
      }

      let subtitle = 'Personal Log';
      if (!e.is_personal) {
        const payerLabel = e.payer_id === userId ? 'You' : e.payer_name;
        subtitle = `${e.group_name || 'Group'} • Paid by ${payerLabel}`;
      }

      formattedExpenses.push({
        title: e.title,
        subtitle: subtitle,
        amount: `₹${parseFloat(e.amount).toFixed(2)}`,
        isOwed: isOwed,
        isPersonal: e.is_personal,
        category: e.category,
        date: new Date(e.date).toLocaleDateString('en-IN', {
          day: 'numeric',
          month: 'short',
          hour: '2-digit',
          minute: '2-digit'
        })
      });
    }

    res.json(formattedExpenses);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error fetching expenses' });
  }
});

app.post('/api/expenses', requireAuth, async (req, res) => {
  const userId = req.user.id;
  const { title, amount, category, isPersonal, groupId } = req.body;

  if (!title || !amount || !category) {
    return res.status(400).json({ error: 'Title, amount, and category are required' });
  }

  const amtNum = parseFloat(amount);
  if (isNaN(amtNum) || amtNum <= 0) {
    return res.status(400).json({ error: 'Amount must be a positive number' });
  }

  try {
    let insertedExpense;

    if (isPersonal) {
      const expenseResult = await db.query(
        `INSERT INTO public.expenses (payer_id, title, amount, category, is_personal)
         VALUES ($1, $2, $3, $4, true)
         RETURNING *`,
        [userId, title, amtNum, category.toLowerCase()]
      );
      insertedExpense = expenseResult.rows[0];

      await db.query(
        `INSERT INTO public.expense_splits (expense_id, user_id, amount)
         VALUES ($1, $2, $3)`,
        [insertedExpense.id, userId, amtNum]
      );
    } else {
      if (!groupId) {
        return res.status(400).json({ error: 'groupId is required for group expenses' });
      }

      const memberCheck = await db.query(
        'SELECT user_id FROM public.group_members WHERE group_id = $1',
        [groupId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(400).json({ error: 'Group has no members or does not exist' });
      }

      const isMember = memberCheck.rows.some(m => m.user_id === userId);
      if (!isMember) {
        return res.status(403).json({ error: 'You are not a member of this group' });
      }

      const expenseResult = await db.query(
        `INSERT INTO public.expenses (group_id, payer_id, title, amount, category, is_personal)
         VALUES ($1, $2, $3, $4, $5, false)
         RETURNING *`,
        [groupId, userId, title, amtNum, category.toLowerCase()]
      );
      insertedExpense = expenseResult.rows[0];

      const splitCount = memberCheck.rows.length;
      const splitAmount = amtNum / splitCount;

      for (const member of memberCheck.rows) {
        await db.query(
          `INSERT INTO public.expense_splits (expense_id, user_id, amount)
           VALUES ($1, $2, $3)`,
          [insertedExpense.id, member.user_id, splitAmount]
        );
      }
    }

    res.status(201).json(insertedExpense);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error creating expense' });
  }
});

// Start listening
app.listen(PORT, () => {
  console.log(`Splity backend listening on port ${PORT}`);
});
