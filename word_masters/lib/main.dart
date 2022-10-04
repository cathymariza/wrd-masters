import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word_masters/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Masters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Word Masters'),
    );
  }
}

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
  void dispose() {
    super.dispose();
    _controller.dispose();
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
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  child: Transform.scale(
                    scale: _scale,
                    child: Button(
                      start: const Color(0xFF2EB62C),
                      end: const Color(0xFF2EB62C),
                      name: 'Easy',
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                child: Transform.scale(
                  scale: _scale,
                  child: Button(
                    start: const Color(0xFFFFEA61),
                    end: const Color(0xFFFFEA61),
                    name: 'Medium',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  chooseWord("hard");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WordScreen(
                              key: Key("Word Screen"),
                            )),
                  );
                },
                child: Transform.scale(
                  scale: _scale,
                  child: Button(
                    start: const Color(0xFF2DC1C13),
                    end: const Color(0xFFDC1C13),
                    name: 'Hard',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const WordScreen(
                key: Key("Word Screen"),
              )),
    );
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  String chooseWord(String diff) {
    File('$diff.txt').readAsString().then((String contents) {
      print(contents);
    });
    return "hello";
  }
}

class WordScreen extends StatefulWidget {
  const WordScreen({Key? key}) : super(key: key);

  @override
  _WordScreenState createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is the second screen"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(30),
          child: Column(children: const [
            Text(
              "Does this thing work",
              style: TextStyle(fontSize: 30),
            )
          ])),
    );
  }
}
