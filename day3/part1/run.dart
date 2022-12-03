import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  int total = 0;
  for (final line in lines) {
    outerLoop:
    for (int i = 0; i < line.length / 2; i++) {
      for (int j = line.length ~/ 2; j < line.length; j++) {
        final a = line[i];
        final b = line[j];
        if (a == b) {
          print(a);
          var answer = a.codeUnitAt(0) - 96;
          if (answer < 0) {
            answer += 58;
          }
          total += answer;
          break outerLoop;
        }
      }
    }
    print(total);
  }
}
