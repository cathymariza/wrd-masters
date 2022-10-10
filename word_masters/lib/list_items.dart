import 'package:flutter/material.dart';
import 'package:word_masters/friends_data.dart';

typedef FriendListChatCallback = Function(Friend item, String word);
typedef FriendListEditCallback = Function(Friend item);

class FriendListItem extends StatelessWidget {
  FriendListItem(
      {required this.friend,
      required this.onListTapped,
      required this.onListEdited,
      required this.word})
      : super(key: ObjectKey(friend));

  final Friend friend;
  final FriendListChatCallback onListTapped;
  final FriendListEditCallback onListEdited;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () {
        onListTapped(friend, word);
      },
      onLongPress: () {
        onListEdited(friend);
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
