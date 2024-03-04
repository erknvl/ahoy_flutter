import 'package:uuid/uuid.dart';

class Environment {
  DateTime date() => DateTime.now();
  Uuid uuid() => const Uuid();
  final Function() visitorToken = visitorTokenProvider;
  final UserDefaults defaults = UserDefaults.standard;
}

class UserDefaults {
  static final UserDefaults standard = UserDefaults();

  // Implement UserDefaults functionality as needed
}

Function() visitorTokenProvider = () {
  return const Uuid().v4();
};

final Environment current = Environment();
