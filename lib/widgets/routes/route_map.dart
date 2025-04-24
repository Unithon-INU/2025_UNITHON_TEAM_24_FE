// lib/widgets/routes/route_map.dart
import 'dart:async';
import 'package:flutter/material.dart';
// *** 수정: 올바른 google_maps_flutter import ***
import 'package:google_maps_flutter/google_maps_flutter.dart';
// *** 수정: 올바른 polyline_points import ***
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../models/route.dart';
import '../../models/place.dart';

class RouteMap extends StatefulWidget {
  final TravelRoute route;

  const RouteMap({Key? key, required this.route}) : super(key: key);

  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _buildMapElements();
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route.id != oldWidget.route.id) {
      print(">>> RouteMap: Route data updated. Rebuilding map elements for route ID: ${widget.route.id}");
      _buildMapElements();
      if (_mapController != null) {
        _moveCameraToBounds();
      }
    }
  }

  void _buildMapElements() {
    _markers.clear();
    _polylines.clear();

    if (widget.route.places.isEmpty) {
      print(">>> RouteMap: No places found in the route.");
      if (mounted) setState(() {});
      return;
    }
    print(">>> RouteMap: Building markers and polylines for ${widget.route.places.length} places.");

    for (int i = 0; i < widget.route.places.length; i++) {
      final place = widget.route.places[i];
      if (place.latitude != 0 && place.longitude != 0) {
        _markers.add(
          Marker(
            markerId: MarkerId('place_${place.id}_$i'),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              i == 0 ? BitmapDescriptor.hueGreen :
              i == widget.route.places.length - 1 ? BitmapDescriptor.hueRed :
              BitmapDescriptor.hueViolet,
            ),
          ),
        );
      }
    }

    if (widget.route.movingInfo.isNotEmpty) {
      for (int i = 0; i < widget.route.movingInfo.length; i++) {
        final movingInfo = widget.route.movingInfo[i];
        if (movingInfo.overviewPolyline != null && movingInfo.overviewPolyline!.isNotEmpty) {
          try {
            final List<PointLatLng> points = 
                polylinePoints.decodePolyline(movingInfo.overviewPolyline!);
            final List<LatLng> polylineCoordinates = points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

            if (polylineCoordinates.isNotEmpty) {
              _polylines.add(
                Polyline(
                  polylineId: PolylineId('route_$i'),
                  color: Colors.blue,
                  points: polylineCoordinates,
                  width: 5,
                ),
              );
            }
          } catch (e) {
            print(">>> RouteMap: Error decoding polyline: $e");
          }
        } else {
          if (i < widget.route.places.length - 1) {
            final start = widget.route.places[i];
            final end = widget.route.places[i + 1];
            if (start.latitude != 0 && start.longitude != 0 &&
                end.latitude != 0 && end.longitude != 0) {
              _polylines.add(
                Polyline(
                  polylineId: PolylineId('direct_$i'),
                  color: Colors.grey,
                  points: [
                    LatLng(start.latitude, start.longitude),
                    LatLng(end.latitude, end.longitude),
                  ],
                  width: 3,
                ),
              );
            }
          }
        }
      }
    } else {
      for (int i = 0; i < widget.route.places.length - 1; i++) {
        final start = widget.route.places[i];
        final end = widget.route.places[i + 1];
        if (start.latitude != 0 && start.longitude != 0 &&
            end.latitude != 0 && end.longitude != 0) {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('direct_$i'),
              color: Colors.grey,
              points: [
                LatLng(start.latitude, start.longitude),
                LatLng(end.latitude, end.longitude),
              ],
              width: 3,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {});
      if (_mapController != null) {
        _moveCameraToBounds();
      }
    }
  }

  void _moveCameraToBounds() {
    if (widget.route.places.isEmpty || _mapController == null) return;

    final bounds = _calculateBounds();
    if (bounds != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    } else {
      final firstPlace = widget.route.places.first;
      if (firstPlace.latitude != 0 && firstPlace.longitude != 0) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(firstPlace.latitude, firstPlace.longitude),
              zoom: 14.0,
            ),
          ),
        );
      }
    }
  }

  LatLngBounds? _calculateBounds() {
    final validPlaces = widget.route.places
        .where((p) => p.latitude != 0 && p.longitude != 0)
        .toList();
    
    if (validPlaces.isEmpty) return null;

    double minLat = validPlaces.first.latitude;
    double maxLat = validPlaces.first.latitude;
    double minLng = validPlaces.first.longitude;
    double maxLng = validPlaces.first.longitude;

    for (final place in validPlaces) {
      if (place.latitude < minLat) minLat = place.latitude;
      if (place.latitude > maxLat) maxLat = place.latitude;
      if (place.longitude < minLng) minLng = place.longitude;
      if (place.longitude > maxLng) maxLng = place.longitude;
    }

    if ((maxLat - minLat) < 0.01) {
      maxLat += 0.005;
      minLat -= 0.005;
    }
    if ((maxLng - minLng) < 0.01) {
      maxLng += 0.005;
      minLng -= 0.005;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route.places.isEmpty) {
      return Center(
        child: Text('장소 정보가 없습니다.'),
      );
    }

    final initialLatLng = widget.route.places.first.latitude != 0 && 
                          widget.route.places.first.longitude != 0
        ? LatLng(
            widget.route.places.first.latitude,
            widget.route.places.first.longitude,
          )
        : const LatLng(37.5665, 126.9780);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialLatLng,
        zoom: 13.0,
      ),
      markers: _markers,
      polylines: _polylines,
      mapType: MapType.normal,
      myLocationEnabled: false,
      zoomControlsEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        Future.delayed(Duration(milliseconds: 300), () {
          _moveCameraToBounds();
        });
      },
    );
  }
}