import 'package:flutter/widgets.dart';

/// Initializes Flutter and mounts the supplied EV Health application.
void bootstrap(Widget application) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(application);
}
