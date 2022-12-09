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

  /*
    92  3 88 13 50
    90 70 24 28 52
    15 98 10 26  5
    84 34 37 73 87
    25 36 74 33 63
  */
  static Future<List<List<int>>> readIntMatrix(String filepath) async {
    final lines = await readFileAsStrings(filepath);
    List<List<int>> result = [];
    for (final line in lines) {
      final parts = line.split('');
      List<int> row = [];
      for (final part in parts) {
        if (part.isEmpty) {
          continue;
        }
        row.add(int.parse(part));
      }
      result.add(row);
    }
    return result;
  }
}
