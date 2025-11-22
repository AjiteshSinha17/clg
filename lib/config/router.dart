
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../screens/auth/auth_gate.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/community/public/create_post_screen.dart';
import '../screens/main_shell/main_scaffold.dart';

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
              path: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: 'create-post',
              builder: (context, state) => const CreatePostScreen(),
            ),
          ]
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = authProvider.user != null;
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!loggedIn && !loggingIn) {
      return '/login';
    }

    if (loggedIn && loggingIn) {
      return '/shell/home';
    }

    return null;
  },
);
