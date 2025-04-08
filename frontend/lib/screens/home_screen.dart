import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spice_bazaar/widgets/avatar_icon.dart';
import '../widgets/custom_button.dart';
import '../widgets/feature_card.dart';
import 'package:uicons/uicons.dart';
import 'package:spice_bazaar/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Spice Bazaar',
            style: poppins(
              style: const TextStyle(
                color: mainPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              AvatarIcon(
                icon: UIcons.regularRounded.hat_chef,
                size: 100,
                iconSize: 50,
              ),
              const SizedBox(height: 10),
              Text(
                'Share Your Culinary Creations',
                style: poppins(
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.25)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Discover, create, and share amazing recipes with fellow food enthusiasts from around the world.',
                style: poppins(
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    text: 'Log In',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    isOutlined: true,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              FeatureCard(
                  icon: UIcons.regularRounded.add_document,
                  title: 'Create',
                  description: 'Upload your favorite recipes',
                  onTap: () {}),
              FeatureCard(
                  icon: UIcons.regularRounded.search,
                  title: 'Discover',
                  description: 'Find recipes from others',
                  onTap: () {}),
              FeatureCard(
                  icon: UIcons.regularRounded.heart,
                  title: 'Save',
                  description: 'Bookmark your favorites',
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
