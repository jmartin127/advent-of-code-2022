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
  Map<Resource, Robot> robotsByType;

  Blueprint(this.id, this.robotsByType);

  @override
  String toString() {
    return 'Id: $id, Robots: $robotsByType';
  }
}

class Resources {
  Map<Resource, int> resources = {};

  @override
  String toString() {
    return 'Resources: $resources';
  }

  bool haveEnoughForRobot(
      Resource robotType, Blueprint blueprint, Resource? ignoreResourceType) {
    final robot = blueprint.robotsByType[robotType]!;
    final cost = robot.cost;
    for (final entry in cost.entries) {
      final resourceType = entry.key;
      final numResourcesRequired = entry.value;
      if (ignoreResourceType != null && resourceType == ignoreResourceType) {
        continue;
      }
      if (!resources.containsKey(resourceType)) {
        return false;
      }
      final numHave = resources[resourceType]!;
      if (numHave < numResourcesRequired) {
        return false;
      }
    }
    return true;
  }

  void spendResources(Map<Resource, int> cost) {
    for (final entry in cost.entries) {
      final resourceType = entry.key;
      final resourceNum = entry.value;
      resources[resourceType] = resources[resourceType]! - resourceNum;
    }
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

  @override
  String toString() {
    return 'Robots: $numRobotsByType';
  }

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

    final robotsByType = {
      Resource.ore: oreRobot,
      Resource.clay: clayRobot,
      Resource.obsidian: obsidianRobot,
      Resource.geode: geodedRobot
    };
    blueprints.add(Blueprint(id, robotsByType));
  }

  print('Num of blueprints: ${blueprints.length}');

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
        spendResources(blueprint, resources, robots);
        print('Spent: ${robots.pendingRobots}');
      }

      // 2. robots collect resources
      // Each robot can collect 1 of its resource type per minute.
      final newResources = robots.collectResources();
      resources.combineResources(newResources);
      print('Now have: $resources');

      // 3. new robots are ready
      // It also takes one minute for the robot factory to construct any type of
      // robot, although it consumes the necessary resources available when construction begins
      robots.convertPendingToActual();
      print('Now have: $robots');
    }
  }
}

// This is really the only thing that matters.
//
// Questions:
// How do you decide if you should build an ore robot or a clay robot?
// How do you know when you should "save up" enough ore to get a higher-level robot vs. spend it on an ore or clay robot?
// ... If you have enough obsidian, for example, then seems you should not spend ore on other things
//
/// Returns pending robots (if any)
void spendResources(Blueprint blueprint, Resources resources, Robots robots) {
  // 1. Build a geode robot if possible (requires obsidian and ore)
  while (true) {
    if (resources.haveEnoughForRobot(Resource.geode, blueprint, null)) {
      resources.spendResources(blueprint.robotsByType[Resource.geode]!.cost);
      robots.addPendingRobot(Resource.geode, 1);
    } else {
      break;
    }
  }
  if (resources.haveEnoughForRobot(Resource.geode, blueprint, Resource.ore)) {
    return; // don't spend more ore till we can build a geode robot
  }

  // 2. Build an obsidian robot if possibe (requres clay and ore)
  while (true) {
    if (resources.haveEnoughForRobot(Resource.obsidian, blueprint, null)) {
      resources.spendResources(blueprint.robotsByType[Resource.obsidian]!.cost);
      robots.addPendingRobot(Resource.obsidian, 1);
    } else {
      break;
    }
  }
  if (resources.haveEnoughForRobot(
      Resource.obsidian, blueprint, Resource.ore)) {
    return; // don't spend more ore till we can build an obsidian robot
  }

  // Decide if we should build a clay robot or an ore robot? Explore both paths?
  // 3. Build a clay robot if possible (requires ore)
  while (true) {
    if (resources.haveEnoughForRobot(Resource.clay, blueprint, null)) {
      resources.spendResources(blueprint.robotsByType[Resource.clay]!.cost);
      robots.addPendingRobot(Resource.clay, 1);
    } else {
      break;
    }
  }

  // 4. Build an ore robot (requires ore)
  while (true) {
    if (resources.haveEnoughForRobot(Resource.ore, blueprint, null)) {
      resources.spendResources(blueprint.robotsByType[Resource.ore]!.cost);
      robots.addPendingRobot(Resource.ore, 1);
    } else {
      break;
    }
  }
}
