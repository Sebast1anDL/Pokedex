import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  late AppDatabase _db;

  // Inicializar la base de datos
  Future<void> init() async {
    _db = AppDatabase();
  }

  AppDatabase get db => _db;

  // ─── USUARIOS ───────────────────────────────────────────

  // Crear usuario
  Future<int> createUser({
    required String username,
    required String password,
  }) async {
    return await _db.into(_db.usuarios).insert(
          UsuariosCompanion.insert(
            username: username,
            password: password,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  // Buscar usuario por username
  Future<Usuario?> getUserByUsername(String username) async {
    return await (_db.select(_db.usuarios)
          ..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  // Verificar si el username ya existe
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // Validar login
  Future<Usuario?> validateLogin({
    required String username,
    required String password,
  }) async {
    return await (_db.select(_db.usuarios)
          ..where(
              (u) => u.username.equals(username) & u.password.equals(password)))
        .getSingleOrNull();
  }

  // ─── FAVORITOS ──────────────────────────────────────────

  // Agregar favorito
  Future<int> addFavorite({
    required int userId,
    required int pokemonId,
    required String pokemonName,
    required String pokemonImage,
  }) async {
    return await _db.into(_db.favoritos).insert(
          FavoritosCompanion.insert(
            userId: userId,
            pokemonId: pokemonId,
            pokemonName: pokemonName,
            pokemonImage: pokemonImage,
          ),
        );
  }

  // Obtener favoritos de un usuario
  Future<List<Favorito>> getFavoritesByUser(int userId) async {
    return await (_db.select(_db.favoritos)
          ..where((f) => f.userId.equals(userId)))
        .get();
  }

  // Verificar si un pokemon es favorito
  Future<bool> isFavorite({
    required int userId,
    required int pokemonId,
  }) async {
    final result = await (_db.select(_db.favoritos)
          ..where(
              (f) => f.userId.equals(userId) & f.pokemonId.equals(pokemonId)))
        .getSingleOrNull();
    return result != null;
  }

  // Eliminar favorito
  Future<void> removeFavorite({
    required int userId,
    required int pokemonId,
  }) async {
    await (_db.delete(_db.favoritos)
          ..where(
              (f) => f.userId.equals(userId) & f.pokemonId.equals(pokemonId)))
        .go();
  }
}
