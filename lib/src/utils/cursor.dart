import 'dart:io';

/// Show/hide cursor
void toggleCursor(Stdout stream, bool enabled) {
  if (!stream.hasTerminal) return;

  if (enabled) {
    stream.write('\x1B[?25h');
  } else {
    stream.write('\x1B[?25l');
  }
}

/// Change cursor positionn
void cursorTo(Stdout stream, int x, [int? y]) {
  if (!stream.hasTerminal) return;

  _cursorTo(stream, x, y);
}

/// Move cursor absolute
void _cursorTo(Stdout stream, int x, [int? y]) {
  final data = y == null
      ? _CSI.apply(['', 'G'], [x + 1])
      : _CSI.apply(['', ';', 'H'], [y + 1, x + 1]);

  stream.write(data);
}

/// Clear full line
void clearLine(Stdout stream, [int? direction]) {
  if (!stream.hasTerminal) return;

  _clearLine(stream, direction ?? 0);
}

/// Clears the current line the cursor is on.
///
/// - `-1` for left of the cursor
/// - `+1` for right of the cursor
/// - `0` for the entire line
void _clearLine(Stdout stream, int dir) {
  final type = dir < 0
      ? _CSI.kClearToLineBeginning
      : dir > 0
          ? _CSI.kClearToLineEnd
          : _CSI.kClearLine;

  stream.write(type);
}

void moveCursor(Stdout stream, int? dx, int? dy) {
  if (dx == null || dy == null) return;

  var data = '';

  if (dx < 0) {
    data += _CSI.apply(['', 'D'], [-dx]);
  } else if (dx > 0) {
    data += _CSI.apply(['', 'C'], [dx]);
  }

  if (dy < 0) {
    data += _CSI.apply(['', 'A'], [-dy]);
  } else if (dy > 0) {
    data += _CSI.apply(['', 'B'], [dy]);
  }

  stream.write(data);
}

/// Control Sequence Introducer
class _CSI {
  static const kEscape = '\x1b';
  static String get kClearToLineBeginning => apply(['1K']);
  static String get kClearToLineEnd => apply(['0K']);
  static String get kClearLine => apply(['2K']);

  static String apply(List<String> strings, [List<int> args = const []]) {
    var ret = '$kEscape[';
    for (var n = 0; n < strings.length; n++) {
      ret += strings[n];
      if (n < args.length) ret += args[n].toString();
    }
    return ret;
  }
}
