import 'package:aoc/day22/part1/run.dart';

void main() {
  final instructions = parseInstructions('10R5L5R10L4R5L5');
  for (final i in instructions) {
    print(i);
  }
}
