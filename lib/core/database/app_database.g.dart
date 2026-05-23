// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, username, password, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<Usuario> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final int id;
  final String username;
  final String password;
  final String createdAt;
  const Usuario(
      {required this.id,
      required this.username,
      required this.password,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      username: Value(username),
      password: Value(password),
      createdAt: Value(createdAt),
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Usuario copyWith(
          {int? id, String? username, String? password, String? createdAt}) =>
      Usuario(
        id: id ?? this.id,
        username: username ?? this.username,
        password: password ?? this.password,
        createdAt: createdAt ?? this.createdAt,
      );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, password, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.username == this.username &&
          other.password == this.password &&
          other.createdAt == this.createdAt);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> password;
  final Value<String> createdAt;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsuariosCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String password,
    required String createdAt,
  })  : username = Value(username),
        password = Value(password),
        createdAt = Value(createdAt);
  static Insertable<Usuario> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsuariosCompanion copyWith(
      {Value<int>? id,
      Value<String>? username,
      Value<String>? password,
      Value<String>? createdAt}) {
    return UsuariosCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FavoritosTable extends Favoritos
    with TableInfo<$FavoritosTable, Favorito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pokemonIdMeta =
      const VerificationMeta('pokemonId');
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
      'pokemon_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pokemonNameMeta =
      const VerificationMeta('pokemonName');
  @override
  late final GeneratedColumn<String> pokemonName = GeneratedColumn<String>(
      'pokemon_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pokemonImageMeta =
      const VerificationMeta('pokemonImage');
  @override
  late final GeneratedColumn<String> pokemonImage = GeneratedColumn<String>(
      'pokemon_image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, pokemonId, pokemonName, pokemonImage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favoritos';
  @override
  VerificationContext validateIntegrity(Insertable<Favorito> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('pokemon_id')) {
      context.handle(_pokemonIdMeta,
          pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta));
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('pokemon_name')) {
      context.handle(
          _pokemonNameMeta,
          pokemonName.isAcceptableOrUnknown(
              data['pokemon_name']!, _pokemonNameMeta));
    } else if (isInserting) {
      context.missing(_pokemonNameMeta);
    }
    if (data.containsKey('pokemon_image')) {
      context.handle(
          _pokemonImageMeta,
          pokemonImage.isAcceptableOrUnknown(
              data['pokemon_image']!, _pokemonImageMeta));
    } else if (isInserting) {
      context.missing(_pokemonImageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Favorito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorito(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      pokemonId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pokemon_id'])!,
      pokemonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pokemon_name'])!,
      pokemonImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pokemon_image'])!,
    );
  }

  @override
  $FavoritosTable createAlias(String alias) {
    return $FavoritosTable(attachedDatabase, alias);
  }
}

class Favorito extends DataClass implements Insertable<Favorito> {
  final int id;
  final int userId;
  final int pokemonId;
  final String pokemonName;
  final String pokemonImage;
  const Favorito(
      {required this.id,
      required this.userId,
      required this.pokemonId,
      required this.pokemonName,
      required this.pokemonImage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['pokemon_name'] = Variable<String>(pokemonName);
    map['pokemon_image'] = Variable<String>(pokemonImage);
    return map;
  }

  FavoritosCompanion toCompanion(bool nullToAbsent) {
    return FavoritosCompanion(
      id: Value(id),
      userId: Value(userId),
      pokemonId: Value(pokemonId),
      pokemonName: Value(pokemonName),
      pokemonImage: Value(pokemonImage),
    );
  }

  factory Favorito.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorito(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      pokemonName: serializer.fromJson<String>(json['pokemonName']),
      pokemonImage: serializer.fromJson<String>(json['pokemonImage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'pokemonId': serializer.toJson<int>(pokemonId),
      'pokemonName': serializer.toJson<String>(pokemonName),
      'pokemonImage': serializer.toJson<String>(pokemonImage),
    };
  }

  Favorito copyWith(
          {int? id,
          int? userId,
          int? pokemonId,
          String? pokemonName,
          String? pokemonImage}) =>
      Favorito(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        pokemonId: pokemonId ?? this.pokemonId,
        pokemonName: pokemonName ?? this.pokemonName,
        pokemonImage: pokemonImage ?? this.pokemonImage,
      );
  Favorito copyWithCompanion(FavoritosCompanion data) {
    return Favorito(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      pokemonName:
          data.pokemonName.present ? data.pokemonName.value : this.pokemonName,
      pokemonImage: data.pokemonImage.present
          ? data.pokemonImage.value
          : this.pokemonImage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorito(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('pokemonName: $pokemonName, ')
          ..write('pokemonImage: $pokemonImage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, pokemonId, pokemonName, pokemonImage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorito &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.pokemonId == this.pokemonId &&
          other.pokemonName == this.pokemonName &&
          other.pokemonImage == this.pokemonImage);
}

class FavoritosCompanion extends UpdateCompanion<Favorito> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> pokemonId;
  final Value<String> pokemonName;
  final Value<String> pokemonImage;
  const FavoritosCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.pokemonId = const Value.absent(),
    this.pokemonName = const Value.absent(),
    this.pokemonImage = const Value.absent(),
  });
  FavoritosCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int pokemonId,
    required String pokemonName,
    required String pokemonImage,
  })  : userId = Value(userId),
        pokemonId = Value(pokemonId),
        pokemonName = Value(pokemonName),
        pokemonImage = Value(pokemonImage);
  static Insertable<Favorito> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? pokemonId,
    Expression<String>? pokemonName,
    Expression<String>? pokemonImage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (pokemonName != null) 'pokemon_name': pokemonName,
      if (pokemonImage != null) 'pokemon_image': pokemonImage,
    });
  }

  FavoritosCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int>? pokemonId,
      Value<String>? pokemonName,
      Value<String>? pokemonImage}) {
    return FavoritosCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pokemonId: pokemonId ?? this.pokemonId,
      pokemonName: pokemonName ?? this.pokemonName,
      pokemonImage: pokemonImage ?? this.pokemonImage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (pokemonName.present) {
      map['pokemon_name'] = Variable<String>(pokemonName.value);
    }
    if (pokemonImage.present) {
      map['pokemon_image'] = Variable<String>(pokemonImage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritosCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('pokemonName: $pokemonName, ')
          ..write('pokemonImage: $pokemonImage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $FavoritosTable favoritos = $FavoritosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [usuarios, favoritos];
}

typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  required String username,
  required String password,
  required String createdAt,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  Value<String> username,
  Value<String> password,
  Value<String> createdAt,
});

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsuariosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsuariosTable,
    Usuario,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (Usuario, BaseReferences<_$AppDatabase, $UsuariosTable, Usuario>),
    Usuario,
    PrefetchHooks Function()> {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              UsuariosCompanion(
            id: id,
            username: username,
            password: password,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String username,
            required String password,
            required String createdAt,
          }) =>
              UsuariosCompanion.insert(
            id: id,
            username: username,
            password: password,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsuariosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsuariosTable,
    Usuario,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (Usuario, BaseReferences<_$AppDatabase, $UsuariosTable, Usuario>),
    Usuario,
    PrefetchHooks Function()>;
typedef $$FavoritosTableCreateCompanionBuilder = FavoritosCompanion Function({
  Value<int> id,
  required int userId,
  required int pokemonId,
  required String pokemonName,
  required String pokemonImage,
});
typedef $$FavoritosTableUpdateCompanionBuilder = FavoritosCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<int> pokemonId,
  Value<String> pokemonName,
  Value<String> pokemonImage,
});

