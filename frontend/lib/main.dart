import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spice_bazaar/screens/add_recipe.dart';
import 'package:spice_bazaar/screens/my_recipes.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/log_in_screen.dart';
import 'screens/create_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/save_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/addrecipe': (context) => const AddRecipeScreen(),
        '/discover': (context) => const MainAppScreen(),
        '/save': (context) => const SaveScreen(),
        '/my_recipes': (context) => const MyRecipesScreen(),
      },
    );
  }
}
