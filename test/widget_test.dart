import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/main.dart';
import 'package:mobile_pos/features/loading/loading_page.dart';

void main() {
  testWidgets('App starts with LoadingPage smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that LoadingPage is rendered.
    expect(find.byType(LoadingPage), findsOneWidget);

    // Wait for the delayed navigation timer in LoadingPage to fire and resolve
    await tester.pumpAndSettle(const Duration(milliseconds: 1000));
  });
}