class $$FavoritosTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritosTable> {
  $$FavoritosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pokemonId => $composableBuilder(
      column: $table.pokemonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pokemonName => $composableBuilder(
      column: $table.pokemonName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pokemonImage => $composableBuilder(
      column: $table.pokemonImage, builder: (column) => ColumnFilters(column));
}

class $$FavoritosTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritosTable> {
  $$FavoritosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pokemonId => $composableBuilder(
      column: $table.pokemonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pokemonName => $composableBuilder(
      column: $table.pokemonName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pokemonImage => $composableBuilder(
      column: $table.pokemonImage,
      builder: (column) => ColumnOrderings(column));
}

class $$FavoritosTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritosTable> {
  $$FavoritosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get pokemonId =>
      $composableBuilder(column: $table.pokemonId, builder: (column) => column);

  GeneratedColumn<String> get pokemonName => $composableBuilder(
      column: $table.pokemonName, builder: (column) => column);

  GeneratedColumn<String> get pokemonImage => $composableBuilder(
      column: $table.pokemonImage, builder: (column) => column);
}

class $$FavoritosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoritosTable,
    Favorito,
    $$FavoritosTableFilterComposer,
    $$FavoritosTableOrderingComposer,
    $$FavoritosTableAnnotationComposer,
    $$FavoritosTableCreateCompanionBuilder,
    $$FavoritosTableUpdateCompanionBuilder,
    (Favorito, BaseReferences<_$AppDatabase, $FavoritosTable, Favorito>),
    Favorito,
    PrefetchHooks Function()> {
  $$FavoritosTableTableManager(_$AppDatabase db, $FavoritosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int> pokemonId = const Value.absent(),
            Value<String> pokemonName = const Value.absent(),
            Value<String> pokemonImage = const Value.absent(),
          }) =>
              FavoritosCompanion(
            id: id,
            userId: userId,
            pokemonId: pokemonId,
            pokemonName: pokemonName,
            pokemonImage: pokemonImage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required int pokemonId,
            required String pokemonName,
            required String pokemonImage,
          }) =>
              FavoritosCompanion.insert(
            id: id,
            userId: userId,
            pokemonId: pokemonId,
            pokemonName: pokemonName,
            pokemonImage: pokemonImage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoritosTable,
    Favorito,
    $$FavoritosTableFilterComposer,
    $$FavoritosTableOrderingComposer,
    $$FavoritosTableAnnotationComposer,
    $$FavoritosTableCreateCompanionBuilder,
    $$FavoritosTableUpdateCompanionBuilder,
    (Favorito, BaseReferences<_$AppDatabase, $FavoritosTable, Favorito>),
    Favorito,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$FavoritosTableTableManager get favoritos =>
      $$FavoritosTableTableManager(_db, _db.favoritos);
}
