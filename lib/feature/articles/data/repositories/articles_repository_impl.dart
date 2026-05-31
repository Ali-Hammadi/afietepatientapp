import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/articles/data/datasources/articles_remote_datasource.dart';
import 'package:afietepatientapp/feature/articles/domain/entities/article_entities.dart';
import 'package:afietepatientapp/feature/articles/domain/repositories/articles_repository.dart';

class ArticlesRepositoryImpl implements ArticlesRepository {
  final ArticlesRemoteDataSource remoteDataSource;

  const ArticlesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesForHome({
    String? userDiagnosis,
    int limit = 5,
  }) async {
    try {
      final articles = await remoteDataSource.getArticlesForHome(
        userDiagnosis: userDiagnosis,
        limit: limit,
      );
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleEntity>>> getArticlesByDoctor(
    String doctorId,
  ) async {
    try {
      final articles = await remoteDataSource.getArticlesByDoctor(doctorId);
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
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
      final articles = await remoteDataSource.getAllArticles(
        page: page,
        pageSize: pageSize,
      );
      return Right(articles.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ArticleEntity>> getArticleById(
    String articleId,
  ) async {
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
  Future<Either<Failure, void>> likeArticle(String articleId) async {
    try {
      await remoteDataSource.likeArticle(articleId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dislikeArticle(String articleId) async {
    try {
      await remoteDataSource.dislikeArticle(articleId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
