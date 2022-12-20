import '../../src/util.dart';

const minutesForElephantTraining = 4;
const actualMinutes = 30;
const totalUsableMinutes = actualMinutes - minutesForElephantTraining;
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
  String lastValveMe = '';
  String lastValveElephant = '';
  Set<String> openValves = {};
  int minute = 0;
  int totalPressureReleased = 0;

  Path();

  @override
  String toString() {
    return 'Minute: $minute, Released: $totalPressureReleased, last me: $lastValveMe, last elephant: $lastValveElephant, open: $openValves';
  }

  // TODO make sure we add a minute when we should as we move and open valves,
  //      but only add one minute for both of us moving and taking actions
  void addMinute() {
    minute++;
  }

  // ... and one minute to follow any tunnel from one valve to another
  void addLastValveMe(String labelMe) {
    lastValveMe = labelMe;
  }

  void addLastValveElephant(String labelElephant) {
    lastValveElephant = labelElephant;
  }

  // you estimate it will take you one minute to open a single valve
  void openValve(Valve valve) {
    openValves.add(valve.label);
    // print(
    //     'Adding ${valve.label} at minute: $minute with rate: ${valve.flowRate}. Minutes remaining: ${(totalMinutes - minute)} Added pressure: ${(totalMinutes - minute) * valve.flowRate}');
    totalPressureReleased +=
        (actualMinutes - (minutesForElephantTraining + minute)) *
            valve.flowRate;
  }

  Path copy() {
    Path newPath = Path();
    newPath.lastValveMe = lastValveMe;
    newPath.lastValveElephant = lastValveElephant;
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
  path.addLastValveMe('AA');
  path.addLastValveElephant('AA');
  path.minute = 0;
  List<Path> paths = [path];
  for (int i = 0; i <= totalUsableMinutes; i++) {
    paths = performOneMinuteOfOperations(paths);
    final maxPath = getMaxPath(paths);
    print(maxPath);
    // heuristics to cull an arbitrary percentage of the paths that suck after
    // an arbitrary iteration number
    if (i > 20) {
      paths =
          removeCrapPaths(paths, (maxPath.totalPressureReleased * .95).toInt());
    }
    if (i > 15) {
      paths =
          removeCrapPaths(paths, (maxPath.totalPressureReleased * .90).toInt());
    }
    if (i > 10) {
      paths =
          removeCrapPaths(paths, (maxPath.totalPressureReleased * .75).toInt());
    } else if (i > 5) {
      paths =
          removeCrapPaths(paths, (maxPath.totalPressureReleased * .60).toInt());
    }
  }

  // Highest numbers: 982, 1965, 2148, 2198, 2216
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

List<Path> performOneMinuteOfOperations(List<Path> paths) {
  List<Path> newPaths = [];
  for (final path in paths) {
    if (path.lastValveMe == path.lastValveElephant) {
      // at the same valve
      final valve = valves[path.lastValveMe]!;
      final tunnels = valves[path.lastValveMe]!.tunnels;
      // determine if we should open a valve
      if (valve.flowRate > 0 && !path.openValves.contains(valve.label)) {
        // we want to open the valve
        // create a bunch of new paths where:
        // 1. I open the valve (shouldn't matter which of us opens the valve)
        // 2. The elephant goes to a new tunnel location
        // 3. We add a minute since we both did something
        // 4. We add this path to the list of possible paths
        for (final valveLabel in tunnels) {
          final newPath = path.copy();
          newPath.addMinute();
          newPath.openValve(valve);
          newPath.addLastValveElephant(valveLabel);
          newPaths.add(newPath);
        }
      } else {
        // we do not want to open the valve
        // create a bunch of new paths where:
        // 1. I go to a new location
        // 2. The elephant goes to a new location
        // 3. We add a minute since we both did something
        // 4. We add this path to the list of possible paths
        for (final valveLabelMe in tunnels) {
          for (final valveLabelElephant in tunnels) {
            final newPath = path.copy();
            newPath.addMinute();
            newPath.addLastValveMe(valveLabelMe);
            newPath.addLastValveElephant(valveLabelElephant);
            newPaths.add(newPath);
          }
        }
      }
    } else {
      // if we are at different valves, then just do your own thing
      final myValve = valves[path.lastValveMe]!;
      final myTunnels = valves[path.lastValveMe]!.tunnels;
      final elephantValve = valves[path.lastValveElephant]!;
      final elephantTunnels = valves[path.lastValveElephant]!.tunnels;

      // determine which valves to open
      final meOpenValve =
          myValve.flowRate > 0 && !path.openValves.contains(myValve.label);
      final elephantOpenValve = elephantValve.flowRate > 0 &&
          !path.openValves.contains(elephantValve.label);
      if (meOpenValve && elephantOpenValve) {
        // we both open valves
        final newPath = path.copy();
        newPath.addMinute();
        newPath.openValve(myValve);
        newPath.openValve(elephantValve);
        newPaths.add(newPath);
      } else if (meOpenValve) {
        // I open a valve, and he goes down tunnels
        for (final elephantTunnelLabel in elephantTunnels) {
          final newPath = path.copy();
          newPath.addMinute();
          newPath.openValve(myValve);
          newPath.addLastValveElephant(elephantTunnelLabel);
          newPaths.add(newPath);
        }
      } else if (elephantOpenValve) {
        // He opens a valve, and I go down tunnels
        for (final myTunnelLabel in myTunnels) {
          final newPath = path.copy();
          newPath.addMinute();
          newPath.openValve(elephantValve);
          newPath.addLastValveMe(myTunnelLabel);
          newPaths.add(newPath);
        }
      } else {
        // We both go down tunnels
        for (final valveLabelMe in myTunnels) {
          for (final valveLabelElephant in elephantTunnels) {
            final newPath = path.copy();
            newPath.addMinute();
            newPath.addLastValveMe(valveLabelMe);
            newPath.addLastValveElephant(valveLabelElephant);
            newPaths.add(newPath);
          }
        }
      }
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
