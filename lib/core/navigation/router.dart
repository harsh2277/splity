import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/home/navigation_shell.dart';
import '../../features/groups/create_group_screen.dart';
import '../../features/groups/join_group_screen.dart';
import '../../features/groups/group_details_screen.dart';
import '../../features/expenses/add_expense_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/dashboard-demo',
      builder: (context, state) => const NavigationShell(),
    ),
    GoRoute(
      path: '/create-group',
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: '/join-group',
      builder: (context, state) => const JoinGroupScreen(),
    ),
    GoRoute(
      path: '/group-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GroupDetailsScreen(groupId: id);
      },
    ),
    GoRoute(
      path: '/add-expense',
      builder: (context, state) => const AddExpenseScreen(),
    ),
  ],
);

