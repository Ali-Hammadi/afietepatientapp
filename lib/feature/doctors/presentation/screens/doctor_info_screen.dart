import 'package:afiete/core/constants/report_types.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_state.dart';
import 'package:afiete/feature/doctors/presentation/widgets/doctor_profile_image.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/core/widget/error_custom_button.dart';
import 'package:afiete/feature/articles/presentation/cubits/articles_cubit.dart';
import 'package:afiete/feature/articles/presentation/widgets/article_card_widget.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';

import 'package:afiete/feature/home/presentation/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorInfo extends StatefulWidget {
  final DoctorEntity? doctor;

  const DoctorInfo({super.key, this.doctor});

  @override
  State<DoctorInfo> createState() => _DoctorInfoState();
}

class _DoctorInfoState extends State<DoctorInfo> {
  @override
  void initState() {
    super.initState();
    final doctorUsername = widget.doctor?.doctorUsername;
    if (doctorUsername != null && doctorUsername.isNotEmpty) {
      context.read<DoctorsCubit>().loadDoctorByUsername(doctorUsername);
      context.read<ArticlesCubit>().loadArticlesByDoctor(doctorUsername);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 72,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      SettingsStrings.doctorNotFound,
                      style: AppStyles.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      widget: Text(
                        SettingsStrings.cancelAction,
                        style: AppStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final remoteDoctor = state is DoctorLoaded ? state.doctor : null;
        final doctor = remoteDoctor ?? widget.doctor;
        final colorScheme = Theme.of(context).colorScheme;
        final doctorName = doctor?.name ?? SettingsStrings.doctorDefaultName;
        final doctorTitle = _doctorTitle(doctor);
        final doctorSpecialties = _doctorSpecialties(doctor);
        final doctorDescription = _doctorDescription(doctor);

        return Scaffold(
          appBar: AppBar(
            title: Text(doctorName, style: AppStyles.headingMedium),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share, color: colorScheme.onSurface),
              ),
            ],
          ),
          body: state is DoctorLoading && doctor == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.padding),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildDoctorPhoto(doctor),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppStyles.padding,
                        ),
                        child: Text(doctorName, style: AppStyles.headingMedium),
                      ),
                      _buildStatsCard(colorScheme: colorScheme, doctor: doctor),
                      _buildSection(
                        title: SettingsStrings.doctorSpecialist,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(doctorTitle, style: AppStyles.bodyMedium),
                        ),
                      ),
                      _buildSection(
                        title: SettingsStrings.doctorAboutTitle,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            doctorDescription,
                            style: AppStyles.bodyMedium,
                          ),
                        ),
                      ),
                      _buildSection(
                        title: SettingsStrings.medicalSpecialtiesLabel,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: doctorSpecialties.isEmpty
                              ? [Text(doctorTitle, style: AppStyles.bodySmall)]
                              : doctorSpecialties
                                  .map(
                                    (specialty) => Text(
                                      specialty,
                                      style: AppStyles.bodySmall,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      _buildSection(
                        title: SettingsStrings.scheduleLabel,
                        child: _buildScheduleSection(
                          doctor: doctor,
                          colorScheme: colorScheme,
                        ),
                      ),
                      _buildSection(
                        title: SettingsStrings.doctorPriceContactTitle,
                        child: _buildSessionPricesSection(
                          doctor: doctor,
                          colorScheme: colorScheme,
                        ),
                      ),
                      _buildDoctorArticlesSection(colorScheme: colorScheme),
                      const SizedBox(height: 20),
                      CustomButton(
                        widget: Text(
                          SettingsStrings.bookSessionNow,
                          style: AppStyles.headingSmall.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            MyRoutes.bookSessionScreen,
                            arguments: doctor,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ErrorCustomButton(
                        widget: Text(
                          SettingsStrings.reportDoctorButton,
                          style: AppStyles.bodyMedium.copyWith(
                            color: colorScheme.onError,
                          ),
                        ),
                        onPressed: () {
                          final authState = context.read<AuthCubit>().state;
                          final username = switch (authState) {
                            AuthLoaded(:final user) => user.patientUsername,
                            AuthProfileUpdated(:final user) =>
                              user.patientUsername,
                            _ => '',
                          };

                          if (username.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  SettingsStrings.pleaseSignInToReportADoctor,
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            MyRoutes.reportScreen,
                            arguments: ReportScreenArgs(
                              reportType: ReportType.doctor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDoctorPhoto(DoctorEntity? doctor) {
    return CustomDoctorProfileImage(height: 100, doctor: doctor!);
  }

  String _doctorTitle(DoctorEntity? doctor) {
    if (doctor == null) {
      return SettingsStrings.doctorSpecialist;
    }

    if (doctor.jobTitle?.isNotEmpty == true) {
      return doctor.jobTitle!;
    }

    if (doctor.specialties.isNotEmpty) {
      return doctor.specialties.first;
    }

    return SettingsStrings.specialtyLabel(doctor.specialization);
  }

  List<String> _doctorSpecialties(DoctorEntity? doctor) {
    if (doctor == null) {
      return const [];
    }

    if (doctor.specialties.isNotEmpty) {
      return doctor.specialties;
    }

    return [doctor.specialization];
  }

  String _doctorDescription(DoctorEntity? doctor) {
    if (doctor == null) {
      return SettingsStrings.doctorProfileUnavailable;
    }

    if (doctor.bio?.isNotEmpty == true) {
      return doctor.bio!;
    }

    if (doctor.description.isNotEmpty) {
      return doctor.description;
    }

    return SettingsStrings.doctorProfileUnavailable;
  }

  Widget _buildStatsCard({
    required ColorScheme colorScheme,
    required DoctorEntity? doctor,
  }) {
    return CustomContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Text(
                      (doctor?.ratingValue ?? 4.9).toStringAsFixed(1),
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
                Text(SettingsStrings.reviewsLabel, style: AppStyles.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  doctor?.experienceYears != null
                      ? '${doctor!.experienceYears} years'
                      : '+ 8 years',
                ),
                Text(
                  SettingsStrings.experienceLabel,
                  style: AppStyles.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(doctor?.patients_count ?? '0'),
                Text(SettingsStrings.patientsLabel, style: AppStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyles.headingSmall),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceServiceTile({
    required String title,
    required String price,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(price),
      leading: Icon(icon, size: 28, color: colorScheme.primary),
    );
  }

  Widget _buildScheduleSection({
    required DoctorEntity? doctor,
    required ColorScheme colorScheme,
  }) {
    final schedules = doctor?.schedules ?? const [];
    if (schedules.isEmpty) {
      return Text(
        SettingsStrings.noAvailableScheduleLoadedYet,
        style: AppStyles.bodySmall.copyWith(color: colorScheme.outline),
      );
    }

    return Column(
      children: schedules
          .map(
            (schedule) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule, color: colorScheme.primary),
              title: Text(schedule.dayOfWeek),
              subtitle: Text('${schedule.startTime} - ${schedule.endTime}'),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSessionPricesSection({
    required DoctorEntity? doctor,
    required ColorScheme colorScheme,
  }) {
    final sessionPrices = doctor?.sessionPrices ?? const [];
    if (sessionPrices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          SettingsStrings.noSessionPrices,
          style: AppStyles.bodySmall.copyWith(color: colorScheme.outline),
        ),
      );
    }

    final items = sessionPrices
        .map(
          (price) =>
              _SessionPriceViewModel(type: price.type, price: price.price),
        )
        .toList();

    return Column(
      children: items
          .map(
            (item) => _buildPriceServiceTile(
              title: _sessionTypeLabel(item.type),
              price:
                  '${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)} \$ / ${SettingsStrings.minuteAbbreviation}',
              icon: _sessionTypeIcon(item.type),
              colorScheme: colorScheme,
            ),
          )
          .toList(),
    );
  }

  String _sessionTypeLabel(String sessionType) {
    switch (sessionType) {
      case 'text_chat':
        return SettingsStrings.chatTitle;
      case 'video_call':
        return SettingsStrings.videoCallTitle;
      case 'voice_call':
        return SettingsStrings.voiceCallTitle;
      default:
        return sessionType;
    }
  }

  IconData _sessionTypeIcon(String sessionType) {
    switch (sessionType) {
      case 'text_chat':
        return Icons.chat_bubble_outline;
      case 'video_call':
        return Icons.videocam_outlined;
      case 'voice_call':
        return Icons.keyboard_voice_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildDoctorArticlesSection({required ColorScheme colorScheme}) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SettingsStrings.articlesLabel,
                style: AppStyles.headingSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.articlesListScreen,
                    arguments: {
                      'doctorUsername': widget.doctor?.doctorUsername,
                      'doctorName': widget.doctor?.name,
                    },
                  );
                },
                child: Text(
                  SettingsStrings.seeAll,
                  style: AppStyles.bodySmall.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          BlocBuilder<ArticlesCubit, ArticlesState>(
            builder: (context, state) {
              if (state is ArticlesLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is ArticlesLoaded) {
                final articles = state.articles
                    .where((article) =>
                        article.doctor.doctorUsername ==
                        widget.doctor?.doctorUsername)
                    .toList();

                if (articles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      SettingsStrings.noArticlesAvailableForThisDoctorYet,
                      style: AppStyles.bodySmall.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  );
                }

                return Column(
                  children: articles
                      .map(
                        (article) => ArticleCardWidget(
                          article: article,
                          flatMode: true,
                          onReadMore: () {
                            Navigator.pushNamed(
                              context,
                              MyRoutes.articleDetailsScreen,
                              arguments: article,
                            );
                          },
                        ),
                      )
                      .toList(),
                );
              }

              if (state is ArticlesError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    state.message,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}

class _SessionPriceViewModel {
  final String type;
  final double price;

  const _SessionPriceViewModel({required this.type, required this.price});
}
