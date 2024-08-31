// home.dart
// Home Screen showing the user's households and their items

// MARK: Imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitchin/home/household.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/services.dart';

// MARK: Home Class
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String title = '';
  late Future<String> currentHousehold;
  late Future<QuerySnapshot> households;

  // MARK: Init State
  @override
  void initState() {
    super.initState();
    households = _getHouseholds();
  }

  // MARK: Pull to refresh
  Future<void> _refresh() async {
    setState(() {
      households = _getHouseholds();
    });
  }

  // Build the app
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: title.isNotEmpty
              ? Text(title)
              : FutureBuilder<String>(
                  future: currentHousehold,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(snapshot.data!);
                    }
                    return const Text('Loading...');
                  },
                ),
          actions: [
            // Add Household Button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to the Create Household screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const Household(newHousehold: true)),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: households,
          builder: (context, snapshot) {
            // If snapshot is done loading
            if (snapshot.connectionState == ConnectionState.done) {
              // If snapshot has data
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) { // MARK: Households
                // Get the households
                final snapshotHouseholds = snapshot.data!.docs;

                // Return the households
                return Swiper(
                  loop: false,
                  onIndexChanged: (int index) {
                    setState(() {
                      title = (snapshotHouseholds[index].data()!
                          as Map<String, dynamic>)['name'];
                    });
                  },
                  itemCount: snapshotHouseholds.length,
                  itemBuilder: (context, index) {
                    // Get the household data
                    final householdID = snapshotHouseholds[index].id;
                    final household = snapshotHouseholds[index].data()
                        as Map<String, dynamic>;

                    // Return Household
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: Swiper(
                        loop: false,
                        scrollDirection: Axis.vertical,
                        itemCount:
                            5, // 5 sections: Shopping List, Fridge, Freezer, Pantry, Settings
                        itemBuilder: (context, index) {
                          // Switch on index
                          switch (index) {
                            case 0:
                              return HomeList(
                                  title: 'Shopping List', household: household);
                            case 1:
                              return HomeList(
                                  title: 'Fridge', household: household);
                            case 2:
                              return HomeList(
                                  title: 'Freezer', household: household);
                            case 3:
                              return HomeList(
                                  title: 'Pantry', household: household);
                            case 4:
                              return Settings(
                                  id: householdID,
                                  household: household
                                );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    );
                  },
                );
              } else { // MARK: No Households
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prompt to create or join a household
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 * 2,
                        child: const Text(
                          'Create or Join a Household to Get Started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Spacing
                      const SizedBox(height: 20),

                      // Get Started Button
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Navigate to the Create Household screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const Household(newHousehold: true)),
                          );
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            // Otherwise, return a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  // MARK: Get Households
  Future<QuerySnapshot> _getHouseholds() async {
    // Get the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the households collection
    final households = firestore.collection('households').where('members',
        arrayContains: FirebaseAuth.instance.currentUser!.email);

    // Set the current household
    currentHousehold = households.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return (snapshot.docs[0].data())['name'];
      }
      return 'KitchIN';
    });

    // Get all households
    return households.get();
  }
}

// MARK: HomeList
class HomeList extends StatelessWidget {
  const HomeList({
    super.key,
    required this.title,
    required this.household,
  });

  final String title; // Shopping List, Fridge, Freezer, Pantry
  final Map<String, dynamic> household;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Row(
          children: [
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
          ],
        ),

