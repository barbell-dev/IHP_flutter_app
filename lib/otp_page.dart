import 'package:flutter/material.dart';
import 'package:xyz_chocolates/login_page.dart';
import 'package:xyz_chocolates/order_page.dart';

class OTPPage extends StatefulWidget {
  final String otp;

  OTPPage({required this.otp});

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _otpController = TextEditingController();

  void _verifyOTP() {
    if (_otpController.text == widget.otp) {
      // OTP verified, proceed with the signup process
      _showSuccessDialog();
    } else {
      // Display an error message
      _showErrorSnackBar();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Successful'),
        content: Text('You can now proceed to the order page.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderPage()),
              ); // Go back to the login page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid OTP. Please try again.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
