import 'package:flutter/material.dart';

class CommentSuggestionsScreen extends StatelessWidget {
  final List<String> comments;
  final Function(String) handler;

  const CommentSuggestionsScreen(this.comments, this.handler, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a comment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: comments
            .map((comment) => GestureDetector(
                  onTap: () => handler(comment),
                  child: Card(
                    child: ListTile(title: Text(comment)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
