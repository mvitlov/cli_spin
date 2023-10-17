> A Dart package that enhances the user experience by displaying a sleek terminal spinner for both sync and async operations.

![preview](https://github.com/mvitlov/cli_spin/blob/main/media/preview.gif)

## Features

- **80+** predefined spinners accessible via `CliSpinners`
- Easily change color of spinners and/or text with use of `CliSpinnerColor` helper
- Define your own character sets (frames) and intervals for your custom spinners
- Custom spinner text (w/ separate suffix and prefix options)
- Start/stop methods
- Stop and persist the spinner with custom text and symbol
- Predefiend `success`, `fail`, `warn` and `info` methods (cross-platform compatible)

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage example

```dart
import 'dart:async';
import 'package:cli_spin/cli_spin.dart';

void main() {
  // Instantiate spinner
  final spinner = CliSpin(
    text: 'Loading data...',
    spinner: CliSpinners.line,
  ).start(); // Chaining methods

  Timer(Duration(milliseconds: 1000), () {
    // Change spinner color
    spinner.color = CliSpinnerColor.yellow; 
    
    // Change spinner text
    spinner.text = 'Still loading, please wait...';

    Timer(Duration(milliseconds: 1000), () {
      // Alias for `stopAndPersist(...)` method
      spinner.success('Data loaded successfully.');
    });
  });
}

```

## Additional information

Inspired by the [ora](https://github.com/sindresorhus/ora) library written in Javascript.
