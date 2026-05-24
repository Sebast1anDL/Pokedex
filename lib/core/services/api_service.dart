import 'package:dio/dio.dart';
import '../../models/pokemon.dart';
import '../../models/pokemon_detail.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://pokeapi.co/api/v2',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Cantidad total de pokémon disponibles
  int _totalCount = 0;
  int get totalCount => _totalCount;

  // Paso 1 — obtener página de la lista general
  Future<List<PokemonListItem>> getPokemonPage({
    required int offset,
    int limit = 20,
  }) async {
    // Llamada 1: lista general con nombre y URL
    final response = await _dio.get(
      '/pokemon',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    // Guardamos el total para saber cuándo parar el scroll
    _totalCount = response.data['count'] as int;

    final results = response.data['results'] as List;

    // Paso 2 — por cada pokémon de la página llamamos a su URL en paralelo
    final details = await Future.wait(
      results.map((p) => _getPokemonDetail(p['url'] as String)),
    );

    // Filtramos los nulls (por si alguna llamada falló)
    return details.whereType<PokemonListItem>().toList();
  }

  // Paso 2 — detalle individual de un pokémon
  Future<PokemonListItem?> _getPokemonDetail(String url) async {
    try {
      final response = await _dio.get(url);
      final data = response.data;

      final id = data['id'] as int;
      final name = data['name'] as String;

      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();

      // Intentamos obtener el artwork oficial, si no el sprite normal
      final imageUrl = data['sprites']['other']['official-artwork']
              ['front_default'] ??
          data['sprites']['front_default'] ??
          '';

      return PokemonListItem(
        id: id,
        name: name,
        imageUrl: imageUrl,
        types: types,
      );
    } catch (e) {
      return null;
    }
  }

  // Buscar pokémon por nombre (para la búsqueda)
  Future<PokemonListItem?> searchPokemon(String name) async {
    try {
      final response = await _dio.get('/pokemon/${name.toLowerCase().trim()}');
      final data = response.data;

      final id = data['id'] as int;
      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();

      final imageUrl = data['sprites']['other']['official-artwork']
              ['front_default'] ??
          data['sprites']['front_default'] ??
          '';

      return PokemonListItem(
        id: id,
        name: name,
        imageUrl: imageUrl,
        types: types,
      );
    } catch (e) {
      return null;
    }
  }

  // ─── Índice ligero ────────────────────────────────────────────────────────

  List<Map<String, String>> _pokemonIndex = [];
  bool _indexLoaded = false;

  // Una sola llamada al arrancar: solo nombres + URLs (~80 KB)
  Future<void> loadIndex() async {
    if (_indexLoaded) return;
    final response = await _dio.get(
      '/pokemon',
      queryParameters: {'limit': 2000, 'offset': 0},
    );
    _totalCount = response.data['count'] as int;
    _pokemonIndex = (response.data['results'] as List)
        .map((p) => {'name': p['name'] as String, 'url': p['url'] as String})
        .toList();
    _indexLoaded = true;
  }

  // Búsqueda parcial local — prioriza los que empiezan con el query
  List<Map<String, String>> searchIndex(String query, {int limit = 20}) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final queryNum = int.tryParse(q);
    final startsWith = <Map<String, String>>[];
    final contains = <Map<String, String>>[];

    for (final p in _pokemonIndex) {
      final name = p['name']!;
      final idNum = int.tryParse(
          p['url']!.split('/').where((s) => s.isNotEmpty).last);
      final idMatch = queryNum != null && idNum == queryNum;

      if (idMatch || name.startsWith(q)) {
        startsWith.add(p);
      } else if (name.contains(q)) {
        contains.add(p);
      }

      if (startsWith.length + contains.length >= limit * 2) break;
    }

    return [...startsWith, ...contains].take(limit).toList();
  }

  // ─── Filtros ──────────────────────────────────────────────────────────────

  final Map<String, List<String>> _filterCache = {};

  // Tipo: el endpoint devuelve {pokemon: [{pokemon: {url}}]}
  Future<List<String>> getTypePokemonUrls(String type) async {
    final key = 'type_$type';
    if (_filterCache.containsKey(key)) return _filterCache[key]!;
    final response = await _dio.get('/type/$type');
    final urls = (response.data['pokemon'] as List)
        .map((p) => p['pokemon']['url'] as String)
        .toList();
    _filterCache[key] = urls;
    return urls;
  }

  // Generación, color, forma y hábitat devuelven {pokemon_species: [{name, url}]}
  // Construimos la URL del pokémon a partir del nombre de la especie.
  Future<List<String>> _getSpeciesFilterUrls(
      String cacheKey, String endpoint) async {
    if (_filterCache.containsKey(cacheKey)) return _filterCache[cacheKey]!;
    final response = await _dio.get(endpoint);
    final species = response.data['pokemon_species'] as List;
    final urls = species
        .map((s) => 'https://pokeapi.co/api/v2/pokemon/${s['name']}/')
        .toList();
    _filterCache[cacheKey] = urls;
    return urls;
  }

  Future<List<String>> getGenerationPokemonUrls(String id) =>
      _getSpeciesFilterUrls('gen_$id', '/generation/$id');

  Future<List<String>> getColorPokemonUrls(String color) =>
      _getSpeciesFilterUrls('color_$color', '/pokemon-color/$color');

  Future<List<String>> getShapePokemonUrls(String shape) =>
      _getSpeciesFilterUrls('shape_$shape', '/pokemon-shape/$shape');

  Future<List<String>> getHabitatPokemonUrls(String habitat) =>
      _getSpeciesFilterUrls('habitat_$habitat', '/pokemon-habitat/$habitat');

  // Carga detalles de una lista de URLs en paralelo
  Future<List<PokemonListItem>> getDetailsByUrls(List<String> urls) async {
    final details =
        await Future.wait(urls.map((url) => _getPokemonDetail(url)));
    return details.whereType<PokemonListItem>().toList();
  }

  // ─── Detalle completo ─────────────────────────────────────────────────────

  Future<PokemonDetail> getPokemonFullDetail(int id) async {
    // Paso 1: pokémon + especie en paralelo
    final responses = await Future.wait([
      _dio.get('/pokemon/$id'),
      _dio.get('/pokemon-species/$id'),
    ]);
    final p = responses[0].data as Map<String, dynamic>;
    final s = responses[1].data as Map<String, dynamic>;

    final types = (p['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    final imageUrl =
        p['sprites']['other']['official-artwork']['front_default'] as String? ??
            p['sprites']['front_default'] as String? ??
            '';
    final shinyImageUrl =
        p['sprites']['other']['official-artwork']['front_shiny'] as String? ??
            p['sprites']['front_shiny'] as String? ??
            '';

    final baseStats = <String, int>{};
    for (final stat in p['stats'] as List) {
      baseStats[stat['stat']['name'] as String] =
          stat['base_stat'] as int;
    }

    final abilityNames = (p['abilities'] as List)
        .map((a) => (
              name: a['ability']['name'] as String,
              url: a['ability']['url'] as String,
              isHidden: a['is_hidden'] as bool,
            ))
        .toList();

    final moves = _parseMoves(p['moves'] as List);

    // Entradas de la pokédex en español
    final entries = (s['flavor_text_entries'] as List)
        .where((e) => e['language']['name'] == 'es')
        .map((e) => PokedexEntry(
              flavorText: (e['flavor_text'] as String)
                  .replaceAll('\n', ' ')
                  .replaceAll('\f', ' '),
              versionName: _formatName(e['version']['name'] as String),
            ))
        .toList();

    // Categoría en español (o inglés como fallback)
    final genera = s['genera'] as List;
    final categoryEntry = genera.firstWhere(
      (g) => g['language']['name'] == 'es',
      orElse: () => genera.firstWhere(
        (g) => g['language']['name'] == 'en',
        orElse: () => {'genus': ''},
      ),
    );
    final category = (categoryEntry['genus'] as String)
        .replaceAll(' Pokémon', '')
        .replaceAll(' Pokemon', '');

    final eggGroups = (s['egg_groups'] as List)
        .map((g) => _formatName(g['name'] as String))
        .toList();

    // Paso 2: habilidades + cadena evolutiva en paralelo
    final evoChainUrl = s['evolution_chain']['url'] as String;
    final futures = <Future>[
      ...abilityNames.map((a) => _dio.get(a.url)),
      _dio.get(evoChainUrl),
    ];
    final results = await Future.wait(futures);

    final abilities = <PokemonAbilityDetail>[];
    for (var i = 0; i < abilityNames.length; i++) {
      final aData = results[i].data as Map<String, dynamic>;
      final effectEntries = aData['effect_entries'] as List;
      final esEntry = effectEntries.firstWhere(
        (e) => e['language']['name'] == 'es',
        orElse: () => effectEntries.firstWhere(
          (e) => e['language']['name'] == 'en',
          orElse: () => null,
        ),
      );
      final description = esEntry != null
          ? (esEntry['short_effect'] as String? ?? '')
          : '';
      abilities.add(PokemonAbilityDetail(
        name: _formatName(abilityNames[i].name),
        description: description,
        isHidden: abilityNames[i].isHidden,
      ));
    }

    final evoData =
        results[abilityNames.length].data as Map<String, dynamic>;
    final evolutionChain =
        await _parseEvolutionNode(evoData['chain'] as Map<String, dynamic>);

    return PokemonDetail(
      id: p['id'] as int,
      name: p['name'] as String,
      imageUrl: imageUrl,
      shinyImageUrl: shinyImageUrl,
      types: types,
      height: p['height'] as int,
      weight: p['weight'] as int,
      baseExperience: p['base_experience'] as int? ?? 0,
      baseStats: baseStats,
      abilities: abilities,
      moves: moves,
      pokedexEntries: entries,
      category: category,
      color: s['color']['name'] as String,
      captureRate: s['capture_rate'] as int,
      baseHappiness: s['base_happiness'] as int? ?? 0,
      growthRate: s['growth_rate']['name'] as String,
      eggGroups: eggGroups,
      genderRate: s['gender_rate'] as int,
      isLegendary: s['is_legendary'] as bool,
      isMythical: s['is_mythical'] as bool,
      generation: s['generation']['name'] as String,
      hatchCounter: s['hatch_counter'] as int? ?? 0,
      evolutionChain: evolutionChain,
    );
  }

  String _formatName(String name) {
    return name
        .split('-')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  List<PokemonMoveEntry> _parseMoves(List movesData) {
    final moves = <PokemonMoveEntry>[];
    for (final m in movesData) {
      final moveName = m['move']['name'] as String;
      for (final vgd in m['version_group_details'] as List) {
        final method = vgd['move_learn_method']['name'] as String;
        final level = vgd['level_learned_at'] as int;
        moves.add(PokemonMoveEntry(
          name: _formatName(moveName),
          learnMethod: method,
          levelLearnedAt: level,
        ));
        break; // solo la primera versión
      }
    }
    // Deduplicar por nombre+método
    final seen = <String>{};
    return moves.where((m) {
      final key = '${m.name}|${m.learnMethod}';
      return seen.add(key);
    }).toList();
  }

  Future<EvolutionNode> _parseEvolutionNode(
      Map<String, dynamic> chain) async {
    final speciesUrl = chain['species']['url'] as String;
    final speciesId = int.parse(
        speciesUrl.split('/').where((s) => s.isNotEmpty).last);

    // Intentamos obtener la imagen del pokémon base de esa especie
    String imageUrl = '';
    try {
      final pr = await _dio.get('/pokemon/$speciesId');
      imageUrl = pr.data['sprites']['other']['official-artwork']
              ['front_default'] as String? ??
          '';
    } catch (_) {}

    final condition = _describeEvolution(chain['evolution_details'] as List);

    final evolvesTo = await Future.wait(
      (chain['evolves_to'] as List)
          .map((child) => _parseEvolutionNode(child as Map<String, dynamic>)),
    );

    return EvolutionNode(
      id: speciesId,
      name: _formatName(chain['species']['name'] as String),
      imageUrl: imageUrl,
      condition: condition,
      evolvesTo: evolvesTo,
    );
  }

  String _describeEvolution(List details) {
    if (details.isEmpty) return '';
    final d = details[0] as Map<String, dynamic>;
    final parts = <String>[];

    final trigger = d['trigger']['name'] as String;
    if (trigger == 'level-up') {
      final minLevel = d['min_level'];
      if (minLevel != null) parts.add('Nv. $minLevel');
    } else if (trigger == 'use-item') {
      final item = d['item'];
      if (item != null) parts.add(_formatName(item['name'] as String));
    } else if (trigger == 'trade') {
      parts.add('Intercambio');
      final item = d['held_item'];
      if (item != null) parts.add('con ${_formatName(item['name'] as String)}');
    } else {
      parts.add(_formatName(trigger));
    }

    final friendship = d['min_happiness'];
    if (friendship != null) parts.add('Amistad ≥$friendship');

    final beauty = d['min_beauty'];
    if (beauty != null) parts.add('Belleza ≥$beauty');

    final affection = d['min_affection'];
    if (affection != null) parts.add('Afecto ≥$affection');

    final timeOfDay = d['time_of_day'];
    if (timeOfDay != null && (timeOfDay as String).isNotEmpty) {
      parts.add(timeOfDay == 'day' ? 'Día' : 'Noche');
    }

    final knownMove = d['known_move'];
    if (knownMove != null) {
      parts.add('Conoce ${_formatName(knownMove['name'] as String)}');
    }

    final location = d['location'];
    if (location != null) {
      parts.add('En ${_formatName(location['name'] as String)}');
    }

    if (parts.isEmpty) parts.add(_formatName(trigger));
    return parts.join(', ');
  }
}
