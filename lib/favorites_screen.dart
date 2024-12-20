import 'package:flutter/material.dart';
import 'favorite_notifier.dart';
import 'product_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoriteNotifier favoriteNotifier;

  FavoritesScreen({required this.favoriteNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 4,
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: favoriteNotifier,
        builder: (context, favoriteIds, child) {
          if (favoriteIds.isEmpty) {
            return Center(
              child: Text('Нет избранных',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            );
          }

          return FutureBuilder(
            future: Supabase.instance.client.from('products').select(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final products = (snapshot.data as List<dynamic>)
                  .map((e) => e as Map<String, dynamic>)
                  .toList();

              final favoriteProducts = products.where((product) {
                return favoriteIds.contains(product['id'].toString());
              }).toList();

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  final isFavorite =
                      favoriteNotifier.isFavorite(product['id'].toString());

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(product['image']),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(product['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${product['calories']} Каллорий'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          favoriteNotifier
                              .toggleFavorite(product['id'].toString());
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: product,
                              favoriteNotifier: favoriteNotifier,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
