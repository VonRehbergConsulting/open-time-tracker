import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/list_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';

class CommentSuggestionsPage extends StatelessWidget {
  final List<String> comments;
  final Function(String) handler;

  const CommentSuggestionsPage(this.comments, this.handler, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScreen(
      title: AppLocalizations.of(context).comment_suggestions_title,
      scrollingEnabled: true,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
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
        ),
      ),
    );
  }
}
