import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:watcher/watcher.dart';

final logger = Logger(
  level: Level.info,
  theme: LogTheme(),
);

void main(List<String> arguments) {
  logger.info('Welcome to Pharaoh CLI 🐎🐎🐎');
  logger.info('Pharaoh CLI is a command line tool for Pharaoh framework.');
  final ArgumentParser argumentsParsed = ArgumentParser(arguments);

  if (argumentsParsed.hasVersion) {
    logger.info('Pharoah version: ${argumentsParsed.version}');
    exit(1);
  }

  if (argumentsParsed.hasHelp) {
    logger.info('A command-line tool to generate an asset class.\n');
    logger.info('Usage: dart Pharaoh [options]\n');
    logger.info('Global options:');
    logger.info('${argumentsParsed.usage}\n');
    exit(1);
  }
  if (argumentsParsed.creatingNew) {
    if (!argumentsParsed.hasProjectName) {
      logger.err('Please provide a project name.');
      final projName = logger.prompt(
        'What is the name of your project?',
        defaultValue: 'new_project',
      );
      return createPharaohProject(projName);
    } else {
      createPharaohProject(argumentsParsed.projectName);
    }
  }
  argumentsParsed.parse();

  // Watch for file changes in the 'lib' directory
  final watcher = DirectoryWatcher('lib');
  // Handle file changes
  watcher.events.listen((event) {
    if (event.type == ChangeType.MODIFY ||
        event.type == ChangeType.ADD ||
        event.type == ChangeType.REMOVE) {
      logger.prompt('File changed: ${event.path}');
      buildRunner();
    }
  });
}

class ArgumentParser {
  final List<String> args;
  ArgumentParser(this.args);

  // parse function
  void parse() {
    // check for invalid arguments and unknown flags
    invalidArgument();
    return;
  }

  bool get hasArguments => args.isNotEmpty;
  bool get hasVersion => args.contains('-v') || args.contains('--version');
  bool get hasHelp => args.contains('-h') || args.contains('--help');
  bool get creatingNew => hasArguments && args.first == "new";
  bool get hasProjectName => args[1].isNotEmpty;
  String get projectName => args[1];

  String version = '0.0.1';

  String usage = '''
    -h, --help       Show this help message.
    -v, --version    Show the version of this application.
  ''';

  void invalidArgument() {
    Map<String, String> flags = {};
    for (var i = 0; i < args.length; i += 2) {
      if (args[i].startsWith('-')) {
        if ([
          '-v',
          '--version',
          '-h',
          '--help',
        ].contains(args[i])) {
          if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
            flags[args[i]] = args[i + 1];
          } else {
            throw Exception('''Expected a value after ${args[i]}
                Run `Pharoah --help` for more information.
                ''');
          }
        } else {
          throw Exception('''Unknown flag ${args[i]}
              Run `Pharoah --help` for more information.
              ''');
        }
      } else {
        throw Exception('''Invalid argument ${args[i]}
            Run `Pharoah --help` for more information.
            ''');
      }
    }
  }
}

void createPharaohProject(String projectName) {
  final progress = logger.progress('Creating $projectName Pharaoh project ...');
  progress.update('Creating $projectName Pharoah project ...');
  Process.run('dart', ['create', '-t', 'console', projectName]).then((ProcessResult results) {
    if (results.exitCode == 0) {
      progress.update(results.stdout);
      progress
          .complete('✅Pharoah project "$projectName" created successfully.\nHappy Coding 🐎🐎🐎');
    } else {
      progress.fail('❌Error creating Pharoah project. Please check the dart installation.');
    }
  });
}

void buildRunner() {
  final progress = logger.progress('Running build_runner...');
  progress.update('Running build_runner...');
  Process.run('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'])
      .then((ProcessResult result) {
    if (result.exitCode == 0) {
      progress.complete('✅Successfully updated generated files...');
    } else {
      progress.fail('❌Error updating generated files...');
    }
  });
}

final repoLink = link(
  message: 'GitHub Repository',
  uri: Uri.parse('https://github.com/codekeyz/yaroo-example'),
);
