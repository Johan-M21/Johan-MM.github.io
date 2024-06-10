import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/pokemon.dart';
import 'package:pokedex/provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'],
      types: json['types'] != null ? json['types'].cast<String>() : [],
      hp: json['stats']['HP'] ?? 0,
      attack: json['stats']['attack'] ?? 0,
      defense: json['stats']['defense'] ?? 0,
      specialAttack: json['stats']['special_attack'] ?? 0,
      specialDefense: json['stats']['special_defense'] ?? 0,
      speed: json['stats']['speed'] ?? 0,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Pokédex',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pokemon',
              ),
            ),
          ),
        ),
        body: const MyGridView(),
        backgroundColor: const Color.fromARGB(255, 36, 33, 33),
      ),
    );
  }
}

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  PokemonDetailScreen(this.initialIndex);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final pokemonList = ref.watch(pokemonListProvider);
    if (pokemonList.isEmpty) {
      return SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Fiche Pokémon'),
      ),
      body: Container(
        color: Color.fromARGB(255, 34, 37, 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: pokemonList.length,
                controller: _controller,
                itemBuilder: (context, index) {
                  final pokemon = pokemonList[index];
                  return PokemonPage(
                    pokemon: pokemon,
                    pokemonList: pokemonList,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalancedTeamScreen extends ConsumerWidget {
  final int id;

  BalancedTeamScreen(this.id);

  @override
  Widget build(BuildContext context, ref) {
    final pokeTeamState = ref.watch(pokemonTeamProvider(id));
    ref.listen(pokemonTeamProvider(id), (_, next) {
      if (next.hasError) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(SnackBar(content: Text(next.error!.toString())));
      }
    });
    if (pokeTeamState.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    final team = pokeTeamState.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Équipe Équilibrée'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: team.length,
        itemBuilder: (context, index) {
          final pokemon = team[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon.id - 1),
                ),
              );
            },
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 160, 118, 103),
                ),
                padding: EdgeInsets.all(20),
                child: Hero(
                  tag: pokemon.name,
                  child: Image.network(
                    pokemon.imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyGridView extends ConsumerWidget {
  const MyGridView({Key? key});

  Future<void> _refreshPokemonList(BuildContext context, WidgetRef ref) async {
    await ref.refresh(pokemonListProvider);
  }

  void _showPokemonDetail(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonListState = ref.watch(pokemonListProvider);
    final pokemonNotifier = ref.watch(pokemonListProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => _refreshPokemonList(context, ref),
      child: pokemonListState.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: pokemonListState.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokemonListState[index];
                      return GestureDetector(
                        onTap: () {
                          _showPokemonDetail(context, index);
                        },
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: pokemon.name,
                                  child: Image.network(
                                    pokemon.imageUrl,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  pokemon.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await pokemonNotifier.loadMorePokemon();
                  },
                  child: Text('Charger plus de Pokémon'),
                ),
              ],
            ),
    );
  }
}
