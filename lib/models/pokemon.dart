class PokemonListItem {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  PokemonListItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  String get formattedNumber => '#${id.toString().padLeft(3, '0')}';

  String get capitalizedName => name[0].toUpperCase() + name.substring(1);
}
