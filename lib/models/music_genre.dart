import 'package:flutter/material.dart';

class MusicGenre {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String assetPath;
  final IconData icon;
  final Color accentColor;

  const MusicGenre({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.accentColor,
  });

  bool get isMuted => id == 'none' || assetPath.isEmpty;

  static const List<MusicGenre> allGenres = [
    MusicGenre(
      id: 'piano',
      name: 'Piano Khidmat',
      subtitle: 'Peaceful & Worship',
      description: 'Melodi tuts piano yang syahdu dan mengalir lembut untuk perenungan firman.',
      assetPath: 'assets/audio/piano_peaceful.wav',
      icon: Icons.piano,
      accentColor: Color(0xFFF59E0B),
    ),
    MusicGenre(
      id: 'acoustic',
      name: 'Akustik Meditasi',
      subtitle: 'Warm & Reflective',
      description: 'Petikan dawai gitar akustik yang hangat membawa suasana doa yang intim.',
      assetPath: 'assets/audio/acoustic_meditation.wav',
      icon: Icons.music_note,
      accentColor: Color(0xFF10B981),
    ),
    MusicGenre(
      id: 'ambient',
      name: 'Ambient Teduh',
      subtitle: 'Celestial Pads',
      description: 'Nuansa hening mendalam dengan alunan pad lembut yang menyejukkan hati.',
      assetPath: 'assets/audio/ambient_worship.wav',
      icon: Icons.waves,
      accentColor: Color(0xFF8B5CF6),
    ),
    MusicGenre(
      id: 'lofi',
      name: 'Lofi Santai',
      subtitle: 'Mellow Chill',
      description: 'Irama santai dan hangat yang menenangkan pikiran untuk fokus membaca.',
      assetPath: 'assets/audio/lofi_chill.wav',
      icon: Icons.headphones,
      accentColor: Color(0xFFEC4899),
    ),
    MusicGenre(
      id: 'nature',
      name: 'Suara Alam Damai',
      subtitle: 'Gentle Rain & Calm',
      description: 'Gemercik rintik hujan dan hembusan angin alami yang menyegarkan jiwa.',
      assetPath: 'assets/audio/nature_rain.wav',
      icon: Icons.water_drop,
      accentColor: Color(0xFF06B6D4),
    ),
    MusicGenre(
      id: 'orchestra',
      name: 'Orkestra Khidmat',
      subtitle: 'Sacred Strings',
      description: 'Alunan string megah dan agung membangkitkan rasa hormat dan kekaguman.',
      assetPath: 'assets/audio/orchestral_strings.wav',
      icon: Icons.queue_music,
      accentColor: Color(0xFFEAB308),
    ),
    MusicGenre(
      id: 'none',
      name: 'Tanpa Musik',
      subtitle: 'Hening',
      description: 'Hanya mendengarkan suara narasi ayat tanpa iringan musik latar.',
      assetPath: '',
      icon: Icons.volume_off,
      accentColor: Color(0xFF64748B),
    ),
  ];

  static MusicGenre getById(String id) {
    return allGenres.firstWhere(
      (g) => g.id == id,
      orElse: () => allGenres.first,
    );
  }
}
