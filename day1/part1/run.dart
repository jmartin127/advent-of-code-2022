import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsInts(
      '/Users/jeff/workspace/advent-of-code-2022/day1/input.txt');

  var total = 0;
  for (final line in lines) {
    total += line;
  }
  print(total);
}
