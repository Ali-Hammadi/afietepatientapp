import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
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
    if (_id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تصحيح: استدعاء دالة جلب المقال المنفرد بواسطة الـ ID بدلاً من مقالات الطبيب
        context.read<ArticlesCubit>().loadArticleById(_id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_id == null && widget.article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Article not provided')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.article?.title ?? 'Article')),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, state) {
            ArticleEntity? displayArticle = widget.article;

            if (state is ArticlesLoading && displayArticle == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ArticleDetailsLoaded) {
              displayArticle = state.article;
            }

            if (state is ArticlesLoaded) {
              final found = state.articles.firstWhere(
                (a) => a.id == _id,
                orElse: () => displayArticle ?? state.articles.first,
              );
              displayArticle = found;
            }

            if (state is ArticlesError && displayArticle == null) {
              return Center(child: Text(state.message));
            }

            if (displayArticle == null) {
              return const Center(child: Text('Article not available'));
            }

            final article = displayArticle;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: AppStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                      'By ${article.doctor.name} • ${article.createdAt.toLocal()}'),
                  const SizedBox(height: 12),
                  if (article.imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (c, e, s) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(article.content, style: AppStyles.bodyMedium),
                  const SizedBox(height: 20),
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
                                  article.id,
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
                                  article.id,
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
