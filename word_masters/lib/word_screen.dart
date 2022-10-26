import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word_masters/game_state.dart';
import 'friends_data.dart';

class WordScreen extends StatefulWidget {
  WordScreen({Key? key, this.game, this.words, this.guess}) : super(key: key);

  final gameBoard? game;
  final words;
  final guess;
  @override
  _WordScreenState createState() => _WordScreenState();
}

// add a field that requires a word to passed to create this screen
class _WordScreenState extends State<WordScreen> {
  _WordScreenState();
  bool turn = true;
  Timer? timer;

  // ALSO I ADDED THIS
  final _entryForm = GlobalKey<FormState>(); // for validator
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget bullsAndCows() {
    if (widget.guess != "") {
      return Text("Opponents last guess : ${widget.guess}");
    } else {
      return const Text("");
    }
  }

  Widget results(String results) {
    return Text(results);
  }

  void friendsPage() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var result = "";
    var screenResult = "";

    //word = widget.friend!.getWord();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Masters"),
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
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter Guess'),
                validator: (inputValue) {
                  if (inputValue == widget.game?.word) {
                    return "The word was ${widget.game!.word}, Woohoo, you are correct!";
                  }
                  if (inputValue == null || inputValue.isEmpty) {
                    return '${widget.game!.word};Please enter a guess';
                  }
                  //bulls and cows portion
                  if (widget.words.contains(inputValue)) {
                    // save list of letters in word
                    // check letters in inputValue agaisnt word
                    // hard part of knowing if it is in the rigth location
                    int bulls = 0;
                    int cows = 0;
                    for (int i = 0; i < inputValue.length; i++) {
                      if (widget.game?.word[i] == inputValue[i]) {
                        bulls += 1;
                      } else {
                        if (widget.game!.word.contains(inputValue[i])) {
                          cows += 1;
                        }
                      }
                    }
                    result = "${widget.game!.word};Cows: $cows, bulls: $bulls";
                    screenResult = "Cows: $cows, Bulls: $bulls";
                    return screenResult;
                  }

                  if (inputValue.length != widget.game?.word.length) {
                    result = "${widget.game!.word};word length doesn't match";
                    screenResult = "Word length doesn't match";
                    return screenResult;
                  } else {
                    result = "${widget.game!.word};not a valid word, try again";
                    screenResult = "Not a valid word, try again";
                    return screenResult;
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
                  widget.game?.friend?.send(result);
                  widget.game?.turn = false;
                  timer = Timer(const Duration(seconds: 4), () {
                    friendsPage();
                  });
                },
                child: const Text('Submit'),
              ),
            ),
            //results(screenResult),
            bullsAndCows(),
          ])),
    );
  }
}
