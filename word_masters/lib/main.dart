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
import 'package:word_masters/game_state.dart';
import "package:word_masters/text_widgets.dart";
import "package:word_masters/home_page.dart";
import 'package:word_masters/word_screen.dart';

import 'game_list.dart';

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

// ignore: camel_case_types
class friendScreen extends StatefulWidget {
  const friendScreen({super.key, required this.title, required this.diff});

  final String diff;
  final String title;

  @override
  State<friendScreen> createState() => friendScreenState();
}

// ignore: camel_case_types
class friendScreenState extends State<friendScreen> {
  String? _ipaddress = "Loading...";
  late Friends _friends;
  late String word;
  late List words;
  late List<DropdownMenuItem<String>> _friendList;
  late TextEditingController _nameController, _ipController;
  late Map<String, gameBoard> games;

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
    games = {};
    games.addAll({
      "127.0.0.1": gameBoard(
          word: "test",
          words: ["test", "torn", "forn"],
          friend: _friends.getFriendWithIP("127.0.0.1"))
    });
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
    if (games.containsKey(ip)) {
      games[ip]?.guess = received;
    } else {
      _friends.add("Friend", ip);
      games.addAll({
        ip: gameBoard(
            friend: _friends.getFriendWithIP(ip)!, words: words, word: word)
      });
    }
    //turn += 1;
  }

  Future<String> _chooseWord(String diff) async {
    List<String> words = [];
    var rand = Random();

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

    return words;
  }

  Future<void> addNew() async {
    word = await _chooseWord(widget.diff);
    words = await _wordList();
    setState(() {
      String ip = _ipController.text;
      _friends.add(_nameController.text, ip);
      games.addAll({
        ip: gameBoard(
            friend: _friends.getFriendWithIP(ip)!, words: words, word: word)
      });
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

  Future<void> _handleListTap(gameBoard game) async {
    gamePageNav(game);
  }

  void _handleEditFriend(Friend friend) {
    setState(() {
      print("Edit");
    });
  }

  void gamePageNav(game) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordScreen(
                key: const Key("Word Screen"),
                game: game,
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
        child: (games.isEmpty)
            ? const Padding(
                padding: EdgeInsets.all(5),
                child: Text('Press + to add a friend!'),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: games.entries.map((game) {
                  return Card(
                    child: ListTile(
                      title: const Text("Bulls and Cows"),
                      subtitle: Text("Turns taken ${game.value.turns}"),
                      onTap: () {
                        _handleListTap(game.value);
                      },
                    ),
                  );
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
