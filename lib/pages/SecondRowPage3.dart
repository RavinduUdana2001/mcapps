import 'package:flutter/material.dart';

class SecondRowPage3 extends StatelessWidget {
  const SecondRowPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Row Page 3')),
      body: const Center(
        child: Text('You are on Page 3 of the Second Row', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
