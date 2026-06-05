import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/domain/usecases/articles_usecases.dart';

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
  bool _loadedAllArticles = false;

  // مؤشرات ترقيم الصفحات والتحكم بالتسلسل للمريض
  int _generalPage = 1;
  final int _pageSize = 10;
  bool _isFetchingMore = false;

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

  /// 🚀 جلب مقالات الصفحة الرئيسية بالتسلسل: أول 5 مقترحة -> أول 5 رائجة
  Future<void> loadArticlesForHome() async {
    emit(const ArticlesLoading());
    _currentIsForHome = true;
    _loadedAllArticles = false;
    _generalPage = 1;

    final List<ArticleEntity> compiledArticles = [];
    final Set<String> uniqueIds = {};

    // 1. جلب أول 5 مقالات مقترحة
    final recommendedResult = await getRecommendedArticlesUseCase();
    recommendedResult.fold(
      (failure) => null, // تجاوز الفشل بهدوء لحماية الواجهة
      (articles) {
        final limited = articles.take(5);
        for (var a in limited) {
          if (uniqueIds.add(a.id)) compiledArticles.add(a);
        }
      },
    );

    // 2. جلب أول 5 مقالات رائجة
    final trendingResult = await getTrendingArticlesUseCase();
    trendingResult.fold(
      (failure) => null,
      (articles) {
        final limited = articles.take(5);
        for (var a in limited) {
          if (uniqueIds.add(a.id)) compiledArticles.add(a);
        }
      },
    );

    _currentArticles = compiledArticles;
    emit(
        ArticlesLoaded(articles: List.from(compiledArticles), isForHome: true));
  }

  /// 🔄 جلب المجموعة الثالثة (المقالات العامة) وتطبيق الـ Pagination عند النزول لأسفل القائمة
  Future<void> loadMoreArticles() async {
    if (_isFetchingMore || _loadedAllArticles || !_currentIsForHome) return;

    _isFetchingMore = true;
    final result =
        await getAllArticlesUseCase(page: _generalPage, pageSize: _pageSize);

    result.fold(
      (failure) {
        _isFetchingMore = false;
        emit(ArticlesError(failure.errorMessage));
      },
      (newArticles) {
        _isFetchingMore = false;
        if (newArticles.isEmpty) {
          _loadedAllArticles = true;
          return;
        }

        final List<ArticleEntity> currentList =
            List.from(_currentArticles ?? []);
        final Set<String> existingIds = currentList.map((a) => a.id).toSet();

        bool hasAddedNew = false;
        for (var article in newArticles) {
          if (existingIds.add(article.id)) {
            currentList.add(article);
            hasAddedNew = true;
          }
        }

        if (!hasAddedNew) {
          _loadedAllArticles = true;
        } else {
          _generalPage++;
        }

        _currentArticles = currentList;
        emit(ArticlesLoaded(articles: currentList, isForHome: true));
      },
    );
  }

  /// 🏥 جلب مقالات طبيب محدد بشكل منفصل تماماً
  Future<void> loadArticlesByDoctor(String doctorId) async {
    emit(const ArticlesLoading());
    _currentIsForHome = false;
    _loadedAllArticles = true; // لا نقوم بعمل pagination هنا منعاً للتداخل

    final result = await getArticlesByDoctorUseCase(doctorId);
    result.fold(
      (failure) => emit(ArticlesError(failure.errorMessage)),
      (articles) {
        _currentArticles = articles;
        emit(ArticlesLoaded(articles: articles, isForHome: false));
      },
    );
  }

  /// 📄 جلب مقالة مفردة بكامل تفاصيلها من السيرفر
  Future<void> loadArticleById(String articleId) async {
    emit(const ArticlesLoading());
    final result = await getArticleByIdUseCase(articleId);
    result.fold(
      (failure) => emit(ArticlesError(failure.errorMessage)),
      (article) => emit(ArticleDetailsLoaded(article)),
    );
  }

  /// ❤️ التفاعل مع المقال (Like / Dislike / None) مع جلب النسخة المحدثة فوراً من السيرفر
  Future<void> reactToArticle(String articleId, String reaction) async {
    final result = await reactToArticleUseCase(articleId, reaction);
    result.fold(
      (failure) => emit(ArticlesError(failure.errorMessage)),
      (_) async {
        final fetchResult = await getArticleByIdUseCase(articleId);
        fetchResult.fold(
          (failure) => emit(ArticlesError(failure.errorMessage)),
          (updatedArticle) {
            _emitUpdatedArticle(updatedArticle);
          },
        );
      },
    );
  }

  void _emitUpdatedArticle(ArticleEntity updatedArticle) {
    if (_currentArticles != null && _currentArticles!.isNotEmpty) {
      _currentArticles = _currentArticles!
          .map((a) => a.id == updatedArticle.id ? updatedArticle : a)
          .toList();
      emit(ArticlesLoaded(
          articles: List.from(_currentArticles!),
          isForHome: _currentIsForHome));
    }

    if (state is ArticleDetailsLoaded) {
      emit(ArticleDetailsLoaded(updatedArticle));
    }
  }

  void resetArticles() {
    _currentArticles = null;
    _currentIsForHome = false;
    _loadedAllArticles = false;
    _generalPage = 1;
    emit(const ArticlesInitial());
  }
}
