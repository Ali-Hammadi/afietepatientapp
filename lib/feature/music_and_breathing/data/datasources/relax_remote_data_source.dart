import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/music_entity.dart';
import '../../domain/usecase/get_recommended_music_usecase.dart';
import '../models/breathing_model.dart';
import '../models/music_model.dart';

abstract class RelaxRemoteDataSource {
  Future<FeelingType> getLastSelectedFeeling();
  Future<void> saveLastSelectedFeeling(FeelingType feeling);
  Future<List<MusicModel>> getRecommendedTracks(RecommendedMusicParams params);
  Future<List<BreathingExerciseModel>> getBreathingExercises();
}

class RelaxRemoteDataSourceImpl implements RelaxRemoteDataSource {
  final Dio dio;

  RelaxRemoteDataSourceImpl({required this.dio});

  @override
  Future<FeelingType> getLastSelectedFeeling() async {
    final response = await dio.get(ApiEndpoints.relaxFeelingLast);

    if (response.statusCode == 200) {
      final data = response.data;
      final jsonMap = data is Map<String, dynamic> ? data : data[0];
      return FeelingType.values.byName(jsonMap['feeling'] as String);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<void> saveLastSelectedFeeling(FeelingType feeling) async {
    final response = await dio.post(
      ApiEndpoints.relaxFeelingLast,
      data: {'feeling': feeling.name},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<List<MusicModel>> getRecommendedTracks(
      RecommendedMusicParams params) async {
    final Map<String, dynamic> queryParameters = {
      'feeling': params.feeling.name,
      'limit': params.limit.toString(),
    };

    if (params.excludeTrackId != null) {
      queryParameters['exclude_track_id'] = params.excludeTrackId!;
    }

    final response = await dio.get(
      ApiEndpoints.,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final List data =
          response.data is List ? response.data : response.data['data'] ?? [];
      return data.map((item) => MusicModel.fromJson(item)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<List<BreathingExerciseModel>> getBreathingExercises() async {
    final response = await dio.get(ApiEndpoints.relaxBreathingExercises);

    if (response.statusCode == 200) {
      final List data =
          response.data is List ? response.data : response.data['data'] ?? [];
      return data.map((item) => BreathingExerciseModel.fromJson(item)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
