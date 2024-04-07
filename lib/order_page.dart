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
                  // Add functionality for bag icon
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
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildVariantItems(String? chocolate) {
    List<String> variants = [];

    if (chocolate == 'Dairy Milk') {
      variants.addAll(
          ['10g - Regular', '35g - Regular', '110g - Regular', '110g - Silk']);
    } else {
      variants.addAll(['10g', '35g', '110g']);
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
      // Increase bag count by the selected quantity
      bagCount += quantity;
    });
  }
}
