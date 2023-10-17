/// Base model for construction custom spinners
///
/// ```dart
/// class MyCustomSpinner extends SpinnerBase {
///  const MyCustomSpinner() : super(interval: 200, frames: const [" ", ".", "..", "..."]);
/// }
/// ```
class SpinnerData {
  const SpinnerData({
    this.interval = 100,
    required this.frames,
  });

  /// Default spinner interval is `100ms`
  final int interval;

  /// List of spinner frames to display while the spinner is active
  final List<String> frames;
}
