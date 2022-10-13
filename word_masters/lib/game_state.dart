import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'friends_data.dart';

class gameBoard {
  String? guess;
  String word;
  Friend friend;
  List words;
  int turn = 1;
  int turns = 0;

  gameBoard({required this.word, required this.words, required this.friend});

// https://stackoverflow.com/questions/60239587/how-can-i-read-text-from-files-and-display-them-as-list-using-widget-s-in-flutte

}
