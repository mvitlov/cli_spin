import 'dart:async';
import 'dart:io';

import 'package:ansi_strip/ansi_strip.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

Future<String> doSpinner(Function fn,
    {bool? isEnabled,
    bool? isSilent,
    String? prefixText,
    String? suffixText}) async {
  final stream = MockStdout();
  final output = stream.stream;

  final spinner = CliSpinner(
    stream: stream,
    text: 'foo',
    color: CliSpinnerColor.white,
    isEnabled: isEnabled ?? true,
    isSilent: isSilent ?? false,
    prefixText: prefixText,
    suffixText: suffixText,
  );

  final events = [];
  output.listen((event) => events.add(stripAnsi(event)));

  spinner.start();
  fn(spinner);
  await stream.controller.close();

  return events.join('');
}

Future<void> macro(void Function(CliSpinner spinner) fn, expected,
    {bool? isEnabled,
    bool? isSilent,
    String? prefixText,
    String? suffixText}) async {
  final res = await doSpinner(fn,
      isEnabled: isEnabled,
      isSilent: isSilent,
      prefixText: prefixText,
      suffixText: suffixText);

  expect(res, matches(RegExp(expected)));
}

// A Mock Cat class
class MockStdout extends Mock implements Stdout {
  final controller = StreamController<String>.broadcast();
  Stream<String> get stream => controller.stream;
  @override
  bool get hasTerminal => true;

  @override
  int get terminalColumns => 80;

  @override
  void write(Object? object) => controller.add('$object');

  @override
  Future close() => controller.close();
}

final spinnerCharacter = Platform.isWindows ? '-' : '⠋';
void noop() {}

void main() {
  test('`.id` is not set when created', () {
    final spinner = CliSpinner(text: 'foo');
    expect(spinner.isSpinning, isFalse);
  });
  test('ignore consecutive calls to `.start()`', () {
    final spinner = CliSpinner(text: 'foo', stream: MockStdout());
    spinner.start();
    final id = spinner.id;
    spinner.start();
    expect(id, spinner.id);
  });

  test('chain call to `.start()` with constructor', () {
    final spinner = CliSpinner(
      stream: MockStdout(),
      text: 'foo',
      isEnabled: true,
    ).start();

    expect(spinner.isSpinning, isTrue);
    expect(spinner.isEnabled, isTrue);
  });

  test('.success()', () async {
    await macro((spinner) {
      spinner.success();
    }, r'[√✔] foo\n$');
  });

  test('.success() - with new text', () async {
    await macro((spinner) {
      spinner.success('bar');
    }, r'[√✔] bar\n$');
  });

  test(
    '.fail()',
    () async {
      await macro((spinner) {
        spinner.fail();
      }, r'[×✖] foo\n$');
    },
  );

  test('.fail() - with new text', () async {
    await macro((spinner) {
      spinner.fail('failed to foo');
    }, r'[×✖] failed to foo\n$');
  });

  test(
    '.warn()',
    () async {
      await macro((spinner) {
        spinner.warn();
      }, r'[‼⚠] foo\n$');
    },
  );

  test(
    '.info()',
    () async {
      await macro((spinner) {
        spinner.info();
      }, r'[iℹ] foo\n$');
    },
  );

  test(
    '.stopAndPersist() - with new text',
    () async {
      await macro((spinner) {
        spinner.stopAndPersist(text: 'all done');
      }, r'\s all done\n$');
    },
  );

  test(
    '.stopAndPersist() - with new symbol and text',
    () async {
      await macro((spinner) {
        spinner.stopAndPersist(symbol: '@', text: 'all done');
      }, r'@ all done\n$');
    },
  );

  test(
    '.start(text)',
    () async {
      await macro((spinner) {
        spinner.start('Test text');
        spinner.stopAndPersist();
      }, r'Test text\n$');
    },
  );

  test('.start() - isEnabled:false outputs text', () async {
    await macro((spinner) {
      spinner.stop();
    }, r'- foo\n$', isEnabled: false);
  });

  test('.stopAndPersist() - isEnabled:false outputs text', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'all done');
    }, r'- foo\n@ all done\n$', isEnabled: false);
  });

  test('.start() - isSilent:true no output', () async {
    await macro((spinner) {
      spinner.stop();
    }, r'^(?![\s\S])', isSilent: true);
  });

  test('.stopAndPersist() - isSilent:true no output', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'all done');
    }, r'^(?![\s\S])', isSilent: true);
  });

  test('.stopAndPersist() - isSilent:true can be disabled', () async {
    await macro((spinner) {
      spinner.isSilent = false;
      spinner.stopAndPersist(symbol: '@', text: 'all done');
    }, r'@ all done\n$', isSilent: true);
  });

  test('reset frameIndex when setting new spinner', () async {
    final stream = MockStdout();
    final output = stream.stream;

    final spinner = CliSpinner(
        stream: stream,
        isEnabled: true,
        spinner: const SpinnerData(frames: ['foo', 'fooo']));

    final events = [];
    output.listen((event) =>
        stripAnsi(event).isNotEmpty ? events.add(stripAnsi(event)) : null);

    spinner.render();
    expect(spinner.frameIndex, 1);

    spinner.spinner = SpinnerData(frames: ['baz']);
    spinner.render();

    await stream.controller.close();

    expect(spinner.frameIndex, 0);
    expect(events.join(' '), matches(RegExp(r'foo baz')));
  });

  test('set the correct interval when changing spinner', () {
    final spinner = CliSpinner(
      isEnabled: false,
      spinner: SpinnerData(frames: ['foo', 'bar']),
      interval: 300,
    );

    expect(spinner.interval, 300);

    spinner.spinner = SpinnerData(frames: ['baz'], interval: 200);

    expect(spinner.interval, 200);
  });

  test('.stopAndPersist() with prefixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'foo');
    }, r'bar @ foo\n$', prefixText: 'bar');
  });

  test('.stopAndPersist() with empty prefixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'foo');
    }, r'@ foo\n$', prefixText: '');
  });

  test('.stopAndPersist() with manual prefixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', prefixText: 'baz', text: 'foo');
    }, r'baz @ foo\n$', prefixText: 'bar');
  });

  test('.stopAndPersist() with manual empty prefixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', prefixText: '', text: 'foo');
    }, r'@ foo\n$', prefixText: 'bar');
  });

  test('.stopAndPersist() with suffixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'foo');
    }, r'@ foo bar\n$', suffixText: 'bar');
  });

  test('.stopAndPersist() with empty suffixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'foo');
    }, r'@ foo\n$', suffixText: '');
  });

  test('.stopAndPersist() with manual suffixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', suffixText: 'baz', text: 'foo');
    }, r'@ foo baz\n$', suffixText: 'bar');
  });

  test('.stopAndPersist() with manual empty suffixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', suffixText: '', text: 'foo');
    }, r'@ foo\n$', suffixText: 'bar');
  });

  test('.stopAndPersist() with prefixText and suffixText', () async {
    await macro((spinner) {
      spinner.stopAndPersist(symbol: '@', text: 'foo');
    }, r'bar @ foo baz\n$', prefixText: 'bar', suffixText: 'baz');
  });

  test('.frame() advances correctly', () async {
    await macro((spinner) {
      final advance = stripAnsi(spinner.frame());
      expect(advance, matches('⠙ foo'));
    }, '⠋ foo');
  });
}
