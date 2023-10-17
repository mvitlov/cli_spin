<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

> A Dart package that enhances the user experience by displaying a sleek terminal spinner for both sync and async operations.

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
import 'package:cli_spinner/cli_spinner.dart';

void main() {
  // Instantiate spinner
  final spinner = CliSpinner(
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
