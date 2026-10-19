import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multiavatar/multiavatar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiAvatar exemple',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'MultiAvatar Exemple'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                ///The svg code
                log(multiavatar(DateTime.now().toIso8601String()));
                setState(() {
                  _controller.text = multiavatar(
                    DateTime.now().toIso8601String(),
                  );
                });
              },
              tooltip: 'Generate',
              child: Icon(Icons.gesture),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
              ),
              maxLines: 20,
            ),
          ],
        ),
      ),
    );
  }
}
