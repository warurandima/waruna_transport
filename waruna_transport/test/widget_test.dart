import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waruna_transport/main.dart';
import 'package:waruna_transport/providers/app_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initialization and splash screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('WARUNA TRANSPORT'), findsOneWidget);
    expect(find.text('වරුණ ට්රාන්ස්පෝර්ට්'), findsOneWidget);

    // Advance past the 3-second splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verifies navigation to LoginScreen with PIN field
    expect(find.text('ඇතුල් වන්න'), findsOneWidget);
    expect(find.text('PIN අංකය ඇතුලත් කරන්න'), findsOneWidget);
  });
}
