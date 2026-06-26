import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/domain/usecases/articles_usecases.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final GetRecommendedArticlesUseCase getRecommendedArticlesUseCase;
  final GetTrendingArticlesUseCase getTrendingArticlesUseCase;
  final GetAllArticlesUseCase getAllArticlesUseCase;
  final GetArticlesByDoctorUseCase getArticlesByDoctorUseCase;
  final GetArticleByIdUseCase getArticleByIdUseCase;
  final ReactToArticleUseCase reactToArticleUseCase;

  ArticlesCubit({
    required this.getRecommendedArticlesUseCase,
    required this.getTrendingArticlesUseCase,
    required this.getAllArticlesUseCase,
    required this.getArticlesByDoctorUseCase,
    required this.getArticleByIdUseCase,
    required this.reactToArticleUseCase,
  }) : super(const ArticlesInitial());

  // =========================
  // Internal cache/state
  // =========================
  List<ArticleEntity>? _currentArticles;
  String _currentSource = "home";

  int _page = 1;
  final int _pageSize = 10;
  bool _isFetchingMore = false;
  bool _hasLoadedAll = false;

  // =========================
  // HOME PIPELINE
  // recommended → trending → all
  // =========================
  Future<void> loadArticlesForHome() async {
    emit(const ArticlesLoading(step: "recommended"));
    _currentSource = "home";

    final List<ArticleEntity> compiled = [];
    final Set<String> ids = {};

// =========================
// 1️⃣ Recommended
// =========================
    final recommendedResult = await getRecommendedArticlesUseCase();

    recommendedResult.fold(
      (failure) {
        print("Recommended error: ${failure.errorMessage}");
      },
      (articles) {
        if (articles.isNotEmpty) {
          for (var a in articles.take(5)) {
            if (ids.add(a.id)) {
              compiled.add(a);
            }
          }
        }
      },
    );

    if (compiled.isEmpty) {
      emit(const ArticlesLoading(step: "trending"));

      final trendingResult = await getTrendingArticlesUseCase();

      trendingResult.fold(
        (failure) {
          print("Trending error: ${failure.errorMessage}");
        },
        (articles) {
          if (articles.isNotEmpty) {
            for (var a in articles.take(5)) {
              if (ids.add(a.id)) {
                compiled.add(a);
              }
            }
          }
        },
      );

      // 3️⃣ Final fallback → All
      if (compiled.isEmpty) {
        emit(const ArticlesLoading(step: "all"));

        final allResult = await getAllArticlesUseCase(
          page: 1,
          pageSize: 10,
        );

        allResult.fold(
          (failure) {
            emit(ArticlesError(
              message: failure.errorMessage,
              step: "all",
            ));
          },
          (articles) {
            if (articles.isNotEmpty) {
              for (var a in articles) {
                if (ids.add(a.id)) {
                  compiled.add(a);
                }
              }
            }
          },
        );
      }
    }

    // Empty check
    if (compiled.isEmpty) {
      emit(const ArticlesEmpty(source: "home"));
      return;
    }

    emit(ArticlesLoaded(
      articles: List.from(compiled),
      source: "home",
    ));
  }

  // =========================
  // PAGINATION (ALL ARTICLES)
  // =========================
  Future<void> loadMoreArticles() async {
    if (_isFetchingMore || _hasLoadedAll || _currentSource != "home") return;

    _isFetchingMore = true;

    final result = await getAllArticlesUseCase(
      page: _page,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) {
        _isFetchingMore = false;
        emit(ArticlesError(
          message: failure.errorMessage,
          step: "all",
        ));
      },
      (newArticles) {
        _isFetchingMore = false;

        if (newArticles.isEmpty) {
          _hasLoadedAll = true;
          return;
        }

        final current = List<ArticleEntity>.from(_currentArticles ?? []);
        final existingIds = current.map((e) => e.id).toSet();

        bool added = false;

        for (var a in newArticles) {
          if (existingIds.add(a.id)) {
            current.add(a);
            added = true;
          }
        }

        if (added) {
          _page++;
        } else {
          _hasLoadedAll = true;
        }

        _currentArticles = current;

        emit(ArticlesLoaded(
          articles: List.from(current),
          source: "home",
        ));
      },
    );
  }

  // =========================
  // DOCTOR ARTICLES
  // =========================
  Future<void> loadArticlesByDoctor(String doctorUsername) async {
    emit(const ArticlesLoading(step: "doctor"));
    _currentSource = "doctor";

    final result = await getArticlesByDoctorUseCase(doctorUsername);

    result.fold(
      (failure) {
        emit(ArticlesError(
          message: failure.errorMessage,
          step: "doctor",
        ));
      },
      (articles) {
        _currentArticles = articles;

        emit(ArticlesLoaded(
          articles: articles,
          source: "doctor",
        ));
      },
    );
  }

  // =========================
  // ARTICLE DETAILS
  // =========================
  Future<void> loadArticleById(String articleId) async {
    emit(const ArticleDetailsLoading());

    final result = await getArticleByIdUseCase(articleId);

    result.fold(
      (failure) => emit(ArticlesError(
        message: failure.errorMessage,
        step: "details",
      )),
      (article) => emit(ArticleDetailsLoaded(article)),
    );
  }

  // =========================
  // REACTIONS (LIKE / DISLIKE)
  // =========================
  Future<void> reactToArticle(String articleId, String reaction) async {
    final result = await reactToArticleUseCase(articleId, reaction);

    result.fold(
      (failure) => emit(ArticlesError(
        message: failure.errorMessage,
        step: "reaction",
      )),
      (_) async {
        final updated = await getArticleByIdUseCase(articleId);

        updated.fold(
          (failure) => emit(ArticlesError(
            message: failure.errorMessage,
            step: "reaction-refresh",
          )),
          (article) => _updateLocal(article),
        );
      },
    );
  }

  // =========================
  // INTERNAL UPDATE
  // =========================
  void _updateLocal(ArticleEntity updated) {
    if (_currentArticles != null) {
      _currentArticles = _currentArticles!
          .map((a) => a.id == updated.id ? updated : a)
          .toList();

      emit(ArticlesLoaded(
        articles: List.from(_currentArticles!),
        source: _currentSource,
      ));
    }

    if (state is ArticleDetailsLoaded) {
      emit(ArticleDetailsLoaded(updated));
    }
  }

  // =========================
  // RESET
  // =========================
  void reset() {
    _currentArticles = null;
    _currentSource = "home";
    _page = 1;
    _isFetchingMore = false;
    _hasLoadedAll = false;

    emit(const ArticlesInitial());
  }
}
