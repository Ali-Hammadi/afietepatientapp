// lib/feature/articles/domain/entities/article_entities.dart
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:equatable/equatable.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';

class ArticleEntity extends Equatable {
  final String id;
  final String title;
  final String titleAr; // ✅ جديد
  final String titleEn; // ✅ جديد
  final String content;
  final String contentAr; // ✅ جديد
  final String contentEn; // ✅ جديد
  final String translatedTitle; // ✅ جديد
  final String translatedContent; // ✅ جديد
  final String summary;
  final String imageUrl;
  final String status;
  final String reaction;
  final DoctorEntity doctor;
  final DateTime createdAt;
  final int likesCount;
  final int dislikesCount;
  final bool isLikedByUser;
  final bool isDislikedByUser;
  final List<String> relatedConditions;

  const ArticleEntity({
    required this.id,
    required this.title,
    this.titleAr = '', // ✅ جديد
    this.titleEn = '', // ✅ جديد
    required this.content,
    this.contentAr = '', // ✅ جديد
    this.contentEn = '', // ✅ جديد
    this.translatedTitle = '', // ✅ جديد
    this.translatedContent = '', // ✅ جديد
    required this.summary,
    this.imageUrl = '',
    this.status = '',
    this.reaction = '',
    required this.doctor,
    required this.createdAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLikedByUser,
    required this.isDislikedByUser,
    required this.relatedConditions,
  });

  // ==========================================
  // 🌍 Localized Getters - الحل السحري!
  // ==========================================

  /// يرجع العنوان باللغة الحالية (عربي/إنجليزي)
  /// الأولوية: الترجمة المباشرة > النص الأصلي
  String get localizedTitle {
    final isArabic = SettingsStrings.isArabic;

    if (isArabic) {
      // إذا فيه ترجمة عربية، استخدمها
      if (titleAr.trim().isNotEmpty) return titleAr;
      // وإلا إذا فيه translated_title مختلف عن الأصل، استخدمه
      if (translatedTitle.trim().isNotEmpty &&
          translatedTitle != title &&
          _isMostlyArabic(translatedTitle)) {
        return translatedTitle;
      }
      // fallback: العنوان الأصلي
      return title;
    } else {
      // إذا فيه ترجمة إنجليزية، استخدمها
      if (titleEn.trim().isNotEmpty) return titleEn;
      // وإلا إذا فيه translated_title، استخدمه
      if (translatedTitle.trim().isNotEmpty) {
        return translatedTitle;
      }
      // fallback: العنوان الأصلي
      return title;
    }
  }

  /// يرجع المحتوى باللغة الحالية (عربي/إنجليزي)
  /// الأولوية: الترجمة المباشرة > النص الأصلي
  String get localizedContent {
    final isArabic = SettingsStrings.isArabic;

    if (isArabic) {
      if (contentAr.trim().isNotEmpty) return contentAr;
      if (translatedContent.trim().isNotEmpty &&
          translatedContent != content &&
          _isMostlyArabic(translatedContent)) {
        return translatedContent;
      }
      return content;
    } else {
      if (contentEn.trim().isNotEmpty) return contentEn;
      if (translatedContent.trim().isNotEmpty) {
        return translatedContent;
      }
      return content;
    }
  }

  /// يرجع الخلاصة باللغة الحالية
  String get localizedSummary {
    // نولد الخلاصة من المحتوى المترجم
    final sourceContent = localizedContent;
    if (sourceContent.trim().isEmpty) return '';

    final sanitized = sourceContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    return sanitized.length > 120
        ? '${sanitized.substring(0, 117)}...'
        : sanitized;
  }

  /// هل اللغة الحالية عربية؟
  bool get isCurrentLanguageArabic => SettingsStrings.isArabic;

  /// دالة مساعدة لتحديد إذا كان النص عربي
  static bool _isMostlyArabic(String text) {
    if (text.trim().isEmpty) return false;
    // Regex للأحرف العربية
    final arabicChars = RegExp(r'[\u0600-\u06FF]');
    final totalChars = text.replaceAll(RegExp(r'\s+'), '').length;
    if (totalChars == 0) return false;
    final arabicCount = arabicChars.allMatches(text).length;
    return (arabicCount / totalChars) > 0.3; // 30% أو أكثر = عربي
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        titleEn,
        content,
        contentAr,
        contentEn,
        translatedTitle,
        translatedContent,
        summary,
        imageUrl,
        status,
        reaction,
        doctor,
        createdAt,
        likesCount,
        dislikesCount,
        isLikedByUser,
        isDislikedByUser,
        relatedConditions,
      ];

  ArticleEntity copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? titleEn,
    String? content,
    String? contentAr,
    String? contentEn,
    String? translatedTitle,
    String? translatedContent,
    String? summary,
    String? imageUrl,
    String? status,
    String? reaction,
    DoctorEntity? doctor,
    DateTime? createdAt,
    int? likesCount,
    int? dislikesCount,
    bool? isLikedByUser,
    bool? isDislikedByUser,
    List<String>? relatedConditions,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      content: content ?? this.content,
      contentAr: contentAr ?? this.contentAr,
      contentEn: contentEn ?? this.contentEn,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedContent: translatedContent ?? this.translatedContent,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      reaction: reaction ?? this.reaction,
      doctor: doctor ?? this.doctor,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isDislikedByUser: isDislikedByUser ?? this.isDislikedByUser,
      relatedConditions: relatedConditions ?? this.relatedConditions,
    );
  }
}
