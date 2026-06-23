import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/assessments/data/models/assisment_question_model.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';

import 'package:dio/dio.dart';

abstract class AssessmentsRemoteDataSource {
  Future<List<AssessmentsEntity>> getAssessmentsQuestions();

  Future<AssessmentsEntity> submitAssessments({
    required List<AssessmentsEntity> answers,
  });

  Future<List<AssessmentScoreEntry>> getAssessmentScores();
}

class AssessmentsRemoteDataSourceImpl implements AssessmentsRemoteDataSource {
  final Dio _dio;

  AssessmentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

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
          const []) as List<dynamic>;
    }

    return const <dynamic>[];
  }

  List<AssessmentsEntity> _extractQuestionsFromForms(List<dynamic> forms) {
    final questions = <AssessmentsEntity>[];

    for (final form in forms.whereType<Map<String, dynamic>>()) {
      final formQuestions = (form['questions'] ?? const []) as List<dynamic>;
      for (final question in formQuestions.whereType<Map<String, dynamic>>()) {
        questions.add(AssessmentsModel.fromQuestionJson(question));
      }
    }

    return questions;
  }

  @override
  Future<List<AssessmentScoreEntry>> getAssessmentScores() async {
    try {
      final response = await _dio.get(ApiEndpoints.Assessmentscores);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AssessmentsModel.fromScoresJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const [];
    } on DioException {
      rethrow;
    } catch (error) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.Assessmentscores),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<AssessmentsEntity>> getAssessmentsQuestions() async {
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
              .map(AssessmentsModel.fromQuestionJson)
              .toList();
        }

        return const <AssessmentsEntity>[];
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
        requestOptions: RequestOptions(path: ApiEndpoints.assessmentsForm),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<AssessmentsEntity> submitAssessments({
    required List<AssessmentsEntity> answers,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assessmentsFormSubmit,
        // ✅ تعديل الـ Keys لتطابق ما يتوقعه السيرفر تماماً
        data: {
          "answers": answers
              .map(
                (answer) => {
                  "question_id":
                      answer.questionId, // 👈 قم بتعديلها إلى question_id
                  "answer_id":
                      answer.selectedOptionId, // 👈 قم بتعديلها إلى answer_id
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
                response.data) as Map<String, dynamic>
            : <String, dynamic>{};
        return AssessmentsModel.fromResultJson(data);
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
        requestOptions:
            RequestOptions(path: ApiEndpoints.assessmentsFormSubmit),
        error: error,
        type: DioExceptionType.unknown,
      );
    }
  }
}
