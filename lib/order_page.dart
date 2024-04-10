import 'package:flutter/material.dart';
import 'checkout.dart'; // Import the new checkout page
import 'order.dart';

export 'order_page.dart';

// int totalPrice = 0;

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
  static Map<String, int> get prices => _OrderPageState.prices;
}

class _OrderPageState extends State<OrderPage> {
  String? selectedChocolate;
  String? selectedVariant;
  int quantity = 0; // Default quantity is 0
  int bagCount = 0;
  List<Order> orders = [];
  static final Map<String, int> prices = {
    '10g - Regular': 10,
    '35g - Regular': 30,
    '110g - Regular': 80,
    '110g - Silk': 95,
  };
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
                      style: const TextStyle(color: Colors.white),
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
                setState(() {
                  selectedChocolate = value;
                  if (!(_buildVariantItems(selectedChocolate) as List<String>)
                      .contains(selectedVariant)) {
                    selectedVariant =
                        null; // Reset variant selection only if the previously selected variant is not available for the newly selected chocolate
                  }
                  // quantity = 0; // No need to reset quantity here
                });
              },
            ),
            SizedBox(height: 16.0),
            // Variant Dropdown
            DropdownButtonFormField<String>(
              value: selectedVariant,
              hint: Text('Select Variant'),
              items: _buildVariantItems(selectedChocolate).map((String value) {
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
                setState(() {
                  selectedVariant = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Quantity TextField
            TextFormField(
              enabled: true,
              decoration: InputDecoration(
                labelText: 'Quantity',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Add to Bag Button
            ElevatedButton(
              onPressed: _isAddToBagEnabled() ? () => addToBag() : null,
              child: Text('Add to Bag'),
            ),
            SizedBox(height: 16.0),
            // Pricing Table
            _buildPricingTable(),
            SizedBox(height: 16.0),
            // Checkout Button
            ElevatedButton(
              onPressed: bagCount > 0
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                              orders: orders,
                              totalPrice:
                                  _calculateTotalPrice()), // Pass totalPrice
                        ),
                      )
                  : null,
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAddToBagEnabled() {
    return selectedChocolate != null && selectedVariant != null && quantity > 0;
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

  List<String> _buildVariantItems(String? chocolate) {
    List<String> variants = [];

    if (chocolate == 'Dairy Milk') {
      variants.addAll(
          ['10g - Regular', '35g - Regular', '110g - Regular', '110g - Silk']);
    } else {
      variants.addAll(['10g - Regular', '35g - Regular', '110g - Regular']);
    }

    return variants;
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
      _updateBagCount();
    });
  }

  // void checkout() {
  //   // Add functionality for checkout button
  // }
  void _updateBagCount() {
    setState(() {
      bagCount = _calculateBagCount();
    });
  }

  void _showOrdersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              int totalPrice = _calculateTotalPrice();
              return Padding(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Orders',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              // setState(() {
                              //   // Update the bag count when the dialog is closed
                              //   bagCount = _calculateBagCount();
                              // });
                              _updateBagCount();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      DataTable(
                        columnSpacing: 8,
                        columns: [
                          DataColumn(label: Text('Chocolate')),
                          DataColumn(label: Text('Variant')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: orders.map((order) {
                          return DataRow(
                            cells: [
                              DataCell(Text(order.chocolate)),
                              DataCell(Text(order.variant)),
                              DataCell(Text(order.quantity.toString())),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (order.quantity > 1) {
                                          // orders.remove(order);
                                          order.quantity--;
                                          totalPrice -= _calculatePrice(order);
                                        } else {
                                          orders.remove(order);
                                          totalPrice -= _calculatePrice(order);
                                        }
                                        _updateBagCount();
                                        // Update the bag count immediately after deleting the order
                                        // setState(() {
                                        //   bagCount = _calculateBagCount();
                                        // });
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        totalPrice -= _calculatePrice(order);

                                        orders.remove(order);
                                        _updateBagCount();
                                      });
                                      // Update the bag count immediately after deleting the order
                                      // setState(() {
                                      //   bagCount = _calculateBagCount();
                                      // });
                                    },
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Total Price: \u{20B9}$totalPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  int _calculateTotalPrice() {
    int totalPrice = 0;
    for (Order order in orders) {
      totalPrice += _calculatePrice(order);
    }
    return totalPrice;
  }

  int _calculatePrice(Order order) {
    final Map<String, int> prices = {
      '10g - Regular': 10,
      '35g - Regular': 30,
      '110g - Regular': 80,
      '110g - Silk': 95,
    };

    return prices[order.variant]! * order.quantity;
  }

  int _calculateBagCount() {
    int count = 0;
    for (Order order in orders) {
      count += order.quantity;
    }
    return count;
  }
}

// class Order {
//   final String chocolate;
//   final String variant;
//   int quantity;

//   Order(this.chocolate, this.variant, this.quantity);
// }

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrderPage(),
  ));
}
