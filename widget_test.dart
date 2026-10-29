import 'package:flutter_test/flutter_test.dart';
import 'package:luxe_chat/main.dart';

void main() {
  testWidgets('shows honest setup screen when backend is not configured', (tester) async {
    await tester.pumpWidget(const LuxeChatApp(backendConfigured: false));
    expect(find.text('LuxeChat'), findsOneWidget);
    expect(find.text('One setup step left'), findsOneWidget);
    expect(find.textContaining('does not pretend to be connected'), findsOneWidget);
  });
}
