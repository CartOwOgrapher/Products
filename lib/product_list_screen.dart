import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'favorite_notifier.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';

class ProductListScreen extends StatefulWidget {
  final FavoriteNotifier favoriteNotifier;

  ProductListScreen({required this.favoriteNotifier});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;

  final List<String> categories = [
    "Все",
    "Фастфуд",
    "Здоровое питание",
    "Десерты",
    "Напитки",
    "Снэки"
  ];
  String selectedCategory = "Все";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await supabase.from('products').select();
      setState(() {
        products = (response as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        filteredProducts = products;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "Все") {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          List<String> productCategories =
              product['categories'].toString().split(', ');
          return productCategories.contains(category);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Помошник при диете',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Категория: $selectedCategory',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    favoriteNotifier: widget.favoriteNotifier,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (category) => filterProducts(category),
            itemBuilder: (context) {
              return categories.map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList();
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<String>>(
              valueListenable: widget.favoriteNotifier,
              builder: (context, favoriteIds, child) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isFavorite =
                        favoriteIds.contains(product['id'].toString());

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(product['image']),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(product['name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${product['calories']} Каллорий'),
                        trailing: GestureDetector(
                          onTap: () {
                            widget.favoriteNotifier
                                .toggleFavorite(product['id'].toString());
                          },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                              key: ValueKey<bool>(isFavorite),
                            ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                                favoriteNotifier: widget.favoriteNotifier,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
