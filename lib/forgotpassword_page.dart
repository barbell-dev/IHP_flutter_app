import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'setpassword_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controllers for phone number and OTP input fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Variables to maintain state
  bool otpFieldVisible = false;
  String verificationId = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref().child('users');
  // Function to handle sending OTP
  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    // Query the database to see if the phone number already exists
    DatabaseEvent event =
        await usersRef.orderByChild('phoneNumber').equalTo(phoneNumber).once();

    // Extract the DataSnapshot from the DatabaseEvent
    DataSnapshot snapshot = event.snapshot;

    // Log some debug information
    print('Phone number being checked: $phoneNumber');
    print('Snapshot exists: ${snapshot.exists}');
    print('Snapshot value: ${snapshot.value}');

    // Check if the phone number exists in the database
    // If the snapshot contains children, the phone number exists
    return snapshot.exists;
  }

  void handleSendOTP() async {
    // Get the entered phone number
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    // Format the phone number with the country code
    if (phoneNumber.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Remove the country code from the phone number.')),
      );
      return;
    }

    // Check if the phone number exists in the database
    bool phoneExists = await _checkPhoneNumberExists(phoneNumber);
    if (!phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Phone number does not exist. Please sign up.')),
      );
      return; // Exit the function if the phone number does not exist
    }

    // If phone number exists, proceed to send OTP
    auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {
        // Verification completed automatically
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          otpFieldVisible = true; // Show the OTP input field
          verificationId = verId;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  // Function to handle verifying OTP
  void handleVerifyOTP() async {
    String otp = otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      // Use FirebaseAuth to sign in with the credential (OTP)
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to SetPasswordPage with the phone number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SetPasswordPage(phoneNumber: phoneController.text.trim()),
        ),
      );
    } catch (e) {
      // Show an error message if OTP verification fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextField for entering the phone number
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                // FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Enter your phone number (without the prefix +91)',
              ),
            ),
            const SizedBox(height: 16.0),
            // Button to send OTP
            ElevatedButton(
              onPressed: handleSendOTP,
              child: const Text('Send OTP'),
            ),
            if (otpFieldVisible) ...[
              const SizedBox(height: 16.0),
              // TextField for entering OTP
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                ),
              ),
              const SizedBox(height: 16.0),
              // Button to verify OTP
              ElevatedButton(
                onPressed: handleVerifyOTP,
                child: const Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
