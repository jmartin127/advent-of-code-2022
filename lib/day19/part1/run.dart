import 'dart:math';

import '../../src/util.dart';

var random = new Random();

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

  int resultingGeodes() {
    return currentResourceCount(Resource.geode);
  }

  int currentResourceCount(Resource type) {
    if (!resources.containsKey(type)) {
      return 0;
    }
    return resources[type]!;
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

  int collectionRate(Resource type) {
    if (!numRobotsByType.containsKey(type)) {
      return 0;
    }
    return numRobotsByType[type]!;
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
  Map<int, int> mostCommonAnswers = {};
  for (int i = 0; i < 2; i++) {
    print('Iteration: $i');
    int answer = runAllBluePrints(blueprints);
    if (mostCommonAnswers.containsKey(answer)) {
      mostCommonAnswers[answer] = mostCommonAnswers[answer]! + 1;
    } else {
      mostCommonAnswers[answer] = 1;
    }
    print(mostCommonAnswers);
  }

  print(mostCommonAnswers);

  /*
  Answers: 
    Too low:: 1535
    Too high: 1590, 1581
    NOT correct: 1568, 1546, 1548, 1574
    So between: 1535 and 1581
    I think it is: 1559, or 1565
  */
  // {1535: 39, 1546: 14, 1547: 7, 1548: 5, 1526: 5, 1536: 4, 1514: 4, 1555: 3, 1544: 4, 1505: 1, 1539: 2, 1525: 1, 1560: 2, 1564: 1, 1553: 1, 1523: 1, 1554: 1, 1537: 3, 1549: 1, 1559: 1}
  // {1535: 33, 1546: 12, 1544: 8, 1559: 7, 1514: 1, 1547: 4, 1550: 1, 1526: 4, 1536: 5, 1527: 2, 1568: 1, 1548: 7, 1557: 1, 1555: 4, 1538: 1, 1537: 4, 1539: 1, 1553: 1, 1523: 1, 1505: 1, 1545: 1}
}

int runAllBluePrints(List<Blueprint> blueprints) {
  int answer = 0;
  for (final blueprint in blueprints) {
    // print('Processing blueprint: ${blueprint.id}');
    int maxGeodes = 0;
    for (int i = 0; i < 10000; i++) {
      final geodeCount = runForBlueprint(blueprint);
      if (geodeCount > maxGeodes) {
        maxGeodes = geodeCount;
        // print('MAX: $maxGeodes');
      }
    }
    final qualityLevel = blueprint.id * maxGeodes;
    answer += qualityLevel;
  }
  return answer;
}

int runForBlueprint(Blueprint blueprint) {
  final resources = Resources();
  final robots = Robots();

  // Fortunately, you have exactly one ore-collecting robot in your pack that
  // you can use to kickstart the whole operation.
  robots.addRobot(Resource.ore, 1);
  for (int minute = 1; minute <= 24; minute++) {
    // print('\n== Minute $minute ==');

    // 1. spend resources
    if (resources.hasResources()) {
      spendResources(blueprint, resources, robots);
      // print('Spent: ${robots.pendingRobots}');
    }

    // 2. robots collect resources
    // Each robot can collect 1 of its resource type per minute.
    final newResources = robots.collectResources();
    resources.combineResources(newResources);
    // print('Now have: $resources');

    // 3. new robots are ready
    // It also takes one minute for the robot factory to construct any type of
    // robot, although it consumes the necessary resources available when construction begins
    robots.convertPendingToActual();
    // print('Now have: $robots');
  }
  return resources.resultingGeodes();
}

// This is really the only thing that matters.
//
/// Returns pending robots (if any)
void spendResources(Blueprint blueprint, Resources resources, Robots robots) {
  // 1. Build a geode robot if possible (requires obsidian and ore)
  // while (true) {
  if (resources.haveEnoughForRobot(Resource.geode, blueprint, null) &&
      randomlyReturnTrue(0.9)) {
    resources.spendResources(blueprint.robotsByType[Resource.geode]!.cost);
    robots.addPendingRobot(Resource.geode, 1);
    return;
  }
  // }
  // if (resources.haveEnoughForRobot(Resource.geode, blueprint, Resource.ore)) {
  //   return; // don't spend more ore till we can build a geode robot
  // }
  // if (closeToEnoughResources(
  //     resources, robots, blueprint, Resource.geode, Resource.obsidian)) {
  //   // print('Going to stock up ore to build a geode robot');
  //   return;
  // }

  // 2. Build an obsidian robot if possible (requres clay and ore)
  // while (true) {
  if (resources.haveEnoughForRobot(Resource.obsidian, blueprint, null) &&
      randomlyReturnTrue(0.9)) {
    resources.spendResources(blueprint.robotsByType[Resource.obsidian]!.cost);
    robots.addPendingRobot(Resource.obsidian, 1);
    return;
  }
  // if (resources.haveEnoughForRobot(
  //     Resource.obsidian, blueprint, Resource.ore)) {
  //   return; // don't spend more ore till we can build an obsidian robot
  // }
  // if (closeToEnoughResources(
  //     resources, robots, blueprint, Resource.obsidian, Resource.clay)) {
  //   // print('Going to stock up ore to build an obsidian robot');
  //   return;
  // }

  // Decide if we should build a clay robot or an ore robot? Explore both paths?
  // How do you decide if you should build an ore robot or a clay robot?
  // 3. Build a clay robot if possible (requires ore)
  // while (true) {
  if (resources.haveEnoughForRobot(Resource.clay, blueprint, null) &&
      randomlyReturnTrue(0.5)) {
    resources.spendResources(blueprint.robotsByType[Resource.clay]!.cost);
    robots.addPendingRobot(Resource.clay, 1);
    return;
  }

  // 4. Build an ore robot (requires ore)
  // while (true) {
  if (resources.haveEnoughForRobot(Resource.ore, blueprint, null) &&
      randomlyReturnTrue(0.5)) {
    resources.spendResources(blueprint.robotsByType[Resource.ore]!.cost);
    robots.addPendingRobot(Resource.ore, 1);
    return;
  }
}

/// For example, store up ore if we are getting close on the first resource
///
bool closeToEnoughResources(Resources resources, Robots robots,
    Blueprint blueprint, Resource desiredResource, Resource requiredResource) {
  // determine how close we are to the first resource, and current rate
  final currentRateOfRequired = robots.collectionRate(requiredResource);
  if (currentRateOfRequired == 0) {
    return false; // we aren't collection the required resource, so not close
  }
  final numNeededOfRequired =
      blueprint.robotsByType[desiredResource]!.cost[requiredResource]!;
  final currentCountOfRequired =
      resources.currentResourceCount(requiredResource);
  final numStillNeededOfRequired = numNeededOfRequired - currentCountOfRequired;
  final numOutstandingCollectionsOfRequired =
      numStillNeededOfRequired / currentRateOfRequired;

  // perform the same calculations for ore
  final currentRateOfOre = robots.collectionRate(Resource.ore);
  final numNeededOfOre =
      blueprint.robotsByType[desiredResource]!.cost[Resource.ore]!;
  final currentCountOfOre = resources.currentResourceCount(Resource.ore);
  final numStillNeededOfOre = numNeededOfOre - currentCountOfOre;
  final numOutstandingCollectionsOfOre = numStillNeededOfOre / currentRateOfOre;

  // check which one has the more outstanding collections
  // print(
  //     '\tNum outstanding for $desiredResource: $numOutstandingCollectionsOfRequired');
  // print('\tNum outstanding for ore: $numOutstandingCollectionsOfOre');

  if (numOutstandingCollectionsOfRequired <= 1 &&
      numOutstandingCollectionsOfOre <= 1) {
    return true;
  }
  return numOutstandingCollectionsOfOre >
      numOutstandingCollectionsOfRequired - 0;
}

bool randomlyReturnTrue(double fraction) {
  return random.nextDouble() <= fraction;
}
