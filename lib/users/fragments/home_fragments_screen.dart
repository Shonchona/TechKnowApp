// ignore_for_file: unused_import, non_constant_identifier_names
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:techknow/users/fragments/cart_screen.dart' as model;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:techknow/users/fragments/product-detail_screen.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeFragmentScreen(),
  ));
}

class HomeFragmentScreen extends StatefulWidget {
  const HomeFragmentScreen({Key? key});

  @override
  State<HomeFragmentScreen> createState() => _HomeFragmentScreen();
}

class _HomeFragmentScreen extends State<HomeFragmentScreen> {
  List<Product> products = [];
  ScrollController _scrollController = ScrollController();
  bool _showWidget = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_showWidget) {
          setState(() {
            _showWidget = true;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_showWidget) {
          setState(() {
            _showWidget = false;
          });
        }
      }
    });
    fetchAllProducts().then((fetchedProducts) {
      setState(() {
        products = fetchedProducts.map((productData) {
          return Product(
            product_id: productData['product_id'],
            name: productData['product_name'],
            price: productData['price'],
            imageUrl:
                'http://femoral-pushdown.000webhostapp.com/img/${productData['product_image']}',
            description: productData['description'],
          );
        }).toList();
      });
    }).catchError((error) {
      print('Error fetching products: $error');
    });
  }

  Future<void> _reloadProducts() async {
    final fetchedProducts = await fetchAllProducts();
    setState(() {
      products = fetchedProducts.map((productData) {
        return Product(
          product_id: productData['product_id'],
          name: productData['product_name'],
          price: productData['price'],
          imageUrl:
              'http://femoral-pushdown.000webhostapp.com/img/${productData['product_image']}',
          description: productData['description'],
        );
      }).toList();
    });
  }

  Future<List<dynamic>> fetchAllProducts() async {
    final response = await http.get(Uri.parse(
        'http://femoral-pushdown.000webhostapp.com/-flutter/products/products.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  List<String> categories = [
    'Laptops',
    'Smartwatches',
    'Cellphones',
    'Cameras',
    'Headphones',
  ];

  void _onProductTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: products[index],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 204, 202, 202),
        title: const Text('TechKnow'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _reloadProducts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 150,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                  ),
                  items: [
                    'https://femoral-pushdown.000webhostapp.com/img/cards/1.jpg',
                    'https://femoral-pushdown.000webhostapp.com/img/cards/2.jpg',
                    'https://femoral-pushdown.000webhostapp.com/img/cards/3.jpg',
                  ].map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 7.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[200],
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(categories[index],
                            style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'All Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return GestureDetector(
                      onTap: () => _onProductTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                child: Image.network(
                                  products[index].imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              products[index].name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'PHP: ${products[index].price}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String product_id;
  final String name;
  final String price;
  final String imageUrl;
  String description;

  Product({
    required this.product_id,
    required this.description,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
