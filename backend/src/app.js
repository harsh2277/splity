import cors from 'cors';
import express from 'express';
import { requireAuth } from './auth.js';
import { query } from './db.js';
import { HttpError } from './http.js';
import { config } from './config.js';
import { meRouter } from './routes/me.js';
import { groupsRouter } from './routes/groups.js';
import { expensesRouter } from './routes/expenses.js';
import { settlementsRouter } from './routes/settlements.js';

export const app = express();

const corsOptions =
  config.corsOrigin === '*'
    ? { origin: '*' }
    : { origin: config.corsOrigin.split(',').map((origin) => origin.trim()) };

app.use(cors(corsOptions));
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', async (_req, res, next) => {
  try {
    await query('select 1');
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

app.use('/api/me', requireAuth, meRouter);
app.use('/api/groups', requireAuth, groupsRouter);
app.use('/api/expenses', requireAuth, expensesRouter);
app.use('/api/settlements', requireAuth, settlementsRouter);

app.use((_req, _res, next) => {
  next(new HttpError(404, 'Route not found'));
});

app.use((error, _req, res, _next) => {
  const status = error.status || 500;
  const message = status === 500 ? 'Internal server error' : error.message;

  if (status === 500) {
    console.error(error);
  }

  res.status(status).json({
    error: {
      message,
      details: error.details,
    },
  });
});
