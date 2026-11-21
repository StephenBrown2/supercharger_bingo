import 'package:material_ui/material_ui.dart';

import '../services/location_service.dart';

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
    // Wait for a location fix, at most 3s.
    Future<void> locate = LocationService.instance
        .getCurrentPosition()
        .then((_) {})
        .catchError((_) {});
    await Future.any([locate, Future.delayed(const Duration(seconds: 3))]);
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
