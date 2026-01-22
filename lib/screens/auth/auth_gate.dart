import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/auth_provider.dart';
import '../../screens/main_shell/main_scaffold.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return authProvider.user != null
        ? const MainScaffold()
        : const LoginScreen();
  }
}
