import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waruna_transport/main.dart';
import 'package:waruna_transport/providers/app_provider.dart';
import 'package:waruna_transport/providers/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initialization and splash screen smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('WARUNA TRANSPORT'), findsOneWidget);

    // Advance past the 5-second splash animation and 800ms page transition
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verifies navigation to LoginScreen with PIN field
    expect(find.text('ඇතුල් වන්න'), findsOneWidget);
    expect(find.text('PIN අංකය ඇතුලත් කරන්න'), findsOneWidget);
  });
}
