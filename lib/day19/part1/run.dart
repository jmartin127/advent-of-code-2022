import '../../src/util.dart';

enum Resource {
  ore,
  clay,
  obsidian,
  geode,
}

class Robot {
  Resource type;
  Map<Resource, int> cost = {};

  Robot(this.type, this.cost);

  @override
  String toString() {
    return 'Type: $type, Cost: $cost';
  }
}

class Blueprint {
  int id;
  List<Robot> robots;

  Blueprint(this.id, this.robots);

  @override
  String toString() {
    return 'Id: $id, Robots: $robots';
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  List<Blueprint> blueprints = [];
  for (String line in lines) {
    // Blueprint 1: Each ore robot costs 2 ore. Each clay robot costs 2 ore. Each obsidian robot costs 2 ore and 17 clay. Each geode robot costs 2 ore and 10 obsidian.
    line = line.replaceAll(':', '');
    final lineParts = line.split(' ');
    final id = int.parse(lineParts[1]);

    // Each ore robot costs 2 ore.
    Robot oreRobot =
        Robot(Resource.ore, {Resource.ore: int.parse(lineParts[6])});

    // Each clay robot costs 2 ore.
    Robot clayRobot =
        Robot(Resource.clay, {Resource.ore: int.parse(lineParts[12])});

    // Each obsidian robot costs 2 ore and 17 clay.
    Robot obsidianRobot = Robot(Resource.obsidian, {
      Resource.ore: int.parse(lineParts[18]),
      Resource.clay: int.parse(lineParts[21])
    });

    // Each geode robot costs 2 ore and 10 obsidian.
    Robot geodedRobot = Robot(Resource.geode, {
      Resource.ore: int.parse(lineParts[27]),
      Resource.obsidian: int.parse(lineParts[30])
    });

    List<Robot> robots = [oreRobot, clayRobot, obsidianRobot, geodedRobot];
    blueprints.add(Blueprint(id, robots));
  }

  print('Num of blueprints: ${blueprints.length}');
  for (final blueprint in blueprints) {
    print(blueprint);
  }
}
