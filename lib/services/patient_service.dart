import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientService {
  final CollectionReference patientRecords =
      FirebaseFirestore.instance.collection('patient_records');

  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> savePatient({
    required String? docId,
    required String name,
    required int? age,
    required double? weight,
    required String symptoms,
    required String color,
    required bool isCompleted,
    String? allergies,
    required String cpfRg,
    required String susCard,
    required String birthDate,
    required String sex,
    required String maritalStatus,
    required String motherName,
    required String address,
    int? pressaoSistolica,
    int? pressaoDiastolica,
    int? frequenciaCardiaca,
    int? saturacaoO2,
    double? temperatura,
    int? frequenciaRespiratoria,
    String? horaSinaisVitais,
  }) async {
    final String formattedLastUpdate = formatter.format(DateTime.now());

    final patientData = <String, dynamic>{
      'name': name,
      'age': age,
      'weight': weight,
      'symptoms': symptoms,
      'color': color,
      'isCompleted': isCompleted,
      'lastUpdate': formattedLastUpdate,
      'cpfRg': cpfRg,
      'susCard': susCard,
      'birthDate': birthDate,
      'sex': sex,
      'maritalStatus': maritalStatus,
      'motherName': motherName,
      'address': address,
      if (allergies != null && allergies.isNotEmpty) 'allergies': allergies,
      if (pressaoSistolica != null) 'pressaoSistolica': pressaoSistolica,
      if (pressaoDiastolica != null) 'pressaoDiastolica': pressaoDiastolica,
      if (frequenciaCardiaca != null) 'frequenciaCardiaca': frequenciaCardiaca,
      if (saturacaoO2 != null) 'saturacaoO2': saturacaoO2,
      if (temperatura != null) 'temperatura': temperatura,
      if (frequenciaRespiratoria != null)
        'frequenciaRespiratoria': frequenciaRespiratoria,
      if (horaSinaisVitais != null && horaSinaisVitais.isNotEmpty)
        'horaSinaisVitais': horaSinaisVitais,
    };

    if (docId == null) {
      await patientRecords.add(patientData);
    } else {
      await patientRecords.doc(docId).update(patientData);
    }
  }

  Future<void> markAsCompleted(String docId) async {
    await patientRecords.doc(docId).update({
      'isCompleted': true,
      'lastUpdate': formatter.format(DateTime.now()),
    });
  }
}
