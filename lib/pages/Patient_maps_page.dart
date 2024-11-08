import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_pdm/models/patient_model.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;
import 'package:trabalho_pdm/service/patient_service.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class PatientMapScreen extends StatefulWidget {
  final PatientModel patient;
  final String patientRef;

  const PatientMapScreen(
      {super.key, required this.patient, required this.patientRef});

  @override
  State<PatientMapScreen> createState() => _PatientMapScreenState();
}

class _PatientMapScreenState extends State<PatientMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startTrackingUserLocation();
  }

  @override
  void dispose() async {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _patientOutOfArea() async {
    await PatientService().outOfArea(widget.patientRef);

    return;
  }

  Future<void> _patientInTheArea() async {
    await PatientService().inTheArea(widget.patientRef);

    return;
  }

  bool isOutOfArea(Position position) {
    List<map_tool.LatLng> delimeterArea = widget.patient.area
        .map(
          (element) => map_tool.LatLng(element.latitude, element.longitude),
        )
        .toList();

    return !map_tool.PolygonUtil.containsLocation(
      map_tool.LatLng(position.latitude, position.longitude),
      delimeterArea,
      false,
    );
  }

  Future<void> _startTrackingUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ToastMessage().warning(message: "Permissão de localização negada.");
        return;
      }
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 0),
    ).listen((Position position) async {
      if (isOutOfArea(position)) {
        await _patientOutOfArea();
      } else {
        await _patientInTheArea();
      }

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<LatLng> delimiterArea = widget.patient.area
        .map(
          (element) => LatLng(element.latitude, element.longitude),
        )
        .toList();

    List<Marker> markers = delimiterArea.map(
      (location) {
        var index = delimiterArea.indexOf(location);
        return Marker(
          markerId: MarkerId('area-$index'),
          position: LatLng(location.latitude, location.longitude),
        );
      },
    ).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(-23.550520, -46.633308),
                zoom: 18,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: {
                ...Set<Marker>.of(markers),
                if (_currentPosition != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
              },
              polygons: delimiterArea.length > 2
                  ? {
                      Polygon(
                        polygonId: PolygonId('area'),
                        points: delimiterArea,
                        fillColor: Colors.blue.shade200.withOpacity(0.2),
                        strokeColor: Colors.blue.shade600,
                        strokeWidth: 2,
                      )
                    }
                  : {},
              circles: delimiterArea.length == 2
                  ? {
                      Circle(
                        circleId: CircleId('circle-area'),
                        center: delimiterArea[0],
                        radius: Geolocator.distanceBetween(
                          delimiterArea[0].latitude,
                          delimiterArea[0].longitude,
                          delimiterArea[1].latitude,
                          delimiterArea[1].longitude,
                        ),
                        strokeColor: Colors.blue.shade600,
                        fillColor: Colors.blue.shade200.withOpacity(0.2),
                        strokeWidth: 2,
                      )
                    }
                  : {},
            ),
    );
  }
}
