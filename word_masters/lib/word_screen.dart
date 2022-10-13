import 'package:flutter/material.dart';
import 'package:word_masters/game_state.dart';
import 'friends_data.dart';

class WordScreen extends StatefulWidget {
  WordScreen({Key? key, this.game}) : super(key: key);

  final gameBoard? game;
  @override
  _WordScreenState createState() => _WordScreenState();
}

// add a field that requires a word to passed to create this screen
class _WordScreenState extends State<WordScreen> {
  _WordScreenState();
  var turn = 0;

  // ALSO I ADDED THIS
  final _entryForm = GlobalKey<FormState>(); // for validator

  // @override
  // void initState() {
  //   super.initState();
  //   widget.friend!.addListener(update);
  // }

  // @override
  // void dispose() {
  //   widget.friend!.removeListener(update);
  //   print("Goodbye");
  //   super.dispose();
  // }

  // void update() {
  //   print("New message!");
  //   setState(() {});
  // }

  // Future<void> send(String msg, String word) async {
  //   await widget.friend!.send(msg, word).catchError((e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Error: $e"),
  //     ));
  //   });
  // }

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
                  if (inputValue == widget.game?.word) {
                    return "Woohoo, you are correct!";
                  }
                  if (inputValue == null || inputValue.isEmpty) {
                    return 'Please enter a guess';
                  }
                  //bulls and cows portion
                  if (widget.game!.words.contains(inputValue)) {
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
                    result = "Cows: $cows, bulls: $bulls";
                    return result;
                  }

                  if (inputValue.length != widget.game?.word.length) {
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
                  widget.game?.friend.send(result);
                },
                child: const Text('Submit'),
              ),
            ),
            //widget.friend!.bullsAndCows()
          ])),
    );
  }
}
