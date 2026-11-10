import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/sync_service.dart';
import '../services/timezone_service.dart';
import 'checkin_dialog.dart';
import 'map_marker_style.dart';

/// Full-screen map with filter controls and accessible markers
/// Can show a bottom drawer with nearby sites for check-in
class MapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool showCheckinDrawer;
  final VoidCallback? onDrawerClosed;

  const MapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.showCheckinDrawer = false,
    this.onDrawerClosed,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  MapFilter _currentFilter = MapFilter.openUnvisited;
  List<Site> _sites = [];
  // Earliest community check-in date per site, used to derive First state.
  Map<int, DateTime> _firstDates = {};
  bool _isLoading = true;
  bool _isLocating = false;
  late AnimationController _locationAnimController;
  late AnimationController _drawerAnimController;
  late Animation<double> _drawerAnimation;
  Stream<LocationMarkerPosition?>? _locationMarkerStream;
  Stream<LocationMarkerHeading?>? _headingStream;

  // Checkin drawer state
  bool _showCheckinDrawer = false;
  Position? _userPosition;
  List<SiteWithDistance> _nearbySites = [];
  Map<int, DateTime> _lastVisits = {};
  // Earliest qualifying community check-in for the nearby rows. Absence means
  // the First is still open. Independent of the hasCheckins counts cache.
  Map<int, DateTime> _nearbyFirstDates = {};
  bool _isLoadingLocation = false;
  bool _isLoadingSites = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    // Build unified location marker stream for plugin
    final unified = LocationService.instance.unifiedPositionStream();
    _locationMarkerStream = unified.map(
      (pos) => LocationMarkerPosition(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
      ),
    );

    // Build heading stream conditionally: only forward heading when available and accurate
    final headingController =
        StreamController<LocationMarkerHeading?>.broadcast();
    _headingStream = headingController.stream;
    unified.listen((pos) {
      // If heading is non-zero and accuracy is reasonable (< 1000m), emit it; else emit null
      if (pos.heading != 0 && pos.accuracy < 1000) {
        headingController.add(
          LocationMarkerHeading(
            heading: pos.heading,
            accuracy: pos.headingAccuracy,
          ),
        );
      } else {
        headingController.add(null);
      }
    });
    _locationAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.showCheckinDrawer ? 1.0 : 0.0,
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeInOut,
    );
    // Use a non-empty splash snapshot for the first paint. An empty snapshot
    // is the pre-sync cache and must not stick.
    final cached = DatabaseService.bootstrapSites;
    if (cached != null &&
        cached.isNotEmpty &&
        _currentFilter == MapFilter.openUnvisited) {
      _sites = cached;
      _isLoading = false;
      // Still need First-state inputs for the cached sites.
      _loadFirstDates(cached);
    } else {
      _loadSites();
    }
    _showCheckinDrawer = widget.showCheckinDrawer;

    // Recompute pin colours once community check-in data finishes syncing.
    SyncService.instance.communityDataVersion.addListener(_onCommunityData);
    SyncService.instance.sitesVersion.addListener(_onSitesSynced);

    _fetchLocationForCheckin();
  }

  void _onCommunityData() {
    if (mounted) _loadSites();
  }

  void _onSitesSynced() {
    if (mounted) _loadSites();
  }

  Future<void> _loadFirstDates(List<Site> sites) async {
    final operationalIds = sites
        .where((s) => isOperational(s.status))
        .map((s) => s.siteId)
        .toList();
    final firstDates = await DatabaseService.getEarliestCheckinDates(
      operationalIds,
    );
    if (mounted) setState(() => _firstDates = firstDates);
  }

  @override
  void dispose() {
    SyncService.instance.communityDataVersion.removeListener(_onCommunityData);
    SyncService.instance.sitesVersion.removeListener(_onSitesSynced);
    _locationAnimController.dispose();
    _drawerAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    try {
      List<Site> sites;
      switch (_currentFilter) {
        case MapFilter.openUnvisited:
          // Open and unvisited
          sites = await DatabaseService.getSites(
            status: SiteStatus.open,
            visited: false,
          );
          break;
        case MapFilter.openUnvisitedConstruction:
          // Open + construction, unvisited
          final openSites = await DatabaseService.getSites(
            status: SiteStatus.open,
            visited: false,
          );
          final constructionSites = await DatabaseService.getSites(
            status: SiteStatus.construction,
            visited: false,
          );
          sites = [...openSites, ...constructionSites];
          break;
        case MapFilter.visited:
          // Any site the current user has checked into, regardless of status.
          sites = await DatabaseService.getSites(visited: true);
          break;
        case MapFilter.all:
          // All sites
          sites = await DatabaseService.getSites();
          break;
      }
      // Derive First state inputs for the operational sites on screen.
      final operationalIds = sites
          .where((s) => isOperational(s.status))
          .map((s) => s.siteId)
          .toList();
      final firstDates = await DatabaseService.getEarliestCheckinDates(
        operationalIds,
      );
      setState(() {
        _sites = sites;
        _firstDates = firstDates;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load sites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle drawer animation when toggled from parent
    if (widget.showCheckinDrawer != oldWidget.showCheckinDrawer) {
      if (widget.showCheckinDrawer) {
        setState(() => _showCheckinDrawer = true);
        _drawerAnimController.forward();
      } else {
        _drawerAnimController.reverse().then((_) {
          if (mounted) {
            setState(() => _showCheckinDrawer = false);
          }
        });
      }
    }
    // Center map on new coordinates if provided
    if (widget.initialLat != null && widget.initialLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(widget.initialLat!, widget.initialLng!), 14);
      });
    }
    // Open/close drawer based on prop change
    if (widget.showCheckinDrawer != oldWidget.showCheckinDrawer) {
      setState(() {
        _showCheckinDrawer = widget.showCheckinDrawer;
        if (_showCheckinDrawer && _userPosition == null) {
          _fetchLocationForCheckin();
        }
      });
    }
  }

  /// Get initial center for map - uses widget params, cached location, or US center
  LatLng _getInitialCenter() {
    if (widget.initialLat != null && widget.initialLng != null) {
      return LatLng(widget.initialLat!, widget.initialLng!);
    }
    final cachedPosition = LocationService.instance.cachedPosition;
    if (cachedPosition != null) {
      return LatLng(cachedPosition.latitude, cachedPosition.longitude);
    }
    return const LatLng(39.8283, -98.5795); // US center
  }

  /// Get initial zoom for map
  double _getInitialZoom() {
    if (widget.initialLat != null && widget.initialLng != null) {
      return 14;
    }
    final cachedPosition = LocationService.instance.cachedPosition;
    if (cachedPosition != null) {
      return cachedPosition.accuracy > 1000 ? 8 : 10;
    }
    return 4; // Zoomed out for US center
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLocating
                ? RotationTransition(
                    turns: _locationAnimController,
                    child: const Icon(Icons.my_location),
                  )
                : const Icon(Icons.my_location),
            onPressed: _isLocating ? null : _centerOnUser,
            tooltip: 'Center on my location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _getInitialCenter(),
              initialZoom: _getInitialZoom(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'bingo.supercharger.checkin',
              ),
              // Site markers with clustering
              if (!_isLoading)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80,
                    size: const Size(40, 40),
                    disableClusteringAtZoom: 10,
                    markers: _buildMarkers(),
                    computeSize: (markers) {
                      // Don't cluster if only 3 markers
                      if (markers.length <= 3) {
                        return const Size(
                          0,
                          0,
                        ); // Return invalid size to prevent clustering
                      }
                      return const Size(40, 40);
                    },
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Live user location marker with custom unified stream
              CurrentLocationLayer(
                positionStream: _locationMarkerStream,
                headingStream: _headingStream,
              ),
              // Nearby sites markers when drawer is open
              if (_showCheckinDrawer && _userPosition != null)
                MarkerLayer(
                  markers: [
                    // Nearest 3 sites
                    ..._nearbySites.take(3).map((siteWithDist) {
                      final site = siteWithDist.site;
                      return Marker(
                        point: LatLng(site.latitude, site.longitude),
                        width: 32,
                        height: 32,
                        child: _MapMarker(
                          site: site,
                          firstDate: _firstDates[site.siteId],
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),

          // Removed full-screen loading overlay; map renders while sites load.

          // Site count badge
          if (!_isLoading)
            Positioned(
              top: 56,
              right: 8,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text('${_sites.length} sites'),
                ),
              ),
            ),

          // Filter chips at top
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: _buildFilterChips(theme),
          ),

          // Legend at bottom
          Positioned(bottom: 16, left: 16, child: _buildLegend(theme)),

          // Zoom controls for desktop (positioned above legend)
          Positioned(
            bottom: _showCheckinDrawer ? 240 : 80,
            right: 16,
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

          // Checkin drawer at bottom
          if (_showCheckinDrawer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_drawerAnimation),
                child: _buildCheckinDrawer(theme),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Open + Unvisited'),
            selected: _currentFilter == MapFilter.openUnvisited,
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = MapFilter.openUnvisited);
                _loadSites();
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('+ Construction'),
            selected: _currentFilter == MapFilter.openUnvisitedConstruction,
            onSelected: (selected) {
              if (selected) {
                setState(
                  () => _currentFilter = MapFilter.openUnvisitedConstruction,
                );
                _loadSites();
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Visited'),
            selected: _currentFilter == MapFilter.visited,
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = MapFilter.visited);
                _loadSites();
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('All Statuses'),
            selected: _currentFilter == MapFilter.all,
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = MapFilter.all);
                _loadSites();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(
              Icons.circle_outlined,
              OkabeIto.green,
              'First up for grabs',
            ),
            const SizedBox(height: 4),
            _legendItem(Icons.schedule, OkabeIto.yellow, 'First today'),
            const SizedBox(height: 4),
            _legendItem(Icons.task_alt, OkabeIto.vermillion, 'First taken'),
            const SizedBox(height: 4),
            _legendItem(Icons.construction, OkabeIto.blue, 'Construction'),
            const SizedBox(height: 4),
            _legendItem(
              Icons.description,
              OkabeIto.reddishPurple,
              'Permit / plan / voting',
            ),
            const SizedBox(height: 4),
            _legendItem(Icons.block, OkabeIto.grey, 'Closed'),
            const SizedBox(height: 4),
            _legendItem(Icons.check_circle, OkabeIto.grey, 'Visited'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return _sites.map((site) {
      return Marker(
        point: LatLng(site.latitude, site.longitude),
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () => _showSiteInfo(site),
          child: _MapMarker(site: site, firstDate: _firstDates[site.siteId]),
        ),
      );
    }).toList();
  }

  void _showSiteInfo(Site site) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(site.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${site.city ?? "Unknown"}, ${site.state ?? ""}, ${site.country}',
            ),
            const SizedBox(height: 4),
            Text('Status: ${site.status.name}'),
            Text('Stalls: ${site.stallCount ?? "Unknown"}'),
            if (site.visited)
              const Chip(label: Text('Visited'), backgroundColor: Colors.green),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await DatabaseService.markSiteVisited(
                      site.siteId,
                      !site.visited,
                    );
                    if (context.mounted) Navigator.pop(context);
                    _loadSites(); // Refresh markers
                  },
                  icon: Icon(
                    site.visited ? Icons.visibility_off : Icons.check_circle,
                  ),
                  label: Text(site.visited ? 'Mark Unvisited' : 'Mark Visited'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _centerOnUser() async {
    setState(() => _isLocating = true);
    _locationAnimController.repeat();

    try {
      final position = await LocationService.instance.getCurrentPosition();

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not determine location. Check location permissions.',
              ),
            ),
          );
        }
        return;
      }

      debugPrint(
        'Got position: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)',
      );

      if (mounted) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          position.accuracy > 1000
              ? 8
              : 10, // Zoom out more for IP-based (less accurate)
        );

        final accuracyNote = position.accuracy > 1000 ? ' (approximate)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Located: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}$accuracyNote',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to get location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: ${e.toString().split('\n').first}'),
          ),
        );
      }
    } finally {
      _locationAnimController.stop();
      _locationAnimController.reset();
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ============================================================================
  // Checkin Drawer Methods
  // ============================================================================

  Widget _buildCheckinDrawer(ThemeData theme) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Update animation based on drag
        if (details.primaryDelta != null && details.primaryDelta! > 0) {
          _drawerAnimController.value =
              (_drawerAnimController.value - details.primaryDelta! / 300).clamp(
                0.0,
                1.0,
              );
        }
      },
      onVerticalDragEnd: (details) {
        // Close if dragged down more than halfway or with velocity
        if (_drawerAnimController.value < 0.5 ||
            (details.primaryVelocity ?? 0) > 500) {
          _closeDrawer();
        } else {
          _drawerAnimController.forward();
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeDrawer,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Location error
            if (_locationError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      onPressed: () {
                        LocationService.instance.clearCache();
                        _fetchLocationForCheckin();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Site list
            Flexible(
              child: _isLoadingLocation || _isLoadingSites
                  ? const Center(child: CircularProgressIndicator())
                  : _nearbySites.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userPosition == null
                                  ? 'Getting location...'
                                  : 'No superchargers nearby',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _nearbySites.length,
                      itemBuilder: (context, index) {
                        final siteWithDist = _nearbySites[index];
                        return FutureBuilder<UserSettingsTableData>(
                          future: DatabaseService.getUserSettings(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return _buildCheckinListTile(
                              siteWithDist,
                              theme,
                              snapshot.data!,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomToSite(Site site) {
    _mapController.move(
      LatLng(site.latitude, site.longitude),
      14, // Zoom level for site view
    );
    _closeDrawer();
  }

  void _closeDrawer() {
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() => _showCheckinDrawer = false);
        widget.onDrawerClosed?.call();
      }
    });
  }

  Widget _buildCheckinListTile(
    SiteWithDistance siteWithDist,
    ThemeData theme,
    UserSettingsTableData settings,
  ) {
    final site = siteWithDist.site;
    final distanceStr = _formatDistance(
      siteWithDist.distanceKm,
      settings.unitSystem,
    );
    final lastVisit = _lastVisits[site.siteId];
    final recent = lastVisit != null
        ? 'Last: ${_formatShortDate(lastVisit)}'
        : 'No previous check-in';
    final firstEligible = !_nearbyFirstDates.containsKey(site.siteId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildCheckinLeadingIcon(theme, firstEligible),
        title: Text(site.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$distanceStr${firstEligible ? " • FIRST eligible" : ""}'),
            Text(recent, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: FilledButton.tonal(
          onPressed: () => _handleCheckin(siteWithDist),
          child: const Text('Check In'),
        ),
        onTap: () => _zoomToSite(site),
      ),
    );
  }

  /// Format distance based on unit system
  String _formatDistance(double distanceKm, UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.imperial) {
      final distanceMiles = distanceKm * 0.621371;
      return '${distanceMiles.toStringAsFixed(1)} mi';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String _formatShortDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _buildCheckinLeadingIcon(ThemeData theme, bool firstEligible) {
    // No qualifying community check-in on or after date_opened.
    if (firstEligible) {
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

  Future<void> _fetchLocationForCheckin() async {
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
      _autoZoomMapToCheckin();
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
      // Get user settings for radius
      final settings = await DatabaseService.getUserSettings();

      final sites = await DatabaseService.getNearbySites(
        latitude: _userPosition!.latitude,
        longitude: _userPosition!.longitude,
        radiusKm: settings.checkinRadiusKm,
        limit: 10,
        status: SiteStatus.open,
        visited: settings.includeVisitedNearby ? null : false,
      );

      final siteIds = sites.map((s) => s.site.siteId).toList();
      final lastVisits = await DatabaseService.getLastVisitDates(siteIds);
      final firstDates = await DatabaseService.getEarliestCheckinDates(siteIds);

      setState(() {
        _nearbySites = sites;
        _lastVisits = lastVisits;
        _nearbyFirstDates = firstDates;
        _isLoadingSites = false;
      });
    } catch (e) {
      debugPrint('Failed to load nearby sites: $e');
      setState(() => _isLoadingSites = false);
    }
  }

  void _autoZoomMapToCheckin() {
    if (_userPosition == null) return;

    final userLatLng = LatLng(
      _userPosition!.latitude,
      _userPosition!.longitude,
    );

    if (_nearbySites.isEmpty) {
      _mapController.move(userLatLng, _userPosition!.accuracy > 1000 ? 10 : 12);
      return;
    }

    // Get up to 3 nearest sites for map bounds
    final sitesToShow = _nearbySites.take(3).toList();

    // Calculate bounds to include user and all sites to show
    double minLat = userLatLng.latitude;
    double maxLat = userLatLng.latitude;
    double minLng = userLatLng.longitude;
    double maxLng = userLatLng.longitude;

    for (final siteWithDist in sitesToShow) {
      final site = siteWithDist.site;
      if (site.latitude < minLat) minLat = site.latitude;
      if (site.latitude > maxLat) maxLat = site.latitude;
      if (site.longitude < minLng) minLng = site.longitude;
      if (site.longitude > maxLng) maxLng = site.longitude;
    }

    // Add padding (10%)
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    final bounds = LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)),
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

    messenger.showSnackBar(
      SnackBar(
        content: Text('Checked in to ${site.name}. Pending until it syncs.'),
      ),
    );
    _closeDrawer();
    _loadSites();
  }
}

/// Custom map marker with accessible design: Okabe-Ito colour paired with a
/// redundant glyph (SPEC Section 5). The green/yellow/red First boundary is
/// recomputed here at render time from the site's earliest check-in date and
/// its local timezone, never from date_opened.
class _MapMarker extends StatelessWidget {
  final Site site;
  final DateTime? firstDate;

  const _MapMarker({required this.site, this.firstDate});

  @override
  Widget build(BuildContext context) {
    final siteLocalNow = TimezoneService.instance.getLocalTimeAtSite(site);
    final firstState = computeFirstState(
      firstDate: firstDate,
      siteLocalNow: siteLocalNow,
    );
    final style = markerStyleFor(
      status: site.status,
      firstState: firstState,
      visited: site.visited,
    );

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
      ),
      child: Icon(
        style.glyph,
        color: glyphForeground(style.color),
        size: 16,
        semanticLabel: style.label,
      ),
    );
  }
}
