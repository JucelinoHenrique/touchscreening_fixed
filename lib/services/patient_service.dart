import 'package:cloud_firestore/cloud_firestore.dart';

class PatientService {
  final CollectionReference patientRecords =
      FirebaseFirestore.instance.collection('patient_records');

  Future<void> savePatient({
    required String? docId,
    required String name,
    required int age,
    required String symptoms,
    required String color,
    required String painOrigin,
    required double painLevel,
  }) async {
    final patientData = {
      'name': name,
      'age': age,
      'symptoms': symptoms,
      'lastUpdate': DateTime.now().toString(),
      'color': color,
      'painOrigin': painOrigin,
      'painLevel': painLevel,
    };

    if (docId == null) {
      await patientRecords.add(patientData);
    } else {
      await patientRecords.doc(docId).update(patientData);
    }
  }
}
