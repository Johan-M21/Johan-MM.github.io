import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/main.dart';
import 'package:http/http.dart' as http;

typedef PokemonList = List<Pokemon>;

class PokemonListNotifier extends StateNotifier<PokemonList> {
  PokemonListNotifier() : super([]);

  int _limit = 100;

  Future<void> fetchPokemonList() async {
    final response = await http
        .get(Uri.parse('https://pokebuildapi.fr/api/v1/pokemon/limit/$_limit'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      state = data.map((pokemonData) => Pokemon.fromJson(pokemonData)).toList();
    } else {
      throw Exception(
          'Failed to load Pokemon list, code is ${response.statusCode}');
    }
  }

  Future<void> loadMorePokemon() async {
    _limit += 100;
    await fetchPokemonList();
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonList>((ref) {
  final notifier = PokemonListNotifier();
  notifier.fetchPokemonList();
  return notifier;
});

final pokemonTeamProvider =
    FutureProvider.family.autoDispose<PokemonList, int>((ref, id) async {
  final response = await http.post(
    Uri.parse('https://pokebuildapi.fr/api/v1/team/suggestion/v2'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<Map<String, dynamic>>[
      {
        id.toString(): "",
      }
    ]),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((pokemonData) => Pokemon.fromJson(pokemonData)).toList();
  } else {
    throw Exception(
        'Failed to load Pokemon list, code is ${response.statusCode}');
  }
});
