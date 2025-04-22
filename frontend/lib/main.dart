import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/screens/confirmation_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/log_in_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/save_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
	try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
	} catch (e) {
		print('Error initializing Firebase: $e');
	}
	
  runApp(const SpiceBazaarApp());
}

class SpiceBazaarApp extends StatelessWidget {
  const SpiceBazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spice Bazaar',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LogInScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/discover') {
          final user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) => MainAppScreen(user: user),
          );
        }
        if (settings.name == '/confirmation') {
          return MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              message: settings.arguments is Map
                  ? (settings.arguments as Map)['message'] as String?
                  : null,
              icon: settings.arguments is Map
                  ? (settings.arguments as Map)['icon'] as IconData?
                  : null,
              iconColor: settings.arguments is Map
                  ? (settings.arguments as Map)['iconColor'] as Color?
                  : null,
              messageColor: settings.arguments is Map
                  ? (settings.arguments as Map)['messageColor'] as Color?
                  : null,
              navigationRoute: settings.arguments is Map
                  ? (settings.arguments as Map)['navigationRoute'] as String?
                  : null,
            ),
          );
        }
        return null;
      },
    );
  }
}
