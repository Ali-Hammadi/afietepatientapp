import 'package:afiete/core/network/dio_factory.dart';
import 'package:afiete/core/network/token_storage.dart';
import 'package:afiete/feature/appointments/domain/repositories/appointments_repository.dart';

import 'package:afiete/feature/assessments/data/datasources/assisments_remote_datasource.dart';
import 'package:afiete/feature/assessments/data/repositories/assisments_repository_impl.dart';
import 'package:afiete/feature/assessments/domain/repositories/assisments_repository.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assessment_scores_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assisment_questions_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/submit_assisment_usecase.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';
import 'package:afiete/feature/auth/domain/usecase/delete_account_usecase.dart';

import 'package:afiete/feature/auth/domain/usecase/fetch_profile_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/google_signin_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/logout_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/reactivate_account_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/request_forgot_password_otp_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/verify_forgot_password_otp_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/update_profile_info_usecase.dart';

import 'package:afiete/feature/appointments/data/datasources/appointments_remote_datasource.dart';
import 'package:afiete/feature/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:afiete/feature/articles/data/datasources/articles_remote_datasource.dart';

import 'package:afiete/feature/appointments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appointments/presentation/cubits/appointments_cubit.dart';
import 'package:afiete/feature/chat/data/datasources/chat_remote_datasource.dart';
import 'package:afiete/feature/chat/data/repositories/chat_repository_impl.dart';
import 'package:afiete/feature/chat/domain/repositories/chat_repository.dart';
import 'package:afiete/feature/chat/domain/usecases/chat_usecase.dart';

import 'package:afiete/feature/chat/presentation/cubit/chat_cubit.dart';
import 'package:afiete/feature/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:afiete/feature/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/feeling/data/datasources/feeling_local_data_source.dart';
import 'package:afiete/feature/feeling/data/repositories/feeling_repository_impl.dart';
import 'package:afiete/feature/feeling/domain/repositories/feeling_repository.dart';
import 'package:afiete/feature/feeling/domain/usecase/feeling_usecases.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';
import 'package:afiete/feature/music_and_breathing/data/datasources/relax_remote_data_source.dart';
import 'package:afiete/feature/music_and_breathing/data/repositories/relax_repository_impl.dart';
import 'package:afiete/feature/music_and_breathing/domain/repositories/music_repository.dart';
import 'package:afiete/feature/music_and_breathing/domain/usecase/get_recommended_music_usecase.dart';
import 'package:afiete/feature/music_and_breathing/presentation/cubit/music_cubit.dart';
import 'package:afiete/feature/notes/data/datasources/notes_local_datasource.dart';
import 'package:afiete/feature/notes/data/datasources/notes_remote_datasource.dart';
import 'package:afiete/feature/notes/data/repositories/notes_repository_impl.dart';
import 'package:afiete/feature/notes/domain/repositories/notes_repository.dart';
import 'package:afiete/feature/payment/data/datasources/payment_remote_datasource.dart';
import 'package:afiete/feature/payment/data/repositories/payment_repository_impl.dart';
import 'package:afiete/feature/payment/domain/repositories/payment_repository.dart';
import 'package:afiete/feature/payment/domain/usecases/process_payment_usecase.dart';
import 'package:afiete/feature/payment/presentation/cubit/payment_cubit.dart';
import 'package:afiete/feature/prespection/data/datasources/patient_prescription_remote_datasource.dart';
import 'package:afiete/feature/prespection/data/repositories/patient_prescription_repository_impl.dart';
import 'package:afiete/feature/prespection/domain/repositories/patient_prescription_repo.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart';
import 'package:afiete/feature/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:afiete/feature/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:afiete/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:afiete/feature/sessions/domain/usecase/add_review_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/cancel_session_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/get_past_sessions_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/get_upcoming_sessions_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/reschedule_session_usecase.dart';
import 'package:afiete/feature/sessions/presentation/cubits/sessions_cubit.dart';
import 'package:afiete/feature/settings/data/data_source/settings_remote_data_source.dart';
import 'package:afiete/feature/settings/data/repositories/settings_repository_impl.dart';
import 'package:afiete/feature/settings/domin/repositories/settings_repository.dart';
import 'package:afiete/feature/prespection/domain/usecases/prescription_usecase.dart';
import 'package:afiete/feature/notes/domain/usecases/notes_usecase.dart';
import 'package:afiete/feature/settings/domin/usecase/submit_report_issue_usecase.dart';
import 'package:afiete/feature/settings/presentation/cubits/settings_cubit.dart';
import 'package:afiete/feature/report/data/datasources/report_remote_datasource.dart';
import 'package:afiete/feature/report/data/repositories/report_repository_impl.dart';
import 'package:afiete/feature/report/domain/usecases/report_usecase.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';
import 'package:afiete/feature/articles/data/repositories/articles_repository_impl.dart';
import 'package:afiete/feature/articles/domain/repositories/articles_repository.dart';
import 'package:afiete/feature/articles/domain/usecases/articles_usecases.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:afiete/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:afiete/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:afiete/feature/auth/domain/repositories/auth_repository.dart';
import 'package:afiete/feature/auth/domain/usecase/login_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/signup_usecase.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:dio/dio.dart';

