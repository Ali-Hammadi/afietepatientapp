import 'package:shared_preferences/shared_preferences.dart';

class NicknameOverrideStorage {
  static const String _keyPrefix = 'nickname_override:';

  static String _keyForEmail(String email) =>
      '$_keyPrefix${email.trim().toLowerCase()}';

  static Future<void> save({
    required String email,
    required String nickname,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) return;

    final trimmedNickname = nickname.trim();
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForEmail(trimmedEmail);

    if (trimmedNickname.isEmpty) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(key, trimmedNickname);
  }

  static Future<String?> read({required String email}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyForEmail(trimmedEmail));
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static Future<void> clear({required String email}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForEmail(trimmedEmail));
  }
}
