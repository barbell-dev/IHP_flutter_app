import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:xyz_chocolates/otp_verification_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phoneNumber = '';
  String _password = '';

  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');

  void _handleSignup() async {
    Future<bool> checkInternetConnectivity() async {
      try {
        final result = await InternetAddress.lookup('example.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    }

    // Check internet connectivity before proceeding with login
    bool isConnected = await checkInternetConnectivity();
    if (!isConnected) {
      // Show SnackBar if device is not connected to the internet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No internet connection. Please try again later.')),
      );
      return; // Return early if not connected to the internet
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if phone number already exists in the database
      bool phoneExists = await _checkPhoneNumberExists(_phoneNumber);

      if (phoneExists) {
        // Show a Snackbar informing the user that the phone number already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Phone number already registered. Please log in.')),
        );
        return;
      } else {
        // Initiate phone number verification
        auth.verifyPhoneNumber(
          phoneNumber: '+91$_phoneNumber',
          timeout:
              const Duration(seconds: 60), // Timeout duration for verification
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto verification (instant verification)
            await _handleVerificationCompleted(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            // Verification failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${e.message}')),
            );
          },
          codeSent: (String verificationId, int? resendToken) async {
            // Navigate to OTPVerificationPage with the verificationId and phone number
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationPage(
                  verificationId: verificationId,
                  phoneNumber: _phoneNumber,
                  name: _name,
                  password: _password,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle auto-retrieval timeout (if needed)
            print('Code auto retrieval timeout');
          },
        );
      }
    }
  }

  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    // Query the database to see if the phone number already exists
    DatabaseEvent event =
        await usersRef.orderByChild('phoneNumber').equalTo(phoneNumber).once();

    // Extract the DataSnapshot from the DatabaseEvent
    DataSnapshot snapshot = event.snapshot;

    // Check if the phone number exists in the database
    // If the snapshot contains children, the phone number exists
    return snapshot.exists;
  }

  Future<void> _handleVerificationCompleted(
      PhoneAuthCredential credential) async {
    try {
      // Sign in with the credential
      await auth.signInWithCredential(credential);

      // Once the user is signed in, add user data to the database
      final userKey = usersRef.push().key;

      if (userKey != null) {
        await usersRef.child(userKey).set({
          'name': _name,
          'phoneNumber': _phoneNumber,
          'password': _password, // You may want to hash the password
        });

        // Navigate to the OrderPage
        Navigator.pushReplacementNamed(context, '/order');
      } else {
        // Handle the case where the user key is null (show an error message)
        print('Error: Unable to create a user key.');
      }
    } catch (e) {
      print('Error during auto verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during auto verification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _handleSignup,
                child: const Text('Signup'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already registered?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
