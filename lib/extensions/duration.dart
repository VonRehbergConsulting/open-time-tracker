extension Round on Duration {
  Duration get roundedToMinutes {
    final seconds = inSeconds - inSeconds.remainder(60);
    return Duration(seconds: seconds);
  }
}
