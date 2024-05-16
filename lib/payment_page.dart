import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            // Add PaymentMethodTile for each payment method
            _buildPaymentMethodTile(
              context,
              icon: Icons.credit_card,
              title: 'Credit Card',
            ),
            _buildPaymentMethodTile(
              context,
              icon: Icons.payment,
              title: 'Debit Card',
            ),
            _buildPaymentMethodTile(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
            ),
            _buildPaymentMethodTile(
              context,
              icon: Icons.payment_outlined,
              title: 'UPI',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build PaymentMethodTile
  Widget _buildPaymentMethodTile(BuildContext context,
      {required IconData icon, required String title}) {
    return PaymentMethodTile(
      icon: icon,
      title: title,
      onTap: () {
        // Navigate to QRCodeImagePage when any payment method is clicked
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRCodeImagePage()),
        );
      },
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PaymentMethodTile(
      {Key? key, required this.icon, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 20.0),
            Text(
              title,
              style: const TextStyle(
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

// Widget to display the QR code image
class QRCodeImagePage extends StatelessWidget {
  const QRCodeImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Specify the image path
    ; // Specify the relative path to the QR code image

    return Scaffold(
      appBar: AppBar(
        title: const Text('You can support me \u{1F61C}'),
      ),
      body: Center(
        child:
            Text('GPAY @ +919449780741'), // Load the QR code image from assets
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PaymentPage(),
  ));
}
