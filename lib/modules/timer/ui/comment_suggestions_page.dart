import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/list_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentSuggestionsPage extends StatelessWidget {
  final List<String> comments;
  final Function(String) handler;

  const CommentSuggestionsPage(this.comments, this.handler, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).comment_suggestions_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
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
