import '../cli_spin_color.dart';
import 'is_unicode_supported.dart';

/// Colored symbols for various log level
final logSymbols =
    isUnicodeSupported() ? _MainLogSymbols() : _FallbackLogSymbols();

abstract class _LogSymbols {
  String get info;
  String get success;
  String get warning;
  String get error;
}

class _MainLogSymbols implements _LogSymbols {
  @override
  final info = CliSpinnerColor.blue.call('ℹ');
  @override
  final success = CliSpinnerColor.green.call('✔');
  @override
  final warning = CliSpinnerColor.yellow.call('⚠');
  @override
  final error = CliSpinnerColor.red.call('✖');
}

class _FallbackLogSymbols implements _LogSymbols {
  @override
  final info = CliSpinnerColor.blue.call('i');
  @override
  final success = CliSpinnerColor.green.call('√');
  @override
  final warning = CliSpinnerColor.yellow.call('‼');
  @override
  final error = CliSpinnerColor.red.call('×');
}
