import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_pdm/pages/login_page.dart';
import 'package:trabalho_pdm/pages/register_patient_page.dart';
import 'package:trabalho_pdm/service/patient_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? userCredential = FirebaseAuth.instance.currentUser;
  final PatientService _pacienteService = PatientService();

  Color _getStatusColor(String status) {
    switch (status) {
      case 'outOfArea':
        return Colors.red;
      case 'active':
        return Colors.green;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(userCredential);

    if (userCredential == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        ModalRoute.withName('/login'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _pacienteService.getPatients(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Não há pacientes cadastrados',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            List<DocumentSnapshot> patients = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final paciente = patients[index].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(
                                  paciente.containsKey('status')
                                      ? paciente['status']
                                      : 'indefinido'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            paciente['name']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text('Endereço: ${paciente['address']}')
                              ]),
                              const SizedBox(height: 5),
                              Row(children: [
                                Text('Idade: ${paciente['age']}')
                              ]),
                              const SizedBox(height: 5),
                              Row(children: [
                                Text('Código do paciente: ${paciente['code']}')
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPatientPage(),
            ),
          );
        },
        backgroundColor: Colors.blue.shade100,
        tooltip: 'Adicionar Paciente',
        child: Icon(Icons.add, color: Colors.blue.shade800),
      ),
    );
  }
}
