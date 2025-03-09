import 'package:flutter/material.dart';

class Button extends StatelessWidget {
 final void Function()? onPressed;
 final String title;
 final IconData icon;
  const Button({super.key,required this.onPressed, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return   SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Color(0xFFD32F2F)),
        ),
        onPressed: onPressed ,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              SizedBox(width: 8.0),
              Text(
                title,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
