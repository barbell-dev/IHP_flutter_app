import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'order_page.dart';
import 'home_page.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String name;
  final String password;

  const OTPVerificationPage(
      {Key? key,
      required this.verificationId,
      required this.phoneNumber,
      required this.name,
      required this.password})
      : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();

  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');

  void _verifyOTP() async {
    String smsCode = _otpController.text;

    // Create a PhoneAuthCredential with the received SMS code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Add user data to the database if OTP verification is successful
      final userKey = usersRef.push().key;

      if (userKey != null) {
        await usersRef.child(userKey).set({
          'name': widget.name,
          'phoneNumber': widget.phoneNumber,
          'password': widget.password, // You may want to hash the password
        });

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(name: widget.name),
          ),
        );
      } else {
        // Handle the case where the user key is null (show an error message)
        print("Error: Unable to create a user key.");
      }
    } catch (e) {
      // Handle errors during OTP verification or adding data to the database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP sent to your mobile number +91${widget.phoneNumber}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6, // The OTP is typically 6 digits
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter OTP',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
