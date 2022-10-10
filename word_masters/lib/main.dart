import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:word_masters/button.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:word_masters/friends_data.dart';
import 'package:network_info_plus/network_info_plus.dart';
import "package:word_masters/text_widgets.dart";

import 'list_items.dart';

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
      theme: ThemeData(primarySwatch: Colors.green),
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
                    String word = await _chooseWord("easy");
                    List words = await _wordList();
                    friendPageNav(word, words);
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
                  String word = await _chooseWord("medium");
                  List words = await _wordList();
                  friendPageNav(word, words);
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
                  String word = await _chooseWord("hard");
                  List words = await _wordList();
                  friendPageNav(word, words);
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

  void friendPageNav(String word, List words) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => friendScreen(
              key: const Key("Word Screen"),
              title: "Friends!",
              word: word,
              words: words)),
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

// ignore: camel_case_types
class friendScreen extends StatefulWidget {
  const friendScreen(
      {super.key,
      required this.title,
      required this.word,
      required this.words});
  final String word;
  final List words;
  final String title;

  @override
  State<friendScreen> createState() => friendScreenState();
}

// ignore: camel_case_types
class friendScreenState extends State<friendScreen> {
  String? _ipaddress = "Loading...";
  late Friends _friends;
  late List<DropdownMenuItem<String>> _friendList;
  late TextEditingController _nameController, _ipController;
  var turn = 0;
  @override
  void initState() {
    super.initState();
    _friends = Friends();
    _friends.add("Self", "127.0.0.1");
    _nameController = TextEditingController();
    _ipController = TextEditingController();
    _setupServer();
    _findIPAddress();
  }

  Future<void> _findIPAddress() async {
    // Thank you https://stackoverflow.com/questions/52411168/how-to-get-device-ip-in-dart-flutter
    String? ip = await NetworkInfo().getWifiIP();
    setState(() {
      _ipaddress = "My IP: " + ip!;
    });
  }

  Future<void> _setupServer() async {
    try {
      ServerSocket server =
          await ServerSocket.bind(InternetAddress.anyIPv4, ourPort);
      server.listen(_listenToSocket); // StreamSubscription<Socket>
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }

  void _listenToSocket(Socket socket) {
    socket.listen((data) {
      setState(() {
        _handleIncomingMessage(socket.remoteAddress.address, data);
      });
    });
  }

  void _handleIncomingMessage(String ip, Uint8List incomingData) {
    String received = String.fromCharCodes(incomingData);
    print("Received '$received' from '$ip'");
    _friends.receiveFrom(ip, received, widget.word);
    //turn += 1;
  }

  void addNew() {
    setState(() {
      _friends.add(_nameController.text, _ipController.text);
    });
  }

  final ButtonStyle yesStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), backgroundColor: Colors.green);
  final ButtonStyle noStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), backgroundColor: Colors.red);

  Future<void> _displayTextInputDialog(BuildContext context) async {
    print("Loading Dialog");
    _nameController.text = "";
    _ipController.text = "";
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add A Friend'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextEntry(
                    width: 200,
                    label: "Name",
                    inType: TextInputType.text,
                    controller: _nameController),
                TextEntry(
                    width: 200,
                    label: "IP Address",
                    inType: TextInputType.number,
                    controller: _ipController),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                key: const Key("CancelButton"),
                style: noStyle,
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                key: const Key("OKButton"),
                style: yesStyle,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    addNew();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _handleChat(Friend friend, String word) async {
    print("Chat");
    gamePageNav(widget.word, widget.words, friend);
  }

  void _handleEditFriend(Friend friend) {
    setState(() {
      print("Edit");
    });
  }

  void gamePageNav(String word, List words, Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordScreen(
                key: const Key("Word Screen"),
                word: word,
                words: words,
                friend: friend,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: _friends.map((name) {
            return FriendListItem(
                friend: _friends.getFriend(name)!,
                onListTapped: _handleChat,
                onListEdited: _handleEditFriend,
                word: widget.word);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
              width: double.infinity,
              child: Text(
                _ipaddress!,
                textAlign: TextAlign.center,
              ))),
    );
  }
}

class WordScreen extends StatefulWidget {
  WordScreen({Key? key, required this.word, required this.words, this.friend})
      : super(key: key);

  final Friend? friend;
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
  var turn = 0;

  // ALSO I ADDED THIS
  final _entryForm = GlobalKey<FormState>(); // for validator

  @override
  void initState() {
    super.initState();
    widget.friend!.addListener(update);
  }

  @override
  void dispose() {
    widget.friend!.removeListener(update);
    print("Goodbye");
    super.dispose();
  }

  void update() {
    print("New message!");
    setState(() {});
  }

  Future<void> send(String msg, String word) async {
    await widget.friend!.send(msg, word).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    var result = "";

    //word = widget.friend!.getWord();
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Masters"),
        backgroundColor: Colors.green,
      ),
      body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            // Text(
            //   word,
            //   style: TextStyle(fontSize: 30),
            // ),

            //// EVERYTHING i ADDED STARTS HERE
            Form(
              key: _entryForm,
              child: TextFormField(
                key: const Key('formKey'),
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter Guess'),
                validator: (inputValue) {
                  if (inputValue == word) {
                    return "Woohoo, you are correct!";
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
                    result = "Cows: $cows, bulls: $bulls";
                    return result;
                  }

                  if (inputValue.length != word.length) {
                    result = "word length doesn't match";
                    return result;
                  } else {
                    result = "not a valid word, try again";
                    return result;
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
                  send(result, word);
                },
                child: const Text('Submit'),
              ),
            ),
            widget.friend!.bullsAndCows()
          ])),
    );
  }
}
