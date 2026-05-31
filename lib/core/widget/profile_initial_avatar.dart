import 'package:flutter/material.dart';

class ProfileInitialAvatar extends StatelessWidget {
  final String? name;
  final double radius;

  const ProfileInitialAvatar({super.key, this.name, required this.radius});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = _resolveInitial(name);
    final fontSize = radius * 0.95;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _resolveInitial(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed.substring(0, 1).toUpperCase();
  }
}
