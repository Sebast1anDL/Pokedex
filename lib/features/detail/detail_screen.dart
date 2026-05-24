import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/type_chart.dart';
import '../../core/services/api_service.dart';
import '../../features/home/home_styles.dart';
import '../../models/pokemon_detail.dart';

class DetailScreen extends StatefulWidget {
  final int pokemonId;
  const DetailScreen({super.key, required this.pokemonId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  PokemonDetail? _detail;
  bool _loading = true;
  String? _error;
  bool _showShiny = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final detail =
          await ApiService().getPokemonFullDetail(widget.pokemonId);
      if (mounted) setState(() { _detail = detail; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Error desconocido')),
      );
    }
    final d = _detail!;
    final primaryType =
        d.types.isNotEmpty ? d.types[0] : 'normal';
    final headerColor = HomeStyles.getTypeColor(primaryType);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: headerColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _Header(
                detail: d,
                showShiny: _showShiny,
                headerColor: headerColor,
                onShinyToggle: () =>
                    setState(() => _showShiny = !_showShiny),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Datos'),
                Tab(text: 'Estrategias'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _DatosTab(detail: d),
            _EstrategiasTab(detail: d),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PokemonDetail detail;
  final bool showShiny;
  final Color headerColor;
  final VoidCallback onShinyToggle;

  const _Header({
    required this.detail,
    required this.showShiny,
    required this.headerColor,
    required this.onShinyToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl =
        showShiny ? detail.shinyImageUrl : detail.imageUrl;
    return Container(
      color: headerColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: 16,
        right: 16,
        bottom: 48, // room for TabBar
      ),
      child: Row(
        children: [
          // Image
          Expanded(
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              height: 160,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white54),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 80,
                color: Colors.white54,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.formattedNumber,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail.capitalizedName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: detail.types.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeLabels[t] ?? t,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onShinyToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: showShiny
                          ? Colors.amber.withValues(alpha: 0.8)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          showShiny ? 'Shiny' : 'Normal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Datos ────────────────────────────────────────────────────────────────

class _DatosTab extends StatelessWidget {
  final PokemonDetail detail;
  const _DatosTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PokedexEntries(entries: detail.pokedexEntries),
        const SizedBox(height: 20),
        const _SectionTitle('Datos generales'),
        _DataTable(rows: [
          ('Categoría', detail.category.isEmpty ? '—' : '${detail.category} Pokémon'),
          ('Altura', '${detail.heightInMeters.toStringAsFixed(1)} m'),
          ('Peso', '${detail.weightInKg.toStringAsFixed(1)} kg'),
          ('Color', _capitalize(detail.color)),
          ('Generación', detail.generationLabel),
          if (detail.isLegendary) ('Categoría especial', 'Legendario'),
          if (detail.isMythical) ('Categoría especial', 'Mítico'),
        ]),
        const SizedBox(height: 20),
        const _SectionTitle('Entrenamiento'),
        _DataTable(rows: [
          ('EXP base', '${detail.baseExperience}'),
          ('Tasa de captura', '${detail.captureRate}'),
          ('Felicidad base', '${detail.baseHappiness}'),
          ('Ritmo de crecimiento', detail.growthRateLabel),
        ]),
        const SizedBox(height: 20),
        const _SectionTitle('Cría'),
        _DataTable(rows: [
          ('Género', detail.genderDisplay),
          ('Grupos huevo', detail.eggGroups.isEmpty ? '—' : detail.eggGroups.join(', ')),
          ('Pasos para eclosionar', detail.eggSteps),
        ]),
        const SizedBox(height: 20),
        const _SectionTitle('Efectividad defensiva'),
        _TypeEffectivenessGrid(types: detail.types),
        const SizedBox(height: 20),
        const _SectionTitle('Cadena evolutiva'),
        _EvolutionChain(root: detail.evolutionChain),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Tab Estrategias ─────────────────────────────────────────────────────────

class _EstrategiasTab extends StatelessWidget {
  final PokemonDetail detail;
  const _EstrategiasTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final levelMoves = detail.moves
        .where((m) => m.learnMethod == 'level-up')
        .toList()
      ..sort((a, b) =>
          (a.levelLearnedAt ?? 0).compareTo(b.levelLearnedAt ?? 0));
    final machineMoves =
        detail.moves.where((m) => m.learnMethod == 'machine').toList();
    final eggMoves =
        detail.moves.where((m) => m.learnMethod == 'egg').toList();
    final tutorMoves =
        detail.moves.where((m) => m.learnMethod == 'tutor').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Estadísticas base'),
        _StatsSection(stats: detail.baseStats, total: detail.statTotal),
        const SizedBox(height: 20),
        const _SectionTitle('Efectividad defensiva'),
        _TypeEffectivenessGrid(types: detail.types),
        const SizedBox(height: 20),
        const _SectionTitle('Habilidades'),
        _AbilitiesSection(abilities: detail.abilities),
        if (levelMoves.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('Movimientos por nivel'),
          _LevelMovesTable(moves: levelMoves),
        ],
        if (machineMoves.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('Movimientos por MT/MO'),
          _MoveChips(moves: machineMoves),
        ],
        if (eggMoves.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('Movimientos huevo'),
          _MoveChips(moves: eggMoves),
        ],
        if (tutorMoves.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle('Movimientos tutor'),
          _MoveChips(moves: tutorMoves),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Shared section components ────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  final List<(String, String)> rows;
  const _DataTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.mapIndexed((i, row) {
          return Container(
            decoration: BoxDecoration(
              border: i < rows.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    )
                  : null,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    row.$1,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    row.$2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PokedexEntries extends StatefulWidget {
  final List<PokedexEntry> entries;
  const _PokedexEntries({required this.entries});

  @override
  State<_PokedexEntries> createState() => _PokedexEntriesState();
}

class _PokedexEntriesState extends State<_PokedexEntries> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();
    final entry = widget.entries[_index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.versionName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const Spacer(),
              if (_index > 0)
                IconButton(
                  onPressed: () => setState(() => _index--),
                  icon: const Icon(Icons.chevron_left),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${_index + 1}/${widget.entries.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (_index < widget.entries.length - 1)
                IconButton(
                  onPressed: () => setState(() => _index++),
                  icon: const Icon(Icons.chevron_right),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.flavorText,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Type effectiveness grid ──────────────────────────────────────────────────

class _TypeEffectivenessGrid extends StatelessWidget {
  final List<String> types;
  const _TypeEffectivenessGrid({required this.types});

  @override
  Widget build(BuildContext context) {
    final chart = getDefensiveChart(types);
    final orderedMults = [4.0, 2.0, 0.5, 0.25, 0.0]
        .where((m) => chart.containsKey(m))
        .toList();

    if (orderedMults.isEmpty) {
      return const Text('Sin debilidades ni resistencias especiales.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderedMults.map((mult) {
        final types = chart[mult]!;
        final label = mult == 0.0
            ? 'Inmune (×0)'
            : mult < 1.0
                ? 'Resiste (×${_fmtMult(mult)})'
                : 'Débil a (×${_fmtMult(mult)})';
        final color = mult == 0.0
            ? Colors.grey
            : mult >= 2.0
                ? Colors.red.shade700
                : Colors.green.shade700;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: types.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: HomeStyles.getTypeColor(t),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      typeLabels[t] ?? t,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _fmtMult(double m) =>
      m == m.truncateToDouble() ? m.toInt().toString() : m.toString();
}

// ─── Evolution chain ──────────────────────────────────────────────────────────

class _EvolutionChain extends StatelessWidget {
  final EvolutionNode? root;
  const _EvolutionChain({required this.root});

  @override
  Widget build(BuildContext context) {
    if (root == null) return const Text('No disponible');
    return _buildChain(context, root!);
  }

  Widget _buildChain(BuildContext context, EvolutionNode node) {
    final children = node.evolvesTo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvoNode(node: node),
        if (children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: children.map((child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EvoArrow(condition: child.condition),
                    _buildChain(context, child),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _EvoNode extends StatelessWidget {
  final EvolutionNode node;
  const _EvoNode({required this.node});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          '/detail',
          arguments: node.id,
        );
      },
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: node.imageUrl,
            width: 64,
            height: 64,
            placeholder: (_, __) => const SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => const Icon(
              Icons.catching_pokemon,
              size: 48,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            node.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvoArrow extends StatelessWidget {
  final String condition;
  const _EvoArrow({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_downward, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          if (condition.isNotEmpty)
            Text(
              condition,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  final Map<String, int> stats;
  final int total;
  const _StatsSection({required this.stats, required this.total});

  static const _statColors = <String, Color>{
    'hp': Color(0xFFFF5959),
    'attack': Color(0xFFF5AC78),
    'defense': Color(0xFFFAE078),
    'special-attack': Color(0xFF9DB7F5),
    'special-defense': Color(0xFFA7DB8D),
    'speed': Color(0xFFFA92B2),
  };

  static const _statLabels = <String, String>{
    'hp': 'PS',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'At. Esp.',
    'special-defense': 'Def. Esp.',
    'speed': 'Velocidad',
  };

  @override
  Widget build(BuildContext context) {
    final entries = stats.entries.toList();
    return Column(
      children: [
        ...entries.map((e) {
          final label = _statLabels[e.key] ?? e.key;
          final color = _statColors[e.key] ?? Colors.blue;
          return _StatBar(label: label, value: e.value, color: color);
        }),
        const Divider(height: 16),
        Row(
          children: [
            const Expanded(
              flex: 3,
              child: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                '$total',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBar extends StatefulWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBar(
      {required this.label, required this.value, required this.color});

  @override
  State<_StatBar> createState() => _StatBarState();
}

class _StatBarState extends State<_StatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${widget.value}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.value / 255) * _anim.value,
                  minHeight: 8,
                  backgroundColor: widget.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(widget.color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Abilities ────────────────────────────────────────────────────────────────

class _AbilitiesSection extends StatelessWidget {
  final List<PokemonAbilityDetail> abilities;
  const _AbilitiesSection({required this.abilities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: abilities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: a.isHidden
                ? Border.all(color: Colors.purple.withValues(alpha: 0.4))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    a.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (a.isHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Oculta',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (a.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  a.description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Moves ────────────────────────────────────────────────────────────────────

class _LevelMovesTable extends StatelessWidget {
  final List<PokemonMoveEntry> moves;
  const _LevelMovesTable({required this.moves});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Nv.',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Movimiento',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...moves.mapIndexed((i, m) {
            return Container(
              decoration: BoxDecoration(
                border: i < moves.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      )
                    : null,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      m.levelLearnedAt == 0
                          ? '—'
                          : '${m.levelLearnedAt}',
                      style: const TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(m.name, style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MoveChips extends StatelessWidget {
  final List<PokemonMoveEntry> moves;
  const _MoveChips({required this.moves});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moves
          .map((m) => Chip(
                label: Text(m.name, style: const TextStyle(fontSize: 12)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ))
          .toList(),
    );
  }
}

// ─── Utilities ────────────────────────────────────────────────────────────────

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

extension _MapIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int i, T e) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
