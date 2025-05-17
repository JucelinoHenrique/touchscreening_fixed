import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientService {
  final CollectionReference patientRecords =
      FirebaseFirestore.instance.collection('patient_records');

  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> savePatient({
    required String? docId,
    required String name,
    required int age,
    required String weight,
    required String symptoms,
    required String color,
    required bool isCompleted,
    String? allergies,
  }) async {
    final patientData = {
      'name': name,
      'age': age,
      'weight': weight,
      'symptoms': symptoms,
      'lastUpdate': formatter.format(now), // Aqui é o ponto crítico corrigido
      'color': color,
      'isCompleted': isCompleted,
      if (allergies != null && allergies.isNotEmpty) 'allergies': allergies,
    };

    if (docId == null) {
      await patientRecords.add(patientData);
    } else {
      await patientRecords.doc(docId).update(patientData);
    }
  }

  Future<void> markAsCompleted(String docId) async {
    await patientRecords.doc(docId).update({'isCompleted': true});
  }
}
