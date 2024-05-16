import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'order.dart'; // Import the Order class
import 'order_page.dart';
import 'payment_page.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatelessWidget {
  final List<Order> orders;
  final int totalPrice; // Add totalPrice parameter

  const CheckoutPage({Key? key, required this.orders, required this.totalPrice})
      : super(key: key);

  Future<void> _generateAndOpenPDF() async {
    final pdf = pdfLib.Document();
    final font = await rootBundle.load("lib/fonts/inr.ttf");
    final ttf = pdfLib.Font.ttf(font);
    final poppins = await rootBundle.load("lib/fonts/poppinssb.ttf");
    final pps = pdfLib.Font.ttf(poppins);
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
                    font: pps,
                  ),
                ),
              ),
              pdfLib.SizedBox(height: 20),
              pdfLib.TableHelper.fromTextArray(
                context: context,
                data: [
                  ['Chocolate', 'Variant', 'Quantity', 'Price'],
                  ...orders.map((order) => [
                        order.chocolate,
                        order.variant,
                        order.quantity.toString(),
                        '\u{20B9}${order.quantity * (OrderPage.prices[order.variant] ?? 0)}',
                      ]),
                ],
                headerStyle:
                    pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
                cellAlignment: pdfLib.Alignment.centerLeft,
                cellPadding: const pdfLib.EdgeInsets.all(10),
                cellStyle: pdfLib.TextStyle(font: pps),
              ),
              pdfLib.SizedBox(height: 20),
              pdfLib.Center(
                child: pdfLib.Text(
                  'Total: \u{20B9}$totalPrice',
                  style: pdfLib.TextStyle(
                    fontSize: 18,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: pps,
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
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Cart"),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Chocolate: ${order.chocolate}'),
                      subtitle: Text(
                        'Variant: ${order.variant}\nQuantity: ${order.quantity}\nPrice: \u20B9${order.quantity * (OrderPage.prices[order.variant] ?? 0)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total price : \u{20B9}$totalPrice',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppinssb',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _generateAndOpenPDF,
              child: const Text('Download PDF of your orders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                );
              },
              child: const Text("Proceed to payment"),
            ),
          ],
        ),
      ),
    );
  }
}
