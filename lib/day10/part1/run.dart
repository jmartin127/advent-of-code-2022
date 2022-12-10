import '../../src/util.dart';

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  List<int> instructions = [];
  int x = 1;
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

  int total = 0;
  int prevX = 0;
  for (int i = 0; i < instructions.length; i++) {
    x += instructions[i];
    print('Cycle: ${i + 1}: $x, ${(i + 1) * x}');
    final num = (i + 1) * prevX;
    final cycle = i + 1;
    if (cycle == 20 ||
        cycle == 60 ||
        cycle == 100 ||
        cycle == 140 ||
        cycle == 180 ||
        cycle == 220) {
      total += num;
    }
    prevX = x;
  }
  print(total);
}
