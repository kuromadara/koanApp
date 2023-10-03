import 'package:flutter/material.dart';
import 'package:koan/ui/constants.dart';

class LoadingDialog extends StatelessWidget {
  final String loadingText;

  const LoadingDialog({super.key, required this.loadingText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                kPrimaryColor,
              ), // Use your desired color here
            ),
            const SizedBox(width: 20.0),
            Text(
              loadingText,
              style: const TextStyle(
                color: kPrimaryColor, // Use your desired color here
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
