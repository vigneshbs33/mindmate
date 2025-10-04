import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmate/src/theme/app_theme.dart';
import 'package:mindmate/src/providers/app_providers.dart';
import 'package:mindmate/src/screens/onboarding_screen.dart';
import 'package:mindmate/src/screens/home_screen.dart';
import 'package:mindmate/src/screens/journal_screen.dart';
import 'package:mindmate/src/screens/tasks_screen.dart';
import 'package:mindmate/src/screens/insights_screen.dart';
import 'package:mindmate/src/screens/settings_screen.dart';

class MindMateApp extends ConsumerStatefulWidget {
  const MindMateApp({super.key});

  @override
  ConsumerState<MindMateApp> createState() => _MindMateAppState();
}

class _MindMateAppState extends ConsumerState<MindMateApp> {
  bool _initialized = false;
  bool _onboardingComplete = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      final hive = ref.read(hiveServiceProvider);
      final notifications = ref.read(notificationServiceProvider);
      final speech = ref.read(speechServiceProvider);
      await hive.init();
      await notifications.init();
      await speech.init();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      print('Service initialization error: $e');
      if (mounted) setState(() => _initialized = true);
    }
  }

  void _completeOnboarding() {
    setState(() => _onboardingComplete = true);
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    // keep provider in sync for programmatic navigation
    ref.read(tabIndexProvider.notifier).state = index;
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const JournalScreen();
      case 2:
        return const TasksScreen();
      case 3:
        return const InsightsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final externalTabIndex = ref.watch(tabIndexProvider);
    if (externalTabIndex != _currentIndex) {
      // sync internal state with provider-driven changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = externalTabIndex);
      });
    }
    
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.light,
        darkTheme: theme.dark,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing MindMate...'),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!_onboardingComplete) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.light,
        darkTheme: theme.dark,
        home: OnboardingScreen(onFinished: _completeOnboarding),
      );
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindMate',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: _getCurrentScreen(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_outlined),
              selectedIcon: Icon(Icons.psychology),
              label: 'Mate',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}


