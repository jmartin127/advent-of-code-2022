import '../../util/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  /*
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
  */
  int result = 0;
  for (final line in lines) {
    final groups = line.split(',');
    final group1 = groups[0];
    final group2 = groups[1];

    final group1Parts = group1.split('-');
    final group2Parts = group2.split('-');

    final group1Start = int.parse(group1Parts[0]);
    final group1End = int.parse(group1Parts[1]);

    final group2Start = int.parse(group2Parts[0]);
    final group2End = int.parse(group2Parts[1]);

    // check if one start is within 2's range
    if (group1Start >= group2Start && group1Start <= group2End) {
      result++;
      continue;
      // check if two is contained in one
    } else if (group2Start >= group1Start && group2Start <= group1End) {
      result++;
      continue;
    }
  }
  print(result);
}
