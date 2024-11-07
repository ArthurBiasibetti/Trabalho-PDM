import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabalho_pdm/models/patient_model.dart';
import 'package:trabalho_pdm/models/user_model.dart';
import 'package:trabalho_pdm/service/auth_service.dart';
import 'package:trabalho_pdm/utils/generatePatientCode.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class PatientService {
  final _db = FirebaseFirestore.instance;

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
        print(error.toString());
        return null;
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPatients() {
    Stream<QuerySnapshot<Map<String, dynamic>>> patientSnapShot =
        _db.collection('Patient').snapshots();

    return patientSnapShot;
  }
}
