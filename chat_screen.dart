import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composer = TextEditingController();
  late final ChatService _service;
  bool _sending = false;
  String? _sendError;

  @override
  void initState() { super.initState(); _service = ChatService(Supabase.instance.client); }
  @override
  void dispose() { _composer.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_sending || _composer.text.trim().isEmpty) return;
    final text = _composer.text;
    setState(() { _sending = true; _sendError = null; });
    try {
      await _service.sendLobbyMessage(text);
      _composer.clear();
    } catch (_) {
      if (mounted) setState(() => _sendError = 'Message not sent. Check your connection and try again.');
    } finally { if (mounted) setState(() => _sending = false); }
  }

  Future<void> _signOut() async => Supabase.instance.client.auth.signOut();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['display_name'] as String?)?.trim().isNotEmpty == true
        ? (user!.userMetadata!['display_name'] as String).trim()
        : (user?.email?.split('@').first ?? 'Member');
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [LuxeChatApp.violet, LuxeChatApp.pink])), child: const Icon(Icons.forum_rounded, color: Colors.white)),
          const SizedBox(width: 11),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LuxeChat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)), Text('Community lobby', style: TextStyle(fontSize: 12, color: Colors.black54))])),
        ]),
        actions: [IconButton(tooltip: 'Sign out', onPressed: _signOut, icon: const Icon(Icons.logout_rounded)), const SizedBox(width: 4)],
      ),
      body: Column(children: [
        Container(margin: const EdgeInsets.fromLTRB(16, 4, 16, 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEDE7FF), Color(0xFFFFE8F2)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: LuxeChatApp.violet), const SizedBox(width: 10), Expanded(child: Text('Hey, $name! Keep it kind and make this space yours.', style: const TextStyle(fontWeight: FontWeight.w600)))])),
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _service.watchLobby(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Could not load messages. Check the Supabase setup and table permissions.', textAlign: TextAlign.center)));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final messages = snapshot.data!;
              if (messages.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_outline, size: 42, color: LuxeChatApp.violet), SizedBox(height: 12), Text('Your conversation starts here', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)), SizedBox(height: 5), Text('Send the first message to the lobby.', style: TextStyle(color: Colors.black54))])));
              return ListView.builder(reverse: true, padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), itemCount: messages.length, itemBuilder: (context, index) {
                final message = messages[index];
                final mine = message.senderId == _service.currentUserId;
                return _MessageBubble(message: message, mine: mine);
              });
            },
          ),
        ),
        if (_sendError != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text(_sendError!, style: const TextStyle(color: Colors.red, fontSize: 12)))),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: TextField(controller: _composer, minLines: 1, maxLines: 5, maxLength: 2000, textCapitalization: TextCapitalization.sentences, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: 'Write something kind…', counterText: '', prefixIcon: const Icon(Icons.chat_bubble_outline), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none)))),
          const SizedBox(width: 8),
          Container(height: 52, width: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [LuxeChatApp.violet, LuxeChatApp.pink])), child: IconButton(tooltip: 'Send message', onPressed: _sending ? null : _send, icon: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, color: Colors.white))),
        ]))),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(message.createdAt);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFFECE5FF) : Colors.white,
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(mine ? 18 : 5), bottomRight: Radius.circular(mine ? 5 : 18)),
            border: Border.all(color: mine ? const Color(0xFFD8CAFF) : const Color(0xFFECEAF2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!mine) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(message.senderName, style: const TextStyle(fontWeight: FontWeight.w800, color: LuxeChatApp.violet, fontSize: 12))),
            Text(message.body, style: const TextStyle(fontSize: 15, height: 1.3, color: LuxeChatApp.ink)),
            const SizedBox(height: 4),
            Align(alignment: Alignment.bottomRight, child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.black45))),
          ]),
        ),
      ),
    );
  }
}
