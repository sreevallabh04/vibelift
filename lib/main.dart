import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/core/theme/app_theme.dart';
import 'package:vibelift/data/providers/settings_provider.dart';

import 'package:vibelift/screens/splash/splash_screen.dart';
import 'package:vibelift/screens/dashboard/dashboard_screen.dart';
import 'package:vibelift/screens/food_tracker/food_tracker_screen.dart';
import 'package:vibelift/screens/lifting_tracker/lifting_tracker_screen.dart';
import 'package:vibelift/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:vibelift/screens/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: VibeLiftApp(),
    ),
  );
}

class VibeLiftApp extends ConsumerWidget {
  const VibeLiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VibeLift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FoodTrackerScreen(),
    LiftingTrackerScreen(),
    WeightTrackerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          height: 70,
          indicatorColor: const Color(0xFF10B981).withAlpha(26),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: Color(0xFF10B981)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant, color: Color(0xFF10B981)),
              label: 'Food',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon:
                  Icon(Icons.fitness_center, color: Color(0xFF10B981)),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_weight_outlined),
              selectedIcon:
                  Icon(Icons.monitor_weight, color: Color(0xFF10B981)),
              label: 'Weight',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF10B981)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
