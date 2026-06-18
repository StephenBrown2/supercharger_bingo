import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import 'checkin_dialog.dart';

/// Check-in screen with mini-map and site list
class CheckinScreen extends StatefulWidget {
  final void Function(int siteId, double lat, double lng)? onCheckinComplete;

  const CheckinScreen({super.key, this.onCheckinComplete});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final MapController _mapController = MapController();

  Position? _userPosition;
  List<SiteWithDistance> _nearbySites = [];
  // siteId -> current user's most recent check-in date at that site.
  Map<int, DateTime> _lastVisits = {};
  bool _isLoadingLocation = true;
  bool _isLoadingSites = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Try to use cached location first
      Position? position = LocationService.instance.cachedPosition;
      if (position == null) {
        position = await LocationService.instance.getCurrentPosition();
      }

      if (position == null) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Could not determine location';
        });
        return;
      }

      setState(() {
        _userPosition = position;
        _isLoadingLocation = false;
      });

      // Load nearby sites first
      await _loadNearbySites();

      // Then auto-zoom to include user and nearest site
      _autoZoomMap();
    } catch (e) {
      debugPrint('Failed to get location: $e');
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Location error: ${e.toString().split('\n').first}';
      });
    }
  }

  Future<void> _loadNearbySites() async {
    if (_userPosition == null) return;

    setState(() => _isLoadingSites = true);

    try {
      final sites = await DatabaseService.getNearbySites(
        latitude: _userPosition!.latitude,
        longitude: _userPosition!.longitude,
        radiusKm: 100.0, // 100km radius
        limit: 20,
        status: SiteStatus.open, // Only open sites
        visited: false, // Exclude visited sites
      );

      final lastVisits = await DatabaseService.getLastVisitDates(
        sites.map((s) => s.site.siteId).toList(),
      );

      setState(() {
        _nearbySites = sites;
        _lastVisits = lastVisits;
        _isLoadingSites = false;
      });
    } catch (e) {
      debugPrint('Failed to load nearby sites: $e');
      setState(() => _isLoadingSites = false);
    }
  }

  /// Auto-zoom map to include user position and nearest unvisited site
  void _autoZoomMap() {
    if (_userPosition == null) return;

    final userLatLng = LatLng(
      _userPosition!.latitude,
      _userPosition!.longitude,
    );

    // If no nearby sites, just center on user
    if (_nearbySites.isEmpty) {
      _mapController.move(userLatLng, _userPosition!.accuracy > 1000 ? 10 : 12);
      return;
    }

    // Get nearest site
    final nearestSite = _nearbySites.first.site;
    final nearestLatLng = LatLng(nearestSite.latitude, nearestSite.longitude);

    // Calculate bounds that include both user and nearest site
    final minLat = userLatLng.latitude < nearestLatLng.latitude
        ? userLatLng.latitude
        : nearestLatLng.latitude;
    final maxLat = userLatLng.latitude > nearestLatLng.latitude
        ? userLatLng.latitude
        : nearestLatLng.latitude;
    final minLng = userLatLng.longitude < nearestLatLng.longitude
        ? userLatLng.longitude
        : nearestLatLng.longitude;
    final maxLng = userLatLng.longitude > nearestLatLng.longitude
        ? userLatLng.longitude
        : nearestLatLng.longitude;

    // Add padding (10%)
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    final bounds = LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    // Fit bounds to map
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingLocation
                ? null
                : () {
                    LocationService.instance.clearCache();
                    _fetchLocation();
                  },
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mini-map at top
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userPosition != null
                        ? LatLng(
                            _userPosition!.latitude,
                            _userPosition!.longitude,
                          )
                        : const LatLng(39.8283, -98.5795), // US center
                    initialZoom: _userPosition != null ? 10 : 4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'bingo.supercharger.checkin',
                    ),
                    // User location marker
                    if (_userPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _userPosition!.latitude,
                              _userPosition!.longitude,
                            ),
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Nearby site markers
                          ..._nearbySites.take(10).map((siteWithDist) {
                            final site = siteWithDist.site;
                            // Match map_screen.dart marker logic:
                            // Green star = first eligible (no checkins)
                            // Red circle = unvisited (has checkins)
                            // Grey circle = visited (shouldn't show since we filter visited)
                            if (!site.hasCheckins) {
                              // First eligible - green star
                              return Marker(
                                point: LatLng(site.latitude, site.longitude),
                                width: 32,
                                height: 32,
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.green,
                                  size: 28,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Has checkins but unvisited - red circle
                              return Marker(
                                point: LatLng(site.latitude, site.longitude),
                                width: 24,
                                height: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                  ],
                ),
                // Zoom controls for non-touch platforms
                if (!kIsWeb &&
                    (Platform.isLinux ||
                        Platform.isWindows ||
                        Platform.isMacOS))
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'zoom_in',
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(
                              _mapController.camera.center,
                              currentZoom + 1,
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 4),
                        FloatingActionButton.small(
                          heroTag: 'zoom_out',
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(
                              _mapController.camera.center,
                              currentZoom - 1,
                            );
                          },
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                // Loading overlay
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),

          // Location status / error
          if (_locationError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Site list header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.near_me, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Nearby Superchargers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_userPosition != null)
                  Text(
                    '${_nearbySites.length} found',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),

          // Site list
          Expanded(
            child: _isLoadingSites
                ? const Center(child: CircularProgressIndicator())
                : _nearbySites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userPosition == null
                              ? 'Waiting for location...'
                              : 'No superchargers nearby',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _nearbySites.length,
                    itemBuilder: (context, index) {
                      final siteWithDist = _nearbySites[index];
                      return _SiteListTile(
                        siteWithDistance: siteWithDist,
                        lastVisit: _lastVisits[siteWithDist.site.siteId],
                        onCheckin: () => _handleCheckin(siteWithDist),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckin(SiteWithDistance siteWithDist) async {
    final site = siteWithDist.site;
    final messenger = ScaffoldMessenger.of(context);
    final queued = await showCheckinDialog(
      context,
      site: site,
      distanceKm: siteWithDist.distanceKm,
      position: _userPosition,
    );
    if (!queued) return;

    widget.onCheckinComplete?.call(site.siteId, site.latitude, site.longitude);
    messenger.showSnackBar(
      SnackBar(content: Text('Checked in to ${site.name}')),
    );
    await _loadNearbySites();
  }
}

/// List tile for a site in the check-in list
class _SiteListTile extends StatelessWidget {
  final SiteWithDistance siteWithDistance;
  final DateTime? lastVisit;
  final VoidCallback onCheckin;

  const _SiteListTile({
    required this.siteWithDistance,
    required this.lastVisit,
    required this.onCheckin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final site = siteWithDistance.site;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildLeadingIcon(theme, site),
        title: Text(site.name),
        subtitle: _buildSubtitle(theme, site),
        trailing: FilledButton.tonal(
          onPressed: onCheckin,
          child: const Text('Check In'),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ThemeData theme, Site site) {
    // First eligible (no check-ins yet)
    if (!site.hasCheckins) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.star, color: Colors.amber),
      );
    }
    // User has visited
    if (site.visited) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: theme.colorScheme.primary),
      );
    }
    // Open but not visited
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.ev_station, color: Colors.green),
    );
  }

  Widget _buildSubtitle(ThemeData theme, Site site) {
    final distanceText = '${siteWithDistance.distanceKm.toStringAsFixed(1)} km';
    // Most-recent check-in indicator (SPEC Section 6, item 3).
    final recent = lastVisit != null
        ? 'Last: ${_formatDate(lastVisit!)}'
        : 'No previous check-in';

    // First eligible
    if (!site.hasCheckins) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(distanceText),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'FIRST eligible',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(recent, style: theme.textTheme.bodySmall),
        ],
      );
    }

    final status = site.visited ? 'Visited' : 'Unvisited';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$distanceText • $status'),
        Text(recent, style: theme.textTheme.bodySmall),
      ],
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
