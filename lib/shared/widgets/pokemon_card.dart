import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/database/database_helper.dart';
import '../../models/pokemon.dart';
import '../../features/home/home_styles.dart';

class PokemonCard extends StatefulWidget {
  final PokemonListItem pokemon;
  final int userId;
  final void Function(bool isFavorite)? onFavoriteChanged;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.userId,
    this.onFavoriteChanged,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await DatabaseHelper().isFavorite(
      userId: widget.userId,
      pokemonId: widget.pokemon.id,
    );
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await DatabaseHelper().removeFavorite(
        userId: widget.userId,
        pokemonId: widget.pokemon.id,
      );
    } else {
      await DatabaseHelper().addFavorite(
        userId: widget.userId,
        pokemonId: widget.pokemon.id,
        pokemonName: widget.pokemon.name,
        pokemonImage: widget.pokemon.imageUrl,
      );
    }
    final newValue = !_isFavorite;
    setState(() => _isFavorite = newValue);
    widget.onFavoriteChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final primaryType =
        widget.pokemon.types.isNotEmpty ? widget.pokemon.types[0] : 'normal';
    final cardColor = HomeStyles.getTypeColor(primaryType);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: widget.pokemon.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Número decorativo
            Positioned(
              right: 8,
              top: 8,
              child: Text(
                widget.pokemon.formattedNumber,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pokemon.capitalizedName,
                    style: HomeStyles.pokemonNameStyle,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: widget.pokemon.types.map((type) {
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
                  Expanded(
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.pokemon.imageUrl,
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

            // Botón de favorito — último en el Stack para quedar encima de la imagen
            Positioned(
              right: 4,
              bottom: 4,
              child: IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red[200] : Colors.white70,
                  size: 20,
                ),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
