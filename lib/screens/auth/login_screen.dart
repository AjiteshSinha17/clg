import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../core/utils/auth_error_mapper.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';
import '../../widgets/theme_toggle_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleSignIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).signInWithEmailAndPassword(email, password);
    } catch (e) {
      final errorMessage = AuthErrorMapper.message(
        e is firebase_auth.FirebaseAuthException ? e : e,
        fallback: 'Login failed. Please try again.',
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _isGoogleSignIn = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    } catch (e) {
      final errorMessage = AuthErrorMapper.message(
        e,
        fallback: 'Google Sign-In failed. Please try again.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isGoogleSignIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final String bgImage = isDark
        ? 'assets/images/theme_dark.jpg'
        : 'assets/images/light.jpg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ThemeToggleButton(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 0. Blocking overlay during Google Sign-In
          if (_isGoogleSignIn)
            const Positioned.fill(
              child: ModalBarrier(
                color: Colors.black54,
                dismissible: false,
              ),
            ),
          if (_isGoogleSignIn)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.liquidGlassDecoration(
                  isDark: isDark,
                  radius: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.darkPrimary),
                    const SizedBox(height: 16),
                    Text(
                      'Signing in with Google...\nCheck for account picker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 1. Background Wallpaper
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark
                    ? const Color(0xFF021429).withValues(alpha: 0.85)
                    : const Color(0xFFF3FBFA).withValues(alpha: 0.65),
                isDark ? BlendMode.darken : BlendMode.lighten,
              ),
              child: Image.asset(bgImage, fit: BoxFit.cover),
            ),
          ),

          // 2. Auth Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: AppTheme.liquidGlassDecoration(
                          isDark: isDark,
                          radius: 32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome Back!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightPrimary,
                                shadows: isDark
                                    ? [
                                        Shadow(
                                          color: AppTheme.aquaGlow.withValues(alpha: 0.6),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Login to your college portal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppTheme.darkOnSurfaceVariant
                                    : AppTheme.lightOnSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _emailController,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: isDark
                                      ? AppTheme.darkPrimary
                                      : AppTheme.lightPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDark
                                      ? AppTheme.darkPrimary
                                      : AppTheme.lightPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: _isLoading ? null : _login,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient(isDark),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.aquaGlow.withValues(
                                        alpha: isDark ? 0.4 : 0.25,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppTheme.darkOnSurfaceVariant
                                        : AppTheme.lightOnSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.go('/signup'),
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppTheme.darkPrimary
                                          : AppTheme.lightPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isLoading ? null : _googleSignIn,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: AppTheme.liquidGlassDecoration(
                        isDark: isDark,
                        radius: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            size: 32,
                            color: isDark
                                ? AppTheme.darkPrimary
                                : AppTheme.lightPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.darkOnSurface
                                  : AppTheme.lightOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

