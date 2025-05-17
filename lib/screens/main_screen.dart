import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/provider.dart' as my_auth;
import '../services/patient_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();

  String? selectedPriority;
  String? selectedPainOrigin;
  double painLevel = 0;
  String? editingDocId;

  final PatientService _patientService = PatientService();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6C00),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('lib/assets/images/logo.png'),
            ),
            const SizedBox(width: 10),
            Text(
              currentUser != null
                  ? 'Olá, Enf. ${currentUser.displayName}'
                  : 'Olá, Enf.',
              style: const TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser != null
                  ? 'Enf. ${currentUser.displayName}'
                  : 'Olá, Enf.'),
              accountEmail:
                  Text(currentUser != null ? ' ${currentUser.email}' : ''),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/logo.png'),
              ),
              decoration: const BoxDecoration(color: Color(0xFFFF6C00)),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Atendimentos Finalizados'),
              onTap: () {
                Navigator.pushNamed(context, '/finished');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Atualizações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patient_records')
                    .where('isCompleted',
                        isEqualTo: false) // apenas não concluídos
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Erro ao carregar registros.'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Nenhum registro encontrado.'));
                  }

                  final records = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final data = record.data() as Map<String, dynamic>;
                      return _buildPatientCard(
                        docId: record.id,
                        name: data['name'],
                        symptoms: (data['symptoms'] as String).split(','),
                        lastUpdate: data['lastUpdate'],
                        color: data['color'],
                        painOrigin: data['painOrigin'],
                        painLevel: (data['painLevel'] as num).toDouble(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPatientForm(),
        backgroundColor: const Color(0xFFFF6C00),
        child: Image.asset('lib/assets/images/LOGO1.png'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        height: 53,
        color: Color.fromARGB(255, 219, 214, 214),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome do Paciente',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Idade',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedPriority,
          items: const [
            DropdownMenuItem(
                value: 'Vermelho', child: Text('Vermelho - Emergência')),
            DropdownMenuItem(
                value: 'Laranja', child: Text('Laranja - Muito urgente')),
            DropdownMenuItem(
                value: 'Amarelo', child: Text('Amarelo - Urgente')),
            DropdownMenuItem(
                value: 'Verde', child: Text('Verde - Pouco urgente')),
            DropdownMenuItem(value: 'Azul', child: Text('Azul - Não urgente')),
          ],
          onChanged: (value) => setState(() => selectedPriority = value),
          decoration: const InputDecoration(
            labelText: 'Prioridade (Manchester)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Origem da Dor:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: [
            _buildPainOriginButton(
                Icons.face,
                'Cabeça',
                () => setState(() => selectedPainOrigin = 'Cabeça'),
                selectedPainOrigin == 'Cabeça'),
            _buildPainOriginButton(
                Icons.accessibility,
                'Peito',
                () => setState(() => selectedPainOrigin = 'Peito'),
                selectedPainOrigin == 'Peito'),
            _buildPainOriginButton(
                Icons.accessibility_new,
                'Braço',
                () => setState(() => selectedPainOrigin = 'Braço'),
                selectedPainOrigin == 'Braço'),
            _buildPainOriginButton(
                Icons.directions_walk,
                'Pernas',
                () => setState(() => selectedPainOrigin = 'Pernas'),
                selectedPainOrigin == 'Pernas'),
          ],
        ),
        const SizedBox(height: 10),
        Slider(
          value: painLevel,
          min: 0,
          max: 5,
          divisions: 5,
          label: painLevel.round().toString(),
          onChanged: (value) => setState(() => painLevel = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: symptomsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Sintomas',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPainOriginButton(
      IconData icon, String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.orange : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openPatientForm({Map<String, dynamic>? data}) async {
    if (data != null) {
      nameController.text = data['name'];
      ageController.text = data['age'].toString();
      symptomsController.text = data['symptoms'];
      selectedPriority = data['color'];
      selectedPainOrigin = data['painOrigin'];
      painLevel = data['painLevel']?.toDouble() ?? 0;
      editingDocId = data['docId']; // 🔥 Corrigido: agora usamos docId
    } else {
      nameController.clear();
      ageController.clear();
      symptomsController.clear();
      selectedPriority = null;
      selectedPainOrigin = null;
      painLevel = 0;
      editingDocId = null;
    }

    final flutterTts = FlutterTts();
    await flutterTts.speak(
        'Formulário de anamnese aberto. Preencha os campos obrigatórios.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cadastro da Ficha do Paciente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Campos do formulário
                _buildFormFields(),
                const SizedBox(height: 20),
                // Botão de salvar
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        ageController.text.isEmpty ||
                        selectedPriority == null ||
                        selectedPainOrigin == null) {
                      _showErrorDialog('Todos os campos são obrigatórios.');
                      return;
                    }

                    await _patientService.savePatient(
                      docId: editingDocId,
                      name: nameController.text,
                      age: int.tryParse(ageController.text) ?? 0,
                      symptoms: symptomsController.text,
                      color: selectedPriority!,
                      painOrigin: selectedPainOrigin!,
                      painLevel: painLevel,
                      isCompleted: false,
                    );

                    Navigator.pop(
                        context); // Fecha o bottom sheet depois de salvar
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatientCard({
    required String docId,
    required String name,
    required List<String> symptoms,
    required String lastUpdate,
    required String color,
    required String painOrigin,
    required double painLevel,
  }) {
    final colorMap = {
      'Vermelho': Colors.red,
      'Laranja': Colors.orange,
      'Amarelo': Colors.yellow,
      'Verde': Colors.green,
      'Azul': Colors.blue,
    };

    final cardColor = colorMap[color] ?? Colors.grey;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      tooltip: 'Marcar como concluído',
                      onPressed: () async {
                        await _patientService.markAsCompleted(docId);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _openPatientForm(data: {
                          'docId': docId,
                          'name': name,
                          'symptoms': symptoms.join(','),
                          'lastUpdate': lastUpdate,
                          'color': color,
                          'painOrigin': painOrigin,
                          'painLevel': painLevel,
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmationDialog(docId),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...symptoms.map((s) => Text('• $s')).toList(),
            const SizedBox(height: 8),
            Text('Origem da Dor: $painOrigin'),
            const SizedBox(height: 8),
            Text('Nível da Dor: ${painLevel.toInt()} de 5'),
            const SizedBox(height: 8),
            Text('Última Atualização: $lastUpdate',
                style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Registro'),
          content:
              const Text('Você tem certeza que deseja excluir este registro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('patient_records')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
