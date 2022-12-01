import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  var currentTotal = 0;
  var max = 0;
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
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
