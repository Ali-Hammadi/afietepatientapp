abstract class ApiEndpoints {
  // ===============================================================================================
  // === Core Auth Endpoints ===
  static const String login = '/api/auth/login/';
  static const String signup = '/api/patient/register/';
  static const String logout = '/api/auth/logout/';
  static const String deactivateAccount = '/api/auth/deactivate/';
  static const String deleteAccount = deactivateAccount;
  static const String activateAccount = '/api/auth/activate/';
  static const String googleLogin = '/api/patient/google/auth/';
  // ===============================================================================================
  // === User Profile ===
  static const String profile = '/api/patient/profile/';
  // ===============================================================================================
  // === OTP Verification (Signup/Login Flow) ===
  static const String otpResend = '/api/auth/otp/resend/';
  static const String otpVerify = '/api/auth/otp/verify/';
  // ===============================================================================================
  // === Password Management ===
  static const String passwordReset = '/api/auth/forgot-password/reset/';
  static const String forgetPassword = '/api/auth/forgot-password/';
  static const String passwordChange = '/api/auth/password/change/';
  static const String forgotPasswordOtp =
      '/api/auth/forgot-password/verify-otp/';
  // ===============================================================================================
  // === Token Management ===
  static const String refreshToken = '/api/auth/token/refresh/';
  static const String accessToken = '/api/auth/token/verify/';
  // ===============================================================================================
  // === Appointments  ===

  static const String createAppointment = '/api/patient/appointments/book/';

  static const String myAppointments = '/api/patient/appointments/my-list/';

  static const String historyAppointments =
      '/api/patient/appointments/history/';

  static const String missedAppointments = '/api/patient/appointments/missed/';

  static String myAppointment(String id) => '/api/patient/appointments/$id/';

  static String cancelAppointment(String id) =>
      '/api/patient/appointments/$id/cancel/';

  static String reschedualAppointment(String id) =>
      '/api/patient/appointments/$id/reschedule/';

  static String hasNextAppointment(String id) =>
      '/api/patient/appointments/$id/next-session/';

  static String appointmentRefund(String id) =>
      '/api/patient/appointments/$id/refund/';
  // === Appointments Payments (المدفوعات) ===

  static const String appointmentPayment =
      '/api/patient/appointments/payments/create/';

  static const String oldAppointmentPayment =
      '/api/patient/appointments/payments/history/';

  // ===============================================================================================
  // === Reports ===
  static const String reportsConfig = '/api/reports/config/';
  static const String appReports = '/api/reports/app/create/';
  static const String myReports = '/api/reports/my-reports/';
  static const String reportOnUser = '/api/reports/user/create/';
  // ===============================================================================================
  // === Rating & Comments ===
  static String rateAppointment(String appointment_id) =>
      '/api/patient/ratings/$appointment_id/create/';
  static String ratings = "/api/patient/ratings/";
  static String rateDoctorByUsername(String doctor_username) =>
      '/api/patient/ratings/$doctor_username/';

  // ===============================================================================================
  // === Assessments ===
  static const String assessmentsDoctorsRecommend =
      '/api/patient/assessment/doctors/recommend/';
  static const String assessmentsForm = '/api/patient/assessment/form/';
  static const String assessmentsFormSubmit =
      '/api/patient/assessment/form/submit/';
  static const String Assessmentscores = '/api/patient/assessment/scores/';

  // ===============================================================================================
  // === Prescription ===
  static const String prescription = '/api/patient/prescriptions/';
  static String getPrescription(dynamic id) =>
      '/api/patient/prescriptions/$id/';

  // ===============================================================================================
  // === Notes ===
  static const String notes = '/api/patient/notes/';

  // ===============================================================================================
  // === Doctors ===
  static const String recommendedDoctors =
      '/api/patient/assessment/doctors/recommend/';

  static const String allDoctors = '/api/patient/doctors/';

  static const String allSpecialties = '/api/patient/doctors/specialties/';

  static String getDoctorsBySpecialty(String specialties) =>
      '/api/patient/doctors/$specialties/';

  static String doctorByUsername(String doctorUsername) =>
      '/api/patient/doctors/$doctorUsername/';

  static String doctorPublicProfile(String doctorUsername) =>
      '/api/patient/doctors/$doctorUsername/profile/public/';

  static String doctorAvailableSlots(String doctorUsername) =>
      '/api/patient/doctors/$doctorUsername/available_slots/';

  // ===============================================================================================
  // === Articles ===

  static String articleById(String id) => '/api/patient/articles/$id/';
  static String articlesByDoctor(String username) =>
      '/api/patient/articles/doctor/$username/';
  static const String articlesRecommended =
      '/api/patient/articles/recommended/';
  static const String articlesFeed = '/api/patient/articles/feed/';
  static const String articlesTrending = '/api/patient/articles/trending/';
  static String articleReact(String article_id) =>
      '/api/patient/articles/$article_id/react/';
  // ===============================================================================================
  // === Relax endpoints (per API spec) ===
  static const String relaxBreathingExercises =
      '/api/patient/assessment/breathing-exercises/';
  static const String relaxFeelingLast =
      '/api/patient/assessment/feeling/last/';

  /// Empty Link
  static const String relaxRecommendedTracks = '';
  // ===============================================================================================
  // === Medical Profile ===
  /// Fake Link
  static const String settingsMedicalProfile = '/api/patient/medical-profile/';
  // ===============================================================================================
  // === Video call Endpoints ===
  /// Fake Links (to be updated with real endpoints when available)
  static const String videoCalls = '/api/patient/videoCalls/token/';
  static const String videoCallsStart = '/api/patient/videoCallsStart/token/';
  static String videoCallsEnd(String id) => '/api/patient/videoCallsEnd/token/';
  // ===============================================================================================
  // === Voice call Endpoints ===
  /// Fake Links (to be updated with real endpoints when available)
  static const String voiceCalls = '/api/patient/videoCalls/token/';
  static const String voiceCallsStart = '/api/patient/videoCallsStart/token/';
  static String voiceCallsEnd(String id) => '/api/patient/videoCallsEnd/token/';
  // ===============================================================================================
}
