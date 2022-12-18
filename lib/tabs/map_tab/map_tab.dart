import 'dart:async';

import 'package:fip_search/models/contact_model.dart';
import 'package:fip_search/services/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class MapsTab extends StatefulWidget {
  const MapsTab({super.key});

  @override
  State<MapsTab> createState() => _MapsTabState();
}

class _MapsTabState extends State<MapsTab> {
  MapController mapController = MapController();
  var currentLocationLayer = CurrentLocationLayer(
    style: const LocationMarkerStyle(marker: DefaultLocationMarker()),
  );
  final PopupController _popupLayerController = PopupController();

  ContactsService service = Get.find();
  List<Contact>? contacts;

  List<Marker> markers = [];
  StreamSubscription? subscription;
  Future<Position>? position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = service.contacts$.listen((el) {
      setState(() {
        contacts = el;
        markers = el
            .map((element) => Marker(
                point: LatLng(element.lat, element.lng),
                builder: (c) => const Icon(Icons.vaccines)))
            .toList();
      });
    });
    service.fetchContacts();
    position = _determinePosition();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription!.cancel();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(center: LatLng(51.165691, 10.451526), zoom: 6),
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
              currentLocationLayer,
              MarkerLayer(markers: markers),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupLayerController,
                  markers: markers,
                  markerRotateAlignment:
                      PopupMarkerLayerOptions.rotationAlignmentFor(
                          AnchorAlign.top),
                  popupBuilder: (BuildContext context, Marker marker) {
                    var index = markers.indexOf(marker);
                    var contact = contacts![index];
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(contact.name!),
                          const SizedBox(
                            height: 8,
                          ),
                          if (contact.email != null) Text(contact.email!),
                          const SizedBox(
                            height: 8,
                          ),
                          if (contact.phoneNumber != null)
                            Text(contact.phoneNumber!),
                          const SizedBox(
                            height: 8,
                          ),
                          if (contact.additionalInfo != null)
                            Text(contact.additionalInfo!),
                          const SizedBox(
                            height: 8,
                          ),
                          FutureBuilder(
                              future: position,
                              builder: ((context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                var position = snapshot.data!;
                                var distance = Geolocator.distanceBetween(
                                    marker.point.latitude,
                                    marker.point.longitude,
                                    position.latitude,
                                    position.longitude);
                                NumberFormat formatter = NumberFormat();
                                formatter.minimumFractionDigits = 0;
                                formatter.maximumFractionDigits = 2;
                                var formattedDistance =
                                    formatter.format(distance / 1000);
                                return Text('Distanz: ${formattedDistance}km');
                              }))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
