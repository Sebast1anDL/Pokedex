class PokedexEntry {
  final String flavorText;
  final String versionName;

  const PokedexEntry({required this.flavorText, required this.versionName});
}

class PokemonAbilityDetail {
  final String name;
  final String description;
  final bool isHidden;

  const PokemonAbilityDetail({
    required this.name,
    required this.description,
    required this.isHidden,
  });
}

class PokemonMoveEntry {
  final String name;
  final String learnMethod; // level-up, machine, egg, tutor
  final int? levelLearnedAt;
  final String? machineId; // TM/MT number

  const PokemonMoveEntry({
    required this.name,
    required this.learnMethod,
    this.levelLearnedAt,
    this.machineId,
  });
}

class EvolutionNode {
  final int id;
  final String name;
  final String imageUrl;
  final String condition; // empty for base form
  final List<EvolutionNode> evolvesTo;

  const EvolutionNode({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.condition,
    required this.evolvesTo,
  });
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final List<String> types;
  final int height; // decimetres
  final int weight; // hectograms
  final int baseExperience;
  final Map<String, int> baseStats;
  final List<PokemonAbilityDetail> abilities;
  final List<PokemonMoveEntry> moves;
  final List<PokedexEntry> pokedexEntries;
  final String category;
  final String color;
  final int captureRate;
  final int baseHappiness;
  final String growthRate;
  final List<String> eggGroups;
  final int genderRate; // -1=genderless, 0–8 (female chance = genderRate/8)
  final bool isLegendary;
  final bool isMythical;
  final String generation;
  final int hatchCounter;
  final EvolutionNode? evolutionChain;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.baseStats,
    required this.abilities,
    required this.moves,
    required this.pokedexEntries,
    required this.category,
    required this.color,
    required this.captureRate,
    required this.baseHappiness,
    required this.growthRate,
    required this.eggGroups,
    required this.genderRate,
    required this.isLegendary,
    required this.isMythical,
    required this.generation,
    required this.hatchCounter,
    required this.evolutionChain,
  });

  double get heightInMeters => height / 10;
  double get weightInKg => weight / 10;
  int get statTotal => baseStats.values.fold(0, (a, b) => a + b);

  String get formattedNumber => '#${id.toString().padLeft(4, '0')}';

  String get capitalizedName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  String get generationLabel {
    const labels = {
      'generation-i': 'Generación I',
      'generation-ii': 'Generación II',
      'generation-iii': 'Generación III',
      'generation-iv': 'Generación IV',
      'generation-v': 'Generación V',
      'generation-vi': 'Generación VI',
      'generation-vii': 'Generación VII',
      'generation-viii': 'Generación VIII',
      'generation-ix': 'Generación IX',
    };
    return labels[generation] ?? generation;
  }

  String get growthRateLabel {
    const labels = {
      'slow': 'Lento',
      'medium': 'Medio',
      'fast': 'Rápido',
      'medium-slow': 'Medio lento',
      'slow-then-very-fast': 'Fluctuante',
      'fast-then-very-slow': 'Errático',
    };
    return labels[growthRate] ?? growthRate;
  }

  String get genderDisplay {
    if (genderRate == -1) return 'Sin género';
    final femalePct = (genderRate / 8 * 100).toStringAsFixed(1);
    final malePct = ((8 - genderRate) / 8 * 100).toStringAsFixed(1);
    return '♂ $malePct%  ♀ $femalePct%';
  }

  String get eggSteps => '${(hatchCounter + 1) * 255}';
}
