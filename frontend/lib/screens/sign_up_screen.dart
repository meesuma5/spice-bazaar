import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/widgets/avatar_icon.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'dart:convert'; // For utf8.encode
import 'package:http/http.dart' as http;
import 'package:uicons/uicons.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  String? _errorMessage;

  Future<void> _createAccount() async {
    // Validate fields
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage =
            'You must agree to the Terms of Service and Privacy Policy';
      });
      return;
    }

    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    try {
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/signup'),
        body: {
          'username': username,
          'email': email,
          'password': hashedPassword,
        },
      );

      if (response.statusCode == 201) {
        // Handle successful account creation
        Navigator.pushReplacementNamed(context, '/discover');
      } else {
        setState(() {
          _errorMessage = 'Failed to create account. Please try again.';
        });
      }
    } catch (e) {
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
                      'Create your account',
                      style: poppins(
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: poppins(
                              style: const TextStyle(color: Colors.black87)),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            "Sign in",
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: poppins(
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              style:
                                  poppins(style: const TextStyle(fontSize: 12)),
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: 'chef_jamie',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Email address',
                              style: poppins(
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              style:
                                  poppins(style: const TextStyle(fontSize: 12)),
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'your.email@example.com',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
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
                              style:
                                  poppins(style: const TextStyle(fontSize: 12)),
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                hintText: '••••••••',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Confirm Password',
                              style: poppins(
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              style:
                                  poppins(style: const TextStyle(fontSize: 12)),
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                hintText: '••••••••',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: poppins(
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12)),
                                        children: const [
                                          TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                              text: 'Terms of Service',
                                              style:
                                                  TextStyle(color: mainPurple)),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                              text: 'Privacy Policy',
                                              style:
                                                  TextStyle(color: mainPurple)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: "Create account",
                                onPressed: _createAccount,
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
