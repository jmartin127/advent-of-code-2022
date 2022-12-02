import '../../util/util.dart';

// a,b,c
// x,y,z
// r,p,s
const result = {
  'AX': 3,
  'AY': 6,
  'AZ': 0,
  'BX': 0,
  'BY': 3,
  'BZ': 6,
  'CX': 6,
  'CY': 0,
  'CZ': 3
};
const shape_selected = {'X': 1, 'Y': 2, 'Z': 3};

// X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win. Good luck!"

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  int total = 0;
  for (final line in lines) {
    final vals = line.split(' ');
    final them = vals[0];
    final me = vals[1];

    var actualMe = '';
    if (me == 'Y') {
      // Y means you need to end the round in a draw
      if (them == 'A') {
        actualMe = 'X';
      } else if (them == 'B') {
        actualMe = 'Y';
      } else {
        actualMe = 'Z';
      }
    } else if (me == 'X') {
      // X means you need to lose
      if (them == 'A') {
        actualMe = 'Z';
      } else if (them == 'B') {
        actualMe = 'X';
      } else {
        actualMe = 'Y';
      }
    } else {
      // Z means you need to win
      if (them == 'A') {
        actualMe = 'Y';
      } else if (them == 'B') {
        actualMe = 'Z';
      } else {
        actualMe = 'X';
      }
    }

    total += result[them + actualMe]! + shape_selected[actualMe]!;
  }
  print(total);
}
