import 'package:flutter/material.dart';
import 'login_page.dart';
import 'order_page.dart';

class HomePage extends StatelessWidget {
  final String name;

  const HomePage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Color.fromARGB(255, 149, 42, 42),
                Color.fromARGB(255, 252, 85, 85),
                Color.fromARGB(255, 255, 153, 153),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            'XYZ Chocolates',
            style: TextStyle(
              fontFamily: 'poppinssb',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hey $name',
              style: const TextStyle(
                fontFamily: 'poppinssb',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                height: 5.0,
              ),
            ),
            Text(
              "Welcome! Here you can order your favorite chocolates!",
              style: const TextStyle(
                letterSpacing: 0.5,
                fontFamily: 'poppinssb',
              ),
            ),
            const SizedBox(height: 100.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderPage(),
                  ),
                );
              },
              child: const Text(
                'Place Your Order',
                style: TextStyle(
                  fontFamily: 'poppinssb',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
