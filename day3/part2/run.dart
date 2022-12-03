import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  List<String> lineSet = [];
  int total = 0;
  for (final line in lines) {
    lineSet.add(line);
    if (lineSet.length == 3) {
      final val = findIntersectionOfLines(lineSet);
      var answer = val.codeUnitAt(0) - 96;
      if (answer < 0) {
        answer += 58;
      }
      total += answer;
      lineSet = [];
    }
  }
  print(total);
}

String findIntersectionOfLines(List<String> lineSet) {
  Map<String, int> counts = {};
  addToCounts(lineSet[0], counts);
  addToCounts(lineSet[1], counts);
  addToCounts(lineSet[2], counts);
  for (final entry in counts.entries) {
    if (entry.value == 3) {
      return entry.key;
    }
  }
  return '';
}

void addToCounts(String line, Map<String, int> counts) {
  Map<String, bool> haveSeen = {};
  for (final char in line.split('')) {
    if (haveSeen.containsKey(char)) {
      continue;
    }
    haveSeen[char] = true;
    if (counts.containsKey(char)) {
      counts[char] = counts[char]! + 1;
    } else {
      counts[char] = 1;
    }
  }
}
