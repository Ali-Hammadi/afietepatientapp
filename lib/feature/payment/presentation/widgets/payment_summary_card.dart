import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomPaymentSummaryCard extends StatelessWidget {
  final String sessionType;
  final String doctorName;
  final DateTime scheduledAt;
  final double amount;

  const CustomPaymentSummaryCard({
    super.key,
    required this.sessionType,
    required this.doctorName,
    required this.scheduledAt,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sessionType),
          Text(doctorName),
          Text(DateFormat('MMM dd, yyyy • h:mm a').format(scheduledAt)),
          const SizedBox(height: 10),
          Text('${amount.toStringAsFixed(2)} \$'),
        ],
      ),
    );
  }
}
