import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart'; // مسار الـ sl
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final ArticleEntity? article;
  final String? articleId;

  const ArticleDetailsScreen({super.key, this.article, this.articleId});

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  late final String? _id;

  @override
  void initState() {
    super.initState();
    _id = widget.article?.id ?? widget.articleId;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // هنا يتم عزل تفاصيل المقال في نسخة منفصلة لا تلمس الـ Home
    return BlocProvider<ArticlesCubit>(
      create: (context) {
        final cubit = sl<ArticlesCubit>();
        if (_id != null) {
          cubit.getAllArticlesUseCase;
        }
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(SettingsStrings.allArticlesTitle),
          centerTitle: true,
        ),
        body: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, state) {
            if (state is ArticlesLoading || state is ArticleDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            ArticleEntity? article;
            if (state is ArticleDetailsLoaded) {
              article = state.article;
            } else if (widget.article != null) {
              article = widget.article;
            }

            if (article == null) {
              return const Center(child: Text("تعذر تحميل بيانات المقال"));
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppStyles.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        article.imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    article.title,
                    style: AppStyles.headingMedium
                        .copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${SettingsStrings.by} ${article.doctor.name}',
                    style: AppStyles.bodyMedium
                        .copyWith(color: colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.content,
                    style: AppStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: article.isLikedByUser
                              ? Colors.blue.shade100
                              : null,
                        ),
                        onPressed: () =>
                            context.read<ArticlesCubit>().reactToArticle(
                                  article!.id,
                                  article.isLikedByUser ? 'none' : 'like',
                                ),
                        icon: Icon(Icons.thumb_up,
                            color: article.isLikedByUser ? Colors.blue : null),
                        label: Text(
                            '${SettingsStrings.like} ${article.likesCount}'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: article.isDislikedByUser
                              ? Colors.red.shade100
                              : null,
                        ),
                        onPressed: () =>
                            context.read<ArticlesCubit>().reactToArticle(
                                  article!.id,
                                  article.isDislikedByUser ? 'none' : 'dislike',
                                ),
                        icon: Icon(Icons.thumb_down,
                            color:
                                article.isDislikedByUser ? Colors.red : null),
                        label: Text(
                            '${SettingsStrings.dislike} ${article.dislikesCount}'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
