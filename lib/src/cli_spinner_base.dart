import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ansi_strip/ansi_strip.dart';
import 'package:string_width/string_width.dart';

import 'cli_spinner_color.dart';
import 'spinner_data.dart';
import 'spinners/spinners.dart';
import 'utils/cursor.dart';
import 'utils/is_unicode_supported.dart';
import 'utils/log_symbols.dart';

/// Creates and controls spinners in terminal
///
/// Usage example:
/// ```dart
/// final spinner = CliSpinner(spinner: CliSpinners.dots2);
/// spinner.start("Loading..."); // Start the spinner
/// Timer(Duration(seconds: 2), () {
///   spinner.text = "Taking more than usual..."; // Update the text
///   Timer(Duration(seconds: 2), () {
///     spinner.success("Done"); // Ends spinner
///   });
/// });
/// ```
class CliSpinner {
  SpinnerData? _spinner;
  Timer? _timer;
  int? _initialInterval;

  late final Stdout _stream;
  late final bool _hideCursor;

  var _linesToClear = 0;
  var _lineCount = 0;
  var _frameIndex = 0;

  late bool _isEnabled;
  var _indent = 0;
  var _text = '';
  var _prefixText = '';
  var _suffixText = '';

  int? lastIndent;

  /// Used to change spinner color
  CliSpinnerColor? color;

  bool isSilent;

  CliSpinner({
    String? text,
    Stdout? stream,
    SpinnerData? spinner,
    bool isEnabled = true,
    String? prefixText,
    String? suffixText,
    int? indent,
    this.color = CliSpinnerColor.cyan,
    bool hideCursor = true,
    this.isSilent = false,
    int? interval,
  }) {
    this.spinner = spinner;

    _initialInterval = interval;
    _stream = stream ?? stderr;

    _isEnabled = isEnabled;

    this.text = text ?? '';
    this.prefixText = prefixText ?? '';
    this.suffixText = suffixText ?? '';
    this.indent = indent ?? 0;
    _hideCursor = hideCursor;
  }

  static Future<T> async<T>(
    Future<T> Function(CliSpinner spinner) action, {
    void Function(T result, CliSpinner spinner)? onSuccess,
    void Function(Object error, CliSpinner spinner)? onError,
    String? text,
    Stdout? stream,
    SpinnerData? spinnerData,
    bool isEnabled = true,
    String? prefixText,
    String? suffixText,
    int? indent,
    CliSpinnerColor color = CliSpinnerColor.cyan,
    bool hideCursor = true,
    bool isSilent = false,
    int? interval,
  }) async {
    final spinner = CliSpinner(
      text: text,
      stream: stream,
      spinner: spinnerData,
      isEnabled: isEnabled,
      prefixText: prefixText,
      suffixText: suffixText,
      indent: indent,
      color: color,
      hideCursor: hideCursor,
      isSilent: isSilent,
      interval: interval,
    ).start();

    try {
      final result = await action(spinner);

      onSuccess != null ? onSuccess.call(result, spinner) : spinner.success();

      return result;
    } catch (error) {
      onError != null ? onError.call(error, spinner) : spinner.success();
      rethrow;
    }
  }

  // Public Getterss & Setters

  int get linesToClear => _linesToClear;
  int get frameIndex => _frameIndex;
  int get lineCount => _lineCount;
  int get interval => _initialInterval ?? _spinner?.interval ?? 100;
  bool get isSpinning => _timer != null;

  Timer? get id => _timer;

  int get indent => _indent;

  set indent(int indent) {
    if (indent < 0) {
      throw Exception('The `indent` option must be an integer from 0 and up');
    }
    _indent = indent;
    _updateLineCount();
  }

  SpinnerData? get spinner => _spinner;

  set spinner(SpinnerData? spinner) {
    _frameIndex = 0;
    _initialInterval = null;

    if (spinner?.frames.isEmpty == true) {
      throw Exception(
          'The given spinner must have a non-empty `frames` property');
    }
    _spinner = spinner;

    if (!isUnicodeSupported()) {
      _spinner = CliSpinners.line;
    } else if (spinner == null) {
      // Set default spinner
      _spinner = CliSpinners.dots;
    }
  }

  String get text => _text;

  set text(String value) {
    _text = value;
    _updateLineCount();
  }

  String get prefixText => _prefixText;

  set prefixText(String? value) {
    _prefixText = value ?? '';
    _updateLineCount();
  }

  String get suffixText => _suffixText;

