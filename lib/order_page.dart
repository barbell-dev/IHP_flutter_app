import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? selectedChocolate;
  String? selectedVariant;
  int quantity = 1; // Default quantity is 1
  int bagCount = 0;
  List<Order> orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Page'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag),
                onPressed: () {
                  _showOrdersDialog();
                },
              ),
              if (bagCount > 0)
                Positioned(
                  right: 8.0,
                  top: 8.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text(
                      '$bagCount',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Chocolate:',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            // Chocolate Dropdown
            DropdownButtonFormField<String>(
              value: selectedChocolate,
              hint: Text('Select Chocolate'),
              items: [
                'Munch',
                'Dairy Milk',
                'KitKat',
                'FiveStar',
                'Perk',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        fontFamily: 'GooglePoppins', color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                // Change the parameter type to String?
                setState(() {
                  selectedChocolate = value;
                  selectedVariant = null; // Reset variant selection
                  quantity = 1; // Reset quantity
                });
              },
            ),
            SizedBox(height: 16.0),
            // Variant Dropdown
            DropdownButtonFormField<String>(
              value: selectedVariant,
              hint: Text('Select Variant'),
              items: _buildVariantItems(selectedChocolate),
              onChanged: (String? value) {
                // Change the parameter type to String?
                setState(() {
                  selectedVariant = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Quantity TextField
            TextField(
              enabled: selectedChocolate != null,
              decoration: InputDecoration(
                labelText: 'Quantity',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 1;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Add to Bag Button
            ElevatedButton(
              onPressed: selectedChocolate != null ? () => addToBag() : null,
              child: Text('Add to Bag'),
            ),
            SizedBox(height: 16.0),
            // Pricing Table
            _buildPricingTable(),
            SizedBox(height: 16.0),
            // Checkout Button
            ElevatedButton(
              onPressed: bagCount > 0 ? () => checkout() : null,
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Variant')),
        DataColumn(label: Text('Price (INR)')),
      ],
      rows: _buildPricingRows(),
    );
  }

  List<DataRow> _buildPricingRows() {
    final Map<String, int> prices = {
      '10g - Regular': 10,
      '35g - Regular': 30,
      '110g - Regular': 80,
      '110g - Silk': 95,
    };

    List<DataRow> rows = [];
    prices.forEach((variant, price) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(variant)),
          DataCell(Row(
            children: [
              Text('\u{20B9}$price'),
            ],
          )),
        ],
      ));
    });
    return rows;
  }

  List<DropdownMenuItem<String>> _buildVariantItems(String? chocolate) {
    List<String> variants = [];

    if (chocolate == 'Dairy Milk') {
      variants.addAll(
          ['10g - Regular', '35g - Regular', '110g - Regular', '110g - Silk']);
    } else {
      variants.addAll(['10g - Regular', '35g - Regular', '110g - Regular']);
    }

    return variants.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: TextStyle(fontFamily: 'GooglePoppins', color: Colors.black),
        ),
      );
    }).toList();
  }

  void addToBag() {
    setState(() {
      // Check if an order with the same chocolate and variant already exists
      bool foundExistingOrder = false;
      for (Order order in orders) {
        if (order.chocolate == selectedChocolate &&
            order.variant == selectedVariant) {
          // Update the quantity of the existing order
          order.quantity += quantity;
          foundExistingOrder = true;
          break;
        }
      }

      // If no existing order found, add a new order
      if (!foundExistingOrder) {
        orders.add(Order(selectedChocolate!, selectedVariant!, quantity));
      }

      // Increase bag count by the selected quantity
      bagCount += quantity;
    });
  }

  void checkout() {
    // Add functionality for checkout button
  }

  void _showOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Your Orders',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Chocolate')),
                      DataColumn(label: Text('Variant')),
                      DataColumn(label: Text('Quantity')),
                    ],
                    rows: orders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(Text(order.chocolate)),
                          DataCell(Text(order.variant)),
                          DataCell(Text(order.quantity.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Order {
  final String chocolate;
  final String variant;
  int quantity;

  Order(this.chocolate, this.variant, this.quantity);
}
