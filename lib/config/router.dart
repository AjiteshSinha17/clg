import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../screens/auth/auth_gate.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/community/public/create_post_screen.dart';
import '../screens/main_shell/main_scaffold.dart';
import '../screens/roommates/roommate_detail_screen.dart';
import '../screens/roommates/roommate_search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/chats/chat_screen.dart';
import '../models/user.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: 'shell',
          builder: (context, state) => const MainScaffold(),
          routes: [
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: 'create-post',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: 'roommate-detail',
              builder: (context, state) {
                final profile = state.extra as User;
                return RoommateDetailScreen(profile: profile);
              },
            ),
            GoRoute(
              path: 'roommate-search',
              builder: (context, state) => const RoommateSearchScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'chat/:chatId',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            final otherUser = state.extra as User;
            return ChatScreen(chatId: chatId, otherUser: otherUser);
          },
        ),
      ],
    ),
  ],

  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for auth to initialize
    if (!authProvider.isInitialized) {
      return null; // Don't redirect while initializing
    }
    
    final loggedIn = authProvider.user != null;
    final isLoginPage = state.matchedLocation == '/login';
    final isSignupPage = state.matchedLocation == '/signup';
    final isAuthPage = isLoginPage || isSignupPage;
    final isRoot = state.matchedLocation == '/';

    // If not logged in and trying to access protected routes
    if (!loggedIn && !isAuthPage && !isRoot) {
      return '/login';
    }

    // If logged in and on auth pages, redirect to main app
    if (loggedIn && isAuthPage) {
      return '/shell';
    }

    // If logged in and on root, redirect to main app
    if (loggedIn && isRoot) {
      return '/shell';
    }

    return null;
  },
);
