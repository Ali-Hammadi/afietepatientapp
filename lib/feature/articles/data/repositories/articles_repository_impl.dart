import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/articles/data/datasources/articles_remote_datasource.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/articles/domain/repositories/articles_repository.dart';

class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticlesRemoteDataSource remoteDataSource;

  const ArticlesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesForHome({
    String? userDiagnosis,
    int limit = 5,
  }) async {
    // تم تفويض المعالجة المتسلسلة والدمج الذكي بالكامل داخل الـ Cubit
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getRecommendedArticles() async {
    try {
      final articles = await remoteDataSource.getRecommendedArticles();
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getTrendingArticles() async {
    try {
      final articles = await remoteDataSource.getTrendingArticles();
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  // أضف تطبيق الدالة داخل كلاس ArticlesRepositoryImpl

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesByDoctor(
      String doctorUsername) async {
    try {
      final models = await remoteDataSource.getArticlesByDoctor(doctorUsername);
      return Right(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Right([]);
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getAllArticles({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final articles =
          await remoteDataSource.getAllArticles(page: page, pageSize: pageSize);
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Right([]);
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> getArticleById(
      String articleId) async {
    try {
      final article = await remoteDataSource.getArticleById(articleId);
      return Right(article.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Article not found.'));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reactToArticle(
      String articleId, String reaction) async {
    try {
      await remoteDataSource.reactToArticle(articleId, reaction);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likeArticle(String articleId) async {
    return reactToArticle(articleId, 'like');
  }

  @override
  Future<Either<Failure, void>> dislikeArticle(String articleId) async {
    return reactToArticle(articleId, 'dislike');
  }
}
