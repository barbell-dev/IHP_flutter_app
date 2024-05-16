import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:xyz_chocolates/login_page.dart';

class SetPasswordPage extends StatefulWidget {
  final String phoneNumber;

  const SetPasswordPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  // Function to update the user's password
  Future<void> updatePassword(String phoneNumber, String newPassword) async {
    // Reference to the Firebase Realtime Database
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    // Query the database to find the document with the specified phone number
    DatabaseEvent event =
        await usersRef.orderByChild('phoneNumber').equalTo(phoneNumber).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      // Assume there is only one user with the specified phone number
      String? userKey = snapshot.children.first.key;
      DatabaseReference userRef = usersRef.child(userKey!);

      // Update the user's password in the Realtime Database document
      await userRef.update({'password': newPassword});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );

      // Navigate to the LoginPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      // If no user found with the provided phone number
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number not found. Please sign up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextField for entering new password
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter new password',
              ),
            ),
            const SizedBox(height: 16.0),
            // Button to update password
            ElevatedButton(
              onPressed: () {
                // Call the updatePassword function when button is pressed
                updatePassword(
                  widget.phoneNumber,
                  passwordController.text.trim(),
                );
              },
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
