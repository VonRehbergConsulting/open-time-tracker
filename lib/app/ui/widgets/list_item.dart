import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';

class ListItem extends StatelessWidget {
  // Properties

  final String? title;
  final String? subtitle;
  final String? comment;
  final String? trailing;
  final Function action;
  final Widget? commentTrailing;

  // Init
  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.comment,
    required this.trailing,
    required this.action,
    this.commentTrailing,
  });

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action(),
      child: ConfiguredCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
              SizedBox(height: subtitle != null ? 4 : 0),
              if (subtitle != null) Text(subtitle!),
              SizedBox(height: comment != null ? 4 : 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (comment != null)
                    Expanded(
                      child: Text(
                        comment!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  if (commentTrailing != null) commentTrailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
