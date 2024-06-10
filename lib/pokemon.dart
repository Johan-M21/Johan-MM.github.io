import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/main.dart';
import 'package:pokedex/provider.dart';

class PokemonPage extends ConsumerStatefulWidget {
  const PokemonPage({
    super.key,
    required this.pokemon,
    required this.pokemonList,
  });

  final Pokemon pokemon;
  final List<Pokemon> pokemonList;

  @override
  ConsumerState<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends ConsumerState<PokemonPage> {
  void _fetchBalancedTeam(Pokemon mainPokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BalancedTeamScreen(mainPokemon.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: widget.pokemon.name,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: Image.network(
                widget.pokemon.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.pokemon.name,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text('HP: ${widget.pokemon.hp}',
              style: TextStyle(color: Colors.white)),
          Text('Attack: ${widget.pokemon.attack}',
              style: TextStyle(color: Colors.white)),
          Text('Defense: ${widget.pokemon.defense}',
              style: TextStyle(color: Colors.white)),
          Text('Special Attack: ${widget.pokemon.specialAttack}',
              style: TextStyle(color: Colors.white)),
          Text('Special Defense: ${widget.pokemon.specialDefense}',
              style: TextStyle(color: Colors.white)),
          Text('Speed: ${widget.pokemon.speed}',
              style: TextStyle(color: Colors.white)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchBalancedTeam(widget.pokemon),
            child: Text('Composer votre équipe'),
          ),
        ],
      ),
    );
  }
}
