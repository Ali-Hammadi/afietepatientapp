import 'package:afietepatientapp/feature/articles/domain/entities/article_entities.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';

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
  final bool isLikedByUser;
  final bool isDislikedByUser;
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
    required this.isLikedByUser,
    required this.isDislikedByUser,
    required this.relatedConditions,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: _readString(json['id']) ?? '',
      title:
          _readString(json['title'] ?? json['headline'] ?? json['name']) ?? '',
      content:
          _readString(
            json['content'] ??
                json['body'] ??
                json['description'] ??
                json['text'],
          ) ??
          '',
      summary:
          _readString(
            json['summary'] ??
                json['excerpt'] ??
                json['short_description'] ??
                json['content_preview'],
          ) ??
          _buildSummary(
            _readString(
                  json['content'] ??
                      json['body'] ??
                      json['description'] ??
                      json['text'],
                ) ??
                '',
          ),
      imageUrl:
          _readString(
            json['imageUrl'] ??
                json['image_url'] ??
                json['image'] ??
                json['cover_image'] ??
                json['thumbnail'] ??
                json['photo'],
          ) ??
          '',
      status: _readString(json['status']) ?? '',
      reaction: _readString(json['reaction']) ?? '',
      doctor: _doctorFromJson(
        _extractDoctorMap(json) ?? const <String, dynamic>{},
      ),
      createdAt:
          _readDateTime(json['createdAt']) ??
          _readDateTime(json['created_at']) ??
          _readDateTime(json['published_at']) ??
          _readDateTime(json['date']) ??
          DateTime.now(),
      likesCount: _readInt(json['likesCount'] ?? json['likes_count']) ?? 0,
      dislikesCount:
          _readInt(json['dislikesCount'] ?? json['dislikes_count']) ?? 0,
      isLikedByUser:
          _readBool(json['isLikedByUser'] ?? json['is_liked_by_user']) ?? false,
      isDislikedByUser:
          _readBool(json['isDislikedByUser'] ?? json['is_disliked_by_user']) ??
          false,
      relatedConditions: List<String>.from(
        json['relatedConditions'] ?? json['related_conditions'] ?? const [],
      ),
    );
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
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
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'imageUrl': imageUrl,
      'status': status,
      'reaction': reaction,
      'doctor': {
        'id': doctor.id,
        'name': doctor.name,
        'specialization': doctor.specialization,
        'imageUrl': doctor.imageUrl,
      },
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'isLikedByUser': isLikedByUser,
      'isDislikedByUser': isDislikedByUser,
      'relatedConditions': relatedConditions,
    };
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      content: content,
      summary: summary,
      imageUrl: imageUrl,
      status: status,
      reaction: reaction,
      doctor: doctor,
      createdAt: createdAt,
      likesCount: likesCount,
      dislikesCount: dislikesCount,
      isLikedByUser: isLikedByUser,
      isDislikedByUser: isDislikedByUser,
      relatedConditions: relatedConditions,
    );
  }

  static DoctorEntity _doctorFromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final user = (json['user'] as Map<String, dynamic>?) ??
        (author?['user'] as Map<String, dynamic>?) ??
        const {};
    final jobTitle = _readString(
      _readNestedValue(json, ['job_title', 'title']) ??
          _readNestedValue(author ?? const {}, ['job_title', 'title']) ??
          json['job_title'] ??
          author?['job_title'] ??
          _readNestedValue(json, ['specialization', 'name']) ??
          _readNestedValue(author ?? const {}, ['specialization', 'name']) ??
          json['specialization'] ??
          author?['specialization'] ??
          json['specialty'] ??
          'General',
    );
    final specializationName =
        _readString(
          _readNestedValue(json, ['specialization', 'name']) ??
              _readNestedValue(author ?? const {}, ['specialization', 'name']) ??
              json['specialization'] ??
              author?['specialization'] ??
              json['specialty'] ??
              jobTitle,
        ) ??
        'General';
    return DoctorEntity(
      id: (json['id'] ?? author?['id'] ?? json['doctor_id'] ?? json['doctorId'] ?? '')
          .toString(),
      firstName:
          _readString(
            json['name'] ??
                author?['name'] ??
                json['full_name'] ??
                json['first_name'] ??
                author?['first_name'] ??
                user['first_name'] ??
                user['username'],
          ) ??
          'Unknown Doctor',
      lastName: _readString(json['last_name'] ?? author?['last_name'] ?? user['last_name']),
      username: _readString(user['username']),
      jobTitle: jobTitle,
      specialties: [specializationName],
      experienceYears: _parseExperienceYears(json['experience']),
      bio: _readString(json['description'] ?? json['bio']),
      imageUrl:
          _readString(
            json['imageUrl'] ??
                json['image_url'] ??
                json['image'] ??
                author?['photo'] ??
                user['image_url'] ??
                user['image'] ??
                user['profile_image'] ??
                json['author_image'] ??
                json['author_image_url'],
          ) ??
          '',
    );
  }
}

dynamic _readNestedValue(Map<String, dynamic> json, List<String> path) {
  dynamic current = json;

  for (final segment in path) {
    if (current is Map<String, dynamic> && current.containsKey(segment)) {
      current = current[segment];
      continue;
    }
    return null;
  }

  return current;
}

String? _readString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

bool? _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  final text = value?.toString().trim().toLowerCase();
  if (text == null) {
    return null;
  }

  if (text == 'true' || text == '1' || text == 'yes') {
    return true;
  }
  if (text == 'false' || text == '0' || text == 'no') {
    return false;
  }

  return null;
}

DateTime? _readDateTime(dynamic value) {
  final text = _readString(value);
  if (text == null) {
    return null;
  }

  return DateTime.tryParse(text);
}

Map<String, dynamic>? _extractDoctorMap(Map<String, dynamic> json) {
  final nestedDoctor = json['doctor'] ?? json['author'] ?? json['created_by'];
  if (nestedDoctor is Map<String, dynamic>) {
    return nestedDoctor;
  }

  final doctorId = json['doctor_id'] ?? json['doctorId'];
  final doctorName =
      json['doctor_name'] ?? json['doctorName'] ?? json['author_name'];
  if (doctorId == null && doctorName == null) {
    return null;
  }

  return <String, dynamic>{
    'id': doctorId,
    'name': doctorName,
    'specialization':
        json['doctor_specialization'] ??
        json['specialization'] ??
        json['job_title'],
    'imageUrl':
        json['doctor_image'] ??
        json['doctor_image_url'] ??
        json['author_image'],
    'experience': json['doctor_experience'] ?? json['experience'],
    'description': json['doctor_bio'] ?? json['doctor_description'],
  };
}

String _buildSummary(String content) {
  final sanitized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (sanitized.isEmpty) {
    return '';
  }

  if (sanitized.length <= 140) {
    return sanitized;
  }

  return '${sanitized.substring(0, 137)}...';
}

int? _parseExperienceYears(dynamic value) {
  final text = value?.toString() ?? '';
  final match = RegExp(r'\d+').firstMatch(text);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(0)!);
}
