import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:equatable/equatable.dart';

abstract class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();
}

class ArticlesLoading extends ArticlesState {
  final String step;

  /// recommended | trending | all | doctor | details | reaction
  const ArticlesLoading({required this.step});

  @override
  List<Object?> get props => [step];
}

class ArticlesLoaded extends ArticlesState {
  final List<ArticleEntity> articles;
  final String source;

  /// source: home | doctor | all
  const ArticlesLoaded({
    required this.articles,
    required this.source,
  });

  @override
  List<Object?> get props => [articles, source];
}

class ArticlesEmpty extends ArticlesState {
  final String source;

  const ArticlesEmpty({required this.source});

  @override
  List<Object?> get props => [source];
}

class ArticlesError extends ArticlesState {
  final String message;
  final String step;

  const ArticlesError({
    required this.message,
    required this.step,
  });

  @override
  List<Object?> get props => [message, step];
}

class ArticleDetailsLoading extends ArticlesState {
  const ArticleDetailsLoading();
}

class ArticleDetailsLoaded extends ArticlesState {
  final ArticleEntity article;

  const ArticleDetailsLoaded(this.article);

  @override
  List<Object?> get props => [article];
}

class ArticleReactionUpdated extends ArticlesState {
  final ArticleEntity article;

  const ArticleReactionUpdated(this.article);

  @override
  List<Object?> get props => [article];
}

class ArticlesReactionError extends ArticlesState {
  final String message;
  final String source;

  const ArticlesReactionError({
    required this.message,
    required this.source,
  });
}
