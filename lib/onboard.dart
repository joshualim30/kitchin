// onboard.dart
// Allow users to sign in or sign up

// MARK: Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitchin/navigation.dart';

// MARK: Onboard Class
class Onboard extends StatelessWidget {
  Onboard({super.key});

  // MARK: Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'KitchIN',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Spacing
              const SizedBox(height: 20),
              // Sign In and Sign Up Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                    // Sign In and Sign Up Forms
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 300,
                        child: TabBarView(
                          children: [
                            // Sign In Form
                            Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Call the sign in function
                                    try {
                                      await _signIn();
                                      // Navigate to Home screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Navigation(),
                                        ),
                                      );
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Sign In'),
                                ),
                              ],
                            ),
                            // Sign Up Form
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: fullNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                    ),
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Call the sign up function
                                      try {
                                        await _signUp();
                                        // Navigate to Home screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Navigation()
                                          ),
                                        );
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Error'),
                                            content: Text(e.toString()),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }

  // MARK: Sign In Function
  Future<dynamic> _signIn() async {
    // Sign In with Email and Password
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Check if the user exists
      if (credential.user != null) {
        return credential;
      } else {
        // TODO: Delete the user in Firebase Auth as well
        throw 'No user found for that email.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Show error message
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        // Show error message
        throw 'Wrong password provided for that user.';
      }
    }
  }

  // MARK: Sign Up Function
  Future<dynamic> _signUp() async {
    // Create a new user with the email and password
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Create a new user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'profilePicture': 'https://ew.com/thmb/UH5Pky8-bPW0xyINGGx9_IP5qqU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/gordon-ramsay-hells-kitchen-02-2000-5ba7b54922864ca9b566bb5f4f0b9ace.jpg',
        'fullName': fullNameController.text,
        'email': emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // Show error message
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        // Show error message
        throw 'The account already exists for that email.';
      }
    }
  }
}
