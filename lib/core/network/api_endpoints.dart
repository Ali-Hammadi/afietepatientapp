abstract class ApiEndpoints {
  static const String api = '/api';

  static const String auth = '/api';
  static const String doctors = '/api/doctors';
  static const String articles = '/api/articles';
  static const String assessments = '$api/assessments';
  // Swagger shows "appointmetns" (historic typo) — keep as primary to match server
  static const String appointments = '$api/appointmetns';
  // Legacy/alternate spelling preserved for local compat
  static const String appointmentsLegacy = '/api/appointments';
  static const String sessions = '/api/sessions';
  static const String settings = '/api/settings';
  static const String assisments = assessments; // legacy typo alias
  static const String reports = '/api/reports';
  static const String relax = '/api/relax';
  static const String voice = '/voice';
  static const String video = '/video';
  static const String users = '$api/users';
  static const String patients = '$api/patients';
  static const String token = '$api/token';

  // === Core Auth Endpoints ===
  static const String login = '$users/login/';
  static const String signup = '$patients/register/';
  static const String logout = '$users/logout/';
  static const String deactivateAccount = '$users/deactivate';
  static const String deleteAccount = deactivateAccount;
  static const String activateAccount = '$users/activate';
  static const String googleLogin = '$patients/google/auth/';

  // === User Profile ===
  static const String profile = '$patients/profile/';

  // === OTP Verification (Signup/Login Flow) ===
  static const String otpResend = '$users/otp/resend';
  static const String otpVerify = '$users/otp/verify';

  // === Email Change (Settings) ===
  static const String emailChangeRequest = '$users/email/reset';
  static const String emailChangeVerify = '$users/otp/verify';

  // === Password Management ===
  static const String passwordReset = '$users/auth/reset-password/';
  static const String passwordChange = '$users/password/change';
  static const String forgotPasswordOtp = '$users/auth/forgot-password/';
  static const String forgotPasswordVerifyOtp = '$users/auth/verify-otp/';

  // === Token Management ===
  static const String tokenObtainPair = '$token/';
  static const String tokenRefresh = '$token/refresh/';
  static const String tokenVerify = '$token/verify/';

  // === Assessments ===
  static const String assessmentsDoctorsRecommend =
      '$assessments/doctors/recommend/';
  static const String assessmentsForm = '$assessments/form/';
  static const String assessmentsFormSubmit = '$assessments/form/submit/';
  static const String assessmentsScores = '$assessments/scores/';

  // Auth request keys
  static const String keyEmail = 'email';
  static const String keyNewEmail = 'new_email';
  static const String keyPassword = 'password';
  static const String keyCurrentPassword = 'current_password';
  static const String keyNewPassword = 'new_password';
  static const String keyOtp = 'code';
  static const String keyAnswers = 'answers';
  static const String keyQuestionId = 'question_id';
  static const String keyAnswerId = 'answer_id';
  static const String keyRefresh = 'refresh';
  static const String keyToken = 'token';
  static const String keyIdToken = 'id_token';

  static const String allDoctors = '$doctors/';
  static String doctorById(String id) => '$doctors/$id/';
  static String doctorPublicProfile(String username) =>
      '$doctors/$username/profile/public';
  static String doctorAvailableSlots(String username, {String? date}) {
    final base = '$doctors/$username/available-slots/';
    return date != null ? '$base?date=$date' : base;
  }
  static const String doctorRegister = '$doctors/register/';
  // Align with Swagger paths: profile update at /doctors/profile/
  static const String doctorProfileUpdate = '$doctors/profile/';
  // Education endpoints per Swagger: add via /doctors/education/add
  static const String doctorEducationAdd = '$doctors/education/add';
  static String doctorEducationById(String id) => '$doctors/education/$id/';
  // Doctor schedule endpoints (per Swagger)
  static const String doctorScheduleList = '$doctors/schedule/';
  static const String doctorScheduleCreate = '$doctors/schedule/';
  static String doctorScheduleById(String id) => '$doctors/schedule/$id/';
  static String doctorScheduleUpdate(String id) => '$doctors/schedule/$id/';
  static String doctorScheduleDelete(String id) => '$doctors/schedule/$id/';
  // Appointments -> doctors prices under the "appointmetns" base (Swagger)
  static const String appointmentsDoctorsPrices =
      '$appointments/dcotors/prices/';
  static String appointmentsDoctorsPricesByType(String type) =>
      '$appointments/dcotors/prices/$type/';

  // Articles endpoints
  static const String allArticles = '$articles/';
  static String articleById(String id) => '$articles/$id/';
  static String articlesByDoctor(String doctorId) =>
      '$doctors/$doctorId/articles/';
  static const String articleCreate = '$articles/create/';
  static const String articlesRecommended = '$articles/recommended/';
  static const String articlesTrending = '$articles/trending/';
  static String articleReact(String articleId) => '$articles/$articleId/react';
  static String articleRemove(String articleId) =>
      '$articles/remove/$articleId';

  // Articles query/body keys for doctor linkage and filtering
  static const String keyDoctor = 'doctor';
  static const String keyDoctorId = 'doctor_id';
  static const String keyUserDiagnosis = 'user_diagnosis';
  static const String keyRelatedConditions = 'related_conditions';
  static const String keyPage = 'page';
  static const String keyPageSize = 'page_size';

  static const String appointmentsList = '$appointments/list';
  static const String appointmentsCreate = '$appointments/create';
  static const String appointmentsCancel = '$appointments/cancel';
  static const String appointmentsReschedule = '$appointments/reschedule';

  static const String sessionsUpcoming = '$sessions/upcoming';
  static const String sessionsPast = '$sessions/past';
  static const String sessionsJoin = '$sessions/join';
  static const String sessionsCancel = '$sessions/cancel';
  static const String sessionsReschedule = '$sessions/reschedule';
  static const String sessionsReview = '$sessions/review';

  static const String settingsMedicalProfile = '$settings/medical-profile';
  static const String settingsMedicalProfileNotes =
      '$settings/medical-profile/notes';
  static const String settingsMedicalProfileNotesShare =
      '$settings/medical-profile/notes/share';
  static const String settingsReports = '$settings/reports';

  static const String assismentQuestions = assessmentsForm;
  static const String assismentSubmit = assessmentsFormSubmit;

  static const String reportsSubmit = '$reports/submit';
  static const String reportsHistory = '$reports/history';
  static const String reportsByType = '$reports/by-type';

  // Relax endpoints (per API spec)
  static const String relaxBreathingExercises = '$relax/breathing-exercises/';
  static const String relaxFeelingLast = '$relax/feeling/last/';
  static const String relaxRecommendations = '$relax/recommendations/';

  static const String voiceCalls = '$voice/calls';
  static const String voiceCallsStart = '$voice/calls/start';
  static String voiceCallsEnd(String callId) => '$voice/calls/$callId/end';

  static const String videoCalls = '$video/calls';
  static const String videoCallsStart = '$video/calls/start';
  static String videoCallsEnd(String callId) => '$video/calls/$callId/end';
}
