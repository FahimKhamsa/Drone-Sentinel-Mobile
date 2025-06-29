// lib/presentation/shared_widgets/message_box.dart

import 'package:flutter/material.dart';

/// A custom modal message box to display alerts or confirmations.
/// Used instead of `alert()` or `confirm()`.
class MessageBox extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const MessageBox({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (onButtonPressed != null) {
              onButtonPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            buttonText,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper to show the message box as a dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return MessageBox(
          title: title,
          message: message,
          buttonText: buttonText,
          onButtonPressed:
              onButtonPressed ?? () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }
}
