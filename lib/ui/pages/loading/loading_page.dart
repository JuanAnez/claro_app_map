import 'package:flutter/material.dart';
import 'package:icc_maps/ui/pages/home/home_page.dart';
// import 'package:icc_maps/ui/pages/map/map_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICC Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(
        username: '',
        password: '',
      ),
    );
  }
}
