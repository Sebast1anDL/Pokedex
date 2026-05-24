import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/api_service.dart';
import '../../models/pokemon.dart';
import 'home_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<PokemonListItem> _allPokemon = [];
  List<PokemonListItem> _filteredPokemon = [];

  String? _selectedType;
  String _username = '';

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isSearching = false;

  String? _errorMessage;
  int _currentOffset = 0;
  int _currentNavIndex = 0;

  static const int _pageSize = 20;

  final List<String> _types = [
    'normal',
    'fire',
    'water',
    'grass',
    'electric',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'steel',
    'fairy',
    'dark',
    'ghost',
    'dragon',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Detectar cuando el usuario llega al final de la lista
  void _onScroll() {
    if (_isSearching) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Entrenador';
    });
  }

  // Carga la primera página al abrir la app
  Future<void> _loadFirstPage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentOffset = 0;
        _hasMore = true;
        _allPokemon = [];
      });

      final pokemon = await ApiService().getPokemonPage(offset: 0);

      setState(() {
        _allPokemon = pokemon;
        _filteredPokemon = pokemon;
        _currentOffset = _pageSize;
        _hasMore = _currentOffset < ApiService().totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar. Verificá tu conexión.';
        _isLoading = false;
      });
    }
  }

  // Carga la siguiente página cuando el usuario scrollea
  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore || _selectedType != null) return;

    setState(() => _isLoadingMore = true);

    try {
      final pokemon = await ApiService().getPokemonPage(
        offset: _currentOffset,
      );

      setState(() {
        _allPokemon.addAll(pokemon);
        _filteredPokemon = _allPokemon;
        _currentOffset += _pageSize;
        _hasMore = _currentOffset < ApiService().totalCount;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  // Búsqueda por nombre
  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredPokemon = _allPokemon;
        _selectedType = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredPokemon = _allPokemon
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.formattedNumber.contains(query))
          .toList();
    });
  }

  // Filtro por tipo
  void _onTypeSelected(String? type) {
    setState(() {
      _selectedType = type;
      _isSearching = type != null;
    });

    if (type == null) {
      setState(() => _filteredPokemon = _allPokemon);
      return;
    }

    setState(() {
      _filteredPokemon =
          _allPokemon.where((p) => p.types.contains(type)).toList();
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'POKÉDEX',
                    style: HomeStyles.titleStyle.copyWith(
                      color: isDark ? Colors.white : const Color(0xFFCC0000),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Saludo
                  Text(
                    'Hola, $_username!',
                    style: HomeStyles.greetingStyle.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: HomeStyles.spacingMedium),

                  // Búsqueda
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: HomeStyles.searchDecoration(context),
                  ),

                  const SizedBox(height: HomeStyles.spacingMedium),

                  // Chips de tipo
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _types.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: HomeStyles.spacingSmall),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return FilterChip(
                            label: const Text('Todos'),
                            selected: _selectedType == null,
                            onSelected: (_) => _onTypeSelected(null),
                            selectedColor: const Color(0xFFCC0000),
                            labelStyle: TextStyle(
                              color: _selectedType == null
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white
                                      : Colors.black87,
                              fontSize: 12,
                            ),
                          );
                        }

                        final type = _types[index - 1];
                        final isSelected = _selectedType == type;
                        final typeColor = HomeStyles.getTypeColor(type);

                        return FilterChip(
                          label: Text(
                            type[0].toUpperCase() + type.substring(1),
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              _onTypeSelected(isSelected ? null : type),
                          selectedColor: typeColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isDark
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: HomeStyles.spacingMedium),

            // Lista de pokémon
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFCC0000),
                          ),
                          SizedBox(height: 16),
                          Text('Cargando Pokémon...'),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadFirstPage,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : _filteredPokemon.isEmpty
                          ? const Center(
                              child: Text('No se encontraron Pokémon'),
                            )
                          : GridView.builder(
                              controller: _scrollController,
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
                              // +1 para el indicador de carga al final
                              itemCount: _filteredPokemon.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Último item — indicador de carga
                                if (index == _filteredPokemon.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFCC0000),
                                      ),
                                    ),
                                  );
                                }
                                return _PokemonCard(
                                  pokemon: _filteredPokemon[index],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),

      // Navegación inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
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

// Card individual de pokémon
class _PokemonCard extends StatelessWidget {
  final PokemonListItem pokemon;

  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
    final cardColor = HomeStyles.getTypeColor(primaryType);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: pokemon.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Número decorativo en el fondo
            Positioned(
              right: 8,
              top: 8,
              child: Text(
                pokemon.formattedNumber,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    pokemon.capitalizedName,
                    style: HomeStyles.pokemonNameStyle,
                  ),

                  const SizedBox(height: 4),

                  // Chips de tipo
                  Wrap(
                    spacing: 4,
                    children: pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: HomeStyles.typeChipStyle,
                        ),
                      );
                    }).toList(),
                  ),

                  // Imagen del pokémon
                  Expanded(
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
