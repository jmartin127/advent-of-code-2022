import 'dart:io';

import '../../src/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // read all the instructions
  List<int> instructions = [];
  for (final line in lines) {
    if (line == 'noop') {
      instructions.add(0);
    } else if (line.startsWith('addx')) {
      final parts = line.split(' ');
      final amt = int.parse(parts[1]);
      instructions.add(0);
      instructions.add(amt);
    }
  }

  List<int> vals = [];
  int x = 1;
  int prevX = 0;
  for (int i = 0; i < instructions.length; i++) {
    x += instructions[i];
    vals.add(prevX);
    prevX = x;
  }

  // print the answer
  for (int i = 0; i < vals.length; i++) {
    final val = vals[i];
    final printPos = i % 40;
    final shouldPrint =
        val == printPos || val - 1 == printPos || val + 1 == printPos;
    stdout.write(shouldPrint ? '#' : '.');
    if ((i + 1) % 40 == 0) {
      print('');
    }
  }
}
