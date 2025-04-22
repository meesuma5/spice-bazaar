import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/services/storage_service.dart';
import 'package:spice_bazaar/widgets/avatar_icon.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:spice_bazaar/widgets/input_field.dart';
import 'dart:convert'; // For utf8.encode
import 'package:http/http.dart' as http;
import 'package:uicons/uicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uicons_updated/uicons.dart';

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
  String? _imageUrl;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  final StorageService _storageService = StorageService();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          // You now have the File object (_imageFile) which you can upload to Firebase Storage.
          print('Selected image path: ${_imageFile!.path} ${_imageFile!.isAbsolute}');
        });
        
        // Upload the file outside of setState
        try {
          String url = await _storageService.uploadFile(_imageFile!.path, _imageFile!);
          setState(() {
            _imageUrl = url;
            print(_imageUrl);
          });
        } catch (error) {
          print('Error uploading image: $error');
          if (error is http.Response) {
            print('Server response: ${error.body}');
          }
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _createAccount() async {
    // Validate fields
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/acc/register/'),
        body: {
          'username': username,
          'email': email,
          'password': password,
          'image_link': _imageUrl ?? '',
        },
      );
      if (response.statusCode == 201) {
        // Check if widget is still mounted before using context
        if (mounted) {
          // Navigate to login.
          var arguments = {
            "icon": UiconsRegular.user_chef,
            "message":
                "Welcome Aboard Chef! We're so happy to have you. Redirecting you to the login page.",
            "navigationRoute": "/login",
          };
          Navigator.pushReplacementNamed(
            context,
            '/confirmation',
            arguments: arguments,
          );
        }
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
        backgroundColor: lighterPurple,
        surfaceTintColor: lighterPurple,
        elevation: 0,
      ),
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
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : null,
                                child: _imageFile == null
                                    ? Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 40,
                                        color: Colors.grey[600],
                                      )
                                    : null,
                              ),
                            ),
                            if (_imageFile == null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Tap to select profile picture',
                                style: poppins(
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            InputField(
                              heading: 'Username',
                              fieldController: _usernameController,
                              hintText: 'chef_jamie',
                            ),
                            const SizedBox(height: 12),
                            InputField(
                                heading: 'Email Address',
                                fieldController: _emailController,
                                hintText: 'your.email@example.com',
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 12),
                            InputField(
                                heading: 'Password',
                                fieldController: _passwordController,
                                hintText: '••••••••',
                                obscureText: true,
                                maxLines: 1),
                            const SizedBox(height: 12),
                            InputField(
                                heading: 'Confirm Password',
                                fieldController: _confirmPasswordController,
                                hintText: '••••••••',
                                obscureText: true,
                                maxLines: 1),
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
                                onPressed: () async {
                                  _createAccount();
                                },
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
