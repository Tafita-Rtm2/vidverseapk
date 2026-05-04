import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF05070F);
  static const Color bg2 = Color(0xFF080C18);
  static const Color sf = Color(0xFF0C1124);
  static const Color s2 = Color(0xFF10192E);
  static const Color s3 = Color(0xFF172240);
  static const Color accent = Color(0xFFE8A020);
  static const Color accent2 = Color(0xFFF0C060);
  static const Color text = Color(0xFFEEF0F8);
  static const Color textSecondary = Color(0xFF7A8AAA);
  static const Color textTertiary = Color(0xFF3A4560);
  static const Color green = Color(0xFF22D3A4);
  static const Color red = Color(0xFFFF4D5E);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE8A020), Color(0xFFF5D060), Color(0xFFC07010)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

const Map<String, String> countryFlags = {
  'MG': '🇲🇬', 'FR': '🇫🇷', 'RE': '🇷🇪', 'MU': '🇲🇺', 'US': '🇺🇸', 'GB': '🇬🇧',
  'ES': '🇪🇸', 'IT': '🇮🇹', 'DE': '🇩🇪', 'BR': '🇧🇷', 'CA': '🇨🇦', 'JP': '🇯🇵',
};

const Map<String, String> countryNames = {
  'MG': 'Madagascar', 'FR': 'France', 'RE': 'Réunion', 'MU': 'Maurice', 'US': 'USA', 'GB': 'UK',
};
