import 'package:flutter/material.dart';

class NewFunctionsPage extends StatelessWidget {
  final List<Map<String, String>> quickAccessItems;

  const NewFunctionsPage({super.key, required this.quickAccessItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Items')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Page
              },
              child: const Text('Add Items'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Delete Page
              },
              child: const Text('Delete Items'),
            ),
          ],
        ),
      ),
    );
  }
}
