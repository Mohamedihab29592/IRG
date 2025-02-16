import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  bool isError ;
   SplashScreen({super.key, this.isError = false});

  @override
  Widget build(BuildContext context) {
    if (isError)
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
