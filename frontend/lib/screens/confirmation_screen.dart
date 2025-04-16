import 'package:flutter/material.dart';
import 'dart:async';

import 'package:spice_bazaar/constants.dart';

class ConfirmationScreen extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? message;
  final Color? messageColor;
  final String? navigationRoute;

  const ConfirmationScreen({
    super.key,
    this.icon,
    this.iconColor,
    this.message,
    this.messageColor,
    this.navigationRoute,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.navigationRoute != null) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(widget.navigationRoute!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: lighterPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon ?? Icons.check_circle_outline,
                size: 80,
                color: widget.iconColor ?? mainPurple,
              ),
              const SizedBox(height: 24),
              Text(
                widget.message ??
                    "Process Completed Successfully! Please wait while we process the data",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: widget.messageColor ?? mainPurple,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
