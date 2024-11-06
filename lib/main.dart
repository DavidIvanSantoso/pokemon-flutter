import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Pokedex';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              TitleSection(
                upperTitle: 'Pokedex 1.0',
                description: 'Pokemon list:',
              ),
              PokemonList()
            ],
          ),
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.upperTitle,
    required this.description,
  });

  final String upperTitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    upperTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(description), // Display description
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({Key? key}) : super(key: key);
  @override
  State<PokemonList> createState() => _PokemonList();
}

class _PokemonList extends State<PokemonList> {
  String dropdownValue = 'Option 1';
  List<String> pokemonRegionNames = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPokemonRegionData();
  }

  // Fetch pokemon region data
  Future<void> fetchPokemonRegionData() async {
    print("Fetching data...");
    try {
      final response =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/pokedex/'));
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        // Parse the response JSON
        final Map<String, dynamic> data = json.decode(response.body);
        print("Parsed JSON: $data");

        if (data['results'] != null && data['results'].isNotEmpty) {
          // Extract the pokemon region names from the response
          List<String> names = [];
          for (var entry in data['results']) {
            names.add(entry['name']);
          }

          // Only update the state if there is data
          setState(() {
            print('setState is being called');
            pokemonRegionNames = names;
            dropdownValue = pokemonRegionNames.isNotEmpty
                ? pokemonRegionNames[0]
                : 'Option 1'; // Default value
            errorMessage = null; // Clear any previous errors
          });
        } else {
          throw Exception('No results found in the response');
        }
      } else {
        throw Exception('Failed to load Pokemon data');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load data: $error';
        pokemonRegionNames = []; // Clear the pokemon names list
      });
    }
  }

  Future<void> fetchPokemonData() async {}
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: errorMessage != null
                ? Column(
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                            color: Colors.red), // Red color for errors
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : pokemonRegionNames.isEmpty
                    ? const CircularProgressIndicator() // Show loading indicator
                    : DropdownButton<String>(
                        value: dropdownValue,
                        items: pokemonRegionNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
