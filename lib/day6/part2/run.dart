import '../../src/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');
  final line = lines[0];
  for (int i = 13; i < line.length; i++) {
    Map<String, bool> numUnique = {};
    for (int j = i; j >= i - 13 && j >= 0; j--) {
      numUnique[line[j]] = true;
    }
    if (numUnique.keys.length == 14) {
      print(i + 1);
      break;
    }
  }
}
