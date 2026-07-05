import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/domain/usecases/articles_usecases.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final GetRecommendedArticlesUseCase getRecommendedArticlesUseCase;
  final GetTrendingArticlesUseCase getTrendingArticlesUseCase;
  final GetAllArticlesUseCase getAllArticlesUseCase;
  final GetArticlesByDoctorUseCase getArticlesByDoctorUseCase;
  final ReactToArticleUseCase reactToArticleUseCase;

  ArticlesCubit({
    required this.getRecommendedArticlesUseCase,
    required this.getTrendingArticlesUseCase,
    required this.getAllArticlesUseCase,
    required this.getArticlesByDoctorUseCase,
    required this.reactToArticleUseCase,
  }) : super(const ArticlesInitial());

  // ==========================================
  // 1. Dual-Cache System لمنع التعارض
  // ==========================================
  String _currentSource = "home"; // 'home' or 'doctor'
  final int _pageSize = 10;

  // كاش الصفحة الرئيسية
  List<ArticleEntity>? _homeArticles;
  int _homePage = 1;
  bool _homeIsFetchingMore = false;
  bool _homeHasLoadedAll = false;

  // كاش مقالات الطبيب
  List<ArticleEntity>? _doctorArticles;
  int _doctorPage = 1;
  bool _doctorIsFetchingMore = false;
  bool _doctorHasLoadedAll = false;

  // ==========================================
  // 2. Dynamic Getters & Setters
  // ==========================================
  List<ArticleEntity>? get _currentArticles =>
      _currentSource == "home" ? _homeArticles : _doctorArticles;

  set _currentArticles(List<ArticleEntity>? value) {
    if (_currentSource == "home") {
      _homeArticles = value;
    } else {
      _doctorArticles = value;
    }
  }

  int get _page => _currentSource == "home" ? _homePage : _doctorPage;
  set _page(int value) {
    if (_currentSource == "home") {
      _homePage = value;
    } else {
      _doctorPage = value;
    }
  }

  bool get _isFetchingMore =>
      _currentSource == "home" ? _homeIsFetchingMore : _doctorIsFetchingMore;
  set _isFetchingMore(bool value) {
    if (_currentSource == "home") {
      _homeIsFetchingMore = value;
    } else {
      _doctorIsFetchingMore = value;
    }
  }

  bool get _hasLoadedAll =>
      _currentSource == "home" ? _homeHasLoadedAll : _doctorHasLoadedAll;
  set _hasLoadedAll(bool value) {
    if (_currentSource == "home") {
      _homeHasLoadedAll = value;
    } else {
      _doctorHasLoadedAll = value;
    }
  }

  // Getter للوصول للمقالات محلياً من قبل الشاشات الأخرى بدون كسر الحالة
  List<ArticleEntity> get currentCachedArticles => _currentArticles ?? [];

  // =========================
  // HOME PIPELINE
  // =========================
  Future<void> refreshArticlesOnLanguageChange() async {
    reset(); // تصفير الكاش
    await loadArticlesForHome();
  }

  Future<void> loadArticlesForHome() async {
    _currentSource = "home"; // تأكيد توجيه المؤشر للهوم

    // Cache Guard: منع إعادة التحميل ومسح الشاشة إذا كانت البيانات موجودة مسبقاً
    if (_homeArticles != null && _homeArticles!.isNotEmpty) {
      if (state is! ArticlesLoaded ||
          (state is ArticlesLoaded &&
              (state as ArticlesLoaded).source != "home")) {
        emit(ArticlesLoaded(
            articles: List.from(_homeArticles!), source: "home"));
      }
      return;
    }

    emit(const ArticlesLoading(step: "home"));

    final Set<String> ids = {};
    final List<ArticleEntity> compiled = [];

    // استخدام Future.wait لجلب البيانات بالتوازي لضمان عدم تأثر الأداء
    final results = await Future.wait([
      getRecommendedArticlesUseCase(),
      getTrendingArticlesUseCase(),
      getAllArticlesUseCase(page: 1, pageSize: 20), // جلب كمية كافية للترتيب
    ]);

    final recommendedResult = results[0];
    final trendingResult = results[1];
    final allResult = results[2];

    // 1️⃣ Recommended
    recommendedResult.fold(
      (failure) => print("Recommended error: ${failure.errorMessage}"),
      (articles) {
        final List<ArticleEntity> recArticles = articles;
        for (var a in recArticles) {
          if (ids.add(a.id)) compiled.add(a);
        }
      },
    );

    // 2️⃣ Trending
    trendingResult.fold(
      (failure) => print("Trending error: ${failure.errorMessage}"),
      (articles) {
        final List<ArticleEntity> trendArticles = articles;
        for (var a in trendArticles) {
          if (ids.add(a.id)) compiled.add(a);
        }
      },
    );

    // 3️⃣ All (Rest sorted by Likes descending)
    allResult.fold(
      (failure) => print("All error: ${failure.errorMessage}"),
      (articles) {
        final List<ArticleEntity> allArticles = articles;
        final List<ArticleEntity> restList = [];

        for (var a in allArticles) {
          if (!ids.contains(a.id)) {
            restList.add(a);
          }
        }

        // ترتيب بقية المقالات تنازلياً حسب عدد الإعجابات
        restList.sort((a, b) => b.likesCount.compareTo(a.likesCount));

        for (var a in restList) {
          if (ids.add(a.id)) compiled.add(a);
        }
      },
    );

    _homeArticles = compiled;

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
          _currentArticles = current;
          emit(ArticlesLoaded(
              articles: List.from(current), source: _currentSource));
        } else {
          _hasLoadedAll = true;
        }
      },
    );
  }

  // =========================
  // DOCTOR ARTICLES
  // =========================
  Future<void> loadArticlesByDoctor(String doctorUsername) async {
    _currentSource = "doctor"; // تغيير المؤشر لكاش الطبيب
    _doctorPage = 1;
    _doctorHasLoadedAll = false;

    // تصفير كاش الطبيب عند كل طلب جديد لضمان جلب أحدث المقالات له
    _doctorArticles = null;

    emit(const ArticlesLoading(step: "doctor"));

    final result = await getArticlesByDoctorUseCase(doctorUsername);

    result.fold(
      (failure) {
        emit(ArticlesError(
          message: failure.errorMessage,
          step: "doctor",
        ));
      },
      (articles) {
        _doctorArticles = articles;
        _doctorHasLoadedAll =
            true; // نعتبرها مكتملة مبدئياً لعدم وجود باجينيشن خاص بالطبيب حالياً

        emit(ArticlesLoaded(
          articles: List.from(_doctorArticles!),
          source: "doctor",
        ));
      },
    );
  }

  // =========================
  // REACTIONS (LIKE / DISLIKE)
  // =========================
  Future<void> reactToArticle(String articleId, String reaction) async {
    final currentState = state;

    final result = await reactToArticleUseCase(articleId, reaction);

    result.fold(
      (failure) {
        // ✅ لا تغير الحالة إذا كانت Loaded، فقط أظهر رسالة خطأ
        if (currentState is ArticlesLoaded) {
          emit(ArticlesReactionError(
            message: failure.errorMessage,
            source: _currentSource,
          ));
          // أعد الحالة السابقة فوراً
          emit(currentState);
        } else {
          emit(ArticlesError(
            message: failure.errorMessage,
            step: "reaction",
          ));
        }
      },
      (_) async {
        final updated = await getAllArticlesUseCase(
          page: 1,
          pageSize: _pageSize,
        );

        updated.fold(
          (failure) {
            // ✅ نفس المنطق هنا
            if (currentState is ArticlesLoaded) {
              emit(ArticlesReactionError(
                message: failure.errorMessage,
                source: _currentSource,
              ));
              emit(currentState);
            }
          },
          (articles) => _updateLocal(articles.first),
        );
      },
    );
  }

  // =========================
  // INTERNAL UPDATE
  // =========================
  void _updateLocal(ArticleEntity updated) {
    // تحديث في كاش الهوم إذا كان موجوداً
    if (_homeArticles != null) {
      _homeArticles =
          _homeArticles!.map((a) => a.id == updated.id ? updated : a).toList();
    }

    // تحديث في كاش الطبيب إذا كان موجوداً
    if (_doctorArticles != null) {
      _doctorArticles = _doctorArticles!
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
    }

    // تحديث الشاشة بناءً على المؤشر الحالي
    if (_currentArticles != null) {
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
    _homeArticles = null;
    _doctorArticles = null;
    _currentSource = "home";

    _homePage = 1;
    _homeIsFetchingMore = false;
    _homeHasLoadedAll = false;

    _doctorPage = 1;
    _doctorIsFetchingMore = false;
    _doctorHasLoadedAll = false;

    emit(const ArticlesInitial());
  }

  // ==========================================
  // 3. الحل السحري لمنع تجمد واختفاء بيانات الهوم عند العودة
  // ==========================================
  @override
  // ignore: must_call_super
  Future<void> close() {
    return Future.value();
  }
}
