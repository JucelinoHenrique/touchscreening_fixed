import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientService {
  final CollectionReference patientRecords =
      FirebaseFirestore.instance.collection('patient_records');

  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> savePatient({
    required String? docId,
    required String name,
    required int?
        age, // Idade pode continuar opcional ou se tornar obrigatória também? Por ora, mantenho opcional.
    required String symptoms,
    required String color,
    required bool isCompleted,
    String? allergies,
    String? medicamentosUsoContinuo,
    required String cpfRg,
    required String susCard,
    required String birthDate,
    required String sex,
    required String maritalStatus,
    required String motherName,
    required String address,
    // SINAIS VITAIS - TORNANDO OBRIGATÓRIOS
    required double weight,
    required int pressaoSistolica,
    required int pressaoDiastolica,
    required int frequenciaCardiaca,
    required int saturacaoO2,
    required double temperatura,
    required int frequenciaRespiratoria,
    required String horaSinaisVitais,
  }) async {
    final String formattedLastUpdate = formatter.format(DateTime.now());

    final patientData = <String, dynamic>{
      'name': name,
      'age': age,
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
      'weight': weight,
      'pressaoSistolica': pressaoSistolica,
      'pressaoDiastolica': pressaoDiastolica,
      'frequenciaCardiaca': frequenciaCardiaca,
      'saturacaoO2': saturacaoO2,
      'temperatura': temperatura,
      'frequenciaRespiratoria': frequenciaRespiratoria,
      'horaSinaisVitais': horaSinaisVitais,
      if (allergies != null && allergies.isNotEmpty) 'allergies': allergies,
      if (medicamentosUsoContinuo != null && medicamentosUsoContinuo.isNotEmpty)
        'medicamentosUsoContinuo': medicamentosUsoContinuo,
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
