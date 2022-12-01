import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  var currentTotal = 0;
  List<int> allVals = [];
  for (final line in lines) {
    if (line.isEmpty) {
      allVals.add(currentTotal);
      currentTotal = 0;
    } else {
      currentTotal += int.parse(line);
    }
  }
  allVals.add(currentTotal);
  allVals.sort();

  print(allVals[allVals.length - 1] +
      allVals[allVals.length - 2] +
      allVals[allVals.length - 3]);
}
