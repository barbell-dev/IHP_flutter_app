import 'package:flutter/material.dart';
import 'order.dart'; // Import the Order class

class CheckoutPage extends StatelessWidget {
  final List<Order> orders;

  const CheckoutPage({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text('Chocolate: ${order.chocolate}'),
                subtitle: Text(
                    'Variant: ${order.variant}\nQuantity: ${order.quantity}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
