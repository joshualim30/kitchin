// recipe.dart

// Imports
import 'package:flutter/material.dart';

// Recipe Class (StatelessWidget)
class Recipe extends StatelessWidget {
  const Recipe({Key? key}) : super(key: key);

  // Build the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          // Add Recipe Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add Recipe
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Coming Soon...'),
      ),
    );
  }
}