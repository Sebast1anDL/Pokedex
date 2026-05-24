import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/api_service.dart';
import '../../models/pokemon.dart';
import '../../shared/widgets/pokemon_card.dart';
import '../home/home_styles.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<PokemonListItem> _favorites = [];
  int _userId = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id') ?? 0;

      final favoritos = await DatabaseHelper().getFavoritesByUser(_userId);

      if (favoritos.isEmpty) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        return;
      }

      // Carga detalles completos (tipos, imagen oficial) de cada favorito
      final urls = favoritos
          .map((f) => 'https://pokeapi.co/api/v2/pokemon/${f.pokemonId}/')
          .toList();
      final pokemon = await ApiService().getDetailsByUrls(urls);

      if (mounted) {
        setState(() {
          _favorites = pokemon;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar favoritos. Verificá tu conexión.';
        });
      }
    }
  }

  void _onFavoriteRemoved(int pokemonId) {
    setState(() {
      _favorites.removeWhere((p) => p.id == pokemonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Text(
                'FAVORITOS',
                style: HomeStyles.titleStyle.copyWith(
                  color: isDark ? Colors.white : const Color(0xFFCC0000),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCC0000),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text(_errorMessage!,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadFavorites,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : _favorites.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 72,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.black26,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tenés favoritos todavía',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tocá el corazón en cualquier Pokémon',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: HomeStyles.spacingMedium,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: HomeStyles.spacingMedium,
                                mainAxisSpacing: HomeStyles.spacingMedium,
                              ),
                              itemCount: _favorites.length,
                              itemBuilder: (context, index) {
                                final pokemon = _favorites[index];
                                return PokemonCard(
                                  pokemon: pokemon,
                                  userId: _userId,
                                  onFavoriteChanged: (isFavorite) {
                                    if (!isFavorite) {
                                      _onFavoriteRemoved(pokemon.id);
                                    }
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
