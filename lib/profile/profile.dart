// profile.dart
// User Profile Screen

// MARK: Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchin/onboard.dart';

// MARK: Profile Class
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Text Field Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // User Data
  late Future<DocumentSnapshot> userData;

  // MARK: Init State
  @override
  void initState() {
    super.initState();
    userData = _getUserData();
  }

  // Build the app
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: userData,
      builder: (context, snapshot) {
        // If snapshot has data
        if (snapshot.hasData) {
          // Get the user data
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Return the user data
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                // Log Out Button
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    // Show Dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Log Out'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: [
                            // Cancel Button
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            // Log Out Button
                            TextButton(
                              onPressed: () async {
                                // Sign out the user
                                await FirebaseAuth.instance.signOut();
                                // Navigate to the Onboard screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Onboard()),
                                );
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacing (20)
                  const SizedBox(height: 20),
                  // Profile Picture
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(userData['profilePicture'] ??
                        'https://ew.com/thmb/UH5Pky8-bPW0xyINGGx9_IP5qqU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/gordon-ramsay-hells-kitchen-02-2000-5ba7b54922864ca9b566bb5f4f0b9ace.jpg'),
                  ),
                  // Spacing (20)
                  const SizedBox(height: 20),
                  // Full Name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        enabled: true,
                      ),
                      onSubmitted: (value) {
                        debugPrint('UID: ${userData['uid']}');
                        // Update the user's full name
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data!.id)
                            .update({'fullName': value});
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
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
                              'Full Name Updated',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Email
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabled: false,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        }

        // Otherwise, return a loading indicator
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // MARK: Get user data
  Future<DocumentSnapshot> _getUserData() async {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    // Get the user data
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: user!.email)
        .get();

    // Set the name and email
    setState(() {
      nameController.text = userData.docs.first.data()['fullName'];
      emailController.text = userData.docs.first.data()['email'];
    });

    // Return the user data
    return userData.docs.first;
  }
}
