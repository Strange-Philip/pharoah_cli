import 'dart:io';
import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:watcher/watcher.dart';

final logger = Logger(
  level: Level.info,
  theme: LogTheme(),
);

void main(List<String> arguments) {
  logger.info('Welcome to Yaroo CLI 🐎🐎🐎');
  logger.info('Yaroo CLI is a command line tool for Pharaoh framework.');
  logger.info('Mind giving us a star on $repoLink? It helps us out a lot.\n');
  final ArgParser argParser = ArgParser()
    ..addCommand('create')
    ..addOption(
      'projectName',
      abbr: 'p',
      help: 'Your project name',
    )
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Display the current version')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Display usage information');

  ArgResults argResults;
  try {
    argResults = argParser.parse(arguments);
  } on ArgParserException catch (e) {
    logger.info(e.message);
    logger.info(argParser.usage);
    exit(1);
  }
  if (argResults['help']) {
    logger.info('A command-line tool to generate an asset class.\n');
    logger.info('Usage: dart Pharaoh [options]\n');
    logger.info('Global options:');
    logger.info('''
    -h, --help       Show this help message.
    -v, --version    Show the version of this application.
  ''');
    exit(0);
  }

  final String command = argResults.command?.name ?? '';

  switch (command) {
    case 'create':
      createProject(argResults);
      break;
    default:
      logger.info('Invalid command. Use "create" command.');
      logger.info(argParser.usage);
      exit(1);
  }

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

void createProject(ArgResults argResults) {
  final String? projectName = argResults['projectName'];

  if (projectName == null || projectName.isEmpty) {
    logger.err('Please provide a project name.');
    final projName = logger.prompt(
      'What is the name of your project?',
      defaultValue: 'new_project',
    );
    return fetchGitHubProject(projName);
  }
  fetchGitHubProject(projectName);
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

void fetchGitHubProject(String projectName) {
  final progress = logger.progress('Cloning template from github ...');
  // Check if git is installed
  String githubLink = "https://github.com/codekeyz/yaroo-example";
  ProcessResult result = Process.runSync('git', ['--version']);
  if (result.exitCode != 0) {
    progress.fail('❌Error: Git is not installed. Please install Git..');
    exit(1);
  }

  // Clone the GitHub project
  Process.run('git', ['clone', githubLink, projectName]).then((ProcessResult results) {
    if (result.exitCode == 0) {
      progress.complete('✅Yaroo project "$projectName" created successfully.\nHappy Coding 🐎🐎🐎');
    } else {
      progress.fail('❌Error cloning GitHub project. Please check the GitHub link and try again...');
    }
  });
}

final repoLink = link(
  message: 'GitHub Repository',
  uri: Uri.parse('https://github.com/codekeyz/yaroo-example'),
);
