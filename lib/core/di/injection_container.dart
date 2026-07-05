import 'package:afiete/core/network/dio_factory.dart';
import 'package:afiete/core/network/token_storage.dart';

// ✅ Auth Feature
import 'package:afiete/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:afiete/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:afiete/feature/auth/domain/repositories/auth_repository.dart';
import 'package:afiete/feature/auth/domain/usecase/login_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/signup_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/logout_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/delete_account_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/reactivate_account_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/google_signin_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/fetch_profile_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/update_profile_info_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/request_forgot_password_otp_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/verify_forgot_password_otp_usecase.dart';
import 'package:afiete/feature/auth/domain/usecase/verify_otp_usecase.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';

// ✅ Chat Feature
import 'package:afiete/feature/chat/data/datasources/chat_remote_datasource.dart';
import 'package:afiete/feature/chat/data/repositories/chat_repository.dart';
import 'package:afiete/feature/chat/data/repositories/course_repository.dart';
import 'package:afiete/feature/chat/presentation/cubit/chat_cubit.dart';

// ✅ Appointments Feature
import 'package:afiete/feature/appointments/data/datasources/appointments_remote_datasource.dart';
import 'package:afiete/feature/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:afiete/feature/appointments/domain/repositories/appointments_repository.dart';
import 'package:afiete/feature/appointments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appointments/presentation/cubits/appointments_cubit.dart';

// ✅ Courses Feature (New - Clean Architecture)
import 'package:afiete/feature/cources/data/datasources/cources_remote_datasource.dart';
import 'package:afiete/feature/cources/data/repositories/cources_repo_impl.dart';
import 'package:afiete/feature/cources/domain/repositories/cources_repo.dart';
import 'package:afiete/feature/cources/domain/usecases/cources_usecase.dart';
import 'package:afiete/feature/cources/presentation/cubit/cources_cubit.dart';

// ✅ Doctors Feature
import 'package:afiete/feature/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:afiete/feature/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/music_and_breathing/data/datasources/relax_mock_datasource.dart';
import 'package:afiete/feature/music_and_breathing/data/datasources/relax_remote_data_source.dart';
import 'package:afiete/feature/music_and_breathing/data/repositories/relax_repository_impl.dart';

// ✅ Sessions Feature
import 'package:afiete/feature/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:afiete/feature/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:afiete/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:afiete/feature/sessions/domain/usecase/get_upcoming_sessions_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/get_past_sessions_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/cancel_session_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/reschedule_session_usecase.dart';
import 'package:afiete/feature/sessions/domain/usecase/add_review_usecase.dart';
import 'package:afiete/feature/sessions/presentation/cubits/sessions_cubit.dart';

// ✅ Payment Feature
import 'package:afiete/feature/payment/data/datasources/payment_remote_datasource.dart';
import 'package:afiete/feature/payment/data/repositories/payment_repository_impl.dart';
import 'package:afiete/feature/payment/domain/repositories/payment_repository.dart';
import 'package:afiete/feature/payment/domain/usecases/process_payment_usecase.dart';
import 'package:afiete/feature/payment/presentation/cubit/payment_cubit.dart';

// ✅ Articles Feature
import 'package:afiete/feature/articles/data/datasources/articles_remote_datasource.dart';
import 'package:afiete/feature/articles/data/repositories/articles_repository_impl.dart';
import 'package:afiete/feature/articles/domain/repositories/articles_repository.dart';
import 'package:afiete/feature/articles/domain/usecases/articles_usecases.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';

// ✅ Assessments Feature
import 'package:afiete/feature/assessments/data/datasources/assisments_remote_datasource.dart';
import 'package:afiete/feature/assessments/data/repositories/assisments_repository_impl.dart';
import 'package:afiete/feature/assessments/domain/repositories/assisments_repository.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assisment_questions_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/submit_assisment_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assessment_scores_usecase.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';

