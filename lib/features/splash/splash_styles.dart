import 'package:flutter/material.dart';

class SplashStyles {
  // Colores del degradado
  static const Color gradientTop = Color(0xFFCC0000);
  static const Color gradientBottom = Color(0xFF0A0A0A);

  // Degradado de fondo
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );

  // Tamaño del GIF
  static const double gifSize = 220.0;

  // Estilos del título
  static const TextStyle titleStyle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 4.0,
  );

  // Estilos del subtítulo
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.white60,
    letterSpacing: 2.0,
  );

  // Tamaño del indicador de carga
  static const double loaderSize = 24.0;
  static const Color loaderColor = Colors.white54;

  // Espaciados
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 32.0;
}
