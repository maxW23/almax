import 'package:flutter/material.dart';

class PromoteButton extends StatelessWidget {
  const PromoteButton({
    super.key,
    this.label = 'Promote',
    this.onPressed,
    this.isCompleted = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 12,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isCompleted;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60, minHeight: 20),
      decoration: BoxDecoration(
        // Match Android vector gradient: #AAB5FF -> (alpha F2)#2B7AFE -> #2B7AFE
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFAAB5FF),
            Color(0xF22B7AFE), // ARGB: F2 alpha for a strong stop around 80%
            Color(0xFF2B7AFE),
          ],
          stops: [0.0, 0.8, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: const Size(60, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
