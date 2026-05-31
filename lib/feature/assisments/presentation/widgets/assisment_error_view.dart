import 'package:afietepatientapp/core/constants/styles.dart';
import 'package:afietepatientapp/core/constants/settings_strings.dart';
import 'package:afietepatientapp/core/widget/custom_button.dart';
import 'package:flutter/material.dart';

class CustomAssismentErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomAssismentErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            CustomButton(
              widget: Text(
                SettingsStrings.retryButton,
                style: AppStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
