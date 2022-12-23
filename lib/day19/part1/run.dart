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

  // Fortunately, you have exactly one ore-collecting robot in your pack that
  // you can use to kickstart the whole operation.

  // Each robot can collect 1 of its resource type per minute.

  // It also takes one minute for the robot factory to construct any type of
  // robot, although it consumes the necessary resources available when construction begins.

  // In analyzing how the data works... it seems the algorithm needs to be:
  // 1. Build a geode robot if possible (requires obsidian and ore)
  // 2. Build an obsidian robot if possibe (requres clay and ore)
  //
  // Decide if we should build a clay robot or an ore robot? Explore both paths?
  // 3. Build a clay robot if possible (requires ore)
  // 4. Build an ore robot (requires ore)
  //
  // Questions:
  // How do you decide if you should build an ore robot or a clay robot?
  // How do you know when you should "save up" enough ore to get a higher-level robot vs. spend it on an ore or clay robot?
  // ... If you have enough obsidian, for example, then seems you should not spend ore on other things

  for (final blueprint in blueprints) {
    Map<Resource, int> resources = {};
    Map<Robot, int> numRobotsByType = {};
    for (int minute = 1; minute <= 24; minute++) {}
  }
}
