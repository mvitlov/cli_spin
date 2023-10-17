part 'utils/color.dart';

/// Helper util used to colorize text with ANSI escape codes
///
/// ```dart
/// final loadingText = CliSpinnerColor.cyan.call("Loading...")
/// final successText = CliSpinnerColor.green.call("Success!")
/// ```
enum CliSpinnerColor {
  black(_black),
  red(_red),
  green(_green),
  yellow(_yellow),
  blue(_blue),
  magenta(_magenta),
  cyan(_cyan),
  white(_white),
  gray(_gray);

  const CliSpinnerColor(this.call);
  final String Function(String) call;
}
