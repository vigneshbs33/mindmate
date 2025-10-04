import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/settings_screen.dart';

final appRouterProvider = Provider<RouterConfig<Object>>((ref) {
  return RouterConfig(
    routerDelegate: _AppRouterDelegate(),
    routeInformationParser: const _AppRouteParser(),
  );
});

class _AppRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _path = '/';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(child: OnboardingScreen(onFinished: () => _go('/home'))),
        if (_path == '/home') const MaterialPage<void>(child: HomeScreen()),
        if (_path == '/journal') const MaterialPage<void>(child: JournalScreen()),
        if (_path == '/tasks') const MaterialPage<void>(child: TasksScreen()),
        if (_path == '/insights') const MaterialPage<void>(child: InsightsScreen()),
        if (_path == '/settings') const MaterialPage<void>(child: SettingsScreen()),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  void _go(String path) {
    _path = path;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    _path = configuration.name ?? '/';
  }
}

class _AppRouteParser extends RouteInformationParser<RouteSettings> {
  const _AppRouteParser();
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    final location = routeInformation.location ?? '/';
    return RouteSettings(name: location);
  }
}


