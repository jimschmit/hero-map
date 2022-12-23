import 'package:fip_search/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfo extends StatelessWidget {
  final Contact contact;
  final Future<Position>? currentPosition;
  final LatLng? referencePosition;
  const ContactInfo({
    super.key,
    this.currentPosition,
    this.referencePosition,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
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
            GestureDetector(
                onTap: () =>
                    launchUrl(Uri.parse('tel://${contact.phoneNumber}')),
                child: Text(contact.phoneNumber!)),
          const SizedBox(
            height: 8,
          ),
          if (contact.additionalInfo != null) Text(contact.additionalInfo!),
          const SizedBox(
            height: 8,
          ),
          if (currentPosition != null)
            FutureBuilder(
                future: currentPosition,
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var position = snapshot.data!;
                  var distance = Geolocator.distanceBetween(
                      referencePosition!.latitude,
                      referencePosition!.longitude,
                      position.latitude,
                      position.longitude);
                  NumberFormat formatter = NumberFormat();
                  formatter.minimumFractionDigits = 0;
                  formatter.maximumFractionDigits = 2;
                  var formattedDistance = formatter.format(distance / 1000);
                  return Text('Distanz: ${formattedDistance}km');
                }))
        ],
      ),
    );
  }
}
