import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/app_router.dart';

// Regression tests for the bug where recording a time entry and then
// switching OpenProject instances did not reload the data.
//
// Root cause: `routeToTimeEntriesListTemporary` used to unconditionally
// `pushAndRemoveUntil(new AppAuthorizedRouter())`, which replaced the
// root route and threw away the `_KeyedAuthorizedRouter` wrapper (and
// its instance-snapshot subscription). Subsequent instance switches
// therefore had nothing listening to remount the authorized subtree.
//
// The fix prefers `popUntil((r) => r.isFirst)` when the navigator has
// something to pop, only falling back to the fabricate-and-replace path
// when there is no underlying route (edge case: app launched directly
// into the timer, e.g. via a Live Activity). These tests exercise the
// happy path — the fallback branch depends on the app's DI graph and
// is covered by manual QA.
void main() {
  testWidgets(
    'routeToTimeEntriesListTemporary pops back to the underlying route '
    'instead of replacing it',
    (tester) async {
      const homeKey = ValueKey('home');
      const timerKey = ValueKey('timer');

      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoPageScaffold(
              key: homeKey,
              child: Center(
                child: CupertinoButton(
                  child: const Text('open timer'),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => const CupertinoPageScaffold(
                          key: timerKey,
                          child: Center(child: Text('timer page')),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Push the "timer" route on top of the home route.
      await tester.tap(find.text('open timer'));
      await tester.pumpAndSettle();

      expect(find.byKey(timerKey), findsOneWidget);

      // Invoke the routing helper from a context that lives inside the
      // "timer" route — this mimics `TimerPage._minimize` / the
      // post-save callback in `TimerPage.onEffect(finish: ...)`.
      final timerContext = tester.element(find.byKey(timerKey));
      AppRouter.routeToTimeEntriesListTemporary(timerContext);
      await tester.pumpAndSettle();

      // The underlying home route must still be mounted — that is what
      // preserves `_KeyedAuthorizedRouter` and its instance-snapshot
      // subscription in the real app.
      expect(find.byKey(homeKey), findsOneWidget);
      expect(find.byKey(timerKey), findsNothing);
    },
  );

  testWidgets(
    'routeToTimeEntriesListTemporary pops multiple intermediate routes '
    'back to the first route',
    (tester) async {
      const homeKey = ValueKey('home');
      const intermediateKey = ValueKey('intermediate');
      const topKey = ValueKey('top');

      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoPageScaffold(
              key: homeKey,
              child: Center(
                child: CupertinoButton(
                  child: const Text('deep'),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (context) => CupertinoPageScaffold(
                          key: intermediateKey,
                          child: Center(
                            child: CupertinoButton(
                              child: const Text('deeper'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (_) =>
                                        const CupertinoPageScaffold(
                                          key: topKey,
                                          child: Center(
                                            child: Text('top page'),
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('deep'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('deeper'));
      await tester.pumpAndSettle();

      expect(find.byKey(topKey), findsOneWidget);

      final topContext = tester.element(find.byKey(topKey));
      AppRouter.routeToTimeEntriesListTemporary(topContext);
      await tester.pumpAndSettle();

      expect(find.byKey(homeKey), findsOneWidget);
      expect(find.byKey(intermediateKey), findsNothing);
      expect(find.byKey(topKey), findsNothing);
    },
  );
}
