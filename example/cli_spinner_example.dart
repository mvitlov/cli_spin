import 'dart:async';

import 'package:cli_spinner/cli_spinner.dart';

// Helper function
Timer _setTimeout(void Function() fn, int interval) =>
    Timer(Duration(milliseconds: interval), fn);

void main(List<String> args) async {
  final spinner2 = CliSpinner(
      text: 'Loading a little bit more data...',
      spinner: CliSpinners.dots,
      color: CliSpinnerColor.white);

  final spinner1 = CliSpinner(
      text: 'Loading data...',
      spinner: CliSpinners.dots2,
      color: CliSpinnerColor.white);

  spinner1.start();

  _setTimeout(() {
    spinner1.success();
  }, 1000);

  _setTimeout(() {
    spinner1.text = 'Loading more data...';
    spinner1.start();
  }, 2000);

  _setTimeout(() {
    spinner1.success();
    spinner2.start();
  }, 3000);

  _setTimeout(() {
    spinner2.color = CliSpinnerColor.yellow;
    spinner2.text =
        'Yellow spinner with ${CliSpinnerColor.red.call('red text')}';
  }, 4000);

  _setTimeout(() {
    spinner2.color = CliSpinnerColor.green;
    spinner2.indent = 2;
    spinner2.text = 'Loading with indent';
  }, 5000);

  _setTimeout(() {
    spinner2.indent = 0;
    spinner2.spinner = CliSpinners.aesthetic;
    spinner2.text = 'Loading with different spinners';
  }, 6000);

  _setTimeout(() {
    spinner2.prefixText = CliSpinnerColor.gray.call('[info]');
    spinner2.spinner = CliSpinners.dots;
    spinner2.text = 'Loading with prefix text';
  }, 8000);

  _setTimeout(() {
    spinner2.prefixText = '';
    spinner2.suffixText = CliSpinnerColor.gray.call('[info]');
    spinner2.text = 'Loading with suffix text';
  }, 10000);

  _setTimeout(() {
    spinner2.prefixText = CliSpinnerColor.gray.call('[info]');
    spinner2.suffixText = CliSpinnerColor.gray.call('[info]');
    spinner2.text = 'Loading with prefix and suffix text';
  }, 12000);

  _setTimeout(() {
    spinner2.stopAndPersist(
      prefixText: '',
      suffixText: '',
      symbol: logSymbols.info,
      text: 'Stopping with different text!',
    );
  }, 14000);
}
