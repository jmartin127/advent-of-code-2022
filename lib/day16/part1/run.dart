import '../../src/util.dart';

const totalMinutes = 30;
final Map<String, Valve> valves = {};

class Valve {
  String label;
  int flowRate;
  List<String> tunnels;

  Valve(this.label, this.flowRate, this.tunnels);

  @override
  String toString() {
    return '$label flow of $flowRate, leads to $tunnels';
  }
}

class Path {
  String lastValve = '';
  Set<String> openValves = {};
  int minute = 0;
  int totalPressureReleased = 0;

  Path();

  @override
  String toString() {
    return 'Minute: $minute, Released: $totalPressureReleased, last: $lastValve, open: $openValves';
  }

  // ... and one minute to follow any tunnel from one valve to another
  void addLastValve(String label) {
    minute++;
    lastValve = label;
  }

  // you estimate it will take you one minute to open a single valve
  void openValve(Valve valve) {
    minute++;
    openValves.add(valve.label);
    // print(
    //     'Adding ${valve.label} at minute: $minute with rate: ${valve.flowRate}. Minutes remaining: ${(totalMinutes - minute)} Added pressure: ${(totalMinutes - minute) * valve.flowRate}');
    totalPressureReleased += (totalMinutes - minute) * valve.flowRate;
  }

  Path copy() {
    Path newPath = Path();
    newPath.lastValve = lastValve;
    newPath.openValves = copyOpen(openValves);
    newPath.minute = minute;
    newPath.totalPressureReleased = totalPressureReleased;
    return newPath;
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // read in the input
  for (var line in lines) {
    // Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    line = line.replaceAll('=', ' ');
    line = line.replaceAll(';', '');
    line = line.replaceAll(',', '');
    // Valve AA has flow rate 0 tunnels lead to valves DD II BB
    final parts = line.split(' ');
    List<String> tunnels = [];
    for (int i = 10; i < parts.length; i++) {
      tunnels.add(parts[i]);
    }
    final label = parts[1];
    final valve = Valve(parts[1], int.parse(parts[5]), tunnels);
    valves[label] = valve;
  }

  // create one iteration of paths
  Path path = Path();
  path.addLastValve('AA');
  path.minute = 0;
  List<Path> paths = [path];
  for (int i = 0; i < totalMinutes; i++) {
    paths = performOnePathIteration(paths);
    final maxPath = getMaxPath(paths);
    print(maxPath);
    // heuristics to cull an arbitrary percentage of the paths that suck after
    // an arbitrary iteration number
    if (i > 11) {
      paths =
          removeCrapPaths(paths, (maxPath.totalPressureReleased * .50).toInt());
    }
  }

  // Answers submitted: 1738
}

List<Path> removeCrapPaths(List<Path> paths, int belowTotal) {
  List<Path> newPaths = [];
  for (final path in paths) {
    if (path.totalPressureReleased >= belowTotal) {
      newPaths.add(path);
    }
  }
  return newPaths;
}

Path getMaxPath(List<Path> paths) {
  int max = -1;
  Path? maxPath;
  for (final path in paths) {
    if (path.totalPressureReleased > max) {
      max = path.totalPressureReleased;
      maxPath = path;
    }
  }
  return maxPath!;
}

List<Path> performOnePathIteration(List<Path> paths) {
  List<Path> newPaths = [];
  for (final path in paths) {
    final tunnels = valves[path.lastValve]!.tunnels;
    // iterate over all possible next valves
    for (final valveLabel in tunnels) {
      final valve = valves[valveLabel]!;

      // walk to the nxt valve
      final newPath = path.copy();
      newPath.addLastValve(valve.label);

      // turn on valves that:
      // a) have a positive flow rate
      // b) we encounter that are not already open
      if (valve.flowRate > 0 && !path.openValves.contains(valve.label)) {
        newPath.openValve(valve);
      }

      // add this new path to the list of paths we are tracking
      newPaths.add(newPath);
    }
  }
  return newPaths;
}

Set<String> copyOpen(Set<String> openValves) {
  Set<String> copy = {};
  for (final valveLabel in openValves) {
    copy.add(valveLabel);
  }
  return copy;
}

void printPaths(List<Path> paths) {
  for (final path in paths) {
    print(path);
  }
}
