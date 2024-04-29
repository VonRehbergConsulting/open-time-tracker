import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';

class SliverScreen extends StatelessWidget {
  final Widget? floatingActionButton;
  final bool scrollingEnabled;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final List<Widget>? body;
  final Color? backgroundColor;

  const SliverScreen({
    super.key,
    this.floatingActionButton,
    this.scrollingEnabled = true,
    this.title,
    this.leading,
    this.actions,
    this.onRefresh,
    this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: CustomScrollView(
          physics:
              scrollingEnabled ? null : const NeverScrollableScrollPhysics(),
          scrollBehavior: const CupertinoScrollBehavior(),
          slivers: [
            if (title != null || leading != null || actions != null)
              SliverAppBar(
                backgroundColor: scaffoldColor,
                title: title != null ? Text(title!) : null,
                leading: leading,
                actions: actions,
              ),
            if (onRefresh != null)
              CupertinoSliverRefreshControl(
                onRefresh: onRefresh,
              ),
            if (body != null) ...body!,
          ],
        ),
      ),
    );
  }
}

class SliverScreenLoading extends StatelessWidget {
  const SliverScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ActivityIndicator(),
      ),
    );
  }
}

class SliverScreenEmpty extends StatelessWidget {
  final String text;

  const SliverScreenEmpty({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
