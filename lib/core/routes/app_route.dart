import 'package:afiete/core/constants/report_types.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/appointments/presentation/screens/reschedule_session_screen.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_state.dart';
import 'package:afiete/feature/assessments/presentation/screens/assisment_result_screen.dart';
import 'package:afiete/feature/assessments/presentation/screens/assisment_test_screen.dart';

import 'package:afiete/feature/auth/presentation/views/auth_info_screen.dart';
import 'package:afiete/feature/auth/presentation/views/delete_account_screen.dart';

import 'package:afiete/feature/auth/presentation/views/forgot_password_screen.dart';
import 'package:afiete/feature/auth/presentation/views/password_change_screen.dart';
import 'package:afiete/feature/auth/presentation/views/reactivate_account_screen.dart';
import 'package:afiete/feature/auth/presentation/views/verify_account_screen.dart';
import 'package:afiete/feature/auth/domain/entities/auth_user_entity.dart';
import 'package:afiete/feature/appointments/presentation/screens/appointments_screen.dart';
import 'package:afiete/feature/appointments/presentation/screens/book_session_screen.dart';
import 'package:afiete/feature/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/screens/doctor_info_screen.dart';
import 'package:afiete/feature/doctors/presentation/screens/doctors_home_screen.dart';
import 'package:afiete/feature/home/presentation/screens/first_home_screen.dart';
import 'package:afiete/feature/home/presentation/screens/global_home_screen.dart';
import 'package:afiete/feature/payment/domain/entities/payment_request_entity.dart';
import 'package:afiete/feature/payment/presentation/screens/payment_screen.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';
import 'package:afiete/feature/report/presentation/screens/report_history_screen.dart';
import 'package:afiete/feature/report/presentation/screens/report_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/contact_us_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/medical_profile_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/privacy_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/profile_info_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/report_issue_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/settings_screen.dart';
import 'package:afiete/feature/sessions/presentation/screens/my_sessions_screen.dart';
import 'package:afiete/feature/splash/presentation/views/splash_screen.dart';
import 'package:afiete/feature/auth/presentation/views/signup_screen.dart';
import 'package:afiete/feature/auth/presentation/views/login_screen.dart';
import 'package:afiete/feature/splash/presentation/views/welcome_screens.dart';
import 'package:afiete/feature/articles/presentation/screens/articles_list_screen.dart';
import 'package:afiete/feature/articles/presentation/screens/article_details_screen.dart';
import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MyRoutes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case MyRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      case MyRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case MyRoutes.welcomeScreens:
        return MaterialPageRoute(builder: (_) => const WelcomeScreens());
      case MyRoutes.homeScreen:
        final homeArgs = settings.arguments;
        final initialIndex = homeArgs is int ? homeArgs : 0;
        return MaterialPageRoute(
          builder: (_) => GlobalHomeScreen(initialIndex: initialIndex),
        );
      case MyRoutes.firstHomeScreen:
        return MaterialPageRoute(builder: (_) => const FirstHomeScreen());
      case MyRoutes.verifyAccountScreen:
        final email =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => VerifyAccountScreen(email: email),
        );
      case MyRoutes.reactivateAccountScreen:
        final args = settings.arguments;
        final reactivation = args is AccountReactivationRequired ? args : null;
        return MaterialPageRoute(
          builder: (_) => ReactivateAccountScreen(
            email: reactivation?.email ?? '',
            password: reactivation?.password ?? '',
            message: reactivation?.message ?? '',
          ),
        );
      case MyRoutes.authInfoScreens:
        return MaterialPageRoute(builder: (_) => const AuthInfoScreen());

      case MyRoutes.passwordChangeScreen:
        return MaterialPageRoute(builder: (_) => const PasswordChangeScreen());
      case MyRoutes.deleteAccountScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<AuthCubit>(),
            child: const DeleteAccountScreen(),
          ),
        );
      case MyRoutes.forgotPasswordScreen:
        final initialEmail =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(initialEmail: initialEmail),
        );
      case MyRoutes.doctorInfoScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              DoctorInfo(doctor: args is DoctorEntity ? args : null),
        );
      case MyRoutes.bookSessionScreen:
        final args = settings.arguments;
        final doctor = args is DoctorEntity
            ? args
            : args is Map<String, dynamic>
                ? args['doctor'] as DoctorEntity?
                : null;

        if (doctor == null) {
          return MaterialPageRoute<Map<String, dynamic>?>(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text(
                  'Doctor data is required to start booking.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }

        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => BookSessionScreen(
            doctor: doctor,
          ),
        );
      case MyRoutes.doctorsHomeScreen:
        return MaterialPageRoute(builder: (_) => const DoctorsHomeScreen());

      case MyRoutes.rescheduleSessionScreen:
        final args = settings.arguments;
        final doctor = args is DoctorEntity
            ? args
            : args is Map<String, dynamic>
                ? args['doctor'] as DoctorEntity?
                : null;

        if (doctor == null) {
          return MaterialPageRoute<Map<String, dynamic>?>(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text(
                  'Doctor data is required to reschedule.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => RescheduleSessionScreen(doctor: doctor),
        );
      case MyRoutes.appointmentsScreen:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case MyRoutes.paymentScreen:
        final args = settings.arguments;
        if (args is! PaymentRequestEntity) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text(
                  'Payment details are required.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => PaymentScreen(request: args));
      case MyRoutes.mySessionsScreen:
        return MaterialPageRoute(builder: (_) => const MySessionsScreen());
      case MyRoutes.chatConversationScreen:
        final args = settings.arguments;
        if (args is! ChatConversationArgs) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text(
                  'Chat conversation data is required.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ChatConversationScreen(args: args),
        );
      case MyRoutes.settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case MyRoutes.medicalProfileScreen:
        return MaterialPageRoute(builder: (_) => const MedicalProfileScreen());
      case MyRoutes.profileInfoScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ProfileInfoScreen(
            initialUser: args is UserAuthEntity ? args : null,
          ),
        );
      case MyRoutes.reportIssueScreen:
        return MaterialPageRoute(builder: (_) => const ReportIssueScreen());
      case MyRoutes.privacyScreen:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
      case MyRoutes.contactUsScreen:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());
      case MyRoutes.assessmentsTestScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AssessmentsCubit>(
            create: (_) => sl<AssessmentsCubit>()..loadQuestions(),
            child: const AssessmentsTestScreen(),
          ),
        );
      case MyRoutes.assessmentsResultScreen:
        final args = settings.arguments;
        if (args is! AssessmentsResultLoaded) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: const Text(
                  'Invalid arguments for assignment result screen',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AssessmentsResultScreen(state: args),
        );

      case MyRoutes.reportScreen:
        final args = settings.arguments;
        final reportArgs = args is ReportScreenArgs
            ? args
            : args is Map<String, dynamic>
                ? ReportScreenArgs(
                    // استخدام الـ Extension الذي قمنا ببنائه لمنع الكراش وتحويل النص لـ Enum بآمان
                    reportType: args['reportType'] is String
                        ? ReportTypeExtension.fromString(
                            args['reportType'] as String)
                        : args['reportType'] as ReportType,
                    reportedUsername: args['reportedUserId'],
                    sessionId: args['sessionId'] as String?,
                    reportedName: args['reportedName'] as String?,
                  )
                : null;

        // إذا كان البلاغ سلوكي (طبيب أو جلسة) ولم نمرر البيانات الأساسية، نرفع شاشة الخطأ حماية للسيستم
        if (reportArgs == null) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("خطأ في البيانات")),
              body: Center(
                child: Text(
                  SettingsStrings.unCompletedReportInformation,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportCubit>(
            create: (_) => sl<ReportCubit>(),
            child: ReportScreen(
              reportedUsername: reportArgs
                  .reportedUsername, // تمرير الـ ID لطبقة الـ Presentation
              targetName: reportArgs.reportedName, // تمرير الاسم للعرض الشكلي
            ),
          ),
        );
      case MyRoutes.reportHistoryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportCubit>(
            create: (_) => sl<ReportCubit>(),
            child: ReportHistoryScreen(),
          ),
        );

      case MyRoutes.articlesListScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ArticlesListScreen(
            doctorUsername: args?['doctorId'],
            doctorName: args?['doctorName'],
            userDiagnosis: args?['userDiagnosis'],
          ),
        );

      case MyRoutes.articleDetailsScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailsScreen(
            article: args is ArticleEntity ? args : null,
            articleId: args is String
                ? args
                : (args is ArticleEntity ? args.id : null),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: const Text(
                'Route not found',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}

class ReportScreenArgs {
  final ReportType reportType;
  final String?
      reportedUsername; // المعرف الرقمي للمستخدم المشكو بحقه (مهم جداً)
  final String? sessionId; // معرف الجلسة إذا كان البلاغ متعلق بموعد
  final String? reportedName; // الاسم الذي سيظهر في الواجهة (طبيب أو مريض)

  const ReportScreenArgs({
    required this.reportType,
    this.reportedUsername,
    this.sessionId,
    this.reportedName,
  });
}

class MyRoutes {
  // Splash Screen
  static const String splashScreen = "/splashScreen";
  // Authentication Screens
  static const String signup = "/signup";
  static const String login = "/login";
  static const String welcomeScreens = "/welcomeScreens";
  static const String verifyAccountScreen = "/verifyAccountScreen";
  static const String reactivateAccountScreen = "/reactivateAccountScreen";
  static const String authInfoScreens = "/authInfoScreens";

  static const String passwordChangeScreen = "/passwordChangeScreen";
  static const String deleteAccountScreen = "/deleteAccountScreen";
  static const String forgotPasswordScreen = "/forgotPasswordScreen";
  // Home Screens
  // Sessions Screens
  static const String mySessionsScreen = "/mySessionsScreen";
  static const String chatConversationScreen = "/chatConversationScreen";
  static const String homeScreen = "/homeScreens";
  static const String firstHomeScreen = "/firstHomeScreen";
  static const String doctorInfoScreen = "/doctorInfoScreen";
  static const String bookSessionScreen = "/bookSessionScreen";
  static const String paymentScreen = "/paymentScreen";
  static const String doctorsHomeScreen = "/doctorsHomeScreen";
  static const String appointmentsScreen = "/appointmentsScreen";
  static const String rescheduleSessionScreen = "/rescheduleSessionScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String medicalProfileScreen = "/medicalProfileScreen";
  static const String profileInfoScreen = "/profileInfoScreen";
  static const String reportIssueScreen = "/reportIssueScreen";
  static const String privacyScreen = "/privacyScreen";
  static const String contactUsScreen = "/contactUsScreen";
  static const String assessmentsTestScreen = "/assessmentsTestScreen";
  static const String assessmentsResultScreen = "/assessmentsResultScreen";
  // Report Screens
  static const String reportScreen = "/reportScreen";
  static const String reportHistoryScreen = "/reportHistoryScreen";
  // Articles Screens
  static const String articlesListScreen = "/articlesListScreen";
  static const String articleDetailsScreen = "/articleDetailsScreen";
}