  set suffixText(String? value) {
    _suffixText = value ?? '';
    _updateLineCount();
  }

  bool get isEnabled => _isEnabled && !isSilent;

  set isEnabled(value) => _isEnabled = value;

  // Public methods

  String frame() {
    final frames = _spinner!.frames;
    var frame = frames[_frameIndex];

    if (color != null) {
      frame = color!.call(frame);
    }

    _frameIndex = (++_frameIndex) % frames.length;
    final fullPrefixText = _prefixText != '' ? '$_prefixText ' : '';
    final fullText = text.isNotEmpty ? ' $text' : '';
    final fullSuffixText = _suffixText != '' ? ' $_suffixText' : '';

    return fullPrefixText + frame + fullText + fullSuffixText;
  }

  CliSpinner clear() {
    if (!_isEnabled || !_stream.hasTerminal) return this;

    cursorTo(_stream, 0);

    for (var index = 0; index < _linesToClear; index++) {
      if (index > 0) {
        moveCursor(_stream, 0, -1);
      }

      clearLine(_stream, 1);
    }

    if (_indent > 0 || lastIndent != _indent) {
      cursorTo(_stream, _indent);
    }

    lastIndent = _indent;
    _linesToClear = 0;

    return this;
  }

  CliSpinner render() {
    if (isSilent) return this;

    clear();
    _stream.write(frame());
    _linesToClear = _lineCount;

    return this;
  }

  CliSpinner start([String? text]) {
    if (text != null && text.isNotEmpty) {
      this.text = text;
    }

    if (isSilent) return this;

    if (!_isEnabled) {
      if (this.text.isNotEmpty) {
        _stream.write('- ${this.text}\n');
      }

      return this;
    }

    if (isSpinning) return this;

    if (_hideCursor) {
      toggleCursor(_stream, false);
    }

    render();
    _timer = Timer.periodic(Duration(milliseconds: interval), (_) {
      render();
    });

    return this;
  }

  CliSpinner stop() {
    if (!_isEnabled) return this;

    _timer?.cancel();
    _timer = null;

    _frameIndex = 0;
    clear();
    if (_hideCursor) {
      toggleCursor(_stream, true);
    }

    return this;
  }

  CliSpinner success([String? text]) {
    return stopAndPersist(symbol: logSymbols.success, text: text);
  }

  CliSpinner fail([String? text]) {
    return stopAndPersist(symbol: logSymbols.error, text: text);
  }

  CliSpinner warn([String? text]) {
    return stopAndPersist(symbol: logSymbols.warning, text: text);
  }

  CliSpinner info([String? text]) {
    return stopAndPersist(symbol: logSymbols.info, text: text);
  }

  CliSpinner stopAndPersist(
      {String? symbol, String? text, String? prefixText, String? suffixText}) {
    if (isSilent) return this;

    prefixText ??= _prefixText;
    final fullPrefixText = _getFullPrefixText(prefixText, ' ');

    final symbolText = symbol ?? ' ';

    text ??= this.text;
    final fullText = text.isNotEmpty ? ' $text' : '';

    suffixText ??= _suffixText;
    final fullSuffixText = _getFullSuffixText(suffixText, ' ');

    final textToWrite =
        '${fullPrefixText + symbolText}$fullText$fullSuffixText\n';

    stop();
    _stream.write(textToWrite);

    return this;
  }

  // Private methods

  String _getFullPrefixText(dynamic prefixText, [String postfix = ' ']) {
    prefixText ??= _prefixText;
    if (prefixText is String && prefixText != '') {
      return prefixText + postfix;
    }

    if (prefixText is Function) {
      return prefixText() + postfix;
    }

    return '';
  }

  String _getFullSuffixText(dynamic suffixText, [String prefix = ' ']) {
    suffixText ??= _suffixText;
    if (suffixText is String && suffixText != '') {
      return prefix + suffixText;
    }

    if (suffixText is Function) {
      return prefix + suffixText();
    }

    return '';
  }

  void _updateLineCount() {
    final columns = _stream.hasTerminal ? _stream.terminalColumns : 80;
    final fullPrefixText = _getFullPrefixText(_prefixText, '-');
    final fullSuffixText = _getFullSuffixText(_suffixText, '-');
    final fullText = '${' ' * _indent}$fullPrefixText--$_text--$fullSuffixText';

    _lineCount = 0;
    for (final line in stripAnsi(fullText).split('\n')) {
      _lineCount += max(1, (stringWidth(line) / columns).ceil());
    }
  }
}
