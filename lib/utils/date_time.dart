String durationToHHMMSS(Duration? duration) {
  if (duration == null || duration.isNegative) return "--:--:--";
  final seconds = duration.inSeconds;

  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}";
}
