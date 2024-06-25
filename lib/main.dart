import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.deepPurple),
      title: 'Flutter Demo',
      home: const ProductList(title: 'Product List'),
    );
  }
}

class ProductList extends StatefulWidget {
  final String title;

  const ProductList({super.key, required this.title});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // A query to filter the products
  String query = "";

  // A text controller to handle the text field input
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // A function to render the list of products
    Widget renderListView(List products) {
      return ListView(
        children: [
          ...products
              .map((e) => Card(
                  color: Theme.of(context).primaryColor,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: const LinearBorder(),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            e['title'],
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16),
                          )))))
              .toList()
        ],
      );
    }

    // The main scaffold of the product list screen
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // A future builder to fetch the products asynchronously or show a loading indicator
              child: FutureBuilder(
                future: fetchProducts(query),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while fetching the products
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    // Render the list of products once the data is fetched
                    return renderListView(snapshot.data as List);
                  } else {
                    // Return a message if the connection state is not waiting or done
                    return const Center(child: Text("No products were found."));
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (text) {
                setState(() => query = text);
              },
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type here to search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<List> fetchProducts(String query) async {
  final url = Uri.parse('https://dummyjson.com/products/search?q=$query');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    return jsonResponse['products'];
  } else {
    print('Failed to fetch products. Status code: ${response.statusCode}');
    return [];
  }
}

// documentation: https://dummyjson.com/docs/products
