import 'package:flutter/material.dart';
import '../models/quick_access_item.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final quickAccessItems =
        ModalRoute.of(context)!.settings.arguments as List<QuickAccessItem>;

    return Scaffold(
      appBar: AppBar(title: const Text('All Quick Access Items')),
      body: ListView.builder(
        itemCount: quickAccessItems.length,
        itemBuilder: (context, index) {
          final item = quickAccessItems[index];
          return ListTile(
            leading: Image.network(item.icon, width: 30, height: 30),
            title: Text(item.name),
          );
        },
      ),
    );
  }
}
