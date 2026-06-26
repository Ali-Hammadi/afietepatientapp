import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/articles/presentation/widgets/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesHomeSection extends StatelessWidget {
  final String? userDiagnosis;

  const ArticlesHomeSection({super.key, this.userDiagnosis});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticlesCubit, ArticlesState>(
      builder: (context, state) {
        if (state is ArticlesLoading) {
          return SizedBox(
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ArticlesLoaded && state.articles.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: state.articles
                    .map(
                      (article) => ArticleCardWidget(
                        article: article,
                        onDoctorTap:
                            article.doctor.doctorUsername.trim().isNotEmpty
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      MyRoutes.doctorInfoScreen,
                                      arguments: article.doctor,
                                    );
                                  }
                                : null,
                        onReadMore: () {},
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      MyRoutes.articlesListScreen,
                      arguments: {'userDiagnosis': userDiagnosis},
                    );
                  },
                  child: Text(SettingsStrings.seeAll),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }

        if (state is ArticlesLoaded && state.articles.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(AppStyles.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SettingsStrings.bestArticlesForYou,
                  style: AppStyles.headingMedium,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 56,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        SettingsStrings.noArticlesFound,
                        style: AppStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ArticlesError) {
          return Padding(
            padding: EdgeInsets.all(AppStyles.padding),
            child: Center(child: Text(state.message)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
