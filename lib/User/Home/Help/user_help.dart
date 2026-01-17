import 'package:flutter/material.dart';
import 'help_main_screen.dart';
import 'help_child_screen.dart';

class UserHelp extends StatefulWidget {
  const UserHelp({super.key});

  @override
  State<UserHelp> createState() => _UserHelpState();
}

class _UserHelpState extends State<UserHelp> {
  @override
  Widget build(BuildContext context) {

    // This Navigator is "nested" inside the Help tab.
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case '/':
          // The main Help screen with the list of help services
            builder = (BuildContext _) => const HelpMainScreen();
            break;
          case '/child':
          // The child screen for a specific service
            final args = settings.arguments as Map<String, String>;
            builder = (BuildContext _) =>
                HelpChildScreen(title: args['title'] ?? '');
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }

        return MaterialPageRoute(
          builder: builder,
          settings: settings,
        );
      },
    );
  }
}
