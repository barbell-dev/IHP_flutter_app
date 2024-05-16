import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:xyz_chocolates/home_page.dart';
import 'signup_page.dart';
import 'forgotpassword_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Create TextEditingController instances
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Create a reference to the Firebase database
  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');

  // Function to handle login
  void handleLogin() async {
    // Get the entered phone number and password
    String phoneNumber = phoneController.text.trim();
    String password = passwordController.text.trim();

    // Check if either phone number or password is empty
    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number and password are required.')),
      );
      return;
    }

    try {
      // Query the database for the user with the provided phone number
      DatabaseEvent event = await usersRef
          .orderByChild('phoneNumber')
          .equalTo(phoneNumber)
          .once();

      // Check if the event has a snapshot and if it exists
      if (event.snapshot.exists) {
        // Iterate through the snapshot children to find the user
        Map<dynamic, dynamic> userData = {};
        bool userFound = false;

        // Iterate through the children of the snapshot
        for (var child in event.snapshot.children) {
          // Check if the child has a value and it matches the expected structure
          if (child.value != null) {
            userData = child.value as Map<dynamic, dynamic>;

            // Check if the phone number matches the entered phone number
            if (userData.containsKey('phoneNumber') &&
                userData['phoneNumber'] == phoneNumber) {
              userFound = true;
              break; // User found, break the loop
            }
          }
        }

        // If user is found, check password
        if (userFound) {
          // Check if the password matches
          if (userData['password'] == password) {
            // Get the user's name
            String userName = userData['name'] ?? '';

            // Navigate to HomePage and pass the name
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(name: userName),
              ),
            );
          } else {
            // Incorrect password, show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Incorrect password. Please try again.')),
            );
          }
        } else {
          // Phone number does not exist in the database, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Phone number does not exist. Please sign up.')),
          );
        }
      } else {
        // Phone number does not exist in the database, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Phone number does not exist. Please sign up.')),
        );
      }
    } catch (error) {
      // Handle any errors during the query
      print("Error querying database: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error querying database: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: Text(
                  "XYZ \n Chocolates",
                  style: TextStyle(
                    fontFamily: "poppinssb",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // TextField for phone number input
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (without the prefix +91)',
              ),
            ),
            const SizedBox(height: 16.0),
            // TextField for password input
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Navigate to forgot password page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontFamily: "poppinssb"),
              ),
            ),
            const SizedBox(height: 16.0),
            // ElevatedButton to perform login action
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Not registered?",
                    style: TextStyle(fontFamily: "poppinssb")),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text('Signup',
                      style: TextStyle(fontFamily: "poppinssb")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
