import 'package:flutter/material.dart';

class DeductPage extends StatelessWidget {
  const DeductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deduct'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(child: Text('This is the Deduct page')),
    );
  }
}
