import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi Global AudioContext agar pemutar audio musik dan narasi suara
  // dapat diputar bersamaan di Android tanpa saling mematikan fokus (mixWithOthers)
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error setting global audio context: $e');
  }

  // Set orientasi portrait & status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final bibleProvider = BibleProvider();
  final audioPlayerProvider = AudioPlayerProvider();
  final themeProvider = ThemeProvider();

  // Inisialisasi service dasar
  await bibleProvider.initialize();
  await audioPlayerProvider.initialize();
  await themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: bibleProvider),
        ChangeNotifierProvider.value(value: audioPlayerProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const AlkitabAudioHarmoniApp(),
    ),
  );
}

class AlkitabAudioHarmoniApp extends StatelessWidget {
  const AlkitabAudioHarmoniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Alkitab Harmoni & Suara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(themeProv.themeMode),
      home: const HomeScreen(),
    );
  }
}
