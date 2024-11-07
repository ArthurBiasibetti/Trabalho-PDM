import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_pdm/components/customButton.dart';
import 'package:trabalho_pdm/components/customTextfield.dart';
import 'package:trabalho_pdm/models/patient_model.dart';
import 'package:trabalho_pdm/pages/maps_page.dart';
import 'package:trabalho_pdm/service/patient_service.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

class RegisterPatientPage extends StatefulWidget {
  RegisterPatientPage({super.key});

  @override
  _RegisterPatientPageState createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController patientAgeController = TextEditingController();
  final TextEditingController patientAddressController =
      TextEditingController();

  List<LatLng> selectedArea = []; // Para armazenar a área selecionada no mapa

  // Método para abrir a página de mapa e selecionar a área
  void _selecionarArea() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapScreen()), // Use sua página de mapa aqui
    ).then((area) {
      setState(() {
        selectedArea = area;
      });
    });
  }

  num _getSquareArea(List<LatLng> areas) {
    List<mt.LatLng> areaList = areas
        .map((element) => mt.LatLng(element.latitude, element.longitude))
        .toList();

    return mt.SphericalUtil.computeArea(areaList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                'Adicionar paciente',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 24),
              ),
              const Icon(Icons.group_add, size: 100),
              const SizedBox(height: 25),
              MyTextField(
                controller: patientNameController,
                hintText: 'Nome completo',
                obscureText: false,
                required: true,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: patientAgeController,
                hintText: 'Idade',
                obscureText: false,
                keyboardType: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: patientAddressController,
                hintText: 'Endereço',
                obscureText: false,
                required: true,
              ),
              const SizedBox(height: 15),

              if (selectedArea.isNotEmpty)
                Text(
                  selectedArea.length > 2
                      ? 'Área de ${_getSquareArea(selectedArea).round()}m²'
                      : 'Área em um raio de ${Geolocator.distanceBetween(selectedArea[0].latitude, selectedArea[0].longitude, selectedArea[1].latitude, selectedArea[1].longitude).round()}m',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),

              const SizedBox(height: 25),

              MyButton(
                onTap: _selecionarArea,
                text: 'Criar área delimitadora',
                color: Colors.black,
              ),

              const SizedBox(height: 15),
              // Botão para adicionar o paciente

              MyButton(
                onTap: () async {
                  final patient = PatientModel(
                    name: patientNameController.text,
                    address: patientAddressController.text,
                    age: int.parse(
                      patientAgeController.text,
                    ),
                    area: selectedArea
                        .map(
                          (location) =>
                              GeoPoint(location.latitude, location.longitude),
                        )
                        .toList(),
                  );
                  PatientService().createPatient(patient).then(
                        (_) async => {
                          await Future.delayed(const Duration(seconds: 1)),
                          if (context.mounted)
                            {
                              Navigator.pop(context),
                            }
                        },
                      );
                },
                text: 'Adicionar',
                color: Colors.deepPurple.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
