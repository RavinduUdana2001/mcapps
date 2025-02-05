import 'package:flutter/material.dart';

class DeletePage extends StatelessWidget {
  final List<Map<String, String>> quickAccessItems;
  final List<Map<String, String>> availableItems;

  const DeletePage({super.key, required this.quickAccessItems, required this.availableItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Quick Access Item'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: quickAccessItems.length,
        itemBuilder: (context, index) {
          final item = quickAccessItems[index];
          return ListTile(
            title: Text(item['name']!),
            leading: Image.network(item['icon']!, width: 40, height: 40),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                availableItems.add(item);  // Add item back to available list
                quickAccessItems.removeAt(index);  // Remove from selected list
                Navigator.pop(context, {'quickAccess': quickAccessItems, 'availableItems': availableItems});
              },
            ),
          );
        },
      ),
    );
  }
}
