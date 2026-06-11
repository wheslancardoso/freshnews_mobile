import 'package:fresh_news_mobile/core/constants/world.dart';

class DebateMessage {
  final String persona;
  final String role;    // 'AI' | 'SEC' | 'DEV' | 'CLOUD' (TECH) ou variantes por mundo
  final String avatar;  // Emoji: '🤖', '🛡️', '💻', '☁️'
  final String color;   // Hex: '#8B5CF6', '#F43F5E', '#10B981', '#06B6D4'
  final String message;

  const DebateMessage({
    required this.persona,
    required this.role,
    required this.avatar,
    required this.color,
    required this.message,
  });

  factory DebateMessage.fromJson(Map<String, dynamic> json) {
    return DebateMessage(
      persona: json['persona'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      color: json['color'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'persona': persona,
    'role': role,
    'avatar': avatar,
    'color': color,
    'message': message,
  };
}

class NewsItem {
  final String headline;
  final String story;
  final String link;
  final String? imageUrl;

  const NewsItem({
    required this.headline,
    required this.story,
    required this.link,
    this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      headline: json['headline'] as String? ?? json['title'] as String? ?? '',
      story: json['story'] as String? ?? json['summary'] as String? ?? '',
      link: json['link'] as String? ?? '#',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'headline': headline,
    'story': story,
    'link': link,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

class NewsCategory {
  final String name;
  final List<NewsItem> items;

  const NewsCategory({required this.name, this.items = const []});

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      name: json['name'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class NewsletterContent {
  final String title;
  final String intro;
  final List<String> quickTakes;
  final List<NewsCategory> categories;
  final String? imagePrompt;

  const NewsletterContent({
    required this.title,
    required this.intro,
    this.quickTakes = const [],
    this.categories = const [],
    this.imagePrompt,
  });

  factory NewsletterContent.fromJson(Map<String, dynamic> json) {
    return NewsletterContent(
      title: json['title'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      quickTakes: (json['quickTakes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => NewsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      imagePrompt: json['image_prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'intro': intro,
    'quickTakes': quickTakes,
    'categories': categories.map((e) => e.toJson()).toList(),
    if (imagePrompt != null) 'image_prompt': imagePrompt,
  };
}

class Newsletter {
  final String id;
  final int editionNumber;
  final String title;
  final String? summaryIntro;
  final NewsletterContent? contentJson;
  final List<DebateMessage> debateLog;
  final String? htmlContent;
  final String status; // 'draft' | 'published'
  final String? imageUrl;
  final String? imagePrompt;
  final String? category;
  final World world; // enum
  final DateTime createdAt;
  final DateTime? publishedAt;

  const Newsletter({
    required this.id,
    required this.editionNumber,
    required this.title,
    this.summaryIntro,
    this.contentJson,
    this.debateLog = const [],
    this.htmlContent,
    this.status = 'draft',
    this.imageUrl,
    this.imagePrompt,
    this.category,
    required this.world,
    required this.createdAt,
    this.publishedAt,
  });

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      id: json['id'] as String,
      editionNumber: json['edition_number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      summaryIntro: json['summary_intro'] as String?,
      contentJson: json['content_json'] != null
          ? NewsletterContent.fromJson(json['content_json'] as Map<String, dynamic>)
          : null,
      debateLog: (json['debate_log'] as List<dynamic>?)
              ?.map((e) => DebateMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      htmlContent: json['html_content'] as String?,
      status: json['status'] as String? ?? 'draft',
      imageUrl: json['image_url'] as String?,
      imagePrompt: json['image_prompt'] as String?,
      category: json['category'] as String?,
      world: WorldRegistry.fromString(json['world'] as String? ?? 'tech'),
      createdAt: DateTime.parse(json['created_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'edition_number': editionNumber,
      'title': title,
      if (summaryIntro != null) 'summary_intro': summaryIntro,
      if (contentJson != null) 'content_json': contentJson?.toJson(),
      'debate_log': debateLog.map((e) => e.toJson()).toList(),
      if (htmlContent != null) 'html_content': htmlContent,
      'status': status,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imagePrompt != null) 'image_prompt': imagePrompt,
      if (category != null) 'category': category,
      'world': world.name.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      if (publishedAt != null) 'published_at': publishedAt?.toIso8601String(),
    };
  }

  bool get isPublished => status == 'published';
  bool get isDraft => status == 'draft';
}
