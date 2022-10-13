import 'package:flutter/material.dart';
import 'package:word_masters/main.dart';
import 'button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;
  late String word;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "What difficulty would you like?",
                  style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )),
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 150),
                child: GestureDetector(
                  onTap: () async {
                    friendPageNav("easy");
                  },
                  child: Transform.scale(
                    scale: _scale,
                    child: const Button(
                      start: Color(0xFF2EB62C),
                      end: Color(0xFF2EB62C),
                      name: 'Easy',
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  friendPageNav("medium");
                },
                child: Transform.scale(
                  scale: _scale,
                  child: const Button(
                    start: Color(0xFFFFEA61),
                    end: Color(0xFFFFEA61),
                    name: 'Medium',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  friendPageNav("hard");
                },
                child: Transform.scale(
                  scale: _scale,
                  child: const Button(
                    start: Color(0xFFDC1C13),
                    end: Color(0xFFDC1C13),
                    name: 'Hard',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void friendPageNav(String diff) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => friendScreen(
              key: const Key("Word Screen"), title: "Friends!", diff: diff)),
    );
  }
}
