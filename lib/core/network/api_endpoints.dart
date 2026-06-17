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
  // === Appointments ===
  static const String createAppointment = '/api/patient/appointments/book/';
  static const String historyAppointments =
      '/api/patient/appointments/history/';
  static const String missedAppointments = '/api/patient/appointments/missed/';
  static String reschedualAppointment(String id) =>
      '/api/patient/appointments/{$id}/reschedule/';
  static String myAppointment(String id) => '/api/patient/appointments/{$id}/';
  static const String myAppointments = '/api/patient/appointments/my-list/';
  static String cancelAppointment(String id) =>
      '/api/patient/appointments/{$id}/cancel/';
  static String hasNextAppointment(String id) =>
      '/api/patient/appointments/{$id}/next-session/';
  static String appointmentRefund(String appointment_id) =>
      '/api/patient/appointments/{$appointment_id}/refund/';
  // === Appointments Payments ===
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
      '/api/patient/ratings/{$appointment_id}/create/';
  static String ratings = "/api/patient/ratings/";
  static String rateDoctorByUsername(String doctor_username) =>
      '/api/patient/ratings/{$doctor_username}/';

  // ===============================================================================================
  // === Assessments ===
  static const String assessmentsDoctorsRecommend =
      '/api/patient/assessment/doctors/recommend/';
  static const String assessmentsForm = '/api/patient/assessment/form/';
  static const String assessmentsFormSubmit =
      '/api/patient/assessment/form/submit/';
  static const String assessmentsScores = '/api/patient/assessment/scores/';

  // ===============================================================================================
  // === Notes ===
  static const String notes = '/api/patient/notes/';
  static String notesId(String id) => '/api/patient/notes/{$id}';

  // ===============================================================================================
  // === Doctors ===
  static const String recommendedDoctors =
      '/api/patient/assessment/doctors/recommend/';

  static const String allDoctors = '/api/patient/doctors/';

  static String getDoctorsBySpecialty(String specialty) =>
      '/api/patient/doctors/specialties/';

  static String doctorByUsername(String doctor_username) =>
      '/api/patient/doctors/{$doctor_username}/';

  static String doctorPublicProfile(String doctor_username) =>
      '/api/patient/doctors/{$doctor_username}/profile/public/';

  static String doctorAvailableSlots(String doctor_username, {String? date}) {
    final base = '/api/patient/doctors/{$doctor_username}/available-slots/';
    return date != null ? '$base?date=$date' : base;
  }

  // ===============================================================================================
  // === Articles ===
  // static const String allArticles = '$articles/';
  static String articleById(String id) => '/api/patient/articles/{$id}/';
  // static String articlesByDoctor(String doctorId) =>
  //     '$doctors/$doctorId/articles/';
  static const String articlesRecommended =
      '/api/patient/articles/recommended/';
  static const String articlesFeed = '/api/patient/articles/feed/';
  static const String articlesTrending = '/api/patient/articles/trending/';
  static String articleReact(String article_id) =>
      '/api/patient/articles/{$article_id}/react/';

  // Articles query/body keys for doctor linkage and filtering

  // ===============================================================================================
  // Relax endpoints (per API spec)
  static const String relaxBreathingExercises =
      '/api/patient/assessment/breathing-exercises/';
  static const String relaxFeelingLast =
      '/api/patient/assessment/feeling/last/';
  // ===============================================================================================
}
