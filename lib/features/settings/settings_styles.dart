import 'package:flutter/material.dart';

class SettingsStyles {
  // Título de sección
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  // Título del item
  static const TextStyle itemTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Subtítulo del item
  static const TextStyle itemSubtitleStyle = TextStyle(
    fontSize: 13,
  );

  // Texto del "Hecho por"
  static const TextStyle madeByStyle = TextStyle(
    fontSize: 12,
  );

  // Estilo del botón de cerrar sesión
  static final ButtonStyle logoutButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFCC0000),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  );

  // Espaciados
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
}
