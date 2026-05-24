import 'package:dio/dio.dart';
import '../../models/pokemon.dart';

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
}
