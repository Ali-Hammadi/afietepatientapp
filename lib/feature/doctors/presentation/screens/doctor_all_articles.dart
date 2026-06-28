import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/di/injection_container.dart'; // مسار الـ sl الخاص بك
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/articles/presentation/widgets/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorSpecialArticleScreen extends StatelessWidget {
  final String doctorUsername;
  final String? doctorName;

  const DoctorSpecialArticleScreen({
    super.key,
    required this.doctorUsername,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // فصل كامل: إنشاء نسخة Cubit مستقلة تنتهي بانتهاء الشاشة
    return BlocProvider<ArticlesCubit>(
      create: (context) =>
          sl<ArticlesCubit>()..loadArticlesByDoctor(doctorUsername),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${SettingsStrings.articlesByDoctorTitle}' '$doctorName'),
        ),
        body: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, state) {
            if (state is ArticlesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ArticlesLoaded) {
              // تصفية صارمة لضمان حصرية مقالات هذا الطبيب فقط
              final doctorArticles = state.articles
                  .where((article) =>
                      article.doctor.doctorUsername == doctorUsername)
                  .toList();

              if (doctorArticles.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد مقالات منشورة لهذا الطبيب حالياً.",
                    style: AppStyles.bodyMedium
                        .copyWith(color: colorScheme.outline),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppStyles.padding),
                itemCount: doctorArticles.length,
                itemBuilder: (context, index) {
                  final article = doctorArticles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ArticleCardWidget(
                      article: article,
                      flatMode: true,
                      onReadMore: () {
                        Navigator.pushNamed(
                          context,
                          MyRoutes.articleDetailsScreen,
                          arguments: article,
                        );
                      },
                    ),
                  );
                },
              );
            }

            if (state is ArticlesError) {
              return Center(
                child: Text(
                  state.message,
                  style:
                      AppStyles.bodyMedium.copyWith(color: colorScheme.error),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
