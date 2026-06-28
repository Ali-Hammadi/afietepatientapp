import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/ln10/language_cubit/language_cubit.dart';
import 'package:afiete/core/theme/theme_cubit.dart';
import 'package:afiete/core/utils/age_utils.dart';
import 'package:afiete/core/widget/profile_initial_avatar.dart';
import 'package:afiete/feature/auth/domain/entities/auth_user_entity.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:afiete/feature/settings/presentation/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().refreshProfileFromBackend();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ThemeCubit, bool>(
      (themeCubit) => themeCubit.state == ThemeMode.dark,
    );
    final authState = context.watch<AuthCubit>().state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = context.select<LanguageCubit, Locale>(
      (cubit) => cubit.state,
    );
    final selectedLanguage = locale.languageCode == 'ar'
        ? SettingsStrings.arabic
        : SettingsStrings.english;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SettingsStrings.settingsSubtitle,
                style: AppStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 20),
              _buildHeader(context, authState),
              const SizedBox(height: 20),
              CustomSettingTile(
                icon: Icons.medical_services_outlined,
                title: SettingsStrings.medicalProfileTitle,
                subtitle: SettingsStrings.medicalProfileSubtitle,
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.medicalProfileScreen);
                },
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.language,
                title: SettingsStrings.languageTitle,
                subtitle:
                    '${SettingsStrings.currentLanguageTitle}: $selectedLanguage',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLanguage,
                        style: AppStyles.bodySmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                onTap: () => _showLanguageSheet(context),
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.dark_mode_outlined,
                title: SettingsStrings.themeTitle,
                trailing: SwitchTheme(
                  data: SwitchTheme.of(context).copyWith(
                    trackOutlineWidth: const WidgetStatePropertyAll(0.8),
                  ),
                  child: Transform.scale(
                    scale: 0.88,
                    child: Switch(
                      value: isDarkMode,
                      onChanged: (value) =>
                          context.read<ThemeCubit>().toggleTheme(value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: SettingsStrings.termsPrivacyTitle,
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.privacyScreen);
                },
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.mail_outline,
                title: SettingsStrings.contactUsTitle,
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.contactUsScreen);
                },
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.report_problem_outlined,
                title: SettingsStrings.reportsTitle,
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.reportIssueScreen);
                },
              ),
              const SizedBox(height: 12),
              CustomSettingTile(
                icon: Icons.logout,
                title: SettingsStrings.logoutTitle,
                subtitle: SettingsStrings.logoutSubtitle,
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 0.9),
                ),
                onTap: () => _confirmLogout(context, authState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final authUser = _resolveAuthUser(authState);
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayUserValue(
      authUser?.nickname?.trim(),
      fallback: authUser?.patientUsername.trim() ?? '—',
    );
    final email = _displayUserValue(authUser?.email.trim());
    final gender = _displayGender(authUser?.gender);
    final age = authUser?.age ?? calculateAge(authUser?.birthDate) ?? 0;

    final summaryChips = <Widget>[
      _buildProfileChip(
        context,
        Icons.cake_outlined,
        age > 0 ? SettingsStrings.yearsOld(age) : SettingsStrings.ageTitle,
      ),
      _buildProfileChip(
        context,
        Icons.badge_outlined,
        gender == '—' ? SettingsStrings.genderTitle : gender,
      ),
    ];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          MyRoutes.profileInfoScreen,
          arguments: authUser,
        );
      },
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 190),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.82),
              colorScheme.primaryContainer.withValues(alpha: 0.94),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colorScheme.onPrimary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -8,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -18,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onPrimary.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
                      child: ProfileInitialAvatar(
                        name: displayName,
                        radius: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppStyles.headingMedium.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: AppStyles.bodySmall.copyWith(
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.82,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(spacing: 10, runSpacing: 10, children: summaryChips),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _displayUserValue(String? value, {String fallback = '—'}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }

  String _displayGender(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.isEmpty) return '—';
    if (value == 'female' ||
        value == 'f' ||
        value == 'أنثى' ||
        value == 'انثى') {
      return SettingsStrings.female;
    }
    if (value == 'male' || value == 'm' || value == 'ذكر') {
      return SettingsStrings.male;
    }
    return raw!.trim();
  }

  void _showLanguageSheet(BuildContext context) {
    final currentLocale = context.read<LanguageCubit>().state;
    String tempLanguage = currentLocale.languageCode == 'ar' ? 'ar' : 'en';
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppStyles.padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SettingsStrings.selectLanguageTitle,
                    style: AppStyles.headingMedium,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      customLanguageOption(
                        title: SettingsStrings.english,
                        onTap: () => setModalState(() => tempLanguage = 'en'),
                      ),
                      const SizedBox(height: 10),
                      customLanguageOption(
                        onTap: () => setModalState(() => tempLanguage = 'ar'),
                        title: SettingsStrings.arabic,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          SettingsStrings.cancel,
                          style: AppStyles.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          await context.read<LanguageCubit>().setLanguageCode(
                                tempLanguage,
                              );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          SettingsStrings.select,
                          style: AppStyles.bodyMedium.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget customLanguageOption(
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthState authState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(SettingsStrings.logoutConfirmTitle),
          content: Text(SettingsStrings.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(SettingsStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(SettingsStrings.logoutTitle),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final loggedOut = await context.read<AuthCubit>().logout();

    // The logout flow triggers a full app wipe and restart; don't perform
    // duplicate local clearing or navigation here.
    if (!context.mounted || !loggedOut) return;
  }

  UserAuthEntity? _resolveAuthUser(AuthState authState) {
    if (authState is AuthLoaded) return authState.user;
    if (authState is AuthProfileUpdated) return authState.user;
    if (authState is SignupOtpVerified) return authState.user;
    return null;
  }
}
