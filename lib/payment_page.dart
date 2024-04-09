import 'checkout.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Credit Card',
              onTap: () {
                // Add functionality for credit card payment
              },
            ),
            PaymentMethodTile(
              icon: Icons.payment,
              title: 'Debit Card',
              onTap: () {
                // Add functionality for debit card payment
              },
            ),
            PaymentMethodTile(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              onTap: () {
                // Add functionality for wallet payment
              },
            ),
            PaymentMethodTile(
              icon: Icons.payment_outlined,
              title: 'UPI',
              onTap: () {
                // Add functionality for UPI payment
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30.0,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 20.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PaymentPage(),
  ));
}
