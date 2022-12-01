import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsInts('input.txt');
  var total = 0;
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
    total += line;
  }
  print(total);
}
