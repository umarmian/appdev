import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const UlocApp());
}

class UlocApp extends StatelessWidget {
  const UlocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uloc',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.green,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final LatLng _initialLocation = const LatLng(
    31.4475,
    73.6978,
  ); // Baba Guru Nanak University
  List<Marker> _markers = [];
  bool _isSearching = false; // To indicate if a search is in progress

  @override
  void initState() {
    super.initState();
    // Add initial marker
    _markers = [
      Marker(
        point: _initialLocation,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.green, size: 40),
      ),
    ];
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true; // Start searching
    });

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&polygon=1&addressdetails=1',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final placeName = data[0]['display_name'];

          if (mounted) {
            setState(() {
              _isSearching = false; // Search complete
              _markers = [
                Marker(
                  point: LatLng(lat, lon),
                  width: 50,
                  height: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 50,
                      ),
                      if (placeName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            placeName.length > 20
                                ? '${placeName.substring(0, 20)}...'
                                : placeName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ];
              _mapController.move(LatLng(lat, lon), 15.0);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isSearching = false; // Search complete (no results)
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No location found matching your search.'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isSearching = false; // Search complete (error)
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch location data.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false; // Search complete (error)
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error during search: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Places')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.uloc.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _isSearching
                            ? const CircularProgressIndicator() // Show progress indicator
                            : IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                if (_markers.length > 1) {
                                  setState(() {
                                    _markers.removeRange(1, _markers.length);
                                    _mapController.move(_initialLocation, 15.0);
                                  });
                                }
                              },
                            ),
                  ),
                  onSubmitted: (query) => _searchLocation(query),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_initialLocation, 15.0);
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
