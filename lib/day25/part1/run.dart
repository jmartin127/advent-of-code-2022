import 'dart:math';

import '../../src/util.dart';

class Snafu {
  List<String> vals;

  Snafu(this.vals);

  // SNAFU works the same way, except it uses powers of five instead of ten.
  // Starting from the right, you have a ones place, a fives place, a
  // twenty-fives place, a one-hundred-and-twenty-fives place, and so on. It's
  // that easy!
  //
  // Instead of using digits four through zero, the digits are 2, 1, 0, minus
  // (written -), and double-minus (written =). Minus is worth -1, and
  // double-minus is worth -2.
  int toInt() {
    int place = 0;
    int answer = 0;
    for (int i = vals.length - 1; i >= 0; i--) {
      final char = vals[i];
      final placePowerFive = pow(5, place).toInt();
      final timesVal = char == '-'
          ? -1
          : char == '='
              ? -2
              : int.parse(char);
      final result = placePowerFive * timesVal;
      answer += result;
      place++;
    }
    return answer;
  }

  @override
  String toString() {
    return vals.toString();
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  List<Snafu> snafus = [];
  for (final line in lines) {
    snafus.add(Snafu(line.split('')));
  }

  int result = 0;
  for (final snafu in snafus) {
    result += snafu.toInt();
  }
  print(result);

  // answer in decimal: 34279402189875
}
