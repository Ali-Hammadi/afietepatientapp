import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/articles/data/models/article_model.dart';
import 'package:dio/dio.dart';

abstract class ArticlesRemoteDataSource {
  Future<List<ArticleModel>> getRecommendedArticles();
  Future<List<ArticleModel>> getTrendingArticles();
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorUsername);
  Future<List<ArticleModel>> getAllArticles(
      {required int page, int pageSize = 10});
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
  Future<List<ArticleModel>> getArticlesByDoctor(String doctorUsername) async {
    final response =
        await _dio.get(ApiEndpoints.doctorArticles(doctorUsername));
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
  Future<void> reactToArticle(String articleId, String reaction) async {
    await _dio.post(
      ApiEndpoints.articleReact(articleId),
      data: {'reaction': reaction},
    );
  }

  List<ArticleModel> _parseArticleList(dynamic data) {
    Iterable? rawList;

    if (data is Map) {
      rawList = data['results'] ?? data['articles'] ?? data['data'];
    } else if (data is List) {
      rawList = data;
    }

    if (rawList == null) return const [];

    final List<ArticleModel> articles = [];

    for (var item in rawList) {
      try {
        final json = Map<String, dynamic>.from(item);
        print("Parsing article: ${json['title']}");
        articles.add(ArticleModel.fromJson(json));
      } catch (e, s) {
        print("❌ Article Parsing Error");
        print(e);
        print(s);
      }
    }

    print("Articles parsed = ${articles.length}");

    return articles;
  }
}
