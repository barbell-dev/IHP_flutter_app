import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'order.dart'; // Import the Order class
import 'order_page.dart';
import 'payment_page.dart';
import 'package:printing/printing.dart';

class CheckoutPage extends StatelessWidget {
  final List<Order> orders;
  final int totalPrice; // Add totalPrice parameter

  const CheckoutPage({Key? key, required this.orders, required this.totalPrice})
      : super(key: key);

  Future<void> _generateAndOpenPDF() async {
    final pdf = pdfLib.Document();

    // Add content to the PDF
    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          return pdfLib.Column(
            children: [
              pdfLib.SizedBox(height: 20),
              pdfLib.Center(
                child: pdfLib.Text(
                  'Order Summary',
                  style: pdfLib.TextStyle(
                    fontSize: 20,
                    fontWeight: pdfLib.FontWeight.bold,
                  ),
                ),
              ),
              pdfLib.SizedBox(height: 20),
              pdfLib.Table.fromTextArray(
                context: context,
                data: [
                  ['Chocolate', 'Variant', 'Quantity', 'Price'],
                  ...orders.map((order) => [
                        order.chocolate,
                        order.variant,
                        order.quantity.toString(),
                        '₹${order.quantity * (OrderPage.prices[order.variant] ?? 0)}',
                      ]),
                ],
                headerStyle:
                    pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
                cellAlignment: pdfLib.Alignment.centerLeft,
                cellPadding: pdfLib.EdgeInsets.all(10),
              ),
              pdfLib.SizedBox(height: 20),
              pdfLib.Center(
                child: pdfLib.Text(
                  'Total: ₹$totalPrice',
                  style: pdfLib.TextStyle(
                    fontSize: 18,
                    fontWeight: pdfLib.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Get the temporary directory
    final output = await getTemporaryDirectory();

    // Create the PDF file
    final file = File('${output.path}/order_summary.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF file
    await Printing.sharePdf(bytes: await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Cart"),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Chocolate: ${order.chocolate}'),
                      subtitle: Text(
                        'Variant: ${order.variant}\nQuantity: ${order.quantity}\nPrice: ${order.quantity * (OrderPage.prices[order.variant] ?? 0)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Total price : $totalPrice',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppinssb',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _generateAndOpenPDF,
              child: Text('Download PDF of your orders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              child: Text("Proceed to payment"),
            ),
          ],
        ),
      ),
    );
  }
}
