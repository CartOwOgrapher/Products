import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_list_screen.dart';
import 'favorite_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pyyqqtivgnzijjbqviig.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5eXFxdGl2Z256aWpqYnF2aWlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MDM0NzYsImV4cCI6MjA1MDE3OTQ3Nn0.yUHYQcXHaQYZropHMsX2kZbltkIEA_6ZfaJ3arNE7wk',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FavoriteNotifier favoriteNotifier = FavoriteNotifier();

  MyApp() {
    favoriteNotifier.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Помошник при диете',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(favoriteNotifier: favoriteNotifier),
    );
  }
}
