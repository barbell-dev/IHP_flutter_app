import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order.dart'; // Import the Order class
import 'order_page.dart';
import 'dart:io';

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
                  ['Chocolate', 'Variant', 'Quantity'],
                  ...orders.map((order) => [
                        order.chocolate,
                        order.variant,
                        order.quantity.toString(),
                      ]),
                ],
                headerStyle:
                    pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
                cellAlignment: pdfLib.Alignment.centerLeft,
                cellPadding: pdfLib.EdgeInsets.all(10),
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

    // Open the PDF file in a popup window
    final url = 'file://${file.path}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Chocolate: ${order.chocolate}'),
                      subtitle: Text(
                        'Variant: ${order.variant}\nQuantity: ${order.quantity}\nPrice: ${order.quantity} * ${OrderPage.prices[order.variant]} = ${order.quantity * (OrderPage.prices[order.variant] ?? 0)}',
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
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
