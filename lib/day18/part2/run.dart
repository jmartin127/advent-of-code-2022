import 'package:quiver/core.dart';

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

  @override
  bool operator ==(other) => other is Cube && x == x && y == y && z == z;

  @override
  int get hashCode => hash3(x.hashCode, y.hashCode, z.hashCode);

  Cube copy() {
    return Cube(x, y, z);
  }

  touchSide(Side side) {
    sidesTouched.add(side);
  }

  int numSidesTouched() {
    return sidesTouched.length;
  }

  int numSidesNotTouched() {
    return 6 - sidesTouched.length;
  }

  bool isTouching(Cube other) {
    // x-axis
    if (abs(x, other.x) == 1 && y == other.y && z == other.z) {
      return true;
    }

    // y-axis
    if (x == other.x && abs(y, other.y) == 1 && z == other.z) {
      return true;
    }

    // z-axis
    if (x == other.x && y == other.y && abs(z, other.z) == 1) {
      return true;
    }

    return false;
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
  Set<Cube> cubes = {};
  for (final line in lines) {
    final parts = line.split(',');
    final cube =
        Cube(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    cubes.add(cube);
  }
  print('Num cubes: ${cubes.length}');
  print(cubes);

  // find the dimensions
  int minX = 100000;
  int maxX = -1;
  int minY = 100000;
  int maxY = -1;
  int minZ = 100000;
  int maxZ = -1;
  for (final cube in cubes) {
    if (cube.x < minX) {
      minX = cube.x;
    }
    if (cube.x > maxX) {
      maxX = cube.x;
    }
    if (cube.y < minY) {
      minY = cube.y;
    }
    if (cube.y > maxY) {
      maxY = cube.y;
    }
    if (cube.z < minZ) {
      minZ = cube.z;
    }
    if (cube.z > maxZ) {
      maxZ = cube.z;
    }
  }
  print('X: $minX --> $maxX');
  print('Y: $minY --> $maxY');
  print('Z: $minZ --> $maxZ');

  // Then starting with a shell of cubes that is just outside the mins/maxes...
  // set these cubes as our starting water/steam cubes
  // start with the layer just above the highest Z.
  // go just one bigger than the x/y as well so that we for sure capture
  // everything and don't call non-water cubes water cubes
  Set<Cube> waterCubes = {};
  for (int j = minY - 1; j <= maxY + 1; j++) {
    for (int i = minX - 1; i <= maxX + 1; i++) {
      final cube = Cube(i, j, maxZ + 1);
      waterCubes.add(cube);
    }
  }
  print('Num of water cubes: ${waterCubes.length}');

  // check for any solid turned to water
  for (final cube in cubes) {
    if (waterCubes.contains(cube)) {
      throw Exception('Solid turned to water: $cube');
    }
  }

  // now we just have the top slice as water cubes, BUT we know anything that
  // touches these cubes that is NOT in the list of solid cubes, IS a water cube
  // so we just need to find all the water cubes within the range we care about
  // in an iterative fashion, coninuing to find more and more water cubes

  // loop through every cube in the area we care about and see if it is
  // touching a water cube, or it already is a water cube, or it already
  // is a solid cube.  If it is NOT either a water or a solid, but it touches
  // a water cube, then make it a water cube as well.
  Set<Cube> currentWaterCubes = waterCubes;
  for (int i = 0; i < 100; i++) {
    final newWaterCubes = findNewWaterCubes(
        minZ, maxZ, minY, maxY, minX, maxX, cubes, currentWaterCubes);
    print('Num of new water cubes: ${newWaterCubes.length}');

    // check for any solid turned to water, and don't add these to the list
    for (final cube in cubes) {
      if (newWaterCubes.contains(cube)) {
        newWaterCubes.remove(cube);
      }
    }

    currentWaterCubes.addAll(newWaterCubes);
    print('Total water cubes: ${currentWaterCubes.length}');
  }

  // once we have found all of the water cubes, we just need to find any cube
  // that is touching these cubes... and then add up the surface area of
  // anything touching water cubes
  for (final cube in cubes) {
    for (final waterCube in waterCubes) {
      cube.updateCubesTouching(waterCube);
    }
  }

  int answer = 0;
  for (final cube in cubes) {
    answer += cube.numSidesTouched();
  }
  print('Answer: $answer');

  // answer is too low: 1394
  // answer is too low: 2472
}

Set<Cube> findNewWaterCubes(int minZ, int maxZ, int minY, int maxY, int minX,
    int maxX, Set<Cube> cubes, Set<Cube> waterCubes) {
  Set<Cube> newWaterCubes = {};
  for (int k = minZ - 1; k <= maxZ + 1; k++) {
    for (int j = minY - 1; j <= maxY + 1; j++) {
      for (int i = minX - 1; i <= maxX + 1; i++) {
        final Cube currentCube = Cube(i, j, k);
        // check if it is a solid or water cube already
        if (cubes.contains(currentCube)) {
          continue;
        } else if (waterCubes.contains(currentCube)) {
          continue;
        }

        // check if it touches a water cube
        for (final waterCube in waterCubes) {
          if (currentCube.isTouching(waterCube)) {
            if (!cubes.contains(currentCube)) {
              newWaterCubes.add(currentCube);
            }
          }
        }
      }
    }
  }
  return newWaterCubes;
}

int abs(int a, int b) {
  if (a > b) {
    return a - b;
  }
  return b - a;
}
