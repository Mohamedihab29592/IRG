import 'package:flutter/material.dart';

import '../widgets/incident_report_page.dart';

class SplashScreen extends StatefulWidget {
   SplashScreen({super.key, });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>  IncidentReportForm(), // Replace with your target screen
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/vf logo.png", height: 200,),
          SizedBox(height: 10,),
          Text("Corporate Security",
            style: TextStyle(fontSize: 25, color: Colors.white),),
        ],
      ),
    )),);

  }
}
