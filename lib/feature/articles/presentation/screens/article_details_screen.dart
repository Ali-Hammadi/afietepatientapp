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
      // Load authoritative article from server
      final id = _id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ArticlesCubit>().loadArticleById(id);
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
        child: BlocBuilder<ArticlesCubit, ArticlesState>(builder: (context, state) {
          ArticleEntity? displayArticle = widget.article;

          if (state is ArticlesLoading) {
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

          if (state is ArticlesError) {
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
                Text('By ${article.doctor.name} • ${article.createdAt.toLocal()}'),
                const SizedBox(height: 12),
                if (article.imageUrl.isNotEmpty) Image.network(article.imageUrl, fit: BoxFit.cover),
                const SizedBox(height: 12),
                Text(article.content, style: AppStyles.bodyMedium),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.read<ArticlesCubit>().toggleLike(article),
                      icon: const Icon(Icons.thumb_up),
                      label: Text('${SettingsStrings.like} ${article.likesCount}'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ArticlesCubit>().toggleDislike(article),
                      icon: const Icon(Icons.thumb_down),
                      label: Text('${SettingsStrings.dislike} ${article.dislikesCount}'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
