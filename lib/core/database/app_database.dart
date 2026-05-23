import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tabla de usuarios
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get password => text()();
  TextColumn get createdAt => text()();
}

// Tabla de favoritos
class Favoritos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  IntColumn get pokemonId => integer()();
  TextColumn get pokemonName => text()();
  TextColumn get pokemonImage => text()();
}

@DriftDatabase(tables: [Usuarios, Favoritos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pokedex.db'));
    return NativeDatabase.createInBackground(file);
  });
}
