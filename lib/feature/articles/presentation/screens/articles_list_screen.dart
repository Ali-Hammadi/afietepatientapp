import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/articles/presentation/widgets/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticlesListScreen extends StatefulWidget {
  final String? doctorUsername;
  final String? doctorName;
  final String? userDiagnosis;

  const ArticlesListScreen({
    super.key,
    this.doctorUsername,
    this.doctorName,
    this.userDiagnosis,
  });

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadArticles();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (widget.doctorUsername == null) {
          context.read<ArticlesCubit>().loadMoreArticles();
        }
      }
    });
  }

  void _loadArticles() {
    final cubit = context.read<ArticlesCubit>();
    if (widget.doctorUsername != null) {
      cubit.loadArticlesByDoctor(widget.doctorUsername!);
    } else {
      return;
    }
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
          if (state is ArticlesLoading &&
              (_scrollController.hasClients == false ||
                  _scrollController.position.pixels == 0)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ArticlesLoaded) {
            if (state.articles.isEmpty) {
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
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return ArticleCardWidget(
                  article: article,
                  onDoctorTap: article.doctor.doctorUsername.trim().isNotEmpty
                      ? () {
                          Navigator.pushNamed(
                            context,
                            MyRoutes.doctorInfoScreen,
                            arguments: article.doctor,
                          );
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
          }

          if (state is ArticlesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: AppStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    widget: Text(
                      SettingsStrings.retry,
                      style: AppStyles.bodyMedium.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: _loadArticles,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
