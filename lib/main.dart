import 'package:flutter/material.dart';

void main() {
  runApp(const HomeLoopApp());
}

class HomeLoopApp extends StatelessWidget {
  const HomeLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('HomeLoop'))),
    );
  }
}
