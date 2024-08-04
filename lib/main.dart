import 'package:IRG/view/screens/home_page.dart';
import 'package:flutter/material.dart';



void main() {


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey[400],appBarTheme: AppBarTheme(color: Colors.grey[400],titleTextStyle: TextStyle(color: Colors.black,fontSize: 25))),
      debugShowCheckedModeBanner: false,

      home:  MyHomePage(),
    );
  }
}


