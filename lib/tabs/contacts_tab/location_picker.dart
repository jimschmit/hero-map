import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.onLocationUpdate,
    this.position,
  });
  final void Function(LatLng location) onLocationUpdate;
  final LatLng? position;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  MapController? mapController = MapController();
  bool mapReady = false;
  Marker? locationMarker;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: ValueKey(MediaQuery.of(context).orientation),
      mapController: mapController,
      options: MapOptions(
          center: widget.position ?? LatLng(51.165691, 10.451526),
          zoom: 6,
          onMapReady: () {
            setState(() {
              mapReady = true;
              locationMarker = Marker(
                  point: mapController!.center,
                  builder: (c) => const Icon(Icons.location_on_sharp));
              mapController?.mapEventStream.listen((event) {
                widget.onLocationUpdate(event.center);
                setState(() {
                  locationMarker = Marker(
                      point: event.center,
                      builder: (c) => const Icon(Icons.location_on_sharp));
                });
              });
            });
          }),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [if (mapReady) locationMarker!],
        ),
      ],
    );
  }
}
