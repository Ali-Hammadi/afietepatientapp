import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/assessments/data/assisment_visibility_store.dart';
import 'package:flutter/material.dart';

class CustomAssignmentWidget extends StatelessWidget {
  const CustomAssignmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AssessmentsVisibilityStore.shouldShowAssessments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == false) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(AppStyles.padding),
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.all(
              Radius.circular(AppStyles.borderRadius),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SettingsStrings.takeAssessmentsTitle,
                style: AppStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                ),
                textAlign: TextAlign.start,
              ),
              Text(
                SettingsStrings.takeAssessmentsDescription,
                style: AppStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                ),
                overflow: TextOverflow.visible,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.assessmentsTestScreen);
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppStyles.borderRadius),
                    ),
                  ),
                  child: Text(
                    SettingsStrings.takeAssessmentsButton,
                    style: AppStyles.bodyMedium.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
