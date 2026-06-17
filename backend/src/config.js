import 'dotenv/config';

const required = ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY', 'DATABASE_URL'];

for (const key of required) {
  if (!process.env[key]) {
    throw new Error(`${key} is required`);
  }
}

export const config = {
  port: Number(process.env.PORT || 4000),
  nodeEnv: process.env.NODE_ENV || 'development',
  supabaseUrl: process.env.SUPABASE_URL,
  supabasePublishableKey: process.env.SUPABASE_PUBLISHABLE_KEY,
  databaseUrl: process.env.DATABASE_URL,
  corsOrigin: process.env.CORS_ORIGIN || '*',
};
