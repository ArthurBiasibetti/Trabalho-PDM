import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

class ConvertLatLng {
  gm.LatLng toGmLatLng(mt.LatLng latLng) {
    return gm.LatLng(latLng.latitude, latLng.longitude);
  }

  mt.LatLng toMtLatLng(gm.LatLng latLng) {
    return mt.LatLng(latLng.latitude, latLng.longitude);
  }
}
