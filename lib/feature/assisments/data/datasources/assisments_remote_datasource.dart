import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/assisments/data/models/assisment_question_model.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:dio/dio.dart';

abstract class AssismentsRemoteDataSource {
  Future<List<AssismentEntity>> getAssismentQuestions();

  Future<AssismentEntity> submitAssisment({
    required List<AssismentEntity> answers,
  });

  Future<List<AssessmentScoreEntry>> getAssessmentScores();
}

class AssismentsRemoteDataSourceImpl implements AssismentsRemoteDataSource {
  final Dio _dio;

  AssismentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  List<dynamic> _extractForms(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      return (data['results'] ??
              data['data'] ??
              data['questions'] ??
              data['forms'] ??
              data['items'] ??
              const [])
          as List<dynamic>;
    }

    return const <dynamic>[];
  }

  List<AssismentEntity> _extractQuestionsFromForms(List<dynamic> forms) {
    final questions = <AssismentEntity>[];

    for (final form in forms.whereType<Map<String, dynamic>>()) {
      final formQuestions = (form['questions'] ?? const []) as List<dynamic>;
      for (final question in formQuestions.whereType<Map<String, dynamic>>()) {
        questions.add(AssismentModel.fromQuestionJson(question));
      }
    }

    return questions;
  }

  @override
  Future<List<AssessmentScoreEntry>> getAssessmentScores() async {
    try {
      final response = await _dio.get(ApiEndpoints.assessmentsScores);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AssismentModel.fromScoresJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const [];
    } on DioException {
      rethrow;
    } catch (error) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.assessmentsScores),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<AssismentEntity>> getAssismentQuestions() async {
    try {
      final response = await _dio.get(ApiEndpoints.assessmentsForm);
      if (response.statusCode == 200) {
        final forms = _extractForms(response.data);
        final questions = _extractQuestionsFromForms(forms);
        if (questions.isNotEmpty) {
          return questions;
        }

        if (response.data is List) {
          return (response.data as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(AssismentModel.fromQuestionJson)
              .toList();
        }

        return const <AssismentEntity>[];
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException {
      rethrow;
    } catch (error) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.assismentQuestions),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<AssismentEntity> submitAssisment({
    required List<AssismentEntity> answers,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assessmentsFormSubmit,
        data: {
          ApiEndpoints.keyAnswers: answers
              .map(
                (answer) => {
                  ApiEndpoints.keyQuestionId: answer.questionId,
                  ApiEndpoints.keyAnswerId: answer.selectedOptionId,
                },
              )
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['result'] ??
                      response.data['score'] ??
                      response.data['data'] ??
                      response.data)
                  as Map<String, dynamic>
            : <String, dynamic>{};
        return AssismentModel.fromResultJson(data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException {
      rethrow;
    } catch (error) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.assismentSubmit),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }
}
