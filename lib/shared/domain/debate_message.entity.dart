class DebateMessage {
  final String id;
  final String postId;
  final String agentName;
  final String content;
  final int orderIndex;
  final DateTime createdAt;

  const DebateMessage({
    required this.id,
    required this.postId,
    required this.agentName,
    required this.content,
    required this.orderIndex,
    required this.createdAt,
  });

  factory DebateMessage.fromJson(Map<String, dynamic> json) {
    return DebateMessage(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      agentName: json['agent_name'] as String,
      content: json['content'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'agent_name': agentName,
      'content': content,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DebateMessage copyWith({
    String? id,
    String? postId,
    String? agentName,
    String? content,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return DebateMessage(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      agentName: agentName ?? this.agentName,
      content: content ?? this.content,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
