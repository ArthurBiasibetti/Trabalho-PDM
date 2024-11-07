import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'package:trabalho_pdm/components/customButton.dart';
import 'package:trabalho_pdm/components/customTextfield.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  LatLng initialCamera = LatLng(-23.550520, -46.633308);
  List<LatLng> area = [];
  GoogleMapController? mapController;
  bool isLoading = true;

  final TextEditingController locationAddressController =
      TextEditingController();

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  void _getCurrentPosition() async {
    if (isLoading) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        LocationPermission requestedPermission =
            await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          print('Permissões negadas');
          return;
        }
      }

      Position location = await Geolocator.getCurrentPosition();

      setState(() {
        initialCamera = LatLng(location.latitude, location.longitude);
        isLoading = false;
      });
    }

    mapController?.animateCamera(CameraUpdate.newLatLng(initialCamera));
  }

  Future<void> _searchAddress() async {
    String address = locationAddressController.text;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;

        mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(location.latitude, location.longitude),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Endereço não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar o endereço')),
      );
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      area.add(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = area.map(
      (location) {
        var index = area.indexOf(location);
        return Marker(
          markerId: MarkerId('area-$index'),
          position: LatLng(location.latitude, location.longitude),
          draggable: true,
          onDragEnd: (location) {
            setState(() {
              area.replaceRange(index, index + 1, [location]);
            });
          },
          onTap: () {
            setState(() {
              area.removeAt(index);
            });
          },
          icon: markerIcon,
        );
      },
    ).toList();

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onTap: _onMapTap,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition:
                        CameraPosition(target: initialCamera, zoom: 14),
                    markers: Set<Marker>.of(markers),
                    polygons: area.length > 2
                        ? {
                            Polygon(
                              polygonId: PolygonId('area'),
                              points: area,
                              fillColor: Colors.blue.shade200.withOpacity(0.2),
                              strokeColor: Colors.blue.shade600,
                              strokeWidth: 2,
                            )
                          }
                        : {},
                    circles: area.length == 2
                        ? {
                            Circle(
                              circleId: CircleId('circle-area'),
                              center: area[0],
                              radius: Geolocator.distanceBetween(
                                area[0].latitude,
                                area[0].longitude,
                                area[1].latitude,
                                area[1].longitude,
                              ),
                              strokeColor: Colors.blue.shade600,
                              fillColor: Colors.blue.shade200.withOpacity(0.2),
                              strokeWidth: 2,
                            )
                          }
                        : {},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  child: Column(
                    children: [
                      MyTextField(
                        controller: locationAddressController,
                        hintText: 'Endereço',
                        obscureText: false,
                        required: false,
                      ),
                      const SizedBox(height: 15),
                      MyButton(
                        onTap: _searchAddress,
                        text: 'Buscar endereço',
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                      MyButton(
                        onTap: () {
                          Navigator.pop(context, area);
                        },
                        text: 'Confirmar área',
                        color: Colors.deepPurple.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Positioned(
            //   top: 32,
            //   right: 24,
            //   child: FloatingActionButton(
            //     backgroundColor: Colors.white,
            //     onPressed: getCurrentPosition,
            //     child: const Icon(
            //       Icons.my_location,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   bottom: 16,
            //   left: 24,
            //   child: FloatingActionButton(
            //     backgroundColor: Colors.white,
            //     onPressed: () => Navigator.pop(context, area),
            //     child: const Icon(
            //       Icons.check,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
          );
  }
}
