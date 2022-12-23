import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';

class GeoCoding {
  final mapbox = MapboxApi(
    accessToken:
        'pk.eyJ1IjoianNjaG1pdCIsImEiOiJjbGMwamF3Z2kxYXg2M3BvNTJlMXp2eHNyIn0.XTlQZlOgy5Y2hb-40gFpyg',
  );
  Future<LatLng> forwardGeoCode(String location) async {
    final response = await mapbox.forwardGeocoding.request(
      searchText: location,
      fuzzyMatch: true,
    );
    var feature = response.features?.first;
    if (feature == null) {
      throw ErrorDescription("Can't map that location to a geocoodinate");
    }
    return Future.value(LatLng(feature.center!.last, feature.center!.first));
  }
}
