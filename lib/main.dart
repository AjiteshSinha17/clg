import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/onesignal_service.dart';
import 'state/auth_provider.dart';
import 'state/chat_provider.dart';
import 'state/community_provider.dart';
import 'state/filter_provider.dart';
import 'state/post_provider.dart';
import 'state/roommate_provider.dart';
import 'state/theme_provider.dart';
import 'state/user_provider.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => RoommateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'ClgJone',
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            builder: (context, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final ns = NotificationService();
                ns.init();
                ns.listenForeground(scaffoldMessengerKey);

                // OneSignal init with your app id (OneSignal dashboard)
                OneSignalService().init(
                  appId: '5c22329e-e3ff-4be7-9d03-76f7773bf8cb',
                );
              });
              return child ?? const SizedBox();
            },
          );
        },
      ),
    );
  }
}
