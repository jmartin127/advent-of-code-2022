import '../../src/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');
  final line = lines[0];
  for (int i = 3; i < line.length; i++) {
    Map<String, bool> numUnique = {};
    numUnique[line[i]] = true;
    numUnique[line[i - 1]] = true;
    numUnique[line[i - 2]] = true;
    numUnique[line[i - 3]] = true;
    if (numUnique.keys.length == 4) {
      print(i + 1);
      break;
    }
  }
}