        // Scrollable List
        Padding(
          padding: const EdgeInsets.only(top: 15, right: 80, left: 20),
          child: Container(
            height: MediaQuery.of(context).size.height - 245,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: ListView.builder(
              itemCount: household[title.toLowerCase()] != null
                  ? (household[title.toLowerCase()] as List).length
                  : 1,
              itemBuilder: (context, index) {
                return household[title.toLowerCase()] == null
                    ? ListTile(
                        title: const Text('Add Items'),
                        onTap: () => {},
                      )
                    : ListTile(
                        title: Text('Item $index'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Delete item
                          },
                        ),
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: Settings
class Settings extends StatefulWidget {
  const Settings({
    super.key,
    required this.id,
    required this.household,
  });

  // ID & Household
  final String id;
  final Map<String, dynamic> household;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // TextField Controller
  final TextEditingController nameController = TextEditingController();

  // Init State
  @override
  void initState() {
    super.initState();
    nameController.text = widget.household['name'];
  }

  // Build the app
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        const Row(
          children: [
            SizedBox(width: 20),
            Text(
              'Settings',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Spacer(),
          ],
        ),

        // Settings
        Padding(
          padding: const EdgeInsets.only(top: 15, right: 80, left: 20),
          child: Container(
            height: MediaQuery.of(context).size.height - 245,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: ListView(
              clipBehavior: Clip.antiAlias,
              children: [
                // Household Name
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Household Name'),
                  subtitle: Text(widget.household['name']),
                  onTap: () {
                    // Show TextField to update household name in Dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Update Household Name'),
                          content: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Household Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Dismiss Dialog
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Update Household Name
                                FirebaseFirestore.instance
                                    .collection('households')
                                    .doc(widget.id)
                                    .update({'name': nameController.text});
                                Navigator.pop(context);
                                // Show SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  // SnackBar Top Screen
                                  SnackBar(
                                    dismissDirection: DismissDirection.up,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: EdgeInsets.only(
                                        right: 10,
                                        left: 10,
                                        bottom:
                                            MediaQuery.of(context).size.height - 100),
                                    content: const Text(
                                      'Household Name Updated, Please Refresh',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // Manage Members
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Manage Members'),
                  subtitle: Text('${widget.household['members'].length} member(s)'),
                  onTap: () {
                    // Manage Members
                  },
                ),

                // If no members, show Delete Household
                if (widget.household['members'].length == 1)
                  ListTile(
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete Household'),
                    subtitle: const Text('This action cannot be undone'),
                    onTap: () {
                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Household'),
                            content: const Text('This action cannot be undone'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Dismiss Dialog
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Delete Household
                                  FirebaseFirestore.instance
                                      .collection('households')
                                      .doc(widget.id)
                                      .delete();
                                  Navigator.pop(context);
                                  // Show SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    // SnackBar Top Screen
                                    SnackBar(
                                      dismissDirection: DismissDirection.up,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                          bottom:
                                              MediaQuery.of(context).size.height - 100),
                                      content: const Text(
                                        'Household Deleted',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                // If more than one member, show Leave Household
                if (widget.household['members'].length > 1)
                  // Leave Household
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Leave Household'),
                    subtitle: const Text('Leave the current household'),
                    onTap: () {
                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Leave Household'),
                            content: const Text('Are you sure you want to leave?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Dismiss Dialog
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Leave Household
                                  FirebaseFirestore.instance
                                      .collection('households')
                                      .doc(widget.id)
                                      .update({
                                    'members': FieldValue.arrayRemove(
                                        [FirebaseAuth.instance.currentUser!.email])
                                  });
                                  Navigator.pop(context);
                                  // Show SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    // SnackBar Top Screen
                                    SnackBar(
                                      dismissDirection: DismissDirection.up,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                          bottom:
                                              MediaQuery.of(context).size.height - 100),
                                      content: const Text(
                                        'Left Household',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Leave'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                // Break
                const Divider(),

                // Household Details (JOIN CODE)
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Household Details'),
                  subtitle: Text('Join Code: ${widget.household['code']}'),
                  onTap: () {
                    // Copy to Clipboard
                    Clipboard.setData(ClipboardData(text: widget.household['code']));
                    // Show SnackBar
                    // Show SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      // SnackBar Top Screen
                      SnackBar(
                        dismissDirection: DismissDirection.up,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.only(
                            right: 10,
                            left: 10,
                            bottom: MediaQuery.of(context).size.height - 100),
                        content: const Text(
                          'Join Code Copied',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Household Structure:
// {
//   'name': 'Household Name',
//   'members': ['email1', 'email2', 'email3'],
//   'recipes': ['recipeID1', 'recipeID2', 'recipeID3'],
//   'shoppingList': ['item1', 'item2', 'item3'],
//   'fridge': ['item1', 'item2', 'item3'],
//   'freezer': ['item1', 'item2', 'item3'],
//   'pantry': ['item1', 'item2', 'item3'],
// }