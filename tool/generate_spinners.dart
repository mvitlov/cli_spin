import 'dart:convert';
import 'dart:io';

final spinnerDir = Directory('lib/src/spinners');
final spinnerFile = File('lib/src/spinners/spinners.dart');

void main(List<String> args) {
  final spinnersJson = jsonDecode(File('tool/spinners.json').readAsStringSync())
      as Map<String, dynamic>;

  if (spinnerDir.existsSync()) {
    spinnerDir.deleteSync(recursive: true);
  }

  spinnerFile.createSync(recursive: true);

  final fileBuffer = StringBuffer()
    ..writeln(
        '/// Auto-generated file.\n/// See under `tool/generate_spinners.dart`.\n')
    ..writeln("import '../spinner_data.dart';\n");

  final topClassBuffer = StringBuffer()..writeln('final class CliSpinners {\n');

  for (var spinnerName in spinnersJson.keys) {
    final spinner = spinnersJson[spinnerName]!;
    final interval = spinner['interval'];
    final frames = spinner['frames'];

    topClassBuffer
      ..writeln('/// $spinnerName spinner, using the following sequence:')
      ..writeln('///')
      ..writeln("/// `${frames.join(', ')}`")
      ..writeln(
          'static const $spinnerName = SpinnerData(interval: $interval, frames: ${jsonEncode(frames)},);');
  }
  topClassBuffer.writeln('}');

  spinnerFile.writeAsStringSync(
    fileBuffer.toString() + topClassBuffer.toString(),
  );

  Process.runSync('dart', ['format', 'lib/src/spinners']);
  Process.runSync('dart', ['fix', '--apply']);
}
