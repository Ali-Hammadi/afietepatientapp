import 'package:afiete/feature/articles/domain/entities/article_entities.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String imageUrl;
  final String status;
  final String reaction;
  final DoctorEntity doctor;
  final DateTime createdAt;
  final int likesCount;
  final int dislikesCount;
  final List<String> relatedConditions;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    this.imageUrl = '',
    this.status = '',
    this.reaction = '',
    required this.doctor,
    required this.createdAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.relatedConditions,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // 1. استخراج وتفكيك بيانات الطبيب المتداخلة من الباك اند (author -> user)
    final authorJson = json['author'] as Map<String, dynamic>? ?? const {};
    final userJson = authorJson['user'] as Map<String, dynamic>? ?? const {};

    // 2. معالجة قائمة التخصصات بدقة كما تتوقعها الـ Entity (List<String>)
    List<String> specialtiesList = const [];
    if (json['specialization'] != null) {
      if (json['specialization'] is List) {
        specialtiesList =
            (json['specialization'] as List).map((e) => e.toString()).toList();
      } else if (json['specialization'] is Map &&
          json['specialization']['name'] != null) {
        specialtiesList = [json['specialization']['name'].toString()];
      }
    } else if (authorJson['specialties'] is List) {
      specialtiesList =
          (authorJson['specialties'] as List).map((e) => e.toString()).toList();
    }

    // 3. بناء كائن الـ DoctorEntity الكامل المتوافق مع تطبيق المواعيد الآخر
    final doctorEntity = DoctorEntity(
      doctorUsername: userJson['username']?.toString() ?? "",
      email: userJson['email']?.toString(),
      gender: userJson['gender']?.toString(),
      imageUrl: authorJson['photo']?.toString() ??
          json['doctor_image']?.toString() ??
          '',
      phone: userJson['phone']?.toString(),
      name: userJson['first_name']?.toString(),
      age: userJson['age']?.toString(),
      jobTitle: authorJson['job_title']?['title']?.toString() ??
          authorJson['job_title']?.toString(),
      specialties: specialtiesList,
      experienceYears: int.tryParse(
          authorJson['experience_years']?.toString() ??
              authorJson['experience']?.toString() ??
              '0'),
      bio: authorJson['bio']?.toString() ?? '',
      sessionPrices: const [], // مصفوفات فارغة افتراضية لأن حقول المقالات لا تعيد أسعار الجلسات
      schedules: const [], // مصفوفات فارغة افتراضية لجدول المواعيد منعاً للـ Crash
    );

    final rawContent = json['content']?.toString() ?? '';

    // 4. بناء الـ Model الكامل للمقالة
    return ArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: rawContent,
      summary: json['summary']?.toString() ?? _buildSummary(rawContent),
      imageUrl:
          json['image_url']?.toString() ?? json['photo']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      reaction: json['reaction']?.toString() ?? 'none',
      doctor: doctorEntity,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likesCount: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      dislikesCount: int.tryParse(json['dislikes']?.toString() ?? '0') ?? 0,
      relatedConditions: json['related_conditions'] is List
          ? List<String>.from(json['related_conditions'])
          : const [],
    );
  }

  /// تحويل الـ Model إلى Entity لطبقة الـ Domain بسلامة تامة
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      content: content,
      summary: summary,
      imageUrl: imageUrl,
      status: status,
      reaction: reaction,
      doctor:
          doctor, // الآن يمرر الـ DoctorEntity الجديد الكامل لتطبيق المواعيد
      createdAt: createdAt,
      likesCount: likesCount,
      dislikesCount: dislikesCount,
      isLikedByUser: reaction.toLowerCase() == 'like',
      isDislikedByUser: reaction.toLowerCase() == 'dislike',
      relatedConditions: relatedConditions,
    );
  }

  /// دالة ذكية لتوليد خلاصة للمقال في حال عدم وجودها من الباك اند
  static String _buildSummary(String content) {
    final sanitized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (sanitized.isEmpty) return '';
    return sanitized.length > 120
        ? '${sanitized.substring(0, 117)}...'
        : sanitized;
  }
}
