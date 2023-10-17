import 'dart:io';

bool isUnicodeSupported() {
  if (!Platform.isWindows) {
    return Platform.environment['TERM'] != 'linux'; // Linux console (kernel)
  }

  return Platform.environment.containsKey('CI') ||
      // Windows Terminal
      Platform.environment.containsKey('WT_SESSION') ||
      // Terminus (<0.2.27)
      Platform.environment.containsKey('TERMINUS_SUBLIME') ||
      // ConEmu and cmder
      Platform.environment['ConEmuTask'] == '{cmd::Cmder}' ||
      Platform.environment['TERM_PROGRAM'] == 'Terminus-Sublime' ||
      Platform.environment['TERM_PROGRAM'] == 'vscode' ||
      Platform.environment['TERM'] == 'xterm-256color' ||
      Platform.environment['TERM'] == 'alacritty' ||
      Platform.environment['TERMINAL_EMULATOR'] == 'JetBrains-JediTerm';
}
