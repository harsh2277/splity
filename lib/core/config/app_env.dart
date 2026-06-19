class AppEnv {
  const AppEnv._();
 
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:4000/api',
  );
  static const String neonAuthBaseUrl = 'https://ep-polished-king-ad7hlb9q.neonauth.c-2.us-east-1.aws.neon.tech/neondb/auth';
}
