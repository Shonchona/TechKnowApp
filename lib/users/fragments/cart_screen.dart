// ignore_for_file: unnecessary_null_comparison, avoid_print, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<dynamic> products = [];
  late int customerId;
  final String baseUrl = 'https://femoral-pushdown.000webhostapp.com/img/';
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    getCustomerId().then((id) {
      if (id != null) {
        customerId = id;
        fetchProducts();
      } else {
        print('Customer ID not available.');
        // Handle this case as needed, e.g., show an error message.
      }
    });
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://femoral-pushdown.000webhostapp.com/-flutter/products/cart_screen.php?customer_id=$customerId'),
      );
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body.trim());
        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          setState(() {
            products = decodedResponse;
            calculateTotalPrice();
          });
        } else {
          print('Invalid or empty response data.');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> deleteProduct(int? productId) async {
    if (productId == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://femoral-pushdown.000webhostapp.com/-flutter/products/delete_from_cart.php'),
        body: jsonEncode({
          'customer_id': customerId,
          'product_id': productId,
        }),
      );
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('Delete response: $decodedResponse');
        if (decodedResponse['success']) {
          print('Product deleted successfully.');
          setState(() {
            products
                .removeWhere((product) => product['product_id'] == productId);
            calculateTotalPrice();
          });
        } else {
          print('Failed to delete product: ${decodedResponse['message']}');
        }
      } else {
        print(
            'Failed to delete product. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<int?> getCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customer_id');
    return customerId;
  }

  Future<void> _reloadProducts() async {
    await fetchProducts();
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (var product in products) {
      double price = double.tryParse(product['price'] ?? '0') ?? 0;
      total += price;
    }
    setState(() {
      totalPrice = total;
    });
  }

  Future<void> checkout() async {
    const url =
        'https://femoral-pushdown.000webhostapp.com/-flutter/products/checkout.php';
    final customerId = await getCustomerId();

    if (customerId != null) {
      final DateTime now = DateTime.now();
      final String orderDate = DateFormat('yyyy-MM-dd').format(now);

      for (var product in products) {
        final String totalAmount = product['price'];

        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode({
            'customer_id': customerId,
            'product_name': product['name'],
            'order_date': orderDate,
            'total_amount': totalAmount,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print('Checkout successful for ${product['name']}');
          // Show Snackbar for successful order
          showOrderSuccessSnackbar();
          // Delete product from cart after successful checkout
          deleteProduct(product['product_id']);
        } else {
          print('Failed to checkout for ${product['name']}');
        }
      }

      // Refresh the screen after successful checkout
      _reloadProducts();
    } else {
      print('Customer ID not found');
    }
  }

  void showOrderSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item ordered successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showDeleteSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('deleted successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        automaticallyImplyLeading: false,
      ),
      body: products.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 20),
              ),
            )
          : RefreshIndicator(
              onRefresh: _reloadProducts,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final imageUrl = baseUrl + product['product_image'];
                  final productId = int.tryParse(product['product_id'] ?? '');
                  return ListTile(
                    leading: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(product['name'] ?? 'No Name'),
                    subtitle: Text('\$${product['price'] ?? 'No Price'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (productId != null) {
                          print('Deleting product ID: $productId');
                          deleteProduct(productId);
                          showDeleteSuccessSnackbar(
                              context); // Call the method to show Snackbar
                        } else {
                          print('Product ID is null');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: SizedBox(
        width: screenWidth * 0.4,
        child: ElevatedButton.icon(
          onPressed: () {
            checkout();
          },
          label: Text(
            'Check out (\$$totalPrice)',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(218, 0, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}
