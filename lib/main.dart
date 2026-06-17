import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_env.dart';
import 'core/theme/index.dart';
import 'core/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabasePublishableKey,
    );
  }

  runApp(const ProviderScope(child: SplityApp()));
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class SplityApp extends ConsumerWidget {
  const SplityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Splity',
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      routerConfig: appRouter,
    );
  }
}
