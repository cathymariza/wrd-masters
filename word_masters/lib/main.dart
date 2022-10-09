import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:word_masters/button.dart';
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
                    List words = await _wordList();
                    gamePageNav(word, words);
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
                  List words = await _wordList();
                  gamePageNav(word, words);
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
                  List words = await _wordList();
                  gamePageNav(word, words);
                },
                child: Transform.scale(
                  scale: _scale,
                  child: Button(
                    start: const Color(0xFFDC1C13),
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

  void gamePageNav(String word, List words) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordScreen(
              key: const Key("Word Screen"), word: word, words: words)),
    );
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

  Future<List> _wordList() async {
    var words = [];
    await rootBundle.loadString('assets/english3.txt').then((q) {
      for (String i in const LineSplitter().convert(q)) {
        words.add(i);
      }
    });
    //print(words);
    return words; // i just really want this word list
  }
}

class WordScreen extends StatefulWidget {
  WordScreen({Key? key, required this.word, required this.words})
      : super(key: key);

  String word;
  List words;

  @override
  _WordScreenState createState() => _WordScreenState(word, words);
}

// add a field that requires a word to passed to create this screen
class _WordScreenState extends State<WordScreen> {
  _WordScreenState(this.word, this.words);
  String word;
  List words;

  // ALSO I ADDED THIS
  final _entryForm = GlobalKey<FormState>(); // for validator

  // i just want the dictionary to check validation -- currently not working
  Future<List> _wordList() async {
    var words = [];
    await rootBundle.loadString('assets/english3.txt').then((q) {
      for (String i in const LineSplitter().convert(q)) {
        words.add(i);
      }
    });
    //print(words);
    return words; // i just really want this word list
  } // AND THIS

  @override
  Widget build(BuildContext context) {
    //var words = await _wordList();
    return Scaffold(
      appBar: AppBar(
        title: Text("This is the second screen"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            Text(
              "$word",
              style: TextStyle(fontSize: 30),
            ),

            //// EVERYTHING i ADDED STARTS HERE
            Form(
              key: _entryForm,
              child: TextFormField(
                key: const Key('formKey'),
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter Guess'),
                validator: (inputValue) {
                  if (inputValue == word) {
                    return "woohoo!";
                  }
                  if (inputValue == null || inputValue.isEmpty) {
                    return 'Please enter a guess';
                  }
                  //bulls and cows portion
                  if (words.contains(inputValue)) {
                    // save list of letters in word
                    // check letters in inputValue agaisnt word
                    // hard part of knowing if it is in the rigth location
                    int bulls = 0;
                    int cows = 0;
                    for (int i = 0; i < inputValue.length; i++) {
                      if (word[i] == inputValue[i]) {
                        bulls += 1;
                      } else {
                        if (word.contains(inputValue[i])) {
                          cows += 1;
                        }
                      }
                    }

                    return "Cows: $cows, bulls: $bulls";
                  }

                  if (inputValue.length != word.length) {
                    return "word length doesn't match";
                  } else {
                    return "not a valid word, try again";
                  }
                },
              ),
            ),
            //this button validates submitted answer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_entryForm.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Guess')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ])),
    );
  }
}
