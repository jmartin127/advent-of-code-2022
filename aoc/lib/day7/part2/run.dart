import '../../src/util.dart';

class Directory {
  String name;
  List<Directory> childrenDirs;
  List<File> childrenFiles;
  Directory? parentDirectory;
  Directory(
      this.name, this.childrenDirs, this.childrenFiles, this.parentDirectory);

  @override
  String toString() {
    return 'Dir Name: $name. Num children dirs: ${childrenDirs.length}. Num children files ${childrenFiles.length}';
  }

  int size() {
    int size = 0;
    for (final file in childrenFiles) {
      size += file.size;
    }
    for (final dir in childrenDirs) {
      size += dir.size();
    }
    return size;
  }

  String fullPath() {
    if (parentDirectory == null) {
      return name;
    }
    return parentDirectory!.fullPath() + '/' + name;
  }
}

class File {
  String name;
  int size;
  File(this.name, this.size);

  @override
  String toString() {
    return 'File Name: $name, Size: $size';
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // first read in the directory structure
  Directory rootDir = Directory('/', [], [], null);
  Directory currentDir = rootDir;
  Map<String, Directory> directoriesByPath = {};
  directoriesByPath['/'] = rootDir;
  for (final line in lines) {
    final lineParts = line.split(' ');
    if (line.startsWith('\$')) {
      final cmd = lineParts[1];
      if (cmd == 'cd') {
        final targetDirName = lineParts[2];
        if (targetDirName == '..') {
          currentDir = currentDir.parentDirectory!;
        } else {
          if (targetDirName == '/') {
            currentDir = rootDir;
          } else {
            final targetDirFullPath =
                currentDir.fullPath() + '/' + targetDirName;
            final targetDir = directoriesByPath[targetDirFullPath]!;
            currentDir = targetDir;
          }
        }
      } else if (cmd == 'ls') {
        // nothing to do here actually
      }
    } else {
      // results of ls command

      // track the new directory
      if (line.startsWith('dir')) {
        final newDirectoryName = lineParts[1];
        final newDirectoryPath = currentDir.fullPath() + '/' + newDirectoryName;

        // check if the directory already exists
        if (!directoriesByPath.containsKey(newDirectoryPath)) {
          final newDirectory = Directory(newDirectoryName, [], [], currentDir);

          // add this directory to the parent
          currentDir.childrenDirs.add(newDirectory);

          // add this directory to the hash
          directoriesByPath[newDirectory.fullPath()] = newDirectory;
        }
      } else {
        // track the new file
        final newFileSize = int.parse(lineParts[0]);
        final newFileName = lineParts[1];
        final newFile = File(newFileName, newFileSize);

        // add this file to the parent
        currentDir.childrenFiles.add(newFile);
      }
    }
  }

  // then read the size of each directory recursively
  print('Root children dirs: ${rootDir.childrenDirs}');
  print('Root children files: ${rootDir.childrenFiles}');
  print('Num dirs: ${directoriesByPath.keys.length}');

  // print the size of each dir
  int result = 0;
  for (final dir in directoriesByPath.values) {
    //print('Size: ${dir.size()}');
    if (dir.size() <= 100000) {
      result += dir.size();
    }
  }
  print(result);

  // determine what to delete
  int outermost = rootDir.size();
  int totalDisk = 70000000;
  int unused = totalDisk - outermost;
  print('Unused: $unused');
  int requiredForUpdate = 30000000;
  int toBeDeleted = requiredForUpdate - unused;
  print('To be deleted: $toBeDeleted');

  // find the smallest one that is just over this amount
  int min = 100000000000;
  for (final dir in directoriesByPath.values) {
    if (dir.size() < min && dir.size() >= toBeDeleted) {
      min = dir.size();
    }
  }
  print(min);
}
