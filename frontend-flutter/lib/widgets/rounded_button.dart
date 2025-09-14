// lib/widgets/rounded_button.dart
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ nullable
  final double height;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.onPressed, // ✅ required + nullable = autorisé
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60C8B3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          minimumSize: Size(double.infinity, height),
        ),
        onPressed: onPressed, // ✅ accepte null -> bouton désactivé
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
