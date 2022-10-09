import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:word_masters/button.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:path/path.dart' as path;
import 'dart:async' show Future, StreamSubscription;
import 'package:flutter/services.dart' show rootBundle;
import 'list_items.dart';
import 'package:word_masters/friends_data.dart';
import 'package:word_masters/text_widgets.dart';

import 'chat.dart';

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
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Word Masters'),*/
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Networking Demo'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  String? _ipaddress = "Loading...";
  late StreamSubscription<Socket> server_sub;
  late Friends _friends;
  late List<DropdownMenuItem<String>> _friendList;
  late TextEditingController _nameController, _ipController;

  
  void initState() {
    super.initState();
    _friends = Friends();
    _friends.add("Self", "127.0.0.1");
    _nameController = TextEditingController();
    _ipController = TextEditingController();
    _setupServer();
    _findIPAddress();
  }

  void dispose() {
    server_sub.cancel();
    super.dispose();
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
      server_sub = server.listen(_listenToSocket); // StreamSubscription<Socket>
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
    _friends.receiveFrom(ip, received);
  }

  void addNew() {
    setState(() {
      _friends.add(_nameController.text, _ipController.text);
    });
  }

  final ButtonStyle yesStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), /*backgroundColor: Colors.green)*/);
  final ButtonStyle noStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), /*backgroundColor: Colors.red*/);

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

  Future<void> _handleChat(Friend friend) async {
    print("Chat");
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(friend: friend),
      ),
    );
  }

  void _handleEditFriend(Friend friend) {
    setState(() {
      print("Edit");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: ElevatedButton(
              child: const Text("Start"),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => LevelScreen(title: "Welcome"))
                  );
              },
              )
            /*child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: _friends.map((name) {
                return FriendListItem(
                  friend: _friends.getFriend(name)!,
                  onListTapped: _handleChat,
                  onListEdited: _handleEditFriend,
                );*/
        
        )
            /*floatingActionButton: FloatingActionButton(
                onPressed: () {
                _displayTextInputDialog(context);
                tooltip: 'Add Friend',
            child: const Icon(Icons.add),*/
          
        /*/bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
              width: double.infinity,
              child: Text(
                _ipaddress!,
                textAlign: TextAlign.center,
              )));*/
  
            
    ]));
       
      
  }
  }


class LevelScreen extends StatefulWidget{
  LevelScreen({super.key, required this.title});

  final String title;

  @override
  //_LevelScreenState createState() => _LevelScreenState();
  _LevelScreenState createState() => _LevelScreenState();
}


class _LevelScreenState extends State<LevelScreen>
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
        backgroundColor: Colors.redAccent,
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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();

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
    print(words);
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
                  if (words.contains(inputValue)) {
                    return "good guess but not the right word";
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