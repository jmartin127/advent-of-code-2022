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

class Resources {
  Map<Resource, int> resources = {};

  @override
  String toString() {
    return 'Resources: $resources';
  }

  bool hasResources() {
    for (final entry in resources.entries) {
      if (entry.value > 0) {
        return true;
      }
    }
    return false;
  }

  void combineResources(Resources other) {
    for (final entry in other.resources.entries) {
      final resource = entry.key;
      final num = entry.value;
      addResources(resource, num);
    }
  }

  void addResources(Resource type, int num) {
    if (resources.containsKey(type)) {
      resources[type] = resources[type]! + num;
    } else {
      resources[type] = num;
    }
  }
}

class Robots {
  Map<Resource, int> numRobotsByType = {};
  Map<Resource, int> pendingRobots = {};

  Resources collectResources() {
    final newResources = Resources();
    for (final entry in numRobotsByType.entries) {
      final robotType = entry.key;
      final numRobots = entry.value;
      newResources.addResources(robotType, numRobots);
    }
    return newResources;
  }

  void addPendingRobot(Resource type, int num) {
    if (pendingRobots.containsKey(type)) {
      pendingRobots[type] = pendingRobots[type]! + num;
    } else {
      pendingRobots[type] = num;
    }
  }

  void addRobot(Resource type, int num) {
    if (numRobotsByType.containsKey(type)) {
      numRobotsByType[type] = numRobotsByType[type]! + num;
    } else {
      numRobotsByType[type] = num;
    }
  }

  void convertPendingToActual() {
    if (pendingRobots.isNotEmpty) {
      for (final entry in pendingRobots.entries) {
        final robotType = entry.key;
        final robotCount = entry.value;
        addRobot(robotType, robotCount);
      }
    }
    pendingRobots = {};
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
  //
  // Obervation, the only thing that really matters is to decide how to spend
  // the resources

  for (final blueprint in blueprints) {
    print('Processing blueprint: ${blueprint.id}');
    final resources = Resources();
    final robots = Robots();

    // Fortunately, you have exactly one ore-collecting robot in your pack that
    // you can use to kickstart the whole operation.
    robots.addRobot(Resource.ore, 1);
    for (int minute = 1; minute <= 24; minute++) {
      print('\n== Minute $minute ==');

      // 1. spend resources
      if (resources.hasResources()) {
        throw Exception('Deal with resources');
      }

      // 2. robots collect resources
      final newResources = robots.collectResources();
      resources.combineResources(newResources);
      print('Now have: $resources');

      // 3. new robots are ready
      robots.convertPendingToActual();
    }
  }
}
