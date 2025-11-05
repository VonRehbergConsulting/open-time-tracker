import 'dart:async';

import 'package:uni_links/uni_links.dart';

/// DeepLinkService captures cold-start links (getInitialLink) and runtime links (linkStream).
/// Call [start] early in application startup. Use [awaitLink] to await the next incoming link
/// (either initial link or next emitted link). Call [notifyAppResumed] when the app is resumed
/// without completing the browser flow to cancel waiting.
class DeepLinkService {
  String? _initialLink;
  StreamSubscription<String?>? _sub;
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  Completer<void>? _canceler;

  DeepLinkService._(this._sub);

  static Future<DeepLinkService> start() async {
    final initial = await getInitialLink();
    final svc = DeepLinkService._(null);
    svc._initialLink = initial;
    svc._sub = linkStream.listen((data) {
      if (data != null) svc._controller.add(data);
    });
    return svc;
  }

  /// Await next link. If an initial link exists (cold-start), it will be returned first.
  /// If [timeout] is null, await indefinitely. If [timeout] is provided, wait up to that duration.
  /// If [notifyAppResumed] is called while awaiting, this will cancel and return null.
  Future<String?> awaitLink({Duration? timeout}) async {
    if (_initialLink != null) {
      final tmp = _initialLink;
      _initialLink = null;
      return tmp;
    }

    _canceler = Completer<void>();
    final futureLink = _controller.stream.first;

    if (timeout == null) {
      // wait until either a link arrives or canceler completes
      final result = await Future.any([
        futureLink,
        _canceler!.future.then((_) => null),
      ]);
      if (result is String) return result;
      return null;
    }

    try {
      final link = await futureLink.timeout(timeout);
      return link;
    } catch (e) {
      return null;
    } finally {
      _canceler = null;
    }
  }

  /// Notify the service that the app was resumed (user may have closed the browser).
  /// This will cancel any pending awaitLink call.
  void notifyAppResumed() {
    if (_canceler != null && !_canceler!.isCompleted) _canceler!.complete();
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
