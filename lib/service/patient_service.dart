import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_pdm/models/patient_model.dart';
import 'package:trabalho_pdm/models/user_model.dart';
import 'package:trabalho_pdm/service/auth_service.dart';
import 'package:trabalho_pdm/utils/generatePatientCode.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class PatientService {
  final _db = FirebaseFirestore.instance;

  inTheArea(String patientRef) async {
    await _db
        .collection('Patient')
        .doc(patientRef)
        .set({"status": 'active'}, SetOptions(merge: true));
  }

  outOfArea(String patientRef) async {
    await _db
        .collection('Patient')
        .doc(patientRef)
        .set({"status": 'outOfArea'}, SetOptions(merge: true));
  }

  logout(String patientRef) async {
    await _db
        .collection('Patient')
        .doc(patientRef)
        .set({"status": 'inactive'}, SetOptions(merge: true));
  }

  login(String code) async {
    QuerySnapshot patient =
        await _db.collection('Patient').where('code', isEqualTo: code).get();

    if (patient.docs.isNotEmpty) {
      await _db
          .collection('Patient')
          .doc(patient.docs.first.id)
          .set({"status": 'active'}, SetOptions(merge: true));

      return patient.docs.first;
    }

    return null;
  }

  createPatient(PatientModel patient) async {
    patient.code = await generateCode();
    UserModel? user = await AuthService().getUser();

    if (user != null) {
      patient.userId = user.id;
    }

    await _db.collection("Patient").add(patient.toJson()).whenComplete(
      () {
        ToastMessage().success(message: 'Paciente criado com sucesso!');
      },
    ).catchError(
      (error, stackTrace) {
        ToastMessage()
            .warning(message: 'Algo deu errado! por favor tente novamente!');
        return null;
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPatients(UserModel user) {
    Stream<QuerySnapshot<Map<String, dynamic>>> patientSnapShot = _db
        .collection('Patient')
        .where('userId', isEqualTo: user.id)
        .snapshots();

    return patientSnapShot;
  }
}
