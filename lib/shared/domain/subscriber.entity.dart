import 'package:fresh_news_mobile/core/constants/worlds.dart';

class Subscriber {
  final String id;
  final String email;
  final List<World> worlds;
  final bool active;
  final DateTime createdAt;

  const Subscriber({
    required this.id,
    required this.email,
    required this.worlds,
    required this.active,
    required this.createdAt,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    return Subscriber(
      id: json['id'] as String,
      email: json['email'] as String,
      worlds: (json['worlds'] as List<dynamic>? ?? [])
          .map((w) => WorldExtension.fromSlug(w as String))
          .toList(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'worlds': worlds.map((w) => w.config.slug).toList(),
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Subscriber copyWith({
    String? id,
    String? email,
    List<World>? worlds,
    bool? active,
    DateTime? createdAt,
  }) {
    return Subscriber(
      id: id ?? this.id,
      email: email ?? this.email,
      worlds: worlds ?? this.worlds,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
