import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../models/pokemon.dart';
import '../../shared/widgets/pokemon_card.dart';
import 'filter_sheet.dart';
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

  // Paginación de filtros activos
  List<String> _filterUrls = [];
  int _filterOffset = 0;

  // Filtro activo
  String? _filterCategory;
  String? _filterValue;
  String? _filterLabel;

  // Búsqueda con sugerencias
  List<Map<String, String>> _suggestions = [];
  bool _showSuggestions = false;
  bool _hasTextSearch = false;
  bool _isIndexReady = false;

  String _username = '';
  int _userId = 0;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  int _currentOffset = 0;
  int _currentNavIndex = 0;

  // 0 = 3 cols (pequeño), 1 = 2 cols (mediano), 2 = 1 col (grande)
  int _gridSize = 1;

  static const int _pageSize = 20;

  int get _columns => const [3, 2, 1][_gridSize];
  double get _aspectRatio => const [0.72, 0.85, 0.9][_gridSize];
  IconData get _gridSizeIcon =>
      const [Icons.grid_view, Icons.view_module, Icons.view_agenda][_gridSize];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadFirstPage();
    _loadIndex();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIndex() async {
    await ApiService().loadIndex();
    if (mounted) setState(() => _isIndexReady = true);
  }

  void _onScroll() {
    final px = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    if (px < max - 200) return;
    if (_hasTextSearch) return;
    if (_filterCategory != null) {
      _loadNextFilterPage();
    } else {
      _loadNextPage();
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Entrenador';
      _userId = prefs.getInt('user_id') ?? 0;
    });
  }

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

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final pokemon =
          await ApiService().getPokemonPage(offset: _currentOffset);
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

  Future<void> _loadNextFilterPage() async {
    if (_isLoadingMore || _filterOffset >= _filterUrls.length) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextUrls =
          _filterUrls.skip(_filterOffset).take(_pageSize).toList();
      final nextPage = await ApiService().getDetailsByUrls(nextUrls);
      if (mounted) {
        setState(() {
          _filteredPokemon.addAll(nextPage);
          _filterOffset += _pageSize;
          _hasMore = _filterOffset < _filterUrls.length;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ─── Búsqueda ─────────────────────────────────────────────────────────────

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _hasTextSearch = false;
        _filterCategory = _filterValue = _filterLabel = null;
        _suggestions = [];
        _showSuggestions = false;
        _filteredPokemon = _allPokemon;
        _hasMore = _currentOffset < ApiService().totalCount;
      });
      return;
    }

    setState(() {
      _hasTextSearch = true;
      _filterCategory = _filterValue = _filterLabel = null;
    });

    if (!_isIndexReady) {
      setState(() {
        _filteredPokemon = _allPokemon
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.formattedNumber.contains(query))
            .toList();
      });
      return;
    }

    final matches = ApiService().searchIndex(query, limit: 6);
    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  Future<void> _selectSuggestion(Map<String, String> suggestion) async {
    final name = suggestion['name']!;
    _searchController.text = name[0].toUpperCase() + name.substring(1);
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
      _isLoading = true;
    });
    final results =
        await ApiService().getDetailsByUrls([suggestion['url']!]);
    if (mounted) {
      setState(() {
        _filteredPokemon = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
      _isLoading = true;
    });
    final matches = _isIndexReady
        ? ApiService().searchIndex(query, limit: 20)
        : <Map<String, String>>[];
    if (matches.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredPokemon = [];
          _isLoading = false;
        });
      }
      return;
    }
    final urls = matches.map((m) => m['url']!).toList();
    final results = await ApiService().getDetailsByUrls(urls);
    if (mounted) {
      setState(() {
        _filteredPokemon = results;
        _isLoading = false;
      });
    }
  }

  // ─── Filtros ──────────────────────────────────────────────────────────────

  Future<List<String>> _getFilterUrls(
      String category, String value) => switch (category) {
        'type' => ApiService().getTypePokemonUrls(value),
        'generation' => ApiService().getGenerationPokemonUrls(value),
        'color' => ApiService().getColorPokemonUrls(value),
        'shape' => ApiService().getShapePokemonUrls(value),
        'habitat' => ApiService().getHabitatPokemonUrls(value),
        _ => Future.value(<String>[]),
      };

  Future<void> _applyFilter(
      String category, String value, String label) async {
    _searchController.clear();
    setState(() {
      _filterCategory = category;
      _filterValue = value;
      _filterLabel = label;
      _hasTextSearch = false;
      _suggestions = [];
      _showSuggestions = false;
      _isLoading = true;
      _filterUrls = [];
      _filterOffset = 0;
      _filteredPokemon = [];
    });

    try {
      final urls = await _getFilterUrls(category, value);
      final firstPage =
          await ApiService().getDetailsByUrls(urls.take(_pageSize).toList());
      if (mounted) {
        setState(() {
          _filterUrls = urls;
          _filterOffset = _pageSize;
          _filteredPokemon = firstPage;
          _hasMore = _filterOffset < urls.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el filtro. Verificá tu conexión.';
        });
      }
    }
  }

  void _clearFilter() {
    setState(() {
      _filterCategory = _filterValue = _filterLabel = null;
      _filterUrls = [];
      _filterOffset = 0;
      _filteredPokemon = _allPokemon;
      _hasMore = _currentOffset < ApiService().totalCount;
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(
        currentCategory: _filterCategory,
        currentValue: _filterValue,
        onApply: (category, value, label) {
          Navigator.pop(context);
          _applyFilter(category, value, label);
        },
        onClear: () {
          Navigator.pop(context);
          _clearFilter();
        },
      ),
    );
  }

  void _cycleGridSize() => setState(() => _gridSize = (_gridSize + 1) % 3);

  // ─── Build ────────────────────────────────────────────────────────────────

  Widget _buildSuggestions(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final s = _suggestions[index];
          final name = s['name']!;
          final capitalized = name[0].toUpperCase() + name.substring(1);
          return ListTile(
            dense: true,
            leading: const Icon(Icons.catching_pokemon, size: 18),
            title: Text(capitalized, style: const TextStyle(fontSize: 14)),
            onTap: () => _selectSuggestion(s),
          );
        },
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'POKÉDEX',
                    style: HomeStyles.titleStyle.copyWith(
                      color:
                          isDark ? Colors.white : const Color(0xFFCC0000),
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

                  // Barra de búsqueda + botones
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearch,
                          onSubmitted: _onSearchSubmitted,
                          decoration: HomeStyles.searchDecoration(context),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Botón filtros (con badge cuando hay filtro activo)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.tune_rounded),
                            onPressed: () => _showFilterSheet(context),
                            tooltip: 'Filtros',
                          ),
                          if (_filterCategory != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCC0000),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Botón tamaño de cards (cicla entre 3 tamaños)
                      IconButton(
                        icon: Icon(_gridSizeIcon),
                        onPressed: _cycleGridSize,
                        tooltip: 'Tamaño de tarjetas',
                      ),
                    ],
                  ),

                  // Sugerencias O chip de filtro activo
                  if (_showSuggestions)
                    _buildSuggestions(isDark)
                  else if (_filterCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Chip(
                        label: Text(_filterLabel!),
                        onDeleted: _clearFilter,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: const Color(0xFFCC0000)
                            .withValues(alpha: 0.12),
                        side:
                            const BorderSide(color: Color(0xFFCC0000)),
                        labelStyle: const TextStyle(
                            color: Color(0xFFCC0000)),
                        deleteIconColor: const Color(0xFFCC0000),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: HomeStyles.spacingMedium),

            // Grid de pokémon
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: Color(0xFFCC0000)),
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
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text(_errorMessage!,
                                  textAlign: TextAlign.center),
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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _columns,
                                childAspectRatio: _aspectRatio,
                                crossAxisSpacing:
                                    HomeStyles.spacingMedium,
                                mainAxisSpacing: HomeStyles.spacingMedium,
                              ),
                              itemCount: _filteredPokemon.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredPokemon.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                          color: Color(0xFFCC0000)),
                                    ),
                                  );
                                }
                                return PokemonCard(
                                  pokemon: _filteredPokemon[index],
                                  userId: _userId,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),

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
