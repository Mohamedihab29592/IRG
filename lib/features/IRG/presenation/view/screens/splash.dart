import 'package:flutter/material.dart';

import '../widgets/incident_report_page.dart';
import 'incident_report_form.dart';

class SplashScreen extends StatefulWidget {
  bool isError ;
   SplashScreen({super.key, this.isError = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Only navigate if isError is false
    if (!widget.isError) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  IncidentReportForm(), // Replace with your target screen
          ),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (widget.isError)
      {
        return Scaffold(body: Center(child: Container(
          color: Colors.black,
          width: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/vf logo.png", height: 200,),
              SizedBox(height: 10,),
              Text("Something went wrong",
                style: TextStyle(fontSize: 25, color: Colors.white),),
            ],
          ),
        )),);
      }
    else {
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
}
