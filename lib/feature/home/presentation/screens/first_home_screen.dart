import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/articles/presentation/widgets/articles_home_section.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_state.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';
import 'package:afiete/feature/home/presentation/widgets/assisment_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/emotions_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/music_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/top_doctor.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articlesCubit = context.read<ArticlesCubit>();

      if (articlesCubit.state is ArticlesInitial) {
        articlesCubit.loadArticlesForHome();
      }
    });
  }

  FeelingType? _selectedFeelingFromState(FeelingState state) {
    if (state is FeelingLoaded) return state.selectedFeeling;
    if (state is FeelingError) return state.selectedFeeling;
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
                context.read<ArticlesCubit>().loadArticlesForHome();
              },
            ),
            BlocListener<ArticlesCubit, ArticlesState>(
              listenWhen: (previous, current) =>
                  current is ArticlesReactionError,
              listener: (context, state) {
                if (state is ArticlesReactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
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
                  BlocBuilder<ArticlesCubit, ArticlesState>(
                    builder: (context, articlesState) {
                      print("STATE = ${articlesState.runtimeType}");

                      if (articlesState is ArticlesLoading ||
                          articlesState is ArticlesInitial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (articlesState is ArticlesReactionError) {
                        return const ArticlesHomeSection();
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
