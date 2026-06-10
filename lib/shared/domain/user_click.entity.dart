class UserClick {
  final String id;
  final String? subscriberId;
  final String targetType;
  final String targetId;
  final DateTime clickedAt;

  const UserClick({
    required this.id,
    this.subscriberId,
    required this.targetType,
    required this.targetId,
    required this.clickedAt,
  });

  factory UserClick.fromJson(Map<String, dynamic> json) {
    return UserClick(
      id: json['id'] as String,
      subscriberId: json['subscriber_id'] as String?,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      clickedAt: DateTime.parse(json['clicked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriber_id': subscriberId,
      'target_type': targetType,
      'target_id': targetId,
      'clicked_at': clickedAt.toIso8601String(),
    };
  }

  UserClick copyWith({
    String? id,
    String? subscriberId,
    String? targetType,
    String? targetId,
    DateTime? clickedAt,
  }) {
    return UserClick(
      id: id ?? this.id,
      subscriberId: subscriberId ?? this.subscriberId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      clickedAt: clickedAt ?? this.clickedAt,
    );
  }
}
