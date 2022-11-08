import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  // Properties

  final String? title;
  final String? subtitle;
  final String? comment;
  final String? trailing;
  final Function action;

  // Init
  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.comment,
    required this.trailing,
    required this.action,
  });

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action(),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
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
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
              SizedBox(height: subtitle != null ? 2 : 0),
              if (subtitle != null) Text(subtitle!),
              SizedBox(height: comment != null ? 2 : 0),
              if (comment != null)
                Text(
                  comment!,
                  style: const TextStyle(color: Colors.black54),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
