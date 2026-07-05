import 'package:afiete/core/di/injection_container.dart' as di;
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/appointments/presentation/screens/reschedule_session_screen.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/screens/special_doctor_article_list_screen.dart';
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
import 'package:afiete/feature/chat/presentation/screens/chat_screen.dart';
import 'package:afiete/feature/cources/presentation/cubit/cources_cubit.dart';
import 'package:afiete/feature/cources/presentation/pages/cources_screen.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/screens/doctor_info_screen.dart';
import 'package:afiete/feature/doctors/presentation/screens/doctors_home_screen.dart';
import 'package:afiete/feature/home/presentation/screens/first_home_screen.dart';
import 'package:afiete/feature/home/presentation/screens/global_home_screen.dart';
import 'package:afiete/feature/notes/presentation/pages/create_note_screen.dart';
import 'package:afiete/feature/notes/presentation/pages/notes_list_screen.dart';
import 'package:afiete/feature/payment/domain/entities/payment_request_entity.dart';
import 'package:afiete/feature/payment/presentation/screens/payment_screen.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_event.dart';
import 'package:afiete/feature/prespection/presentation/pages/patient_prescription_detail_page.dart';
import 'package:afiete/feature/prespection/presentation/pages/patient_prescriptions_screen.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';
import 'package:afiete/feature/report/presentation/screens/report_history_screen.dart';
import 'package:afiete/feature/report/presentation/screens/report_issue_screen.dart';
import 'package:afiete/feature/report/presentation/screens/report_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/contact_us_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/privacy_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/profile_info_screen.dart';
import 'package:afiete/feature/settings/presentation/screens/settings_screen.dart';
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

      case MyRoutes.doctorSpecialArticleScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SpecialDoctorArticleListScreen(
            doctorUsername: args?['doctorUsername'],
            doctorName: args?['doctorName'],
            userDiagnosis: args?['userDiagnosis'],
          ),
        );
      case MyRoutes.doctorInfoScreen:
        final doctor = settings.arguments as DoctorEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ArticlesCubit>(
            create: (context) => sl<ArticlesCubit>(),
            child: DoctorInfo(doctor: doctor),
          ),
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
// في onGenerateRoute
      // في onGenerateRoute
      case MyRoutes.chatScreen:
        final args = settings.arguments;

        if (args is ChatConversationArgs) {
          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              courseId: args.courseId,
              doctorName: args.doctorName,
              patientName: null,
              doctorImageUrl: args.doctorImageUrl, // ✅ تمرير imageUrl
              readOnly: args.readOnly,
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => const ChatScreen(
            courseId: '',
            doctorName: 'Chat',
          ),
          settings: settings,
        );
      case MyRoutes.notesListScreen:
        return MaterialPageRoute(builder: (_) => const NotesListScreen());
      case MyRoutes.createNoteScreen:
        return MaterialPageRoute(builder: (_) => const CreateNoteScreen());
      case MyRoutes.settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case MyRoutes.patientPrescriptionsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<PatientPrescriptionsBloc>()
              ..add(LoadPatientPrescriptions()),
            child: const PatientPrescriptionsScreen(),
          ),
        );
      case MyRoutes.coursesScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<CoursesCubit>(),
            child: const CoursesScreen(),
          ),
          settings: settings,
        );

      case MyRoutes.patientPrescriptionDetailPage:
        final prescriptionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<PatientPrescriptionsBloc>()
              ..add(LoadPatientPrescriptionDetail(prescriptionId)),
            child: PatientPrescriptionDetailPage(
              prescriptionId: prescriptionId,
            ),
          ),
        );

      case MyRoutes.profileInfoScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ProfileInfoScreen(
            initialUser: args is UserAuthEntity ? args : null,
          ),
        );

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
      case MyRoutes.reportIssueScreen:
        return MaterialPageRoute(
          builder: (_) => const ReportIssueScreen(),
        );
      case MyRoutes.reportScreen:
        final args = settings.arguments;

        String? reportedUsername;
        String? targetName;

        if (args is ReportScreenArgs) {
          reportedUsername = args.reportedUsername;
          targetName = args.targetName;
        } else if (args is Map<String, dynamic>) {
          reportedUsername = args['reportedUsername'] as String?;
          targetName =
              args['targetName'] as String? ?? args['reportedName'] as String?;
        }

        final isUserReport =
            reportedUsername != null && reportedUsername.trim().isNotEmpty;

        if (isUserReport) {
        } else if (args != null && !isUserReport) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(SettingsStrings.reportIssueTitle)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    SettingsStrings.unCompletedReportInformation,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportCubit>(
            create: (_) => sl<ReportCubit>(),
            child: ReportScreen(
              reportedUsername: reportedUsername,
              targetName: targetName,
            ),
          ),
        );

      case MyRoutes.reportHistoryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReportCubit>(
            create: (_) => sl<ReportCubit>(),
            child: const ReportHistoryScreen(),
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
  final String? reportedUsername;
  final String? targetName;

  const ReportScreenArgs({
    this.reportedUsername,
    this.targetName,
  });

  factory ReportScreenArgs.appReport() {
    return const ReportScreenArgs(
      reportedUsername: null,
      targetName: null,
    );
  }
  factory ReportScreenArgs.userReport({
    required String username,
    String? displayName,
  }) {
    return ReportScreenArgs(
      reportedUsername: username,
      targetName: displayName ?? username,
    );
  }
}

// lib/core/routes/chat_args.dart
class ChatConversationArgs {
  const ChatConversationArgs({
    required this.courseId,
    required this.doctorName,
    required this.currentUserId,
    this.doctorImageUrl, // ✅ إضافة parameter للصورة
    this.readOnly = false,
  });

  final String courseId;
  final String doctorName;
  final String currentUserId;
  final String? doctorImageUrl; // ✅ إضافة parameter للصورة
  final bool readOnly;
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
  static const String chatScreen = "/chatScreen";
  static const String homeScreen = "/homeScreens";
  static const String firstHomeScreen = "/firstHomeScreen";
  static const String doctorInfoScreen = "/doctorInfoScreen";
  static const String bookSessionScreen = "/bookSessionScreen";
  static const String paymentScreen = "/paymentScreen";
  static const String doctorsHomeScreen = "/doctorsHomeScreen";
  static const String appointmentsScreen = "/appointmentsScreen";
  static const String rescheduleSessionScreen = "/rescheduleSessionScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String patientPrescriptionsScreen =
      "/patientPrescriptionsScreen";
  static const String patientPrescriptionDetailPage =
      "/patientPrescriptionDetailPage";
  static const String profileInfoScreen = "/profileInfoScreen";
  static const String privacyScreen = "/privacyScreen";
  static const String contactUsScreen = "/contactUsScreen";
  static const String notesListScreen = "/notesListScreen";
  static const String createNoteScreen = "/createNoteScreen";
  static const String assessmentsTestScreen = "/assessmentsTestScreen";
  static const String assessmentsResultScreen = "/assessmentsResultScreen";
  // Report Screens
  static const String reportScreen = "/reportScreen";
  static const String reportHistoryScreen = "/reportHistoryScreen";
  static const String reportIssueScreen = '/report-issue';
  // Cources Screens
  static const String coursesScreen = '/courses';

  // Articles Screens
  static const String articlesListScreen = "/articlesListScreen";
  static const String articleDetailsScreen = "/articleDetailsScreen";
  static const String doctorSpecialArticleScreen =
      "/doctorSpecialArticleScreen";
}
