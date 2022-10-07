import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_masters/button.dart';
import 'package:path/path.dart' as path;
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

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
                  onTap: () async {
                    String word = await _chooseWord("easy");
                    gamePageNav(word);
                    print(word);
                  },
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
                onTap: () async {
                  String word = await _chooseWord("medium");
                  gamePageNav(word);
                  print(word);
                },
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
                onTap: () async {
                  String word = await _chooseWord("hard");
                  gamePageNav(word);
                  print(word);
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

  void gamePageNav(String word) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendScreen(
                key: const Key("Friend Screen"),
                title: "Welcome",
              )),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => const WordScreen(
    //             key: Key("Word Screen"),
    //           )),
    // );
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  // https://stackoverflow.com/questions/60239587/how-can-i-read-text-from-files-and-display-them-as-list-using-widget-s-in-flutte
  Future<String> _chooseWord(String diff) async {
    List<String> words = [];
    var rand = new Random();

    await rootBundle.loadString('assets/$diff.txt').then((q) {
      for (String i in LineSplitter().convert(q)) {
        words.add(i);
      }
    });
    var word = words[rand.nextInt(words.length)];
    print(word);
    print(word.runtimeType);

    return word;
  }
}

class WordScreen extends StatefulWidget {
  WordScreen({Key? key, required this.word}) : super(key: key);

  String word;

  @override
  _WordScreenState createState() => _WordScreenState(word);
}

// add a field that requires a word to passed to create this screen
class _WordScreenState extends State<WordScreen> {
  _WordScreenState(this.word);
  String word;

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
          child: Column(children: [
            Text(
              "$word",
              style: TextStyle(fontSize: 30),
            )
          ])),
    );
  }
}
class FriendScreen extends StatefulWidget {
  FriendScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _FriendScreenState createState() => _FriendScreenState(title);
}

// add a field that requires a word to passed to create this screen
class _FriendScreenState extends State<FriendScreen> {
  _FriendScreenState(this.title);
  String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is the second screen"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(30),
          child: Column(children: [
            Text(
              "Hi",
              style: TextStyle(fontSize: 30),
            )
          ])),
    );
  }
}
