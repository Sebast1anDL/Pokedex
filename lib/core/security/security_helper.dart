import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilidades de seguridad para la aplicación.
///
/// Implementa hashing de contraseñas con SHA-256 + salt derivado
/// para evitar almacenamiento en texto plano en la base de datos local.
class SecurityHelper {
  // Salt fijo de la aplicación (previene ataques de rainbow table genéricos)
  static const String _appSalt = 'pokedex_app_2026_salt_v1';

  /// Hashea una contraseña combinando:
  /// - Salt fijo de la app
  /// - Salt dinámico basado en el username (único por usuario)
  ///
  /// Ejemplo: `hashPassword('secret', 'ash')` → SHA-256 hex string
  static String hashPassword(String password, String username) {
    // Salt compuesto: appSalt + username (evita que dos usuarios con la misma
    // contraseña tengan el mismo hash)
    final salt = '$_appSalt:${username.toLowerCase()}';
    final salted = '$salt:$password';
    final bytes = utf8.encode(salted);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica si una contraseña en texto plano coincide con su hash almacenado.
  static bool verifyPassword({
    required String plainPassword,
    required String storedHash,
    required String username,
  }) {
    final computed = hashPassword(plainPassword, username);
    return computed == storedHash;
  }
}
