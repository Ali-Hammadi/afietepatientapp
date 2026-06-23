import 'package:shared_preferences/shared_preferences.dart';

class AssessmentsVisibilityStore {
  static const String _lastBookedAtKey = 'Assessments_last_booked_at';
  static const String _lastCompletedAtKey = 'Assessments_last_completed_at';
  static const Duration _hideAfterBookingDuration = Duration(days: 10);

  static Future<void> markAssessmentsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastCompletedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> markAssessmentsBooked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBookedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> shouldShowAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final bookedAtMillis = prefs.getInt(_lastBookedAtKey);

    if (bookedAtMillis == null) {
      return true;
    }

    final bookedAt = DateTime.fromMillisecondsSinceEpoch(bookedAtMillis);
    return DateTime.now().difference(bookedAt) >= _hideAfterBookingDuration;
  }
}
