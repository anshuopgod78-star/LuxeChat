import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatService {
  ChatService(this._client);
  final SupabaseClient _client;

  String get currentUserId => _client.auth.currentUser!.id;
  String get currentUserName {
    final user = _client.auth.currentUser!;
    final metadataName = user.userMetadata?['display_name'];
    if (metadataName is String && metadataName.trim().isNotEmpty) return metadataName.trim();
    return user.email?.split('@').first ?? 'Member';
  }

  Stream<List<ChatMessage>> watchLobby() {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(100)
        .map((rows) => rows.map(ChatMessage.fromMap).toList());
  }

  Future<void> sendLobbyMessage(String rawBody) async {
    final body = rawBody.trim();
    if (body.isEmpty) return;
    if (body.length > 2000) throw ArgumentError('Messages must be 2,000 characters or fewer.');
    await _client.from('messages').insert({
      'sender_id': currentUserId,
      'sender_name': currentUserName,
      'body': body,
    });
  }
}
