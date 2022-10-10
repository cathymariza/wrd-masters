import 'dart:io';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

const int ourPort = 8888;
final m = Mutex();

class Friends extends Iterable<String> {
  Map<String, Friend> _names2Friends = {};
  Map<String, Friend> _ips2Friends = {};

  void add(String name, String ip) {
    Friend f = Friend(ipAddr: ip, name: name);
    _names2Friends[name] = f;
    _ips2Friends[ip] = f;
  }

  String? ipAddr(String? name) => _names2Friends[name]?.ipAddr;

  Friend? getFriend(String? name) => _names2Friends[name];

  void receiveFrom(String ip, String message, String word) {
    print("receiveFrom($ip, $message)");
    if (!_ips2Friends.containsKey(ip)) {
      String newFriend = "Friend${_ips2Friends.length}";
      print("Adding new friend");
      add(newFriend, ip);
      print("added $newFriend!");
    }
    _ips2Friends[ip]!.receive(message, word);
  }

  @override
  Iterator<String> get iterator => _names2Friends.keys.iterator;
}

class Friend extends ChangeNotifier {
  final String ipAddr;
  final String name;
  final List<Message> _messages = [];
  Message test = Message(author: "", content: "", word: "");

  Friend({required this.ipAddr, required this.name});

  Future<void> send(String message, String word) async {
    Socket socket = await Socket.connect(ipAddr, ourPort);
    socket.write(message);
    socket.close();
    test = Message(author: "Me", content: message, word: word);
    await _add_message(
      "Me",
      message,
      word,
    );
  }

  Future<void> receive(String message, String word) async {
    return _add_message(name, message, word);
  }

  Future<void> _add_message(String name, String message, String word) async {
    await m.protect(() async {
      test = Message(author: name, content: message, word: word);
      //_messages.add(Message(author: name, content: message));
      notifyListeners();
    });
  }

  String history() => _messages
      .map((m) => m.transcript)
      .fold("", (message, line) => message + '\n' + line);

  String getWord() => test.word;

  Widget bullsAndCows() {
    bool is_me = test.author == "Me";
    return Text(
      test.content,
      style: TextStyle(color: is_me ? Color(0xffffffff) : Color(0xFF1B87F3)),
    );
  }
}

class Message {
  final String content;
  final String author;
  final String word;

  Message({
    required this.author,
    required this.content,
    required this.word,
  });

  String get transcript => '$author: $content : $word';
}
