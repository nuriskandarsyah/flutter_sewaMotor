import 'package:flutter/material.dart';
import 'sewa_motor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sewa Motor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SewaMotorPage(), // Halaman utama aplikasi
    );
  }
}
