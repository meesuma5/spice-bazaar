import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/avatar_icon.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'dart:convert'; // For utf8.encode
import 'package:http/http.dart' as http;
import 'package:uicons/uicons.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/acc/login/'),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        // Handle successful login
				final User user = User.fromJson(json.decode(response.body));
        Navigator.pushReplacementNamed(context, '/discover', arguments: user);
			}
      else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
      // uncomment the above and comment the below in production
      // Navigator.pushReplacementNamed(context, '/discover');
    } catch (e) {
			print(e);
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lighterPurple,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarIcon(
                      icon: UIcons.regularRounded.hat_chef,
                      size: 60,
                      iconSize: 30,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to your account',
                      style: poppins(
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account yet?",
                          style: poppins(
                              style: const TextStyle(color: Colors.black87)),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Sign up",
                            style: poppins(
                                style: const TextStyle(
                                    color: mainPurple,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 4, right: 16, bottom: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12.0, left: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email address',
                                    style: poppins(
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    style: poppins(
                                        style: const TextStyle(fontSize: 12)),
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      hintText: 'your.email@example.com',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Password',
                                    style: poppins(
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    style: poppins(
                                        style: const TextStyle(fontSize: 12)),
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                      hintText: '••••••••',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox.adaptive(
                                      splashRadius: -8,
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                    ),
                                    Text("Remember me", style: poppins()),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/forgot-password'),
                                  child: const Text(
                                    'Forgot your password?',
                                    style: TextStyle(color: mainPurple),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(left: 12),
                              width: double.infinity,
                              child: CustomButton(
                                text: "Sign In",
                                onPressed: _signIn,
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: poppins(
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
