// ignore_for_file: avoid_print, file_names, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techknow/users/fragments/home_fragments_screen.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Future<void> addToCart(Product product, BuildContext context) async {
    const url =
        'https://femoral-pushdown.000webhostapp.com/-flutter/products/cart.php';
    final customerId = await getCustomerId();

    if (customerId != null) {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'customer_id': customerId,
          'product_id': product.product_id,
          'product_name': product.name,
          'product_price': product.price,
          'description': product.description,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Added to cart ${product.name}');
        showOrderSuccessSnackbar(context); // Pass the context here
      } else {
        print('Failed to add ${product.name} to cart');
      }
    } else {
      print('Customer ID not found');
    }
  }

  Future<void> checkout() async {
    const url =
        'https://femoral-pushdown.000webhostapp.com/-flutter/products/checkout.php';
    final customerId = await getCustomerId();

    if (customerId != null) {
      final DateTime now = DateTime.now();
      final String orderDate = DateFormat('yyyy-MM-dd').format(now);
      final String totalAmount =
          product.price; // Assuming total_amount is the product price

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'customer_id': customerId,
          'product_name': product.name,
          'order_date': orderDate,
          'total_amount': totalAmount,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Checkout successful');
      } else {
        print('Failed to checkout');
      }
    } else {
      print('Customer ID not found');
    }
  }

  Future<int?> getCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customer_id');
    print(
        'Retrieved Customer ID: $customerId'); // Add this line to verify retrieval
    return customerId;
  }

  void showOrderSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Section
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 220, // Max height for the image container
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit
                              .contain, // Ensure the entire image is visible without cropping
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Price:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '\$${product.price}\n',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Text(
                          'Description:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    addToCart(product, context); // Pass the context here
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart'),
                ),

                const SizedBox(height: 20),
                // Checkout button
                ElevatedButton.icon(
                  onPressed: () {
                    final BuildContext currentContext = context;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Purchase'),
                          content: const Text(
                              'Are you sure you want to purchase this item?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close the dialog
                                // Show loading indicator
                                showDialog(
                                  context:
                                      currentContext, // Use the saved context here
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Row(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(width: 16.0),
                                          Text(
                                              'Your item is preparing to ship...'),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                Navigator.of(currentContext).pop();
                                ScaffoldMessenger.of(currentContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Your item is preparing to ship!'),
                                  ),
                                );
                                await checkout();
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_checkout,
                      color: Colors.white),
                  label: const Text(
                    'Check out',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(218, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
