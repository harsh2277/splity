import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/home/navigation_shell.dart';
import '../../features/groups/create_group_screen.dart';
import '../../features/groups/join_group_screen.dart';
import '../../features/groups/group_details_screen.dart';
import '../../features/expenses/add_expense_screen.dart';
import '../../features/members/add_member_screen.dart';
import '../../features/members/member_details_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/notifications_settings_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/help_support_screen.dart';
import '../../features/settings/live_chat_screen.dart';
import '../../features/settings/email_support_screen.dart';
import '../../features/settings/suggest_improvement_screen.dart';
import '../../features/settings/user_profile_screen.dart';
import '../../features/settings/edit_profile_screen.dart';
import '../../features/payments/payment_success_screen.dart';
import '../../features/payments/payment_waiting_screen.dart';
import '../../features/payments/payment_error_screen.dart';
import '../../features/history/transaction_details_screen.dart';
import '../../features/expenses/expenses_provider.dart';

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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
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
      builder: (context, state) {
        final groupId = state.uri.queryParameters['groupId'];
        return AddExpenseScreen(defaultGroupId: groupId);
      },
    ),
    GoRoute(
      path: '/add-member',
      builder: (context, state) => const AddMemberScreen(),
    ),
    GoRoute(
      path: '/member-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MemberDetailsScreen(memberId: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/live-chat',
      builder: (context, state) => const LiveChatScreen(),
    ),
    GoRoute(
      path: '/email-support',
      builder: (context, state) => const EmailSupportScreen(),
    ),
    GoRoute(
      path: '/suggest-improvement',
      builder: (context, state) => const SuggestImprovementScreen(),
    ),
    GoRoute(
      path: '/user-profile',
      builder: (context, state) => const UserProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) => const PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/payment-waiting',
      builder: (context, state) => const PaymentWaitingScreen(),
    ),
    GoRoute(
      path: '/payment-error',
      builder: (context, state) => const PaymentErrorScreen(),
    ),
    GoRoute(
      path: '/transaction-details',
      builder: (context, state) {
        final expense = state.extra as Expense?;
        if (expense == null) return const SizedBox();
        return TransactionDetailsScreen(expense: expense);
      },
    ),
  ],
);
