import 'package:flutter/material.dart';
import 'order_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'XYZ Chocolates',
          style: TextStyle(
            fontFamily: 'poppinssb',
            fontSize: 24.0, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Make the text bold
            letterSpacing: 1.5, // Add some letter spacing
            color: Color.fromARGB(255, 149, 42, 42), // Change the text color
          ),
        ),
        centerTitle: true, // Center the title horizontally
        elevation: 0, // Remove app bar shadow
        toolbarHeight: 100, // Adjust the height of the app bar
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPage()),
            );
          },
          child: const Text('Place Your Order'),
        ),
      ),
    );
  }
}
