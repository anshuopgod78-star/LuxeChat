class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'].toString(),
      senderId: map['sender_id'] as String? ?? '',
      senderName: map['sender_name'] as String? ?? 'Member',
      body: map['body'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
