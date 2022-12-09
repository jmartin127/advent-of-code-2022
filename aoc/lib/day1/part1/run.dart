import '../../src/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  var currentTotal = 0;
  var max = 0;
  for (final line in lines) {
    if (line.isEmpty) {
      if (currentTotal > max) {
        max = currentTotal;
      }
      currentTotal = 0;
    } else {
      currentTotal += int.parse(line);
    }
  }
  print(max);
}
