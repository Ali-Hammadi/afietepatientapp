import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:flutter/material.dart';

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          SettingsStrings.reportIssueTitle,
          style: AppStyles.headingMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        SettingsStrings.reportIssueDescription,
                        style: AppStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                SettingsStrings.reportIssue,
                style: AppStyles.headingMedium,
              ),
              const SizedBox(height: 16),
              _buildReportTypeCard(
                context: context,
                icon: Icons.bug_report,
                title: SettingsStrings.reportOnApp,
                description: SettingsStrings.reportOnAppDescription,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.reportScreen,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildReportTypeCard(
                context: context,
                icon: Icons.medical_services,
                title: SettingsStrings.reportOnUser,
                description: SettingsStrings.reportOnUserDescription,
                onTap: () => _showUsernameInputDialog(
                  context,
                  reportType: 'doctor',
                  title: SettingsStrings.reportOnUser,
                ),
              ),
              const SizedBox(height: 12),
              _buildReportTypeCard(
                context: context,
                icon: Icons.event_busy,
                title: SettingsStrings.reportOnSession,
                description: SettingsStrings.reportOnSessionDescription,
                onTap: () => _showUsernameInputDialog(
                  context,
                  reportType: 'session',
                  title: SettingsStrings.reportOnSessionDescription,
                ),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CustomButton(
                    widget: Text(SettingsStrings.reportHistoryTitle),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, MyRoutes.reportHistoryScreen);
                    }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.outline,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameInputDialog(
    BuildContext context, {
    required String reportType,
    required String title,
  }) {
    final usernameController = TextEditingController();
    final displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: SettingsStrings.usernameLabel,
                hintText: SettingsStrings.usernameHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: SettingsStrings.nameOnCardHint,
                hintText: SettingsStrings.nameOnCardHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(SettingsStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(SettingsStrings.enterDoctorUsername)),
                );
                return;
              }

              Navigator.pop(dialogContext);
              Navigator.pushNamed(
                context,
                MyRoutes.reportScreen,
                arguments: ReportScreenArgs(
                  reportedUsername: username,
                  targetName: displayNameController.text.trim().isEmpty
                      ? username
                      : displayNameController.text.trim(),
                ),
              );
            },
            child: Text(SettingsStrings.next),
          ),
        ],
      ),
    );
  }
}
