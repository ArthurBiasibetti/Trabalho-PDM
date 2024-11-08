import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_pdm/components/customButton.dart';
import 'package:trabalho_pdm/components/customTextfield.dart';
import 'package:trabalho_pdm/models/patient_model.dart';
import 'package:trabalho_pdm/pages/Patient_maps_page.dart';
import 'package:trabalho_pdm/service/patient_service.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class PatientLoginPage extends StatelessWidget {
  PatientLoginPage({super.key});

  final _patientCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Future<void> patientLogin() async {
      try {
        dynamic patient = await PatientService()
            .login(_patientCodeController.text.toUpperCase().trim());

        if (patient != null) {
          dynamic patientData = patient.data() as Map;
          List<dynamic> areaData = patientData['area'];
          List<GeoPoint> areaCoordinates =
              areaData.map((item) => item as GeoPoint).toList();

          PatientModel patientModel = PatientModel(
            name: patientData['name'],
            age: patientData['age'],
            address: patientData['address'],
            area: areaCoordinates,
          );
          await Future.delayed(const Duration(seconds: 1));

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => PatientMapScreen(
                    patient: patientModel, patientRef: patient.id),
              ),
              ModalRoute.withName('/patient-map'),
            );
          }
        } else {
          ToastMessage().warning(message: "Esse código não existe!");
        }
      } catch (error) {
        ToastMessage().error(message: 'Algo deu errado. Tente novamente!');

        throw ErrorDescription(error.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Entrar como paciente',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 24),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _patientCodeController,
                  hintText: 'Código do paciente',
                  obscureText: false,
                  required: true,
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: patientLogin,
                  text: 'Entrar',
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
