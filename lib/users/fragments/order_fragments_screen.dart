import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderFragmentScreen extends StatefulWidget {
  const OrderFragmentScreen({Key? key}) : super(key: key);

  @override
  _OrderFragmentScreenState createState() => _OrderFragmentScreenState();
}

class _OrderFragmentScreenState extends State<OrderFragmentScreen> {
  late Future<List<dynamic>> _dataFuture;
  final String baseUrl = 'https://femoral-pushdown.000webhostapp.com/img/';

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? customerId = prefs.getInt('customer_id');
    if (customerId == null) {
      throw Exception('Customer ID not found');
    }

    final response = await http.get(Uri.parse(
        'https://femoral-pushdown.000webhostapp.com/-flutter/products/orders_screen.php?customer_id=$customerId'));
    if (response.statusCode == 200) {
      print('API Response Body: ${response.body}');
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Lists'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final imageUrl = baseUrl + item['product_image'];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(
                      item['product_name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('\$${item['total_amount'] ?? 'No Price'}'),
                    onTap: () {
                      // Add any onTap functionality here if needed
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
