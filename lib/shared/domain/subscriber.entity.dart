import 'package:fresh_news_mobile/core/constants/world.dart';

class Subscriber {
  final String id;
  final String email;
  final List<World> worlds;
  final bool active;
  final List<String> preferences;
  final String status;
  final DateTime createdAt;

  const Subscriber({
    required this.id,
    required this.email,
    required this.worlds,
    required this.active,
    this.preferences = const [],
    this.status = 'active',
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
      preferences: (json['preferences'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'worlds': worlds.map((w) => w.config.slug).toList(),
      'active': active,
      'preferences': preferences,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Subscriber copyWith({
    String? id,
    String? email,
    List<World>? worlds,
    bool? active,
    List<String>? preferences,
    String? status,
    DateTime? createdAt,
  }) {
    return Subscriber(
      id: id ?? this.id,
      email: email ?? this.email,
      worlds: worlds ?? this.worlds,
      active: active ?? this.active,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

