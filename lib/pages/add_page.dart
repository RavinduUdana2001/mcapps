import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddModal extends StatefulWidget {
  final List<Map<String, String>> quickAccessItems;
  final List<Map<String, String>> availableItems;

  const AddModal({super.key, required this.quickAccessItems, required this.availableItems});

  @override
  _AddModalState createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quick Access Icon'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an icon to add to Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: widget.availableItems.length,
                itemBuilder: (context, index) {
                  final item = widget.availableItems[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.quickAccessItems.add(item);
                        widget.availableItems.removeAt(index);
                      });
                      saveQuickAccessItems();
                      Navigator.pop(context);  // Close the AddModal
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(item['icon']!),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveQuickAccessItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('quickAccessItems', json.encode(widget.quickAccessItems));
  }
}
