import 'dart:io';

import 'package:quiver/core.dart';

import '../../src/util.dart';

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  @override
  bool operator ==(other) => other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => hash2(x, y);
}

class Grove {
  Set<Point> elves = {};

  Grove();

  void addElf(Point elf) {
    elves.add(elf);
  }

  int minX() {
    int min = 100000;
    for (final elf in elves) {
      if (elf.x < min) {
        min = elf.x;
      }
    }
    return min;
  }

  int maxX() {
    int max = -1;
    for (final elf in elves) {
      if (elf.x > max) {
        max = elf.x;
      }
    }
    return max;
  }

  int minY() {
    int min = 100000;
    for (final elf in elves) {
      if (elf.y < min) {
        min = elf.y;
      }
    }
    return min;
  }

  int maxY() {
    int max = -1;
    for (final elf in elves) {
      if (elf.y > max) {
        max = elf.y;
      }
    }
    return max;
  }

  void printGrove() {
    for (int i = minY(); i <= maxY(); i++) {
      for (int j = minX(); j <= maxX(); j++) {
        final valToPrint = elves.contains(Point(j, i)) ? '#' : '.';
        stdout.write(valToPrint);
      }
      print('');
    }
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // parse the input
  final grove = Grove();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (int j = 0; j < line.length; j++) {
      final char = line[j];
      if (char == '#') {
        grove.addElf(Point(j, i));
      }
    }
  }
  grove.printGrove();
}
