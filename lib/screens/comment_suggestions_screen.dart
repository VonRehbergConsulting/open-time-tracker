import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/list_item.dart';

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
            .map(
              (comment) => ListItem(
                title: comment,
                subtitle: null,
                comment: null,
                trailing: null,
                action: () => handler(comment),
              ),
            )
            .toList(),
      ),
    );
  }
}
