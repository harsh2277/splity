import { supabase } from './supabase.js';
import { query } from './db.js';
import { HttpError } from './http.js';

function getBearerToken(req) {
  const header = req.get('authorization') || '';
  const [scheme, token] = header.split(' ');

  if (scheme?.toLowerCase() !== 'bearer' || !token) {
    throw new HttpError(401, 'Missing bearer token');
  }

  return token;
}

export async function ensureProfile(user) {
  const email = user.email || `${user.id}@supabase.local`;
  const fullName =
    user.user_metadata?.full_name ||
    user.user_metadata?.name ||
    user.user_metadata?.display_name ||
    null;
  const avatar = user.user_metadata?.avatar || user.user_metadata?.avatar_url || null;
  const phone = user.phone || user.user_metadata?.phone || null;

  const result = await query(
    `
      insert into profiles (supabase_user_id, email, full_name, avatar, phone)
      values ($1, $2, $3, $4, $5)
      on conflict (supabase_user_id)
      do update set
        email = excluded.email,
        full_name = coalesce(profiles.full_name, excluded.full_name),
        avatar = coalesce(profiles.avatar, excluded.avatar),
        phone = coalesce(profiles.phone, excluded.phone)
      returning *
    `,
    [user.id, email, fullName, avatar, phone],
  );

  return result.rows[0];
}

export async function requireAuth(req, _res, next) {
  try {
    const token = getBearerToken(req);
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      throw new HttpError(401, 'Invalid or expired token');
    }

    req.auth = {
      token,
      user: data.user,
      profile: await ensureProfile(data.user),
    };

    next();
  } catch (error) {
    next(error);
  }
}
