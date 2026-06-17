import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/articles/data/models/article_model.dart';
import 'package:dio/dio.dart';

abstract class ArticlesRemoteDataSource {
  Future<List<ArticleModel>> getRecommendedArticles();
  Future<List<ArticleModel>> getTrendingArticles();
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorId);
  Future<List<ArticleModel>> getAllArticles(
      {required int page, int pageSize = 10});
  Future<ArticleModel> getArticleById(String articleId);
  Future<void> reactToArticle(String articleId, String reaction);
}

class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final Dio _dio;

  ArticlesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ArticleModel>> getRecommendedArticles() async {
    final response = await _dio.get(ApiEndpoints.articlesRecommended);
    return _parseArticleList(response.data);
  }

  @override
  Future<List<ArticleModel>> getTrendingArticles() async {
    final response = await _dio.get(ApiEndpoints.articlesTrending);
    return _parseArticleList(response.data);
  }

  @override
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorId) async {
    // جلب مقالات طبيب معين (تصفية عبر Query parameters أو endpoint مخصصة)
    final response = await _dio.get(ApiEndpoints.articleById(doctorId),
        queryParameters: {'author': doctorId});
    return _parseArticleList(response.data);
  }

  @override
  Future<List<ArticleModel>> getAllArticles(
      {required int page, int pageSize = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.articlesFeed,
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return _parseArticleList(response.data);
  }

  @override
  Future<ArticleModel> getArticleById(String articleId) async {
    final response = await _dio.get(ApiEndpoints.articleById(articleId));
    return ArticleModel.fromJson(_parseArticleMap(response.data));
  }

  @override
  Future<void> reactToArticle(String articleId, String reaction) async {
    await _dio.post(
      ApiEndpoints.articleReact(articleId),
      data: {'reaction': reaction},
    );
  }

  List<ArticleModel> _parseArticleList(dynamic data) {
    final rawList = data is Map<String, dynamic>
        ? (data['results'] ?? data['articles'] ?? data['data'] ?? const [])
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
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }
    throw DioException(
      requestOptions: RequestOptions(path: 'article_parsing'),
      error: 'Invalid response layout structure',
    );
  }
}
