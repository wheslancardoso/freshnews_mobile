import 'package:fresh_news_mobile/core/constants/worlds.dart';

class Newsletter {
  final String id;
  final World world;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Newsletter({
    required this.id,
    required this.world,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      id: json['id'] as String,
      world: WorldExtension.fromSlug(json['world'] as String),
      title: json['title'] as String,
      slug: json['slug'] as String,
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'world': world.config.slug,
      'title': title,
      'slug': slug,
      'summary': summary,
      'content': content,
      'status': status,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Newsletter copyWith({
    String? id,
    World? world,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? status,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Newsletter(
      id: id ?? this.id,
      world: world ?? this.world,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