// ✅ Feeling Feature
import 'package:afiete/feature/feeling/data/datasources/feeling_local_data_source.dart';
import 'package:afiete/feature/feeling/data/repositories/feeling_repository_impl.dart';
import 'package:afiete/feature/feeling/domain/repositories/feeling_repository.dart';
import 'package:afiete/feature/feeling/domain/usecase/feeling_usecases.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';

// ✅ Music & Breathing Feature

import 'package:afiete/feature/music_and_breathing/domain/repositories/music_repository.dart';
import 'package:afiete/feature/music_and_breathing/domain/usecase/get_recommended_music_usecase.dart';
import 'package:afiete/feature/music_and_breathing/presentation/cubit/music_cubit.dart';

// ✅ Notes Feature
import 'package:afiete/feature/notes/data/datasources/notes_local_datasource.dart';
import 'package:afiete/feature/notes/data/datasources/notes_remote_datasource.dart';
import 'package:afiete/feature/notes/data/repositories/notes_repository_impl.dart';
import 'package:afiete/feature/notes/domain/repositories/notes_repository.dart';
import 'package:afiete/feature/notes/domain/usecases/notes_usecase.dart';
import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';

// ✅ Prescription Feature
import 'package:afiete/feature/prespection/data/datasources/patient_prescription_remote_datasource.dart';
import 'package:afiete/feature/prespection/data/repositories/patient_prescription_repository_impl.dart';
import 'package:afiete/feature/prespection/domain/repositories/patient_prescription_repo.dart';
import 'package:afiete/feature/prespection/domain/usecases/prescription_usecase.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart';

// ✅ Settings Feature
import 'package:afiete/feature/settings/data/data_source/settings_remote_data_source.dart';
import 'package:afiete/feature/settings/data/repositories/settings_repository_impl.dart';
import 'package:afiete/feature/settings/domin/repositories/settings_repository.dart';
import 'package:afiete/feature/settings/domin/usecase/submit_report_issue_usecase.dart';
import 'package:afiete/feature/settings/presentation/cubits/settings_cubit.dart';

// ✅ Report Feature
import 'package:afiete/feature/report/data/datasources/report_remote_datasource.dart';
import 'package:afiete/feature/report/data/repositories/report_repository_impl.dart';
import 'package:afiete/feature/report/domain/usecases/report_usecase.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';

// ✅ Core Packages
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;
const bool useMockDataSources = false;
const String googleWebClientId =
    '1003547921607-12juc731vap30cbmmfjtkf38tr09ck8b.apps.googleusercontent.com';

