import 'package:afietepatientapp/core/network/api_endpoints.dart';
import 'package:afietepatientapp/feature/articles/data/models/article_model.dart';
import 'package:dio/dio.dart';

abstract class ArticlesRemoteDataSource {
  Future<List<ArticleModel>> getArticlesForHome({
    String? userDiagnosis,
    int limit = 5,
  });
  Future<List<ArticleModel>> getRecommendedArticles();
  Future<List<ArticleModel>> getTrendingArticles();
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorId);
  Future<List<ArticleModel>> getAllArticles({int page = 1, int pageSize = 10});
  Future<ArticleModel> getArticleById(String articleId);
  Future<void> reactToArticle(String articleId, String reaction);
  Future<void> likeArticle(String articleId);
  Future<void> dislikeArticle(String articleId);
}

class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final Dio _dio;

  ArticlesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ArticleModel>> getArticlesForHome({
    String? userDiagnosis,
    int limit = 5,
  }) async {
    try {
      final recommended = await getRecommendedArticles();
      final trending = await getTrendingArticles();

      return _uniqueById([
        ...recommended.take(limit),
        ...trending.take(limit),
      ]);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.articlesRecommended),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<ArticleModel>> getRecommendedArticles() async {
    try {
      return _loadArticles(ApiEndpoints.articlesRecommended);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiEndpoints.articlesRecommended,
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<ArticleModel>> getTrendingArticles() async {
    try {
      return _loadArticles(ApiEndpoints.articlesTrending);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.articlesTrending),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorId) async {
    try {
      final response = await _dio.get(ApiEndpoints.articlesByDoctor(doctorId));
      return _parseArticleList(response.data);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiEndpoints.articlesByDoctor(doctorId),
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<ArticleModel>> getAllArticles({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.allArticles,
        queryParameters: {
          ApiEndpoints.keyPage: page,
          ApiEndpoints.keyPageSize: pageSize,
        },
      );
      return _parseArticleList(response.data);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.allArticles),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<ArticleModel> getArticleById(String articleId) async {
    try {
      final response = await _dio.get(ApiEndpoints.articleById(articleId));
      final article = _parseArticleMap(response.data);
      return ArticleModel.fromJson(article);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiEndpoints.articleById(articleId),
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> likeArticle(String articleId) async {
    await reactToArticle(articleId, 'like');
  }

  @override
  Future<void> dislikeArticle(String articleId) async {
    await reactToArticle(articleId, 'dislike');
  }

  @override
  Future<void> reactToArticle(String articleId, String reaction) async {
    await _dio.post(
      ApiEndpoints.articleReact(articleId),
      data: {'reaction': reaction},
    );
  }

  Future<List<ArticleModel>> _loadArticles(String endpoint) async {
    final response = await _dio.get(endpoint);
    return _parseArticleList(response.data);
  }

  List<ArticleModel> _uniqueById(Iterable<ArticleModel> articles) {
    final seenIds = <String>{};
    final uniqueArticles = <ArticleModel>[];

    for (final article in articles) {
      if (article.id.isEmpty || seenIds.contains(article.id)) {
        continue;
      }
      seenIds.add(article.id);
      uniqueArticles.add(article);
    }

    return uniqueArticles;
  }

  List<ArticleModel> _parseArticleList(dynamic data) {
    final rawList = data is Map<String, dynamic>
        ? (data['results'] ??
              data['articles'] ??
              data['data'] ??
              data['items'] ??
              const [])
        : (data as List? ?? const []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromJson)
        .where((article) => article.id.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic> _parseArticleMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'] ?? data['article'] ?? data['result'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }

    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.articleById('')),
      response: Response(
        requestOptions: RequestOptions(path: ApiEndpoints.articleById('')),
        statusCode: 404,
        data: const {'detail': 'Article not found.'},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
