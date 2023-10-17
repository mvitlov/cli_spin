part of '../cli_spin_color.dart';

class _Code {
  String open;
  String close;
  RegExp regexp;
  _Code({required this.open, required this.close, required this.regexp});
}

_Code _code(List<int> open, int close) {
  return _Code(
    open: '\x1b[${open.join(";")}m',
    close: '\x1b[${close}m',
    regexp: RegExp('\\x1b\\[${close}m'),
  );
}

// Applies color and background based on color code and its associated text
String _run(String str, _Code code) {
  return '${code.open}${str.replaceAll(code.regexp, code.open)}${code.close}';
}

String _black(String str) {
  return _run(str, _code([30], 39));
}

String _red(String str) {
  return _run(str, _code([31], 39));
}

String _green(String str) {
  return _run(str, _code([32], 39));
}

String _yellow(String str) {
  return _run(str, _code([33], 39));
}

String _blue(String str) {
  return _run(str, _code([34], 39));
}

String _magenta(String str) {
  return _run(str, _code([35], 39));
}

String _cyan(String str) {
  return _run(str, _code([36], 39));
}

String _white(String str) {
  return _run(str, _code([37], 39));
}

String _gray(String str) {
  return _run(str, _code([90], 39));
}
