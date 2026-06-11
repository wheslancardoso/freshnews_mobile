import 'package:fresh_news_mobile/core/constants/world.dart';

class Post {
  final String id;
  final World world;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String? imageUrl;
  final String category;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String url;
  final String? source;
  final int score;
  final String subCategory;
  final Map<String, dynamic>? themeConfig;
  final String? whatsappSummary;
  final Map<String, dynamic>? metadata;

  const Post({
    required this.id,
    required this.world,
    required this.title,
    this.slug = '',
    this.summary = '',
    this.content = '',
    this.imageUrl,
    required this.category,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    this.updatedAt,
    required this.url,
    this.source,
    this.score = 0,
    this.subCategory = 'GERAL',
    this.themeConfig,
    this.whatsappSummary,
    this.metadata,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      world: WorldExtension.fromSlug(json['world'] as String? ?? 'tech'),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? 'TECH_HACKER',
      status: json['status'] as String? ?? 'pending',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      url: json['url'] as String? ?? '',
      source: json['source'] as String?,
      score: json['score'] as int? ?? 0,
      subCategory: json['sub_category'] as String? ?? 'GERAL',
      themeConfig: json['theme_config'] as Map<String, dynamic>?,
      whatsappSummary: json['whatsapp_summary'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      'image_url': imageUrl,
      'category': category,
      'status': status,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'url': url,
      'source': source,
      'score': score,
      'sub_category': subCategory,
      'theme_config': themeConfig,
      'whatsapp_summary': whatsappSummary,
      'metadata': metadata,
    };
  }

  Post copyWith({
    String? id,
    World? world,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? imageUrl,
    String? category,
    String? status,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? url,
    String? source,
    int? score,
    String? subCategory,
    Map<String, dynamic>? themeConfig,
    String? whatsappSummary,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id ?? this.id,
      world: world ?? this.world,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      url: url ?? this.url,
      source: source ?? this.source,
      score: score ?? this.score,
      subCategory: subCategory ?? this.subCategory,
      themeConfig: themeConfig ?? this.themeConfig,
      whatsappSummary: whatsappSummary ?? this.whatsappSummary,
      metadata: metadata ?? this.metadata,
    );
  }
}

