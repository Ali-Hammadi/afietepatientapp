// lib/feature/courses/presentation/screens/courses_screen.dart
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/widget/custom_button.dart';

import 'package:afiete/feature/chat/presentation/navigator/chat_navigator.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/cources/presentation/cubit/cources_cubit.dart';
import 'package:afiete/feature/cources/presentation/cubit/cources_state.dart';
import 'package:afiete/feature/cources/presentation/widgets/active_cource_card.dart';
import 'package:afiete/feature/cources/presentation/widgets/archive_cource_card.dart';

import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late CoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CoursesCubit>();
    if (_cubit.state is CoursesInitial) {
      _cubit.loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ✅ استخدام backgroundColor من الـ theme
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'My Treatment Courses',
                  style: AppStyles.headingMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ✅ Content
              Expanded(
                child: BlocConsumer<CoursesCubit, CoursesState>(
                  listener: (context, state) {
                    if (state is CoursesError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CoursesLoading || state is CoursesInitial) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      );
                    }

                    if (state is CoursesError) {
                      return _buildErrorState(colorScheme, state.message);
                    }

                    if (state is CoursesLoaded) {
                      return _buildLoadedState(state, colorScheme);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// في CoursesScreen - إضافة retry button
  Widget _buildErrorState(ColorScheme colorScheme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: AppStyles.headingSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
              onPressed: () => _cubit.loadCourses(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(CoursesLoaded state, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () => _cubit.loadCourses(forceRefresh: true),
      color: colorScheme.primary,
      backgroundColor: Theme.of(context).cardColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // ✅ Active Course Section
          if (state.activeCourse != null) ...[
            _SectionHeader(
              icon: Icons.favorite_rounded,
              title: 'Active Course',
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _SlideInWrapper(
              delay: 0,
              child: ActiveCourseCard(
                course: state.activeCourse!,
                doctor: _cubit.findDoctorByUsername(
                  state.activeCourse!.doctorUsername,
                ),
                onViewChat: () => _openChat(state.activeCourse!, state.doctors),
                onEndCourse: () => _confirmEndCourse(state.activeCourse!),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ✅ Archived Courses Section
          _SectionHeader(
            icon: Icons.archive_outlined,
            title: 'Completed Courses',
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            count: state.archivedCourses.length,
          ),
          const SizedBox(height: 8),

          if (state.archivedCourses.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No completed courses yet',
                    style: AppStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            ...state.archivedCourses.asMap().entries.map(
                  (entry) => _SlideInWrapper(
                    delay: (entry.key + 1) * 100,
                    child: ArchivedCourseCard(
                      course: entry.value,
                      doctor: _cubit.findDoctorByUsername(
                        entry.value.doctorUsername,
                      ),
                      onViewChat: () => _openChat(
                        entry.value,
                        state.doctors,
                        readOnly: true,
                      ),
                      onRequestContinue: () =>
                          _confirmRequestContinue(entry.value),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _openChat(CourseEntity course, List<DoctorEntity> doctors,
      {bool readOnly = true}) {
    final doctor = _cubit.findDoctorByUsername(course.doctorUsername);
    ChatNavigator.openCourseChat(
      context,
      courseId: course.id.toString(),
      doctorName: doctor?.name ?? 'Doctor',
      currentUserId: course.patientUsername,
      doctorImageUrl: doctor?.imageUrl,
      readOnly: readOnly,
    );
  }

  void _confirmEndCourse(CourseEntity course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Course'),
        content: const Text(
          'Are you sure you want to end this treatment course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _cubit.endCourse(course.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Course ended successfully'
                          : 'Failed to end course',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Course'),
          ),
        ],
      ),
    );
  }

  void _confirmRequestContinue(CourseEntity course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request Continue'),
        content: const Text(
          'Would you like to request continuing this treatment course with your doctor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _cubit.requestContinue(course.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Continue request sent to your doctor'
                          : 'Failed to send request',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final int? count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppStyles.headingSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: AppStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SlideInWrapper extends StatefulWidget {
  final Widget child;
  final int delay;

  const _SlideInWrapper({required this.child, required this.delay});

  @override
  State<_SlideInWrapper> createState() => _SlideInWrapperState();
}

class _SlideInWrapperState extends State<_SlideInWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}

// ✅ Extension على List
extension ListExtension<T> on List<T> {
  Map<int, T> asMap() {
    return asMap();
  }
}
