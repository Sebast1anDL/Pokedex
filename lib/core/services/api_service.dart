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
}
