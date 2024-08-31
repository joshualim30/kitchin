// home.dart
// Main screen of the app, 3 tabs

// MARK: Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitchin/chat/chat.dart';
import 'package:kitchin/home/home.dart';
import 'package:kitchin/onboard.dart';
import 'package:kitchin/profile/profile.dart';
import 'package:kitchin/recipe/recipe.dart';
import 'package:kitchin/scan/scan.dart';

// MARK: Home Class
class Navigation extends StatefulWidget {
  const Navigation({
    super.key,
  });

  @override
  _NavigationState createState() => _NavigationState();
}

// _HomeState Class
class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  // MARK: Widget Options
  final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Scan(),
    const Recipe(),
    const Profile()
  ];

  // MARK: On Item Tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: <Widget>[
      
          // Show the current screen
          _widgetOptions.elementAt(_selectedIndex),
      
          // MARK: Bottom Navigation
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // MARK: Chat Button
                Row(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: IconButton(
                        padding: const EdgeInsets.all(15),
                        icon: const Icon(
                          Icons.chat,
                          size: 20,
                        ),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Chat(),
                            ),
                          ),
                        },
                        color: Colors.white,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // MARK: Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.home),
                          onPressed: () => _onItemTapped(0),
                          color: _selectedIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.barcode_reader),
                          onPressed: () => _onItemTapped(1),
                          color: _selectedIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.book),
                          onPressed: () => _onItemTapped(2),
                          color: _selectedIndex == 2
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.person),
                          onPressed: () => _onItemTapped(3),
                          color: _selectedIndex == 3
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}