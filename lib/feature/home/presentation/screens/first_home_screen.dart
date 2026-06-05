import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/constants/feeling_type.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/presentation/cubits/assisments_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/widgets/articles_home_section.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';
import 'package:afiete/feature/home/presentation/widgets/assisment_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/emotions_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/music_widget.dart';
import 'package:afiete/feature/home/presentation/widgets/top_doctor.dart';
import 'package:afiete/feature/relax/presentation/cubit/music_cubit.dart';
// تذكر استيراد الـ Cubit الخاص بالأطباء إذا لم يكن مستورداً داخل الـ CustomTopDoctorsWidget
// import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirstHomeScreen extends StatelessWidget {
  const FirstHomeScreen({super.key});

  FeelingType? _selectedFeelingFromState(FeelingState state) {
    if (state is FeelingLoaded) {
      return state.selectedFeeling;
    }
    if (state is FeelingError) {
      return state.selectedFeeling;
    }
    return null;
  }

  String? _resolveClosestDiagnosis(AssismentsState assignmentsState) {
    if (assignmentsState is! AssismentsResultLoaded) {
      return null;
    }

    final AssismentEntity result = assignmentsState.result;
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
            create: (_) => sl<FeelingCubit>()..loadFeelingHub(),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            // 1. الـ Listener الخاص بالمشاعر والموسيقا
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

            // 2. 🔥 الحل السحري: الـ Listener المركزي المسؤول عن تحديث الأطباء والمقالات بناءً على التشخيص
            // هذا يضمن أن يتم استدعاء الـ APIs مرة واحدة فقط عند تغير حالة التشخيص وليس مع كل Rebuild للـ UI
            BlocListener<AssismentsCubit, AssismentsState>(
              listener: (context, assignmentsState) {
                final currentDiagnosis =
                    _resolveClosestDiagnosis(assignmentsState);

                // نقوم بجلب المقالات بشكل آمن هنا خارج الـ Build Cycle
                context.read<ArticlesCubit>().getArticlesForHomeUseCase(
                      userDiagnosis: currentDiagnosis,
                    );

                // 💡 إذا كان الـ CustomTopDoctorsWidget يعتمد على تفعيل يدوي، يمكنك تحريضه هنا أيضاً:
                // context.read<DoctorsCubit>().getRecommendedDoctors(specialty: currentDiagnosis);
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
                    textAlign: TextAlign.start,
                  ),

                  const CustomEmotionsWidget(),
                  const CustomAssignmentWidget(),
                  const CustomMusicWidget(),

                  Text(
                    SettingsStrings.topDoctorsTitle,
                    style: AppStyles.headingMedium,
                  ),

                  // عرض الأطباء بناءً على حالة التشخيص الحالية بسلامة
                  BlocBuilder<AssismentsCubit, AssismentsState>(
                    builder: (context, assignmentsState) {
                      return CustomTopDoctorsWidget(
                        specialty: _resolveClosestDiagnosis(assignmentsState),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // سيكشن المقالات مستقر ومحمي تماماً الآن لأن البيانات تُطلب عبر الـ Listener في الأعلى
                  BlocBuilder<AssismentsCubit, AssismentsState>(
                    builder: (context, assignmentsState) {
                      final currentDiagnosis =
                          _resolveClosestDiagnosis(assignmentsState);

                      return BlocConsumer<ArticlesCubit, ArticlesState>(
                        listenWhen: (previous, current) =>
                            current is ArticlesInitial,
                        listener: (context, state) {
                          if (state is ArticlesInitial) {
                            context
                                .read<ArticlesCubit>()
                                .getArticlesForHomeUseCase(
                                  userDiagnosis: currentDiagnosis,
                                );
                          }
                        },
                        buildWhen: (previous, current) {
                          if (current is ArticlesInitial) {
                            context
                                .read<ArticlesCubit>()
                                .getArticlesForHomeUseCase(
                                  userDiagnosis: currentDiagnosis,
                                );
                            return false;
                          }
                          return true;
                        },
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
