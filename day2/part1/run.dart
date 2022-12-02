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

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  int total = 0;
  for (final line in lines) {
    final vals = line.split(' ');
    final them = vals[0];
    final me = vals[1];
    total += result[them + me]! + shape_selected[me]!;
  }
  print(total);
}
