import 'package:flutter/material.dart';
import 'home_styles.dart';

// ─── Datos de filtros ─────────────────────────────────────────────────────────

const _typeOptions = [
  ('normal', 'Normal'), ('fire', 'Fuego'), ('water', 'Agua'),
  ('grass', 'Planta'), ('electric', 'Eléctrico'), ('ice', 'Hielo'),
  ('fighting', 'Lucha'), ('poison', 'Veneno'), ('ground', 'Tierra'),
  ('flying', 'Volador'), ('psychic', 'Psíquico'), ('bug', 'Bicho'),
  ('rock', 'Roca'), ('ghost', 'Fantasma'), ('dragon', 'Dragón'),
  ('steel', 'Acero'), ('fairy', 'Hada'), ('dark', 'Siniestro'),
];

const _genOptions = [
  ('1', 'Gen I · Kanto'), ('2', 'Gen II · Johto'), ('3', 'Gen III · Hoenn'),
  ('4', 'Gen IV · Sinnoh'), ('5', 'Gen V · Unova'), ('6', 'Gen VI · Kalos'),
  ('7', 'Gen VII · Alola'), ('8', 'Gen VIII · Galar'), ('9', 'Gen IX · Paldea'),
];

const _colorOptions = [
  ('black', 'Negro'), ('blue', 'Azul'), ('brown', 'Marrón'),
  ('gray', 'Gris'), ('green', 'Verde'), ('pink', 'Rosa'),
  ('purple', 'Morado'), ('red', 'Rojo'), ('white', 'Blanco'),
  ('yellow', 'Amarillo'),
];

const _shapeOptions = [
  ('ball', 'Bola'), ('squiggle', 'Serpenteante'), ('fish', 'Pez'),
  ('arms', 'Con brazos'), ('blob', 'Amorfo'), ('upright', 'Erguido'),
  ('legs', 'Con piernas'), ('quadruped', 'Cuadrúpedo'), ('wings', 'Con alas'),
  ('tentacles', 'Tentáculos'), ('heads', 'Múltiples cabezas'),
  ('humanoid', 'Humanoide'), ('bug-wings', 'Alas de insecto'),
  ('armor', 'Armadura'),
];

const _habitatOptions = [
  ('cave', 'Cueva'), ('forest', 'Bosque'), ('grassland', 'Pradera'),
  ('mountain', 'Montaña'), ('rare', 'Raro'),
  ('rough-terrain', 'Terreno escarpado'), ('sea', 'Mar'),
  ('urban', 'Urbano'), ('waters-edge', 'Orilla del agua'),
];

const _colorMap = <String, Color>{
  'black': Color(0xFF424242),
  'blue': Color(0xFF4286F4),
  'brown': Color(0xFF8D6040),
  'gray': Color(0xFF9E9E9E),
  'green': Color(0xFF4CAF50),
  'pink': Color(0xFFE91E8C),
  'purple': Color(0xFF9C27B0),
  'red': Color(0xFFCC0000),
  'white': Color(0xFFBDBDBD),
  'yellow': Color(0xFFFFC107),
};

// ─── Widget ───────────────────────────────────────────────────────────────────

class FilterSheet extends StatefulWidget {
  final String? currentCategory;
  final String? currentValue;
  final void Function(String category, String value, String label) onApply;
  final VoidCallback onClear;

  const FilterSheet({
    super.key,
    this.currentCategory,
    this.currentValue,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selCategory;
  String? _selValue;
  String? _selLabel;

  @override
  void initState() {
    super.initState();
    _selCategory = widget.currentCategory;
    _selValue = widget.currentValue;
    if (_selCategory != null && _selValue != null) {
      _selLabel = _labelFor(_selCategory!, _selValue!);
    }
  }

  String _labelFor(String category, String value) {
    for (final opt in _optionsFor(category)) {
      if (opt.$1 == value) return opt.$2;
    }
    return value;
  }

  List<(String, String)> _optionsFor(String category) => switch (category) {
        'type' => _typeOptions,
        'generation' => _genOptions,
        'color' => _colorOptions,
        'shape' => _shapeOptions,
        'habitat' => _habitatOptions,
        _ => [],
      };

  void _select(String category, String value, String label) {
    setState(() {
      if (_selCategory == category && _selValue == value) {
        _selCategory = _selValue = _selLabel = null;
      } else {
        _selCategory = category;
        _selValue = value;
        _selLabel = label;
      }
    });
  }

  Widget _section(
    BuildContext context,
    String title,
    String category,
    List<(String, String)> options, {
    Color? Function(String)? chipColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected =
                  _selCategory == category && _selValue == opt.$1;
              final color = chipColor?.call(opt.$1) ??
                  Theme.of(context).colorScheme.primary;
              return FilterChip(
                label: Text(opt.$2),
                selected: isSelected,
                onSelected: (_) => _select(category, opt.$1, opt.$2),
                selectedColor: color,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSelection = _selCategory != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onClear,
                    child: Text(
                      'Limpiar todo',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Contenido scrollable
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _section(
                    context, 'TIPO', 'type', _typeOptions,
                    chipColor: HomeStyles.getTypeColor,
                  ),
                  _section(context, 'GENERACIÓN', 'generation', _genOptions),
                  _section(
                    context, 'COLOR', 'color', _colorOptions,
                    chipColor: (v) => _colorMap[v],
                  ),
                  _section(context, 'FORMA', 'shape', _shapeOptions),
                  _section(context, 'HÁBITAT', 'habitat', _habitatOptions),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Botón aplicar
            Container(
              padding: EdgeInsets.fromLTRB(
                20, 12, 20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: hasSelection
                      ? () => widget.onApply(
                            _selCategory!,
                            _selValue!,
                            _selLabel!,
                          )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aplicar filtro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
