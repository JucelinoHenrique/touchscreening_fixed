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
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController susCardController = TextEditingController();
  final TextEditingController cpfRgController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  String? selectedSex;
  String? selectedMaritalStatus;
  String? selectedPriority;
  String? editingDocId;

  final PatientService _patientService = PatientService();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    symptomsController.dispose();
    allergiesController.dispose();
    weightController.dispose();
    susCardController.dispose();
    cpfRgController.dispose();
    motherNameController.dispose();
    addressController.dispose();
    birthDateController.dispose();

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
                        age: data['age'],
                        symptoms: (data['symptoms'] as String).split(','),
                        lastUpdate: data['lastUpdate'],
                        color: data['color'],
                        weight: data['weight'],
                        allergies: data['allergies'],
                        cpfRg: data['cpfRg'],
                        susCard: data['susCard'],
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
          controller: birthDateController,
          decoration: const InputDecoration(
            labelText: 'Data de Nascimento',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedSex,
          onChanged: (value) => setState(() => selectedSex = value),
          decoration: const InputDecoration(
            labelText: 'Sexo',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
            DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
            DropdownMenuItem(value: 'Outros', child: Text('Outros'))
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedMaritalStatus,
          onChanged: (value) => setState(() => selectedMaritalStatus = value),
          decoration: const InputDecoration(
            labelText: 'Estado Civil',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Solteiro', child: Text('Solteiro')),
            DropdownMenuItem(value: 'Casado', child: Text('Casado')),
            DropdownMenuItem(value: 'Divorciado', child: Text('Divorciado')),
            DropdownMenuItem(value: 'Viúvo', child: Text('Viúvo')),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: cpfRgController,
          decoration: const InputDecoration(
            labelText: 'RG ou CPF',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: susCardController,
          decoration: const InputDecoration(
            labelText: 'Cartão SUS',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: motherNameController,
          decoration: const InputDecoration(
            labelText: 'Nome da Mãe',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(
            labelText: 'Endereço',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
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
        TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
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
        TextField(
          controller: allergiesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Alergias (Opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
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

  void _openPatientForm({Map<String, dynamic>? data}) async {
    if (data != null) {
      nameController.text = data['name'];
      ageController.text = data['age'].toString();
      symptomsController.text = data['symptoms'];
      selectedPriority = data['color'];
      editingDocId = data['docId'];
      weightController.text = data['weight'] ?? '';
      allergiesController.text = data['allergies'] ?? '';
// 🔥 Corrigido: agora usamos docId
    } else {
      nameController.clear();
      ageController.clear();
      symptomsController.clear();
      weightController.clear();
      allergiesController.clear();
      selectedPriority = null;
      editingDocId = null;
      nameController.clear();
      ageController.clear();
      symptomsController.clear();
      weightController.clear();
      allergiesController.clear();
      birthDateController.clear();
      susCardController.clear();
      cpfRgController.clear();
      motherNameController.clear();
      addressController.clear();
      selectedSex = null;
      selectedMaritalStatus = null;
      selectedPriority = null;
      editingDocId = null;
      setState(() {
        selectedSex = null;
        selectedMaritalStatus = null;
        selectedPriority = null;
      });
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
                        weightController.text.isEmpty) {
                      _showErrorDialog('Todos os campos são obrigatórios.');
                      return;
                    }

                    await _patientService.savePatient(
                      docId: editingDocId,
                      name: nameController.text,
                      age: int.tryParse(ageController.text) ?? 0,
                      weight: weightController.text,
                      symptoms: symptomsController.text,
                      color: selectedPriority!,
                      isCompleted: false,
                      allergies: allergiesController.text,
                      cpfRg: cpfRgController.text,
                      susCard: susCardController.text,
                      birthDate: birthDateController.text,
                      sex: selectedSex ?? '',
                      maritalStatus: selectedMaritalStatus ?? '',
                      motherName: motherNameController.text,
                      address: addressController.text,
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
    required int age,
    String? weight,
    String? allergies,
    required cpfRg,
    required susCard,
  }) {
    final colorMap = {
      'Vermelho': Colors.red.shade100,
      'Laranja': Colors.orange.shade100,
      'Amarelo': Colors.yellow.shade100,
      'Verde': Colors.green.shade100,
      'Azul': Colors.blue.shade100,
    };

    final cardColor = colorMap[color] ?? Colors.grey.shade200;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nome e idade + ações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 4),
                    Text('$age anos',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text('CPF/RG: $cpfRg',
                        style: TextStyle(fontSize: 13, color: Colors.black)),
                    Text('Cartão SUS: $susCard',
                        style: TextStyle(fontSize: 13, color: Colors.black)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
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
                          'age': age,
                          'symptoms': symptoms.join(','),
                          'lastUpdate': lastUpdate,
                          'color': color,
                          'weight': weight ?? '',
                          'allergies': allergies ?? '',
                          'cpfRg': cpfRg,
                          'susCard': susCard,
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

            const Divider(thickness: 1.2),
            const SizedBox(height: 8),

            // Sintomas
            const Text('Sintomas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...symptoms.map((s) => Text('• $s')).toList(),

            if (weight != null && weight.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.monitor_weight_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Peso:', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('$weight kg'),
            ],

            if (allergies != null && allergies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Alergias:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(allergies!),
            ],

            const SizedBox(height: 8),
            Text('Última Atualização: $lastUpdate',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
