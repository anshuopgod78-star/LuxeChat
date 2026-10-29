import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creatingAccount = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (_creatingAccount) {
        final result = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'display_name': _name.text.trim()},
        );
        if (mounted && result.session == null) {
          setState(() => _error = 'Check your email for a confirmation link, then sign in.');
        }
      } else {
        await auth.signInWithPassword(email: _email.text.trim(), password: _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Align(alignment: Alignment.centerLeft, child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), gradient: const LinearGradient(colors: [LuxeChatApp.violet, LuxeChatApp.pink])),
                    child: const Icon(Icons.forum_rounded, color: Colors.white, size: 32),
                  )),
                  const SizedBox(height: 22),
                  const Text('Your people,\nyour space.', style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w800, color: LuxeChatApp.ink)),
                  const SizedBox(height: 10),
                  Text(_creatingAccount ? 'Create your LuxeChat account.' : 'Welcome back to LuxeChat.', style: const TextStyle(color: Colors.black54, fontSize: 16)),
                  const SizedBox(height: 28),
                  if (_creatingAccount) ...[
                    TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => (v == null || v.trim().length < 2) ? 'Enter at least 2 characters.' : null),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)), validator: (v) => (v == null || !v.contains('@') || !v.contains('.')) ? 'Enter a valid email address.' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _password, obscureText: _hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters.' : null),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFEAF1), borderRadius: BorderRadius.circular(14)), child: Text(_error!, style: const TextStyle(color: Color(0xFF9E2853)))),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: LuxeChatApp.violet, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                    child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_creatingAccount ? 'Create account' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: _busy ? null : () => setState(() { _creatingAccount = !_creatingAccount; _error = null; }), child: Text(_creatingAccount ? 'Already have an account? Sign in' : 'New to LuxeChat? Create an account')),
                  const SizedBox(height: 8),
                  const Text('Be kind. Keep your account secure. Never share your password or verification codes.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
