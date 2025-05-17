import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinishedScreen extends StatelessWidget {
  const FinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos Concluídos'),
        backgroundColor: const Color(0xFFFF6C00),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patient_records')
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar registros.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum atendimento concluído.'));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;

              return Card(
                color: Colors.green[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['name'] ?? 'Sem nome'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Sintomas: ${data['symptoms']}'),
                      Text('Origem da dor: ${data['painOrigin']}'),
                      Text('Nível da dor: ${data['painLevel'].toString()}'),
                      Text('Última atualização: ${data['lastUpdate']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
