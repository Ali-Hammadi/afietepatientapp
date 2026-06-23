import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/widgets/articles_home_section.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_state.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';
import 'package:afiete/feature/home/presentation/widgets/assisment_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/emotions_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/music_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/top_doctor.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:afiete/feature/music_and_breathing/presentation/cubit/music_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// تحويل إلى StatefulWidget لإدارة دورة حياة الشاشة بشكل سليم
class FirstHomeScreen extends StatefulWidget {
  const FirstHomeScreen({super.key});

  @override
  State<FirstHomeScreen> createState() => _FirstHomeScreenState();
}

class _FirstHomeScreenState extends State<FirstHomeScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 الحل السحري: استدعاء البيانات فور إقلاع الشاشة بعد بناء أول إطار (Frame) بأمان
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articlesCubit = context.read<ArticlesCubit>();

      // نطلب المقالات فقط إذا كانت في الحالة الابتدائية ولم يتم جلبها مسبقاً لمنع التكرار
      if (articlesCubit.state is ArticlesInitial) {
        final assignmentsState = context.read<AssessmentsCubit>().state;
        final currentDiagnosis = _resolveClosestDiagnosis(assignmentsState);

        articlesCubit.getArticlesForHomeUseCase(
          userDiagnosis: currentDiagnosis,
        );
      }
    });
  }

  FeelingType? _selectedFeelingFromState(FeelingState state) {
    if (state is FeelingLoaded) return state.selectedFeeling;
    if (state is FeelingError) return state.selectedFeeling;
    return null;
  }

  String? _resolveClosestDiagnosis(AssessmentsState assignmentsState) {
    if (assignmentsState is! AssessmentsResultLoaded) {
      return null;
    }

    final result = assignmentsState.result;
    if (result.recommendedSpecialties.isNotEmpty) {
      return result.recommendedSpecialties.first;
    }

    if (result.severity.trim().isNotEmpty) {
      return result.severity;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<MusicCubit>(create: (_) => sl<MusicCubit>()..loadHub()),
          BlocProvider<FeelingCubit>(
              create: (_) => sl<FeelingCubit>()..loadFeelingHub()),
        ],
        child: MultiBlocListener(
          listeners: [
            // 1. مراقبة المشاعر لتحديث الموسيقى
            BlocListener<FeelingCubit, FeelingState>(
              listenWhen: (previous, current) =>
                  _selectedFeelingFromState(previous) !=
                  _selectedFeelingFromState(current),
              listener: (context, state) {
                final selectedFeeling = _selectedFeelingFromState(state);
                if (selectedFeeling == null) return;

                final musicState = context.read<MusicCubit>().state;
                if (musicState is MusicLoaded &&
                    musicState.selectedFeeling == selectedFeeling) {
                  return;
                }
                context.read<MusicCubit>().selectFeeling(selectedFeeling);
              },
            ),

            BlocListener<AssessmentsCubit, AssessmentsState>(
              listenWhen: (previous, current) =>
                  previous is! AssessmentsResultLoaded &&
                  current is AssessmentsResultLoaded,
              listener: (context, assignmentsState) {
                final currentDiagnosis =
                    _resolveClosestDiagnosis(assignmentsState);
                context.read<ArticlesCubit>().getArticlesForHomeUseCase(
                      userDiagnosis: currentDiagnosis,
                    );
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.padding),
            child: SingleChildScrollView(
              key: const PageStorageKey('first_home_scroll'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SettingsStrings.howAreYouFeelingToday,
                    style: AppStyles.headingSmall,
                  ),
                  const CustomEmotionsWidget(),
                  const CustomMusicWidget(),
                  const CustomAssignmentWidget(),
                  const SizedBox(height: 12),

                  Text(
                    SettingsStrings.topDoctorsTitle,
                    style: AppStyles.headingMedium,
                  ),

                  BlocBuilder<AssessmentsCubit, AssessmentsState>(
                    builder: (context, assignmentsState) {
                      List<DoctorEntity>? recommendedDoctors;
                      if (assignmentsState is AssessmentsResultLoaded) {
                        recommendedDoctors = assignmentsState.doctors;
                      }

                      return CustomTopDoctorsWidget(
                        specialtyId: null,
                        customDoctors: recommendedDoctors,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  Text(
                    SettingsStrings.bestArticlesForYou,
                    style: AppStyles.headingMedium,
                  ),

                  // بناء سيكشن المقالات بشكل نقي ومستقر دون تدخل برمجي جانبي (Side effects)
                  BlocBuilder<ArticlesCubit, ArticlesState>(
                    builder: (context, articlesState) {
                      if (articlesState is ArticlesLoading ||
                          articlesState is ArticlesInitial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (articlesState is ArticlesError) {
                        return const SizedBox.shrink();
                      }
                      return const ArticlesHomeSection();
                    },
                  ),
                  const SizedBox(height: AppStyles.padding * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
