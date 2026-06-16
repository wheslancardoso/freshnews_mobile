import 'package:fresh_news_mobile/core/constants/world.dart';

class Subscriber {
  final String id;
  final String email;
  final List<World> worlds;
  final bool active;
  final List<String> preferences;
  final Map<String, double> affinityVector;
  final String? phone;
  final bool notifyEmail;
  final bool notifyWhatsapp;
  final String status;
  final DateTime createdAt;

  const Subscriber({
    required this.id,
    required this.email,
    required this.worlds,
    required this.active,
    this.preferences = const [],
    this.affinityVector = const {},
    this.phone,
    this.notifyEmail = true,
    this.notifyWhatsapp = false,
    this.status = 'active',
    required this.createdAt,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    // Parse affinity_vector safelly
    Map<String, double> parsedAffinity = {};
    if (json['affinity_vector'] != null) {
      final map = json['affinity_vector'] as Map<String, dynamic>;
      parsedAffinity = map.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    return Subscriber(
      id: json['id'] as String,
      email: json['email'] as String,
      worlds: (json['active_worlds'] as List<dynamic>? ?? [])
          .map((w) => WorldExtension.fromSlug(w as String))
          .toList(),
      active: (json['status'] as String? ?? 'active') == 'active',
      preferences: (json['preferences'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      affinityVector: parsedAffinity,
      phone: json['phone'] as String?,
      notifyEmail: json['notify_email'] as bool? ?? true,
      notifyWhatsapp: json['notify_whatsapp'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'active_worlds': worlds.map((w) => w.config.slug).toList(),
      'preferences': preferences,
      'affinity_vector': affinityVector,
      if (phone != null) 'phone': phone,
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
    Map<String, double>? affinityVector,
    String? phone,
    bool? notifyEmail,
    bool? notifyWhatsapp,
    String? status,
    DateTime? createdAt,
  }) {
    return Subscriber(
      id: id ?? this.id,
      email: email ?? this.email,
      worlds: worlds ?? this.worlds,
      active: active ?? this.active,
      preferences: preferences ?? this.preferences,
      affinityVector: affinityVector ?? this.affinityVector,
      phone: phone ?? this.phone,
      notifyEmail: notifyEmail ?? this.notifyEmail,
      notifyWhatsapp: notifyWhatsapp ?? this.notifyWhatsapp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

