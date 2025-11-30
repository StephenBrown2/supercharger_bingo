import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/database_service.dart';

/// Simple splash screen shown while we fetch initial location
class SplashScreen extends StatefulWidget {
  final VoidCallback onReady;

  const SplashScreen({super.key, required this.onReady});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _prepare();
  }

  Future<void> _prepare() async {
    // Race: either location resolves or 3s timeout, whichever first
    // Start parallel tasks: location + bootstrap preload
    Future<void> locate = LocationService.instance
        .getCurrentPosition()
        .then((_) {})
        .catchError((_) {});
    Future<void> preload = DatabaseService.preloadBootstrapData().catchError(
      (_) {},
    );
    Future<void> timeout = Future.delayed(const Duration(seconds: 3));
    // Complete when either both tasks finish or timeout fires
    await Future.any([
      Future.wait([locate, preload]),
      timeout,
    ]);
    if (mounted) widget.onReady();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _animController,
              child: Icon(
                Icons.ev_station,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Loading your location...'),
          ],
        ),
      ),
    );
  }
}
