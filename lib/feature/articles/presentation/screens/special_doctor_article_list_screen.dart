import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/presentation/widgets/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpecialDoctorArticleListScreen extends StatefulWidget {
  final String? doctorUsername;
  final String? doctorName;
  final String? userDiagnosis;

  const SpecialDoctorArticleListScreen({
    super.key,
    this.doctorUsername,
    this.doctorName,
    this.userDiagnosis,
  });

  @override
  State<SpecialDoctorArticleListScreen> createState() =>
      _SpecialDoctorArticleListScreenState();
}

class _SpecialDoctorArticleListScreenState
    extends State<SpecialDoctorArticleListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // تم إلغاء طلب الـ API من هنا للاعتماد كلياً على الفلترة المحلية كما هو مطلوب.

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (widget.doctorUsername == null) {
          context.read<ArticlesCubit>().loadMoreArticles();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctorUsername != null
              ? '${SettingsStrings.articlesByDoctorTitle} ${widget.doctorName ?? SettingsStrings.doctorDefaultName}'
              : SettingsStrings.allArticlesTitle,
          style: AppStyles.headingMedium,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder: (context, state) {
          final cubit = context.read<ArticlesCubit>();
          final allArticles = cubit.currentCachedArticles;

          // الفلترة المحلية الصارمة حسب الـ Username
          List<ArticleEntity> displayArticles = [];
          if (widget.doctorUsername != null &&
              widget.doctorUsername!.trim().isNotEmpty) {
            displayArticles = allArticles
                .where((a) => a.doctor.doctorUsername == widget.doctorUsername)
                .toList();
          } else {
            displayArticles = allArticles;
          }

          if (state is ArticlesLoading && allArticles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (displayArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    SettingsStrings.noArticlesFound,
                    style: AppStyles.headingMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppStyles.padding),
            itemCount: displayArticles.length,
            itemBuilder: (context, index) {
              final article = displayArticles[index];

              return ArticleCardWidget(
                article: article,
                onDoctorTap: article.doctor.doctorUsername.trim().isNotEmpty
                    ? () {
                        // تجنب التوجيه لنفس شاشة الطبيب إذا كنا بداخلها بالفعل
                        if (widget.doctorUsername !=
                            article.doctor.doctorUsername) {
                          Navigator.pushNamed(
                            context,
                            MyRoutes.doctorInfoScreen,
                            arguments: article.doctor,
                          );
                        }
                      }
                    : null,
                onReadMore: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.articleDetailsScreen,
                    arguments: article,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
