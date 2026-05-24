import 'package:flutter/material.dart';

class HomeStyles {
  // Colores por tipo de Pokémon
  static const Map<String, Color> typeColors = {
    'fire': Color(0xFFFF6B35),
    'water': Color(0xFF4FC3F7),
    'grass': Color(0xFF81C784),
    'electric': Color(0xFFFFD54F),
    'psychic': Color(0xFFF06292),
    'ice': Color(0xFF80DEEA),
    'dragon': Color(0xFF7C4DFF),
    'dark': Color(0xFF546E7A),
    'fairy': Color(0xFFF48FB1),
    'fighting': Color(0xFFFF7043),
    'flying': Color(0xFF90CAF9),
    'poison': Color(0xFFCE93D8),
    'ground': Color(0xFFFFCC80),
    'rock': Color(0xFFBCAAA4),
    'bug': Color(0xFFAED581),
    'ghost': Color(0xFF9575CD),
    'steel': Color(0xFFB0BEC5),
    'normal': Color(0xFFE0E0E0),
  };

  static Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? const Color(0xFFE0E0E0);
  }

  // Título
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 3.0,
  );

  // Saludo
  static const TextStyle greetingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  // Nombre del pokémon en la card
  static const TextStyle pokemonNameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Número del pokémon en la card
  static const TextStyle pokemonNumberStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  // Chip de tipo
  static const TextStyle typeChipStyle = TextStyle(
    fontSize: 10,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  // Barra de búsqueda
  static InputDecoration searchDecoration(BuildContext context) {
    return InputDecoration(
      hintText: 'Buscar Pokémon...',
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white12
          : Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
    );
  }

  // Espaciados
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
}
