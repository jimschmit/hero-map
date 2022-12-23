import 'package:fip_search/models/contact_model.dart';
import 'package:fip_search/services/contacts_service.dart';
import 'package:fip_search/services/geo_coding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class DistanceTab extends StatefulWidget {
  const DistanceTab({super.key});

  @override
  State<DistanceTab> createState() => _DistanceTabState();
}

class _DistanceTabState extends State<DistanceTab> {
  LatLng? searchPosition;
  GeoCoding geoCodingService = GeoCoding();
  ContactsService contactsService = Get.find();
  MapController? mapController;
  final PopupController _popupLayerController = PopupController();

  bool mapReady = false;

  List<Contact>? contacts;
  Contact? selectedContact;

  List<Marker> markers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
            'Bitte eine Suchanfrage eingeben (PLZ, ganze Adresse, Ort,...)'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: searchController,
                decoration: const InputDecoration(
                    hintText: "54338", labelText: "Anfrage"),
              ),
            ),
            TextButton(
                onPressed: () async {
                  searchPosition = await geoCodingService
                      .forwardGeoCode(searchController.text);
                  var contacts = contactsService.contacts$;
                  contacts.sort((a, b) {
                    var distanceA = Geolocator.distanceBetween(
                        searchPosition!.latitude,
                        searchPosition!.longitude,
                        a.lat,
                        a.lng);
                    var distanceB = Geolocator.distanceBetween(
                        searchPosition!.latitude,
                        searchPosition!.longitude,
                        b.lat,
                        b.lng);
                    return distanceA < distanceB ? -1 : 1;
                  });
                  setState(() {
                    mapController?.move(searchPosition!, 7);
                    this.contacts = contacts;
                    selectedContact = null;
                  });
                },
                child: const Text('Suchen'))
          ],
        ),
        if (searchPosition != null)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildMap()),
                if (contacts != null)
                  Expanded(
                    child: ListView.builder(
                        itemCount: contacts!.length,
                        itemBuilder: ((context, index) {
                          var contact = contacts![index];
                          var distance = Geolocator.distanceBetween(
                              searchPosition!.latitude,
                              searchPosition!.longitude,
                              contact.lat,
                              contact.lng);
                          return ListTile(
                            onTap: () => setState(() {
                              selectedContact = contact;
                              var position = LatLng(
                                  selectedContact!.lat, selectedContact!.lng);
                              markers = [
                                Marker(
                                    builder: ((context) =>
                                        const Icon(Icons.vaccines)),
                                    point: position)
                              ];
                              mapController?.move(position, 14);
                            }),
                            title: Text(
                                "${contact.name}: ${_formatDistance(distance)}km"),
                          );
                        })),
                  )
              ],
            ),
          )
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          center: searchPosition,
          zoom: 9,
          onMapReady: () {
            setState(() {
              mapController = MapController();
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
        if (searchPosition != null) ...[
          MarkerLayer(
            markers: [
              Marker(
                  point: searchPosition!,
                  builder: ((context) => const Icon(Icons.location_on)))
            ],
          ),
          MarkerLayer(
            markers: markers,
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupLayerController,
              markers: markers,
              markerRotateAlignment:
                  PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
              popupBuilder: (BuildContext context, Marker marker) {
                var contact = selectedContact!;
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
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  _formatDistance(double distance) {
    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 2;
    return formatter.format(distance / 1000);
  }
}