Future<void> init() async {
  // ═══════════════════════════════════════════════════════════════
  // 🌐 CORE - Network & Storage
  // ═══════════════════════════════════════════════════════════════

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton<Dio>(() => DioFactory.create());

  // ═══════════════════════════════════════════════════════════════
  // 🔐 AUTH FEATURE - تسجيل الدخول والتسجيل
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      serverClientId: googleWebClientId,
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignupUseCase>(
    () => SignupUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ReactivateAccountUseCase>(
    () => ReactivateAccountUseCase(sl<AuthRepository>()),
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

  // Cubit
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

  // ═══════════════════════════════════════════════════════════════
  // 💬 CHAT FEATURE - المحادثات
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(sl<ChatRemoteDataSource>()),
  );

  // ✅ Course Repository (القديم - للـ Chat)
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepository(sl<Dio>()),
  );

  // Cubit
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(sl<ChatRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════
  // 📅 APPOINTMENTS FEATURE - المواعيد
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(
      dataSource: sl<AppointmentsRemoteDataSource>(),
    ),
  );

  // Use Cases
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

  // Cubit
  sl.registerFactory<AppointmentsCubit>(
    () => AppointmentsCubit(
      getAppointmentsUseCase: sl<GetAppointmentsUseCase>(),
      createAppointmentDraftUseCase: sl<CreateAppointmentUseCase>(),
      getAllDoctorsUseCase: sl<GetAllDoctorsUseCase>(),
      cancelAppointmentUseCase: sl<CancelAppointmentUseCase>(),
      rescheduleAppointmentUseCase: sl<RescheduleAppointmentUseCase>(),
      getAvailableSlotsUseCase: sl<GetAvailableSlotsUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🎓 COURSES FEATURE - الكورسات العلاجية (New)
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<CoursesRemoteDataSource>(
    () => CoursesRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetActiveCourseUseCase>(
    () => GetActiveCourseUseCase(sl()),
  );
  sl.registerLazySingleton<GetArchivedCoursesUseCase>(
    () => GetArchivedCoursesUseCase(sl()),
  );
  sl.registerLazySingleton<EndCourseUseCase>(
    () => EndCourseUseCase(sl()),
  );
  sl.registerLazySingleton<RequestContinueUseCase>(
    () => RequestContinueUseCase(sl()),
  );
  sl.registerLazySingleton<DeclineContinueUseCase>(
    () => DeclineContinueUseCase(sl()),
  );

  // Cubit
  sl.registerFactory<CoursesCubit>(
    () => CoursesCubit(
      getActiveCourseUseCase: sl(),
      getArchivedCoursesUseCase: sl(),
      endCourseUseCase: sl(),
      requestContinueUseCase: sl(),
      declineContinueUseCase: sl(),
      getAllDoctorsUseCase: sl(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 👨‍⚕️ DOCTORS FEATURE - الأطباء
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<DoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<DoctorsRepository>(
    () =>
        DoctorsRepositoryImpl(remoteDataSource: sl<DoctorsRemoteDataSource>()),
  );

  // Use Cases
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

  // Cubit
  sl.registerFactory<DoctorsCubit>(
    () => DoctorsCubit(
      sl<GetAllDoctorsUseCase>(),
      sl<GetDoctorsBySpecialtyUseCase>(),
      sl<GetDoctorByUsernameUseCase>(),
      sl<GetSpecialtiesUseCase>(),
      sl<GetAvailableSlotsUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🩺 SESSIONS FEATURE - الجلسات
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<SessionsRemoteDataSource>(
    () => SessionsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<SessionsRepository>(
    () => SessionsRepositoryImpl(dataSource: sl<SessionsRemoteDataSource>()),
  );

  // Use Cases
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

  // Cubit
  sl.registerFactory<SessionsCubit>(
    () => SessionsCubit(
      sl<GetUpcomingSessionsUseCase>(),
      sl<GetPastSessionsUseCase>(),
      sl<CancelSessionUseCase>(),
      sl<RescheduleSessionUseCase>(),
      sl<AddReviewUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 💳 PAYMENT FEATURE - الدفع
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dataSource: sl<PaymentRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<ProcessPaymentUseCase>(
    () => ProcessPaymentUseCase(sl<PaymentRepository>()),
  );

  // Cubit
  sl.registerFactory<PaymentCubit>(
    () => PaymentCubit(sl<ProcessPaymentUseCase>()),
  );

  // ═══════════════════════════════════════════════════════════════
  // 📰 ARTICLES FEATURE - المقالات
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<ArticlesRemoteDataSource>(
    () => ArticlesRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<ArticlesRepository>(
    () => ArticlesRepositoryImpl(
      remoteDataSource: sl<ArticlesRemoteDataSource>(),
    ),
  );

  // Use Cases
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

  // Cubit
  sl.registerFactory<ArticlesCubit>(
    () => ArticlesCubit(
      getTrendingArticlesUseCase: sl<GetTrendingArticlesUseCase>(),
      getArticlesByDoctorUseCase: sl<GetArticlesByDoctorUseCase>(),
      getAllArticlesUseCase: sl<GetAllArticlesUseCase>(),
      reactToArticleUseCase: sl<ReactToArticleUseCase>(),
      getRecommendedArticlesUseCase: sl<GetRecommendedArticlesUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 📝 ASSESSMENTS FEATURE - التقييمات
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<AssessmentsRemoteDataSource>(
    () => AssessmentsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<AssessmentsRepository>(
    () => AssessmentsRepositoryImpl(
      remoteDataSource: sl<AssessmentsRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetAssessmentsQuestionsUseCase>(
    () => GetAssessmentsQuestionsUseCase(sl<AssessmentsRepository>()),
  );
  sl.registerLazySingleton<SubmitAssessmentsUseCase>(
    () => SubmitAssessmentsUseCase(sl<AssessmentsRepository>()),
  );
  sl.registerLazySingleton<GetAssessmentScoresUseCase>(
    () => GetAssessmentScoresUseCase(sl<AssessmentsRepository>()),
  );

  // Cubit
  sl.registerFactory<AssessmentsCubit>(
    () => AssessmentsCubit(
      sl<GetAssessmentsQuestionsUseCase>(),
      sl<SubmitAssessmentsUseCase>(),
      sl<GetAllDoctorsUseCase>(),
      sl<GetDoctorsBySpecialtyUseCase>(),
      sl<GetAssessmentScoresUseCase>(),
    ),
  );
// ═══════════════════════════════════════════════════════════════
// 😊 FEELING FEATURE - المشاعر
// ═══════════════════════════════════════════════════════════════

// Data Sources
  sl.registerLazySingleton<FeelingLocalDataSource>(
    () => FeelingLocalDataSourceImpl(),
  );

// Repository
  sl.registerLazySingleton<FeelingRepository>(
    () => FeelingRepositoryImpl(localDataSource: sl<FeelingLocalDataSource>()),
  );

// Use Cases
  sl.registerLazySingleton<SaveFeelingUseCase>(
    () => SaveFeelingUseCase(sl<FeelingRepository>()),
  );
  sl.registerLazySingleton<GetCurrentFeelingUseCase>(
    () => GetCurrentFeelingUseCase(sl<FeelingRepository>()),
  );
  sl.registerLazySingleton<GetFeelingHistoryUseCase>(
    () => GetFeelingHistoryUseCase(sl<FeelingRepository>()),
  );

// ✅ Use Cases للـ FeelingCubit (تستخدم FeelingRepository)
  sl.registerLazySingleton<GetLastSelectedFeelingUseCase>(
    () => GetLastSelectedFeelingUseCase(sl<FeelingRepository>()),
  );
  sl.registerLazySingleton<SaveLastSelectedFeelingUseCase>(
    () => SaveLastSelectedFeelingUseCase(sl<FeelingRepository>()),
  );

// Cubit
  sl.registerFactory<FeelingCubit>(
    () => FeelingCubit(
      sl<GetLastSelectedFeelingUseCase>(),
      sl<SaveLastSelectedFeelingUseCase>(),
      sl<GetFeelingHistoryUseCase>(),
    ),
  );
// ═══════════════════════════════════════════════════════════════
// 🎵 MUSIC & BREATHING FEATURE - الموسيقى وتمارين التنفس
// ═══════════════════════════════════════════════════════════════

// Data Sources
// ✅ استخدم Mock Data Source للتجربة
  sl.registerLazySingleton<RelaxRemoteDataSource>(
    () => RelaxMockDataSource(),
  );

// Repository
  sl.registerLazySingleton<RelaxRepository>(
    () => RelaxRepositoryImpl(remoteDataSource: sl<RelaxRemoteDataSource>()),
  );

// Use Cases
  sl.registerLazySingleton<GetRecommendedMusicUseCase>(
    () => GetRecommendedMusicUseCase(sl<RelaxRepository>()),
  );
  sl.registerLazySingleton<GetBreathingExercisesUseCase>(
    () => GetBreathingExercisesUseCase(sl<RelaxRepository>()),
  );

// ✅ Use Cases للـ MusicCubit (تستخدم RelaxRepository)
  sl.registerLazySingleton<GetMusicLastSelectedFeelingUseCase>(
    () => GetMusicLastSelectedFeelingUseCase(sl<RelaxRepository>()),
  );
  sl.registerLazySingleton<SaveMusicLastSelectedFeelingUseCase>(
    () => SaveMusicLastSelectedFeelingUseCase(sl<RelaxRepository>()),
  );

// Cubit
  sl.registerFactory<MusicCubit>(
    () => MusicCubit(
      sl<GetRecommendedMusicUseCase>(),
      sl<GetBreathingExercisesUseCase>(),
      sl<GetMusicLastSelectedFeelingUseCase>(),
      sl<SaveMusicLastSelectedFeelingUseCase>(),
    ),
  );
  // ═══════════════════════════════════════════════════════════════
  // 📓 NOTES FEATURE - الملاحظات
  // ═══════════════════════════════════════════════════════════════

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
      localDataSource: sl<NoteLocalDataSource>(),
      remoteDataSource: sl<NoteRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<CreateNoteUseCase>(
    () => CreateNoteUseCase(sl<NoteRepository>()),
  );
  sl.registerLazySingleton<UpdateNoteUseCase>(
    () => UpdateNoteUseCase(sl<NoteRepository>()),
  );
  sl.registerLazySingleton<DeleteNoteUseCase>(
    () => DeleteNoteUseCase(sl<NoteRepository>()),
  );
  sl.registerLazySingleton<GetNotesUseCase>(
    () => GetNotesUseCase(sl<NoteRepository>()),
  );

  // Cubit
  sl.registerFactory<NotesCubit>(
    () => NotesCubit(
      createNoteUseCase: sl<CreateNoteUseCase>(),
      updateNoteUseCase: sl<UpdateNoteUseCase>(),
      deleteNoteUseCase: sl<DeleteNoteUseCase>(),
      getNotesUseCase: sl<GetNotesUseCase>(),
      repository: sl<NoteRepository>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 💊 PRESCRIPTION FEATURE - الوصفات الطبية
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<PatientPrescriptionRemoteDataSource>(
    () => PatientPrescriptionRemoteDataSource(
      dio: sl<Dio>(),
      baseUrl: DioFactory.baseUrl,
      getToken: () => TokenStorage.getAccessToken(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PatientPrescriptionRepository>(
    () => PatientPrescriptionRepositoryImpl(
      remoteDataSource: sl<PatientPrescriptionRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetPatientPrescriptions>(
    () => GetPatientPrescriptions(sl<PatientPrescriptionRepository>()),
  );
  sl.registerLazySingleton<GetPatientPrescriptionDetail>(
    () => GetPatientPrescriptionDetail(sl<PatientPrescriptionRepository>()),
  );
  sl.registerLazySingleton<DownloadPrescriptionHtml>(
    () => DownloadPrescriptionHtml(sl<PatientPrescriptionRepository>()),
  );

  // Bloc
  sl.registerFactory<PatientPrescriptionsBloc>(
    () => PatientPrescriptionsBloc(
      getPrescriptions: sl<GetPatientPrescriptions>(),
      getPrescriptionDetail: sl<GetPatientPrescriptionDetail>(),
      downloadPrescriptionHtml: sl<DownloadPrescriptionHtml>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // ⚙️ SETTINGS FEATURE - الإعدادات
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: sl<SettingsRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SubmitReportIssueUseCase>(
    () => SubmitReportIssueUseCase(sl<SettingsRepository>()),
  );

  // Cubit
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<SubmitReportIssueUseCase>()),
  );

  // ═══════════════════════════════════════════════════════════════
  // 📊 REPORT FEATURE - التقارير
  // ═══════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<ReportsRemoteDataSourceImpl>(
    () => ReportsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<ReportsRepositoryImpl>(
    () => ReportsRepositoryImpl(
      remoteDataSource: sl<ReportsRemoteDataSourceImpl>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetReportConfigUseCase>(
    () => GetReportConfigUseCase(sl<ReportsRepositoryImpl>()),
  );
  sl.registerLazySingleton<GetMyReportsUseCase>(
    () => GetMyReportsUseCase(sl<ReportsRepositoryImpl>()),
  );
  sl.registerLazySingleton<CreateAppReportUseCase>(
    () => CreateAppReportUseCase(sl<ReportsRepositoryImpl>()),
  );

  // Cubit
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
}
