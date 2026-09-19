import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:alkitab_suara_harmoni/main.dart';
import 'package:alkitab_suara_harmoni/providers/theme_provider.dart';
import 'package:alkitab_suara_harmoni/providers/bible_provider.dart';
import 'package:alkitab_suara_harmoni/providers/audio_player_provider.dart';

void main() {
  testWidgets('AlkitabAudioHarmoniApp basic smoke test', (WidgetTester tester) async {
    final themeProv = ThemeProvider();
    final bibleProv = BibleProvider();
    final audioProv = AudioPlayerProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProv),
          ChangeNotifierProvider.value(value: bibleProv),
          ChangeNotifierProvider.value(value: audioProv),
        ],
        child: const AlkitabAudioHarmoniApp(),
      ),
    );

    expect(find.byType(AlkitabAudioHarmoniApp), findsOneWidget);
  });
}
