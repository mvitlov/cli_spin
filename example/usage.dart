import 'dart:async';

import 'package:cli_spinner/cli_spinner.dart';

void main(List<String> args) {
  final spinner = CliSpinner(
    text: 'Loading data...',
    spinner: CliSpinners.line,
  ).start();

  Timer(Duration(milliseconds: 1000), () {
    spinner.color = CliSpinnerColor.yellow;
    spinner.text = 'Still loading, please wait...';

    Timer(Duration(milliseconds: 1000), () {
      spinner.success('Data loaded successfully.');
    });
  });
}
