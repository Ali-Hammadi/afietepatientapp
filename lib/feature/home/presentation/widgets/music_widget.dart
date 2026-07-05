// lib/feature/home/presentation/widgets/music_widget.dart
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/music_and_breathing/presentation/cubit/music_cubit.dart';
import 'package:afiete/feature/music_and_breathing/presentation/screens/music_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomMusicWidget extends StatefulWidget {
  const CustomMusicWidget({super.key});

  @override
  State<CustomMusicWidget> createState() => _CustomMusicWidgetState();
}

class _CustomMusicWidgetState extends State<CustomMusicWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize الـ controller أولاً
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ✅ Initialize الـ animation ثانياً
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // التحقق من الحالة الابتدائية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<MusicCubit>().state;
      _manageGlowEffect(state);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _manageGlowEffect(MusicState state) {
    if (state is MusicLoaded && state.hasSavedFeeling) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<MusicCubit, MusicState>(
      listener: (context, state) {
        _manageGlowEffect(state);
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glowValue = _glowAnimation.value;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppStyles.padding,
              horizontal: 2,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      colorScheme.primaryContainer.withValues(alpha: 0.45),
                      colorScheme.primaryContainer.withValues(alpha: 0.8),
                      glowValue,
                    )!,
                    Color.lerp(
                      theme.cardColor,
                      colorScheme.primaryContainer.withValues(alpha: 0.55),
                      glowValue * 0.6,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Color.lerp(
                    colorScheme.primary.withValues(alpha: 0.2),
                    colorScheme.primary.withValues(alpha: 0.75),
                    glowValue,
                  )!,
                  width: 1.0 + (glowValue * 1.2),
                ),
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: 0.08 + (glowValue * 0.28),
                    ),
                    blurRadius: 8 + (glowValue * 20),
                    spreadRadius: glowValue * 3,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: glowValue * 0.18,
                    ),
                    blurRadius: 24 + (glowValue * 18),
                    spreadRadius: glowValue * 2,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.library_music_rounded,
              color: colorScheme.primary,
            ),
          ),
          title: Text(
            SettingsStrings.relax,
            style: AppStyles.headingSmall.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            SettingsStrings.musicSubtitle,
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MusicCubit>(),
                  child: const MusicHubScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