import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;
const bool useMockDataSources = false;

const String googleWebClientId =
    '1003547921607-12juc731vap30cbmmfjtkf38tr09ck8b.apps.googleusercontent.com';

Future<void> init() async {
  // Core network
  sl.registerLazySingleton<Dio>(() => DioFactory.create());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      serverClientId: googleWebClientId,
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignupUseCase>(
    () => SignupUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ReactivateAccountUseCase>(
    () => ReactivateAccountUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GoogleSignInUseCase>(
    () => GoogleSignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<FetchProfileUseCase>(
    () => FetchProfileUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileInfoUseCase>(
    () => UpdateProfileInfoUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RequestForgotPasswordOtpUseCase>(
    () => RequestForgotPasswordOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyForgotPasswordOtpUseCase>(
    () => VerifyForgotPasswordOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );

  // Cubits
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      sl<LoginUseCase>(),
      sl<SignupUseCase>(),
      sl<LogoutUseCase>(),
      sl<DeleteAccountUseCase>(),
      sl<ReactivateAccountUseCase>(),
      sl<GoogleSignInUseCase>(),
      sl<FetchProfileUseCase>(),
      sl<UpdateProfileInfoUseCase>(),
      sl<RequestForgotPasswordOtpUseCase>(),
      sl<VerifyForgotPasswordOtpUseCase>(),
      sl<VerifyOtpUseCase>(),
      sl<AuthRepository>(),
    ),
  );
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      getChatRoom: GetChatRoom(sl<ChatRepository>()),
      getMessagesStream: GetMessagesStream(sl<ChatRepository>()),
      sendMessage: SendMessage(sl<ChatRepository>()),
    ),
  );

  // Chat Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      sl<ChatRemoteDataSource>(),
    ),
  );
  // Chat data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Booking Assessments data sources
  sl.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Booking Assessments repositories
  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(
      dataSource: sl<AppointmentsRemoteDataSource>(),
    ),
  );

  // Booking Assessments use cases
  sl.registerLazySingleton<GetAppointmentsUseCase>(
    () => GetAppointmentsUseCase(sl<AppointmentsRepository>()),
  );
  sl.registerLazySingleton<CreateAppointmentUseCase>(
    () => CreateAppointmentUseCase(sl<AppointmentsRepository>()),
  );
  sl.registerLazySingleton<CancelAppointmentUseCase>(
    () => CancelAppointmentUseCase(sl<AppointmentsRepository>()),
  );
  sl.registerLazySingleton<RescheduleAppointmentUseCase>(
    () => RescheduleAppointmentUseCase(sl<AppointmentsRepository>()),
  );
  sl.registerLazySingleton<GetAvailableSlotsUseCase>(
    () => GetAvailableSlotsUseCase(sl<AppointmentsRepository>()),
  );

  // Booking Assessments cubits
  sl.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(
        getAppointmentsUseCase: sl<GetAppointmentsUseCase>(),
        createAppointmentDraftUseCase: sl<CreateAppointmentUseCase>(),
        getAllDoctorsUseCase: sl<GetAllDoctorsUseCase>(),
        cancelAppointmentUseCase: sl<CancelAppointmentUseCase>(),
        rescheduleAppointmentUseCase: sl<RescheduleAppointmentUseCase>(),
        getAvailableSlotsUseCase: sl<GetAvailableSlotsUseCase>()),
  );

  // Payment data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Payment repositories
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dataSource: sl<PaymentRemoteDataSource>()),
  );

  // Payment use cases
  sl.registerLazySingleton<ProcessPaymentUseCase>(
    () => ProcessPaymentUseCase(sl<PaymentRepository>()),
  );

  // Payment cubits
  sl.registerFactory<PaymentCubit>(
    () => PaymentCubit(sl<ProcessPaymentUseCase>()),
  );

  // Sessions data sources
  sl.registerLazySingleton<SessionsRemoteDataSource>(
    () => SessionsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Sessions repositories
  sl.registerLazySingleton<SessionsRepository>(
    () => SessionsRepositoryImpl(dataSource: sl<SessionsRemoteDataSource>()),
  );

  // Sessions use cases
  sl.registerLazySingleton<GetUpcomingSessionsUseCase>(
    () => GetUpcomingSessionsUseCase(sl<SessionsRepository>()),
  );
  sl.registerLazySingleton<GetPastSessionsUseCase>(
    () => GetPastSessionsUseCase(sl<SessionsRepository>()),
  );
  sl.registerLazySingleton<CancelSessionUseCase>(
    () => CancelSessionUseCase(sl<SessionsRepository>()),
  );
  sl.registerLazySingleton<RescheduleSessionUseCase>(
    () => RescheduleSessionUseCase(sl<SessionsRepository>()),
  );
  sl.registerLazySingleton<AddReviewUseCase>(
    () => AddReviewUseCase(sl<SessionsRepository>()),
  );

  // Sessions cubits
  sl.registerFactory<SessionsCubit>(
    () => SessionsCubit(
      sl<GetUpcomingSessionsUseCase>(),
      sl<GetPastSessionsUseCase>(),
      sl<CancelSessionUseCase>(),
      sl<RescheduleSessionUseCase>(),
      sl<AddReviewUseCase>(),
    ),
  );

  // Doctors data sources
  sl.registerLazySingleton<DoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Doctors repositories
  sl.registerLazySingleton<DoctorsRepository>(
    () =>
        DoctorsRepositoryImpl(remoteDataSource: sl<DoctorsRemoteDataSource>()),
  );

  // Doctors use cases
  sl.registerLazySingleton<GetAllDoctorsUseCase>(
    () => GetAllDoctorsUseCase(sl<DoctorsRepository>()),
  );
  sl.registerLazySingleton<GetDoctorsBySpecialtyUseCase>(
    () => GetDoctorsBySpecialtyUseCase(sl<DoctorsRepository>()),
  );
  sl.registerLazySingleton<GetDoctorByUsernameUseCase>(
    () => GetDoctorByUsernameUseCase(sl<DoctorsRepository>()),
  );
  sl.registerLazySingleton<GetSpecialtiesUseCase>(
    () => GetSpecialtiesUseCase(sl<DoctorsRepository>()),
  );

  // Feeling data sources
  sl.registerLazySingleton<FeelingLocalDataSource>(
    () => FeelingLocalDataSourceImpl(),
  );

  // Feeling repositories
  sl.registerLazySingleton<FeelingRepository>(
    () => FeelingRepositoryImpl(localDataSource: sl<FeelingLocalDataSource>()),
  );

  // Feeling use cases
  sl.registerLazySingleton<SaveFeelingUseCase>(
    () => SaveFeelingUseCase(sl<FeelingRepository>()),
  );
  sl.registerLazySingleton<GetCurrentFeelingUseCase>(
    () => GetCurrentFeelingUseCase(sl<FeelingRepository>()),
  );
  sl.registerLazySingleton<GetFeelingHistoryUseCase>(
    () => GetFeelingHistoryUseCase(sl<FeelingRepository>()),
  );

  // Feeling cubit
  sl.registerFactory<FeelingCubit>(
    () => FeelingCubit(
      sl<SaveFeelingUseCase>(),
      sl<GetCurrentFeelingUseCase>(),
      sl<GetFeelingHistoryUseCase>(),
    ),
  );

  // Music data sources
  sl.registerLazySingleton<RelaxRemoteDataSource>(
    () => RelaxRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Music repositories
  sl.registerLazySingleton<RelaxRepository>(
    () => RelaxRepositoryImpl(remoteDataSource: sl<RelaxRemoteDataSource>()),
  );

  // Music use cases
  sl.registerLazySingleton<GetRecommendedMusicUseCase>(
    () => GetRecommendedMusicUseCase(sl<RelaxRepository>()),
  );
  sl.registerLazySingleton<SaveLastSelectedFeelingUseCase>(
    () => SaveLastSelectedFeelingUseCase(sl<RelaxRepository>()),
  );
  sl.registerLazySingleton<GetLastSelectedFeelingUseCase>(
    () => GetLastSelectedFeelingUseCase(sl<RelaxRepository>()),
  );
  sl.registerLazySingleton<GetBreathingExercisesUseCase>(
    () => GetBreathingExercisesUseCase(sl<RelaxRepository>()),
  );

  // Music cubit
  sl.registerFactory<MusicCubit>(
    () => MusicCubit(
      sl<GetRecommendedMusicUseCase>(),
      sl<GetBreathingExercisesUseCase>(),
      sl<GetLastSelectedFeelingUseCase>(),
      sl<SaveLastSelectedFeelingUseCase>(),
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  // Dio (assuming it's already registered in your app, otherwise register it here)
  // If Dio is not registered yet:
  // sl.registerLazySingleton<Dio>(() => Dio());

  // Data Sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(sharedPreferences: sharedPreferences),
  );
  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => NoteRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton(() => GetNotesUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => NotesCubit(
      createNoteUseCase: sl(),
      updateNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
      getNotesUseCase: sl(),
    ),
  );

  // Assessments data sources
  sl.registerLazySingleton<AssessmentsRemoteDataSource>(
    () => AssessmentsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Assessments repositories
  sl.registerLazySingleton<AssessmentsRepository>(
    () => AssessmentsRepositoryImpl(
      remoteDataSource: sl<AssessmentsRemoteDataSource>(),
    ),
  );

  // Assessments use cases
  sl.registerLazySingleton<GetAssessmentsQuestionsUseCase>(
    () => GetAssessmentsQuestionsUseCase(sl<AssessmentsRepository>()),
  );
  sl.registerLazySingleton<SubmitAssessmentsUseCase>(
    () => SubmitAssessmentsUseCase(sl<AssessmentsRepository>()),
  );
  sl.registerLazySingleton<GetAssessmentScoresUseCase>(
    () => GetAssessmentScoresUseCase(sl<AssessmentsRepository>()),
  );

  // Assessments cubit
  sl.registerFactory<AssessmentsCubit>(
    () => AssessmentsCubit(
      sl<GetAssessmentsQuestionsUseCase>(),
      sl<SubmitAssessmentsUseCase>(),
      sl<GetAllDoctorsUseCase>(),
      sl<GetDoctorsBySpecialtyUseCase>(),
      sl<GetAssessmentScoresUseCase>(),
    ),
  );

  // Doctors cubits
  sl.registerFactory<DoctorsCubit>(
    () => DoctorsCubit(
        sl<GetAllDoctorsUseCase>(),
        sl<GetDoctorsBySpecialtyUseCase>(),
        sl<GetDoctorByUsernameUseCase>(),
        sl<GetSpecialtiesUseCase>()),
  );
  // Settings data sources
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Settings repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: sl<SettingsRemoteDataSource>(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => PatientPrescriptionsBloc(
      getPrescriptions: sl(),
      getPrescriptionDetail: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPatientPrescriptions(sl()));
  sl.registerLazySingleton(() => GetPatientPrescriptionDetail(sl()));

  // Repository
  sl.registerLazySingleton<PatientPrescriptionRepository>(
    () => PatientPrescriptionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton(
    () => PatientPrescriptionRemoteDataSource(
      dio: sl<Dio>(),
      baseUrl: DioFactory.baseUrl,
      getToken: () => "${TokenStorage.getAccessToken()}",
    ),
  );

  // Settings cubit
  sl.registerFactory<SettingsCubit>(() => SettingsCubit(
        sl<SubmitReportIssueUseCase>(),
      ));

  // Report data sources
  sl.registerLazySingleton<ReportsRemoteDataSourceImpl>(
    () => ReportsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Report repositories
  sl.registerLazySingleton<ReportsRepositoryImpl>(
    () => ReportsRepositoryImpl(
        remoteDataSource: sl<ReportsRemoteDataSourceImpl>()),
  );

  // Report use cases
  sl.registerLazySingleton<GetReportConfigUseCase>(
    () => GetReportConfigUseCase(sl<ReportsRepositoryImpl>()),
  );
  sl.registerLazySingleton<GetMyReportsUseCase>(
    () => GetMyReportsUseCase(sl<ReportsRepositoryImpl>()),
  );
  sl.registerLazySingleton<CreateAppReportUseCase>(
    () => CreateAppReportUseCase(sl<ReportsRepositoryImpl>()),
  );
  sl.registerLazySingleton<SubmitReportIssueUseCase>(
    () => SubmitReportIssueUseCase(sl<SettingsRepository>()),
  );

  // Report cubit
  sl.registerFactory<ReportCubit>(
    () => ReportCubit(
      createAppReportUseCase:
          CreateAppReportUseCase(sl<ReportsRepositoryImpl>()),
      createUserReportUseCase:
          CreateUserReportUseCase(sl<ReportsRepositoryImpl>()),
      getMyReportsUseCase: GetMyReportsUseCase(sl<ReportsRepositoryImpl>()),
      getReportConfigUseCase:
          GetReportConfigUseCase(sl<ReportsRepositoryImpl>()),
    ),
  );

  // Articles data sources
  sl.registerLazySingleton<ArticlesRemoteDataSource>(
    () => ArticlesRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Articles repositories
  sl.registerLazySingleton<ArticlesRepository>(
    () => ArticlesRepositoryImpl(
      remoteDataSource: sl<ArticlesRemoteDataSource>(),
    ),
  );

  // Articles use cases
  sl.registerLazySingleton<GetArticlesForHomeUseCase>(
    () => GetArticlesForHomeUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<GetRecommendedArticlesUseCase>(
    () => GetRecommendedArticlesUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<GetTrendingArticlesUseCase>(
    () => GetTrendingArticlesUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<GetArticlesByDoctorUseCase>(
    () => GetArticlesByDoctorUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<GetAllArticlesUseCase>(
    () => GetAllArticlesUseCase(sl<ArticlesRepository>()),
  );

  sl.registerLazySingleton<LikeArticleUseCase>(
    () => LikeArticleUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<ReactToArticleUseCase>(
    () => ReactToArticleUseCase(sl<ArticlesRepository>()),
  );
  sl.registerLazySingleton<DislikeArticleUseCase>(
    () => DislikeArticleUseCase(sl<ArticlesRepository>()),
  );

  // Articles cubit
  sl.registerFactory<ArticlesCubit>(
    () => ArticlesCubit(
      getTrendingArticlesUseCase: sl<GetTrendingArticlesUseCase>(),
      getArticlesByDoctorUseCase: sl<GetArticlesByDoctorUseCase>(),
      getAllArticlesUseCase: sl<GetAllArticlesUseCase>(),
      reactToArticleUseCase: sl<ReactToArticleUseCase>(),
      getRecommendedArticlesUseCase: sl<GetRecommendedArticlesUseCase>(),
    ),
  );
}
