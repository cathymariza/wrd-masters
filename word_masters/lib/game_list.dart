import 'package:flutter/material.dart';
import 'package:word_masters/friends_data.dart';

typedef PlayGame = Function(Friend item, String word);

class GameListItem extends StatelessWidget {
  const GameListItem(
      {required this.friend, required this.onListTapped, required this.word})
      : super(key: const Key("Testing"));

  final Friend friend;
  final PlayGame onListTapped;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () {
        onListTapped(friend, word);
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(friend.name[0].toUpperCase()),
      ),
      title: Text(
        friend.name,
      ),
      subtitle: Text(friend.ipAddr),
    ));
  }
}
