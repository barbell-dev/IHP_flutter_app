import 'package:flutter/material.dart';
import 'checkout.dart'; // Import the new checkout page
import 'order.dart';

export 'order_page.dart';
import 'login_page.dart';
// int totalPrice = 0;

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

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
        title: const Text(
          'Order Page',
          style: TextStyle(fontFamily: 'poppinssb'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate back to the login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LoginPage(), // Replace LoginPage with your login page class
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your favourite chocolates :',
              style: TextStyle(
                  fontSize: 16.0, color: Colors.white, fontFamily: 'poppinssb'),
            ),
            // Chocolate Dropdown
            DropdownButtonFormField<String>(
              value: selectedChocolate,
              hint: const Text(
                'Select Chocolate',
                style: TextStyle(fontFamily: 'poppinssb'),
              ),
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
                    style: const TextStyle(
                        fontFamily: 'poppinssb', color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedChocolate = value;
                  if (!(_buildVariantItems(selectedChocolate))
                      .contains(selectedVariant)) {
                    selectedVariant =
                        null; // Reset variant selection only if the previously selected variant is not available for the newly selected chocolate
                  }
                  // quantity = 0; // No need to reset quantity here
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Variant Dropdown
            DropdownButtonFormField<String>(
              value: selectedVariant,
              hint: const Text(
                'Select Variant',
                style: TextStyle(fontFamily: 'poppinssb'),
              ),
              items: _buildVariantItems(selectedChocolate).map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontFamily: 'poppinssb', color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedVariant = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Quantity TextField
            TextFormField(
              enabled: true,
              style: TextStyle(fontFamily: 'poppinssb'),
              decoration: const InputDecoration(
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
            const SizedBox(height: 16.0),
            // Add to Bag Button
            Center(
              child: ElevatedButton(
                onPressed: _isAddToBagEnabled() ? () => addToBag() : null,
                child: const Text('Add to Bag'),
              ),
            ),
            const SizedBox(height: 16.0),
            // Pricing Table
            _buildPricingTable(),
            const SizedBox(height: 16.0),
            // Checkout Button
            Center(
              child: ElevatedButton(
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
                child: const Text('Checkout'),
              ),
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
    return Center(
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text(
            'Variant',
            style: TextStyle(fontFamily: 'poppinssb'),
          )),
          DataColumn(
              label: Text(
            'Price \u{20B9}',
            style: TextStyle(fontFamily: 'poppinssb'),
          )),
        ],
        rows: _buildPricingRows(),
      ),
    );
  }

  List<DataRow> _buildPricingRows() {
    List<DataRow> rows = [];
    prices.forEach((variant, price) {
      rows.add(DataRow(
        cells: [
          DataCell(Text(
            variant,
            style: TextStyle(fontFamily: 'poppinssb'),
          )),
          DataCell(Row(
            children: [
              Text(
                '\u{20B9}$price',
                style: TextStyle(fontFamily: 'poppinssb'),
              ),
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
        int totalPrice = _calculateTotalPrice();
        double dialogWidth = MediaQuery.of(context).size.width *
            0.8; // Dynamic width based on screen width

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Orders',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _updateBagCount();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // DataTable displaying orders
                  DataTable(
                    columnSpacing: 16.0, // Reduce spacing between columns
                    columns: [
                      DataColumn(
                        label: Text(
                          'Chocolate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow:
                              TextOverflow.ellipsis, // Handle text overflow
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Variant',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    rows: orders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(Text(order.chocolate,
                              overflow: TextOverflow.ellipsis)),
                          DataCell(Text(
                              order.variant +
                                  "                                                                           ",
                              overflow: TextOverflow.clip)),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(order.quantity.toString(),
                                    overflow: TextOverflow.ellipsis),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      // Handle remove button
                                      order.quantity--;
                                      if (order.quantity <= 0) {
                                        orders.remove(order);
                                      }
                                      _updateBagCount();
                                      Navigator.pop(context);
                                      _showOrdersDialog();
                                    });
                                    ;
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      // Handle delete button
                                      orders.remove(order);
                                      _updateBagCount();
                                      Navigator.pop(context);
                                      _showOrdersDialog();
                                    });
                                    ;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16.0),
                  // Display total price
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 1.0),
                      child: Text(
                        'Total Price: \u{20B9}$totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrderPage(),
  ));
}
