import 'dart:io';

class Util {
  static Future<List<String>> readFileAsStrings(String filepath) async {
    final file = File(filepath);
    return file.readAsLinesSync();
  }

  static Future<List<int>> readFileAsInts(String filepath) async {
    final vals = await readFileAsStrings(filepath);
    List<int> result = [];
    for (final val in vals) {
      result.add(int.parse(val));
    }
    return result;
  }
}
