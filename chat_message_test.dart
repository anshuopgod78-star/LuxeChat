import 'package:flutter_test/flutter_test.dart';
import 'package:luxe_chat/models/chat_message.dart';

void main() {
  group('ChatMessage.fromMap', () {
    test('parses a normal message', () {
      final message = ChatMessage.fromMap({
        'id': 42,
        'sender_id': 'user-123',
        'sender_name': 'Ari',
        'body': 'Hello LuxeChat',
        'created_at': '2026-01-02T03:04:05.000Z',
      });
      expect(message.id, '42');
      expect(message.senderId, 'user-123');
      expect(message.senderName, 'Ari');
      expect(message.body, 'Hello LuxeChat');
      expect(message.createdAt.isUtc, isFalse);
    });

    test('uses safe fallbacks for missing optional fields', () {
      final message = ChatMessage.fromMap({'id': 'm-1'});
      expect(message.senderId, '');
      expect(message.senderName, 'Member');
      expect(message.body, '');
      expect(message.createdAt.millisecondsSinceEpoch, 0);
    });
  });
}
