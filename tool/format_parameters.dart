// Formats Dart files so that every parameter list with more than one
// parameter puts each parameter on its own line, followed by a comma.
//
// It adds a trailing comma to such parameter lists and then runs
// `dart format`. Because `analysis_options.yaml` sets
// `formatter: trailing_commas: preserve`, the formatter splits every list
// that ends with a trailing comma into one item per line.
//
// Usage: tool/format_parameters.sh <file-or-directory>...
//    or: dart run tool/format_parameters.dart <file-or-directory>...
//
// VS Code runs tool/format_parameters.sh (a cached, faster launcher for this
// script) automatically when a Dart file is saved (see .vscode/settings.json).

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/format_parameters.dart <file-or-directory>...',
    );
    exit(64);
  }

  final files = <String>[];
  for (final arg in args) {
    if (FileSystemEntity.isDirectorySync(arg)) {
      files.addAll(
        Directory(arg)
            .listSync(recursive: true)
            .whereType<File>()
            .map((file) => file.path)
            .where((path) => path.endsWith('.dart')),
      );
    } else if (arg.endsWith('.dart') && File(arg).existsSync()) {
      files.add(arg);
    }
  }
  if (files.isEmpty) return;

  for (final path in files) {
    _addTrailingCommas(path);
  }

  final result = await Process.run('dart', ['format', ...files]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exitCode = result.exitCode;
}

void _addTrailingCommas(String path) {
  final file = File(path);
  final source = file.readAsStringSync();
  final parsed = parseString(
    content: source,
    path: path,
    throwIfDiagnostics: false,
  );
  // Leave files that do not parse alone; `dart format` will report the error.
  if (parsed.errors.isNotEmpty) return;

  final collector = _MissingCommaCollector();
  parsed.unit.accept(collector);
  if (collector.offsets.isEmpty) return;

  final buffer = StringBuffer();
  var start = 0;
  for (final offset in collector.offsets..sort()) {
    buffer
      ..write(source.substring(start, offset))
      ..write(',');
    start = offset;
  }
  buffer.write(source.substring(start));
  file.writeAsStringSync(buffer.toString());
}

/// Collects the offsets at which a trailing comma must be inserted: right
/// after the last parameter of every parameter list that has more than one
/// parameter and no trailing comma yet.
class _MissingCommaCollector extends RecursiveAstVisitor<void> {
  final offsets = <int>[];

  @override
  void visitFormalParameterList(FormalParameterList node) {
    final parameters = node.parameters;
    if (parameters.length > 1) {
      final last = parameters.last;
      if (last.endToken.next?.type != TokenType.COMMA) {
        offsets.add(last.end);
      }
    }
    super.visitFormalParameterList(node);
  }
}
