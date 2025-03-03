import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageItemsPage extends StatefulWidget {
  const ManageItemsPage({super.key});

  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  List<Map<String, String>> quickAccessItems = [];

  @override
  void initState() {
    super.initState();
    loadQuickAccessItems();
  }

  // Load items from SharedPreferences
  Future<void> loadQuickAccessItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('quickAccessItems');
    setState(() {
      quickAccessItems = data != null
          ? List<Map<String, String>>.from((json.decode(data) as List)
              .map((item) => Map<String, String>.from(item as Map<String, dynamic>)))
          : [];
    });
  }

  // Save items to SharedPreferences
  Future<void> saveQuickAccessItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('quickAccessItems', json.encode(quickAccessItems));
  }

  // Add a new item
  void addItem(String name, String icon, String url) {
    setState(() {
      quickAccessItems.add({'name': name, 'icon': icon, 'url': url});
      saveQuickAccessItems();
    });
  }

  // Delete an item
  void deleteItem(int index) {
    setState(() {
      quickAccessItems.removeAt(index);
      saveQuickAccessItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    final urlController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Items')),
      body: Column(
        children: [
          // Form to add a new item
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(labelText: 'Icon URL'),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        iconController.text.isNotEmpty &&
                        urlController.text.isNotEmpty) {
                      addItem(
                        nameController.text,
                        iconController.text,
                        urlController.text,
                      );
                      nameController.clear();
                      iconController.clear();
                      urlController.clear();
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List of items
          Expanded(
            child: ListView.builder(
              itemCount: quickAccessItems.length,
              itemBuilder: (context, index) {
                final item = quickAccessItems[index];
                return ListTile(
                  leading: Image.network(item['icon']!, width: 40, height: 40),
                  title: Text(item['name']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
