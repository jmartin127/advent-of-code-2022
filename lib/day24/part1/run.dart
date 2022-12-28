import 'dart:io';

import 'package:quiver/core.dart';

import '../../src/util.dart';

enum Facing {
  left,
  right,
  up,
  down,
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  @override
  bool operator ==(other) => other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => hash2(x, y);
}

class Blizzard {
  Point currentLocation;
  Facing facing;

  Blizzard(this.currentLocation, this.facing);

  static Blizzard parseBlizzard(int x, int y, String facingDir) {
    final loc = Point(x, y);
    Facing face;
    switch (facingDir) {
      case '>':
        face = Facing.right;
        break;
      case '<':
        face = Facing.left;
        break;
      case 'v':
        face = Facing.down;
        break;
      case '^':
        face = Facing.up;
        break;
      default:
        throw Exception('Unable to parse blizzard direction from $facingDir');
    }
    return Blizzard(loc, face);
  }

  String facingAsString() {
    switch (facing) {
      case Facing.left:
        return '<';
      case Facing.right:
        return '>';
      case Facing.up:
        return '^';
      case Facing.down:
        return 'v';
    }
  }
}

class Basin {
  List<List<String>> values = [];
  Map<Point, List<Blizzard>> blizzardsByPosition = {};
  late Point startPosition;
  late Point endPosition;

  /*
    #.######
    #>>.<^<#
    #.<..<<#
    #>v.><>#
    #<^v^^>#
    ######.#
  */
  Basin(List<String> input) {
    for (int i = 0; i < input.length; i++) {
      final line = input[i];
      List<String> row = [];
      final chars = line.split('');
      for (int j = 0; j < chars.length; j++) {
        final char = chars[j];
        row.add(char == '#' ? char : '.');
        if (char != '#' && char != '.') {
          final newBlizzard = Blizzard.parseBlizzard(j, i, char);
          final currentPos = Point(j, i);
          if (blizzardsByPosition.containsKey(currentPos)) {
            blizzardsByPosition[currentPos]!.add(newBlizzard);
          } else {
            blizzardsByPosition[currentPos] = [newBlizzard];
          }
        }
      }
      values.add(row);
    }

    // Your expedition begins in the only non-wall position in the top row and
    // needs to reach the only non-wall position in the bottom row.
    for (int x = 0; x < values.length; x++) {
      if (values[0][x] == '.') {
        startPosition = Point(x, 0);
      }
    }
    for (int x = 0; x < values.length; x++) {
      if (values[values.length - 1][x] == '.') {
        startPosition = Point(x, values.length - 1);
      }
    }
  }

  void printBasin() {
    for (int i = 0; i < values.length; i++) {
      for (int j = 0; j < values[0].length; j++) {
        var char = values[i][j];
        final currentPoint = Point(j, i);
        if (blizzardsByPosition.containsKey(currentPoint)) {
          final blizzards = blizzardsByPosition[currentPoint]!;
          if (blizzards.length > 1) {
            char = '${blizzards.length}';
          } else if (blizzards.length == 1) {
            char = blizzards[0].facingAsString();
          }
        }
        stdout.write(char);
      }
      print('');
    }
  }
}

Future<void> main() async {
  final input = await Util.readFileAsStrings('input.txt');

  // initialize the basin
  final basin = Basin(input);
  basin.printBasin();

  // run for each minute
}

void runOneMinute(Basin basin) {}
