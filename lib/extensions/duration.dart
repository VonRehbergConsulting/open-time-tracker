extension Round on Duration {
  Duration get roundedToMinutes {
    final seconds = inSeconds - inSeconds.remainder(60);
    return Duration(seconds: seconds);
  }
}

extension Format on Duration {
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String longWatch() {
    String hours = _twoDigits(inHours);
    String minutes = _twoDigits(inMinutes.remainder(60));
    String seconds = _twoDigits(inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String shortWatch() {
    String hours = _twoDigits(inHours);
    String minutes = _twoDigits(inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  String withLetters() {
    var result = '';
    if (inHours > 0) {
      result += '${inHours}h';
    }
    if (inMinutes.remainder(60) > 0) {
      result += ' ${inMinutes.remainder(60)}m';
    }
    if (inSeconds.remainder(60) > 0) {
      result += ' ${inSeconds.remainder(60)}s';
    }
    if (result.startsWith(' ')) {
      result = result.substring(1);
    }
    return result;
  }

  String toISO8601() {
    var result = 'PT';
    if (inHours > 0) {
      result += '${_twoDigits(inHours)}H';
    }
    if (inMinutes.remainder(60) > 0) {
      result += '${_twoDigits(inMinutes.remainder(60))}M';
    }
    if (inSeconds.remainder(60) > 0) {
      result += '${_twoDigits(inSeconds.remainder(60))}S';
    }
    return result;
  }
}
