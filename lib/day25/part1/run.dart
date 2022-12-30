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
  // answer in decimal on real data: 34279402189875

  // generate a set of snafu numbers
  // print(Snafu('1121-1110-1=0'.split('')).toInt());
  // -----------------------------------------
  final finalAnswer = Snafu('2-00=12=21-0=01--000'.split('')).toInt();
  print('$finalAnswer');
  if (finalAnswer > result) {
    print('too high');
  } else if (finalAnswer < result) {
    print('too low');
  } else {
    print('correct!');
  }

  // incorrect: 02-00=12=21-0=01--000 (had a leading zero)
}

Snafu toSnafu(int input) {
  final vals = input.toString().split('');

  int place = 0;
  Snafu answer = Snafu([]);
  for (int i = vals.length - 1; i >= 0; i--) {
    final char = vals[i];
    final placePowerTen = pow(10, place).toInt();
    final timesVal = int.parse(char);
    final result = placePowerTen * timesVal;
    print(placePowerTen);
    if (result == 5 && answer.vals.isEmpty) {
      answer = Snafu(['1', '0']);
      place++;
      continue;
    }
    throw Exception('need to add $result to the current snafu');
    place++;
  }
  return answer;
}
