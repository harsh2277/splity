const { jwtVerify, createRemoteJWKSet } = require('jose');
require('dotenv').config();

const NEON_JWKS_URL = `${process.env.NEON_AUTH_BASE_URL}/.well-known/jwks.json`;
const JWKS = createRemoteJWKSet(new URL(NEON_JWKS_URL));

// Local secret key for HS256 local JWTs
const LOCAL_SECRET = new TextEncoder().encode(
  process.env.JWT_SECRET || 'fallback_secret_at_least_32_characters_long'
);

async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authorization token required' });
  }

  const token = authHeader.split(' ')[1];
  
  // 1. Try local verification (HS256) first
  try {
    const { payload } = await jwtVerify(token, LOCAL_SECRET);
    if (payload && payload.id) {
      req.user = {
        id: payload.id,
        email: payload.email,
        name: payload.name,
        image: payload.avatar || payload.image // support both naming conventions
      };
      return next();
    }
  } catch (localError) {
    // If it's not a local JWT or invalid signature, fall through to Neon Auth JWKS
  }

  // 2. Try Neon Auth JWKS verification
  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: new URL(process.env.NEON_AUTH_BASE_URL).origin
    });

    if (!payload || !payload.id) {
      return res.status(401).json({ error: 'Invalid token payload' });
    }

    req.user = {
      id: payload.id,
      email: payload.email,
      name: payload.name,
      image: payload.image
    };

    next();
  } catch (error) {
    console.error('Authentication error (Local & JWKS failed):', error.message);
    return res.status(401).json({ error: 'Unauthorized or token expired' });
  }
}

module.exports = {
  requireAuth
};
