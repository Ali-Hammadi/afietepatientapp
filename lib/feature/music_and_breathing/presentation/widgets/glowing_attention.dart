import 'package:flutter/material.dart';

class GlowingAttention extends StatelessWidget {
  final Widget child;
  final bool isGlowing;

  const GlowingAttention({
    super.key,
    required this.child,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      // إذا تم اختيار الشعور (isGlowing = true)، بيبدأ التأثير
      tween: Tween<double>(begin: 0.0, end: isGlowing ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutSine, // حركة ناعمة للضوء
      builder: (context, value, childWidget) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999), // حسب شكل العنصر تبعك
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary
                    .withValues(alpha: value * 0.6), // شفافية متغيرة
                blurRadius: value * 20, // انتشار الضوء
                spreadRadius: value * 4,
              ),
            ],
          ),
          child: childWidget,
        );
      },
      child: child,
    );
  }
}
