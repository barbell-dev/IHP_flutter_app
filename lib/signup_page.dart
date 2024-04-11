import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'otp_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phoneNumber = '';
  String _password = '';
  String _otp = '';

  late TwilioFlutter twilioClient;

  @override
  void initState() {
    super.initState();
    twilioClient = TwilioFlutter(
      accountSid: 'ACef4000326b184edc0aeccfa567a277db',
      authToken: 'e4e9ddd7e33abda75fbaebbcc97fd4fb',
      twilioNumber: '+1 205 236 0176', // Replace with your Twilio phone number
    );
  }

  bool _isPhoneNumberValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    if (value.length != 10) {
      return false;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return false;
    }
    return true;
  }

  String _generateOTP() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  Future<bool> _sendOTP(String phoneNumber, String _name) async {
    try {
      await twilioClient.sendSMS(
        toNumber: '+91$phoneNumber',
        messageBody: 'Hello $_name ! Your OTP is: $_otp',
      );
      return true; // OTP sent successfully
    } catch (e) {
      print('Error sending OTP: $e');
      return false; // Failed to send OTP
    }
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _otp = _generateOTP();
      if (await _sendOTP(_phoneNumber, _name)) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OTPPage(otp: _otp)),
        );
      } else {
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
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
                decoration: InputDecoration(
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
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (!_isPhoneNumberValid(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _handleSignup,
                child: Text('Signup'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already registered?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Login'),
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
