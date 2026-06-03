// removed unused import

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afietepatientapp/feature/articles/domain/entities/article_entities.dart';
import 'package:afietepatientapp/feature/articles/domain/usecases/articles_usecases.dart';

part 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final GetArticlesForHomeUseCase getArticlesForHomeUseCase;
  final GetRecommendedArticlesUseCase getRecommendedArticlesUseCase;
  final GetTrendingArticlesUseCase getTrendingArticlesUseCase;
  final GetArticlesByDoctorUseCase getArticlesByDoctorUseCase;
  final GetAllArticlesUseCase getAllArticlesUseCase;
  final GetArticleByIdUseCase getArticleByIdUseCase;
  final LikeArticleUseCase likeArticleUseCase;
  final ReactToArticleUseCase reactToArticleUseCase;
  final DislikeArticleUseCase dislikeArticleUseCase;
  List<ArticleEntity>? _currentArticles;
  bool _currentIsForHome = false;
  String? _currentDoctorId;
  String? _currentUserDiagnosis;
  bool _loadedAllArticles = false;

  ArticlesCubit({
    required this.getArticlesForHomeUseCase,
    required this.getRecommendedArticlesUseCase,
    required this.getTrendingArticlesUseCase,
    required this.getArticlesByDoctorUseCase,
    required this.getAllArticlesUseCase,
    required this.getArticleByIdUseCase,
    required this.likeArticleUseCase,
    required this.reactToArticleUseCase,
    required this.dislikeArticleUseCase,
  }) : super(const ArticlesInitial());

  Future<void> loadArticlesForHome({String? userDiagnosis}) async {
    emit(const ArticlesLoading());
    _currentDoctorId = null;
    _loadedAllArticles = false;
    _currentUserDiagnosis = userDiagnosis;
    final result = await getArticlesForHomeUseCase(
      userDiagnosis: userDiagnosis,
      limit: 5,
    );

    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (
      articles,
    ) {
      _currentArticles = List<ArticleEntity>.from(articles);
      _currentIsForHome = true;
      emit(ArticlesLoaded(articles: _currentArticles!, isForHome: true));
    });
  }

  Future<void> loadArticlesByDoctor(String doctorId) async {
    emit(const ArticlesLoading());
    _currentDoctorId = doctorId;
    _loadedAllArticles = false;
    _currentUserDiagnosis = null;
    final result = await getArticlesByDoctorUseCase(doctorId);

    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (
      articles,
    ) {
      _currentArticles = List<ArticleEntity>.from(articles);
      _currentIsForHome = false;
      emit(ArticlesLoaded(articles: _currentArticles!, isForHome: false));
    });
  }

  Future<void> loadAllArticles({int page = 1, int pageSize = 10}) async {
    emit(const ArticlesLoading());
    _currentDoctorId = null;
    _currentUserDiagnosis = null;
    _loadedAllArticles = true;
    final result = await getAllArticlesUseCase(page: page, pageSize: pageSize);

    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (
      articles,
    ) {
      _currentArticles = List<ArticleEntity>.from(articles);
      _currentIsForHome = false;
      emit(ArticlesLoaded(articles: _currentArticles!, isForHome: false));
    });
  }

  Future<void> loadArticleById(String articleId) async {
    emit(const ArticlesLoading());
    final result = await getArticleByIdUseCase(articleId);

    result.fold(
      (failure) => emit(ArticlesError(failure.errorMessage)),
      (article) => emit(ArticleDetailsLoaded(article)),
    );
  }

  Future<void> loadRecommendedArticles() async {
    emit(const ArticlesLoading());
    final result = await getRecommendedArticlesUseCase();

    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (
      articles,
    ) {
      _currentArticles = List<ArticleEntity>.from(articles);
      _currentIsForHome = true;
      emit(ArticlesLoaded(articles: _currentArticles!, isForHome: true));
    });
  }

  Future<void> loadTrendingArticles() async {
    emit(const ArticlesLoading());
    final result = await getTrendingArticlesUseCase();

    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (
      articles,
    ) {
      _currentArticles = List<ArticleEntity>.from(articles);
      _currentIsForHome = false;
      emit(ArticlesLoaded(articles: _currentArticles!, isForHome: false));
    });
  }

  Future<void> reloadCurrent() async {
    if (_currentDoctorId != null) {
      await loadArticlesByDoctor(_currentDoctorId!);
      return;
    }

    if (_loadedAllArticles) {
      await loadAllArticles();
      return;
    }

    await loadArticlesForHome(userDiagnosis: _currentUserDiagnosis);
  }

  Future<void> toggleLike(ArticleEntity article) async {
    // Perform the reaction on the server, then fetch authoritative state.
    final reactResult = await reactToArticleUseCase(article.id, 'like');
    reactResult.fold((failure) => emit(ArticlesError(failure.errorMessage)), (_) async {
      final fetchResult = await getArticleByIdUseCase(article.id);
      fetchResult.fold((failure) => emit(ArticlesError(failure.errorMessage)), (updated) {
        _emitUpdatedArticle(updated);
      });
    });
  }

  Future<void> toggleDislike(ArticleEntity article) async {
    // Perform the reaction on the server, then fetch authoritative state.
    final reactResult = await reactToArticleUseCase(article.id, 'dislike');
    reactResult.fold((failure) => emit(ArticlesError(failure.errorMessage)), (_) async {
      final fetchResult = await getArticleByIdUseCase(article.id);
      fetchResult.fold((failure) => emit(ArticlesError(failure.errorMessage)), (updated) {
        _emitUpdatedArticle(updated);
      });
    });
  }

  Future<void> reactToArticle(String articleId, String reaction) async {
    final result = await reactToArticleUseCase(articleId, reaction);
    result.fold((failure) => emit(ArticlesError(failure.errorMessage)), (_) async {
      final fetchResult = await getArticleByIdUseCase(articleId);
      fetchResult.fold((failure) => emit(ArticlesError(failure.errorMessage)), (updated) {
        _emitUpdatedArticle(updated);
      });
    });
  }

  // helper removed — no local optimistic updates allowed; authoritative state fetched from server

  void _emitUpdatedArticle(ArticleEntity updatedArticle) {
    final currentArticles = _currentArticles;
    if (currentArticles != null && currentArticles.isNotEmpty) {
      final updatedArticles = currentArticles
          .map(
            (article) =>
                article.id == updatedArticle.id ? updatedArticle : article,
          )
          .toList(growable: false);
      _currentArticles = updatedArticles;
      emit(
        ArticlesLoaded(articles: updatedArticles, isForHome: _currentIsForHome),
      );
      return;
    }

    emit(ArticleDetailsLoaded(updatedArticle));
  }
}
