import 'dart:io';

import 'package:quiver/core.dart';

import '../../src/util.dart';

enum Direction {
  north,
  east,
  south,
  west,
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

class Grove {
  Set<Point> elves = {};

  Grove();

  // The Elf looks in each of four directions in the following order and proposes
  // moving one step in the first valid direction:
  //
  // If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
  // If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
  // If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
  // If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.
  Point? proposeMove(Point elf, List<Direction> directionOrder) {
    for (final direction in directionOrder) {
      switch (direction) {
        case Direction.north:
          if (isOpen(elf.x - 1, elf.y - 1) &&
              isOpen(elf.x, elf.y - 1) &&
              isOpen(elf.x + 1, elf.y - 1)) {
            return Point(elf.x, elf.y - 1); // move north
          }
          break;
        case Direction.east:
          if (isOpen(elf.x + 1, elf.y - 1) &&
              isOpen(elf.x + 1, elf.y) &&
              isOpen(elf.x + 1, elf.y + 1)) {
            return Point(elf.x + 1, elf.y); // move east
          }
          break;
        case Direction.south:
          if (isOpen(elf.x - 1, elf.y + 1) &&
              isOpen(elf.x, elf.y + 1) &&
              isOpen(elf.x + 1, elf.y + 1)) {
            return Point(elf.x, elf.y + 1); // move south
          }
          break;
        case Direction.west:
          if (isOpen(elf.x - 1, elf.y - 1) &&
              isOpen(elf.x - 1, elf.y) &&
              isOpen(elf.x - 1, elf.y + 1)) {
            return Point(elf.x - 1, elf.y); // move west
          }
          break;
      }
    }
    return null;
  }

  bool isOpen(int x, int y) {
    return !elves.contains(Point(x, y));
  }

  // During the first half of each round, each Elf considers the eight positions
  // adjacent to themself.
  bool isAnyElfClose(Point elf) {
    for (int i = elf.y - 1; i <= elf.y + 1; i++) {
      for (int j = elf.x - 1; j <= elf.x + 1; j++) {
        if (i == elf.y && j == elf.x) {
          continue; // skip itself
        }
        if (elves.contains(Point(j, i))) {
          return true;
        }
      }
    }
    return false;
  }

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

  // To do this, count the number of empty ground tiles contained by the
  //smallest rectangle that contains every Elf.
  int countEmptyGroundtiles() {
    int result = 0;
    for (int i = minY(); i <= maxY(); i++) {
      for (int j = minX(); j <= maxX(); j++) {
        if (!elves.contains(Point(j, i))) {
          result++;
        }
      }
    }
    return result;
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

  List<Direction> directionOrder = [
    Direction.north,
    Direction.south,
    Direction.west,
    Direction.east,
  ];

  // Figure out where the Elves need to go. What is the number of the first round where no Elf moves?
  Grove currentGrove = grove;
  int iterationNumber = 0;
  while (true) {
    iterationNumber++;
    print('Iteration Number: $iterationNumber');
    currentGrove = runRound(currentGrove, directionOrder);
  }
}

Grove runRound(Grove grove, List<Direction> directionOrder) {
  // 1st have of the round, make proposals
  Map<Point, int> proposalCounts = {};
  Map<Point, Point> proposalsByElf = {};
  for (final elf in grove.elves) {
    // If no other Elves are in one of those eight positions, the Elf does not
    // do anything during this round.
    if (!grove.isAnyElfClose(elf)) {
      continue;
    }

    // Otherwise, the Elf looks in each of four directions in the following
    // order and proposes moving one step in the first valid direction:
    final proposal = grove.proposeMove(elf, directionOrder);
    if (proposal != null) {
      proposalsByElf[elf] = proposal;
      if (proposalCounts.containsKey(proposal)) {
        proposalCounts[proposal] = proposalCounts[proposal]! + 1;
      } else {
        proposalCounts[proposal] = 1;
      }
    }
  }

  // After each Elf has had a chance to propose a move, the second half of the
  // round can begin. Simultaneously, each Elf moves to their proposed destination
  // tile if they were the only Elf to propose moving to that position. If two or
  // more Elves propose moving to the same position, none of those Elves move.
  Grove newGrove = Grove();
  int numMoved = 0;
  for (final elf in grove.elves) {
    final proposal = proposalsByElf[elf];
    if (proposal == null) {
      newGrove.addElf(elf);
      continue;
    }
    final proposalCount = proposalCounts[proposal]!;
    if (proposalCount == 1) {
      newGrove.addElf(proposal);
      numMoved++;
    } else {
      newGrove.addElf(elf);
    }
  }
  if (numMoved == 0) {
    throw Exception('No elves moved!');
  }

  // Finally, at the end of the round, the first direction the Elves considered
  // is moved to the end of the list of directions. For example, during the second
  // round, the Elves would try proposing a move to the south first, then west,
  // then east, then north. On the third round, the Elves would first consider
  // west, then east, then north, then south.
  moveFrontToBack(directionOrder);

  return newGrove;
}

void moveFrontToBack(List<Direction> directionOrder) {
  final front = directionOrder.removeAt(0);
  directionOrder.add(front);
}
