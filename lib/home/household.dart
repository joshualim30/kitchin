// household.dart

// MARK: Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// MARK: Household Class
class Household extends StatefulWidget {
  const Household({
    super.key,
    required this.newHousehold,
  });

  // Variables
  final bool newHousehold;

  @override
  State<Household> createState() => _HouseholdState();
}

class _HouseholdState extends State<Household> {
  // MARK: Text Field Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController membersController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // Build the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create or Join Household'),
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Create'),
                  Tab(text: 'Join'),
                ],
              ),
              // Create or Join Household Forms
              SizedBox(
                height: MediaQuery.of(context).size.height - 160,
                child: TabBarView(
                  children: [
                    // Create Household Form
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Name
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Household Name',
                            ),
                          ),

                          // Members
                          TextField(
                            controller: membersController,
                            decoration: const InputDecoration(
                              labelText: 'Members',
                            ),
                          ),

                          // Spacer
                          const Spacer(),

                          // Create Button
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            onPressed: () async {
                              // Create Household
                              _createHousehold(nameController.text,
                                  membersController.text.split(','));
                              // Pop the screen
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Create Household',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Join Household Form
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Code
                          TextField(
                            controller: codeController,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                            ),
                          ),

                          // Spacer
                          const Spacer(),

                          // Join Button
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            onPressed: () {
                              // Join Household
                              _joinHousehold(codeController.text);
                              // Pop the screen
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Join Household',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // MARK: Create Household
  Future<String> _createHousehold(String name, List<String> members) async {
    // Get the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Generate a household code
    var code = '';
    var rng = Random();
    for (var i = 0; i < 10; i++) {
      code += rng.nextInt(10).toString();
    }

    // Check if the code already exists
    final households = await firestore
        .collection('households')
        .where('code', isEqualTo: code)
        .get();
    if (households.docs.isNotEmpty) {
      return _createHousehold(name, members);
    }

    // Create members list
    members = [
      FirebaseAuth.instance.currentUser!.email!,
      ...members,
    ];

    // Remove duplicates and empty strings
    members = members.toSet().toList();
    members.removeWhere((element) => element.isEmpty);

    // Create the household
    final household = await firestore.collection('households').add({
      'name': name,
      'members': members,
      'code': code,
      'fridge': [],
      'freezer': [],
      'pantry': [],
      'shoppingList': [],
    });

    // Return the household ID
    return household.id;
  }

  // MARK: Join Household
  Future<void> _joinHousehold(String code) async {
    // Get the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the household
    final household = await firestore
        .collection('households')
        .where('code', isEqualTo: code)
        .get();

    // Add the user to the household
    await household.docs.first.reference.update({
      'members':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email]),
    });
  }
}
