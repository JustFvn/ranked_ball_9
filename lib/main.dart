import 'package:flutter/material.dart';

void main() {
  runApp(const RankedBallApp());
}

class RankedBallApp extends StatelessWidget {
  const RankedBallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranked Ball Game',
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Ranked Ball Game 起始畫面',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
