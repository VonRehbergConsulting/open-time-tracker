class DurationFormatter {
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String longWatch(Duration duration) {
    String hours = _twoDigits(duration.inHours);
    String minutes = _twoDigits(duration.inMinutes.remainder(60));
    String seconds = _twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  static String shortWatch(Duration duration) {
    String hours = _twoDigits(duration.inHours);
    String minutes = _twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  static String toISO8601(Duration duration) {
    var result = 'PT';
    if (duration.inHours > 0) {
      result += '${_twoDigits(duration.inHours)}H';
    }
    if (duration.inMinutes.remainder(60) > 0) {
      result += '${_twoDigits(duration.inMinutes.remainder(60))}M';
    }
    if (duration.inSeconds.remainder(60) > 0) {
      result += '${_twoDigits(duration.inSeconds.remainder(60))}S';
    }
    return result;
  }
}
