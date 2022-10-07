import 'package:flutter/material.dart';

// Button code from https://github.com/sagarshende23/bouncing_button_flutter
class Button extends StatelessWidget {
  const Button(
      {Key? key, required this.start, required this.end, required this.name})
      : super(key: key);

  final Color start;
  final Color end;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 200,
      decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 30.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          )),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
              fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
