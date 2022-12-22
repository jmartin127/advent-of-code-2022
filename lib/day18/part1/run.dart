import '../../../src/util.dart';

enum Side {
  xNeg,
  xPos,
  yNeg,
  yPos,
  zNeg,
  zPos,
}

class Cube {
  int x;
  int y;
  int z;
  Set<Side> sidesTouched = {};

  Cube(this.x, this.y, this.z);

  touchSide(Side side) {
    sidesTouched.add(side);
  }

  int numSidesNotTouched() {
    return 6 - sidesTouched.length;
  }

  void updateCubesTouching(Cube other) {
    // x-axis
    if (abs(x, other.x) == 1 && y == other.y && z == other.z) {
      if (x > other.x) {
        sidesTouched.add(Side.xNeg);
        other.sidesTouched.add(Side.xPos);
      } else {
        sidesTouched.add(Side.xPos);
        other.sidesTouched.add(Side.xNeg);
      }
    }

    // y-axis
    if (x == other.x && abs(y, other.y) == 1 && z == other.z) {
      if (y > other.y) {
        sidesTouched.add(Side.yNeg);
        other.sidesTouched.add(Side.yPos);
      } else {
        sidesTouched.add(Side.yPos);
        other.sidesTouched.add(Side.yNeg);
      }
    }

    // z-axis
    if (x == other.x && y == other.y && abs(z, other.z) == 1) {
      if (z > other.z) {
        sidesTouched.add(Side.zNeg);
        other.sidesTouched.add(Side.zPos);
      } else {
        sidesTouched.add(Side.zPos);
        other.sidesTouched.add(Side.zNeg);
      }
    }
  }

  @override
  String toString() {
    return 'x: $x, y: $y, z: $z';
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // read in all cubes
  List<Cube> cubes = [];
  for (final line in lines) {
    // 2,2,2
    final parts = line.split(',');
    cubes.add(
        Cube(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])));
  }
  print('Num cubes: ${cubes.length}');
  print(cubes);

  Set<Cube> cubesProcessed = {};

  // have each cube touch each other cube
  for (final cube in cubes) {
    for (final otherCube in cubesProcessed) {
      cube.updateCubesTouching(otherCube);
    }
    cubesProcessed.add(cube);
  }

  // print the answer
  int answer = 0;
  for (final cube in cubes) {
    answer += cube.numSidesNotTouched();
  }
  print(answer);
}

int abs(int a, int b) {
  if (a > b) {
    return a - b;
  }
  return b - a;
}
