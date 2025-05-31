import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController symptomsController =
      TextEditingController(); // Corresponde a Situação/Queixa
  final TextEditingController allergiesController = TextEditingController();
  // NOVO: Controller para Medicamentos em Uso Contínuo
  final TextEditingController medicamentosUsoContinuoController =
      TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController susCardController = TextEditingController();
  final TextEditingController cpfRgController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // Controllers para Sinais Vitais
  final TextEditingController pressaoArterialSistolicaController =
      TextEditingController();
  final TextEditingController pressaoArterialDiastolicaController =
      TextEditingController();
  final TextEditingController frequenciaCardiacaController =
      TextEditingController();
  final TextEditingController saturacaoO2Controller = TextEditingController();
  final TextEditingController temperaturaController = TextEditingController();
  final TextEditingController frequenciaRespiratoriaController =
      TextEditingController();
  final TextEditingController horaSinaisVitaisController =
      TextEditingController();

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
    // NOVO: Dispose do controller de Medicamentos
    medicamentosUsoContinuoController.dispose();
    weightController.dispose();
    susCardController.dispose();
    cpfRgController.dispose();
    motherNameController.dispose();
    addressController.dispose();
    birthDateController.dispose();

    pressaoArterialSistolicaController.dispose();
    pressaoArterialDiastolicaController.dispose();
    frequenciaCardiacaController.dispose();
    saturacaoO2Controller.dispose();
    temperaturaController.dispose();
    frequenciaRespiratoriaController.dispose();
    horaSinaisVitaisController.dispose();

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
                    .where('isCompleted', isEqualTo: false)
                    .orderBy('lastUpdate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print(
                        "Erro no StreamBuilder MainScreen: ${snapshot.error} \nStack trace: ${snapshot.stackTrace}"); // Log do erro
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
                        data: data,
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
            labelText: 'Data de Nascimento (DD/MM/AAAA)',
            border: OutlineInputBorder(),
          ),
          onTap: () async {
            FocusScope.of(context)
                .requestFocus(FocusNode()); // Para não abrir o teclado
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
            if (pickedDate != null) {
              birthDateController.text =
                  DateFormat('dd/MM/yyyy').format(pickedDate);
            }
          },
          readOnly: true,
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
            DropdownMenuItem(value: 'Outro', child: Text('Outro'))
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
            DropdownMenuItem(value: 'Solteiro(a)', child: Text('Solteiro(a)')),
            DropdownMenuItem(value: 'Casado(a)', child: Text('Casado(a)')),
            DropdownMenuItem(
                value: 'Divorciado(a)', child: Text('Divorciado(a)')),
            DropdownMenuItem(value: 'Viúvo(a)', child: Text('Viúvo(a)')),
            DropdownMenuItem(
                value: 'União Estável', child: Text('União Estável')),
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
            labelText: 'Endereço (Rua, Nº, Bairro, Cidade)',
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
        ExpansionTile(
          title: const Text('Sinais Vitais',
              style: TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: false,
          childrenPadding: const EdgeInsets.all(10.0).copyWith(top: 0),
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pressaoArterialSistolicaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PA Sistólica (mmHg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: pressaoArterialDiastolicaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PA Diastólica (mmHg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: frequenciaCardiacaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'FC (bpm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: saturacaoO2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SPO₂ (%)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: temperaturaController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Temp (°C)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: frequenciaRespiratoriaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'FR (rpm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: horaSinaisVitaisController,
              decoration: const InputDecoration(
                labelText: 'Hora da Aferição (HH:mm)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  // ignore: use_build_context_synchronously
                  horaSinaisVitaisController.text = pickedTime.format(context);
                }
              },
              readOnly: true,
            ),
          ],
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
        // NOVO: Campo para Medicamentos em Uso Contínuo
        TextField(
          controller: medicamentosUsoContinuoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Medicamentos em Uso Contínuo (Opcional)',
            border: OutlineInputBorder(),
            hintText: 'Ex: Losartana 50mg, AAS 100mg...',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: symptomsController, // Situação/Queixa
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Situação / Queixa',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _openPatientForm({Map<String, dynamic>? data}) async {
    if (data != null) {
      // Editando
      editingDocId = data['docId'] as String?;
      nameController.text = data['name'] ?? '';
      ageController.text = data['age']?.toString() ?? '';
      symptomsController.text = data['symptoms'] ?? '';
      selectedPriority = data['color'] ?? '';
      weightController.text = data['weight']?.toString() ?? '';
      allergiesController.text = data['allergies'] ?? '';
      // NOVO: Carregar medicamentos em uso
      medicamentosUsoContinuoController.text =
          data['medicamentosUsoContinuo'] ?? '';
      cpfRgController.text = data['cpfRg'] ?? '';
      susCardController.text = data['susCard'] ?? '';
      birthDateController.text = data['birthDate'] ?? '';
      selectedSex = data['sex'];
      selectedMaritalStatus = data['maritalStatus'];
      motherNameController.text = data['motherName'] ?? '';
      addressController.text = data['address'] ?? '';

      pressaoArterialSistolicaController.text =
          data['pressaoSistolica']?.toString() ?? '';
      pressaoArterialDiastolicaController.text =
          data['pressaoDiastolica']?.toString() ?? '';
      frequenciaCardiacaController.text =
          data['frequenciaCardiaca']?.toString() ?? '';
      saturacaoO2Controller.text = data['saturacaoO2']?.toString() ?? '';
      temperaturaController.text = data['temperatura']?.toString() ?? '';
      frequenciaRespiratoriaController.text =
          data['frequenciaRespiratoria']?.toString() ?? '';
      horaSinaisVitaisController.text = data['horaSinaisVitais'] ?? '';
      setState(() {});
    } else {
      editingDocId = null;
      nameController.clear();
      ageController.clear();
      symptomsController.clear();
      weightController.clear();
      allergiesController.clear();
      medicamentosUsoContinuoController.clear();
      cpfRgController.clear();
      susCardController.clear();
      birthDateController.clear();
      motherNameController.clear();
      addressController.clear();

      pressaoArterialSistolicaController.clear();
      pressaoArterialDiastolicaController.clear();
      frequenciaCardiacaController.clear();
      saturacaoO2Controller.clear();
      temperaturaController.clear();
      frequenciaRespiratoriaController.clear();
      horaSinaisVitaisController.clear();

      setState(() {
        selectedSex = null;
        selectedMaritalStatus = null;
        selectedPriority = null;
      });
    }

    final flutterTts = FlutterTts();
    await flutterTts.speak(
        'Formulário de paciente aberto. Preencha os campos necessários.');

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
                _buildFormFields(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Validação básica (Nome e Prioridade)
                    if (nameController.text.isEmpty ||
                        selectedPriority == null) {
                      _showErrorDialog(
                          'Nome do paciente e Prioridade são obrigatórios.');
                      return;
                    }

                    // --- VALIDAÇÃO DOS CAMPOS DOUBLE OBRIGATÓRIOS ---

                    // Peso (double obrigatório)
                    if (weightController.text.isEmpty) {
                      _showErrorDialog('O campo "Peso (kg)" é obrigatório.');
                      return;
                    }
                    final double? weightValueParsed = double.tryParse(
                        weightController.text.replaceAll(',', '.'));
                    if (weightValueParsed == null) {
                      _showErrorDialog(
                          'Valor inválido para "Peso (kg)". Use números (ex: 70.5).');
                      return;
                    }

                    // Temperatura (double obrigatório)
                    if (temperaturaController.text.isEmpty) {
                      _showErrorDialog('O campo "Temp (°C)" é obrigatório.');
                      return;
                    }
                    final double? temperaturaValueParsed = double.tryParse(
                        temperaturaController.text.replaceAll(',', '.'));
                    if (temperaturaValueParsed == null) {
                      _showErrorDialog(
                          'Valor inválido para "Temp (°C)". Use números (ex: 36.5).');
                      return;
                    }

                    // --- VALIDAÇÃO DOS CAMPOS INT OBRIGATÓRIOS (SINAIS VITAIS) ---
                    // Pressão Arterial Sistólica
                    if (pressaoArterialSistolicaController.text.isEmpty) {
                      _showErrorDialog('O campo "PA Sistólica" é obrigatório.');
                      return;
                    }
                    final int? paSistolicaValue =
                        int.tryParse(pressaoArterialSistolicaController.text);
                    if (paSistolicaValue == null) {
                      _showErrorDialog(
                          'Valor inválido para "PA Sistólica". Use números inteiros.');
                      return;
                    }

                    // Pressão Arterial Diastólica
                    if (pressaoArterialDiastolicaController.text.isEmpty) {
                      _showErrorDialog(
                          'O campo "PA Diastólica" é obrigatório.');
                      return;
                    }
                    final int? paDiastolicaValue =
                        int.tryParse(pressaoArterialDiastolicaController.text);
                    if (paDiastolicaValue == null) {
                      _showErrorDialog(
                          'Valor inválido para "PA Diastólica". Use números inteiros.');
                      return;
                    }

                    // Frequência Cardíaca
                    if (frequenciaCardiacaController.text.isEmpty) {
                      _showErrorDialog('O campo "FC (bpm)" é obrigatório.');
                      return;
                    }
                    final int? fcValue =
                        int.tryParse(frequenciaCardiacaController.text);
                    if (fcValue == null) {
                      _showErrorDialog(
                          'Valor inválido para "FC (bpm)". Use números inteiros.');
                      return;
                    }

                    // Saturação de O₂
                    if (saturacaoO2Controller.text.isEmpty) {
                      _showErrorDialog('O campo "SPO₂ (%)" é obrigatório.');
                      return;
                    }
                    final int? spo2Value =
                        int.tryParse(saturacaoO2Controller.text);
                    if (spo2Value == null) {
                      _showErrorDialog(
                          'Valor inválido para "SPO₂ (%)". Use números inteiros.');
                      return;
                    }

                    // Frequência Respiratória
                    if (frequenciaRespiratoriaController.text.isEmpty) {
                      _showErrorDialog('O campo "FR (rpm)" é obrigatório.');
                      return;
                    }
                    final int? frValue =
                        int.tryParse(frequenciaRespiratoriaController.text);
                    if (frValue == null) {
                      _showErrorDialog(
                          'Valor inválido para "FR (rpm)". Use números inteiros.');
                      return;
                    }

                    // Hora da Aferição dos Sinais Vitais (String obrigatória)
                    if (horaSinaisVitaisController.text.isEmpty) {
                      _showErrorDialog(
                          'O campo "Hora da Aferição" dos sinais vitais é obrigatório.');
                      return;
                    }

                    // --- FIM DA VALIDAÇÃO DOS SINAIS VITAIS ---

                    int? ageValue = int.tryParse(
                        ageController.text); // Idade continua opcional

                    await _patientService.savePatient(
                      docId: editingDocId,
                      name: nameController.text,
                      age: ageValue,
                      symptoms: symptomsController.text,
                      color: selectedPriority!,
                      isCompleted: false,
                      allergies: allergiesController.text.isNotEmpty
                          ? allergiesController.text
                          : null,
                      medicamentosUsoContinuo:
                          medicamentosUsoContinuoController.text.isNotEmpty
                              ? medicamentosUsoContinuoController.text
                              : null,
                      cpfRg: cpfRgController.text,
                      susCard: susCardController.text,
                      birthDate: birthDateController.text,
                      sex: selectedSex ?? '',
                      maritalStatus: selectedMaritalStatus ?? '',
                      motherName: motherNameController.text,
                      address: addressController.text,
                      weight: weightValueParsed,
                      pressaoSistolica: paSistolicaValue,
                      pressaoDiastolica: paDiastolicaValue,
                      frequenciaCardiaca: fcValue,
                      saturacaoO2: spo2Value,
                      temperatura: temperaturaValueParsed,
                      frequenciaRespiratoria: frValue,
                      horaSinaisVitais: horaSinaisVitaisController.text,
                    );

                    Navigator.pop(context);
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
          title: const Text('Erro de Validação'),
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
    required Map<String, dynamic> data,
  }) {
    final name = data['name'] as String? ?? 'Nome não informado';
    final age = data['age'] as int?;
    final symptomsRaw = data['symptoms'] as String?;
    final symptomsList = (symptomsRaw?.isNotEmpty ?? false)
        ? symptomsRaw!.split(',')
        : <String>[];
    final lastUpdate = data['lastUpdate'] as String? ?? 'Data não informada';
    final color = data['color'] as String? ?? 'Azul';
    final weight = data['weight']?.toString();
    final allergies = data['allergies'] as String?;
    // NOVO: Extrair medicamentos em uso
    final medicamentosUsoContinuo = data['medicamentosUsoContinuo'] as String?;
    final cpfRg = data['cpfRg'] as String? ?? '-';
    final susCard = data['susCard'] as String? ?? '-';

    final paSistolica = data['pressaoSistolica']?.toString();
    final paDiastolica = data['pressaoDiastolica']?.toString();
    final fc = data['frequenciaCardiaca']?.toString();
    final spo2 = data['saturacaoO2']?.toString();
    final temp = data['temperatura']?.toString();
    final fr = data['frequenciaRespiratoria']?.toString();
    final horaSinais = data['horaSinaisVitais'] as String?;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      if (age != null)
                        Text('$age anos',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 4),
                      if (cpfRg != '-')
                        Text('CPF/RG: $cpfRg',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                      if (susCard != '-')
                        Text('SUS: $susCard',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      tooltip: 'Marcar como concluído',
                      onPressed: () async {
                        await _patientService.markAsCompleted(docId);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () {
                        final editData = Map<String, dynamic>.from(data);
                        editData['docId'] = docId;
                        _openPatientForm(data: editData);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirmationDialog(docId),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            if (horaSinais != null && horaSinais.isNotEmpty)
              Text('Sinais Vitais ($horaSinais):',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                if (paSistolica != null && paDiastolica != null)
                  Chip(label: Text('PA: $paSistolica/$paDiastolica mmHg')),
                if (fc != null) Chip(label: Text('FC: $fc bpm')),
                if (spo2 != null) Chip(label: Text('SPO₂: $spo2 %')),
                if (temp != null) Chip(label: Text('Temp: $temp °C')),
                if (fr != null) Chip(label: Text('FR: $fr rpm')),
                if (weight != null && weight.isNotEmpty)
                  Chip(
                      label: Text(
                          'Peso: $weight kg')), // Adicionado cheque de isNotEmpty
              ],
            ),
            if (horaSinais != null && horaSinais.isNotEmpty)
              const SizedBox(height: 8),

            if (symptomsList.isNotEmpty) ...[
              const Text('Situação/Queixa:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ...symptomsList
                  .map((s) => Text('• $s',
                      style: const TextStyle(color: Colors.black87)))
                  .toList(),
              const SizedBox(height: 8),
            ],

            if (allergies != null && allergies.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: Colors.orangeAccent),
                  SizedBox(width: 6),
                  Text('Alergias:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(allergies, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 8),
            ],

            // NOVO: Exibir Medicamentos em Uso Contínuo no Card
            if (medicamentosUsoContinuo != null &&
                medicamentosUsoContinuo.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(Icons.medication_outlined,
                      size: 18, color: Colors.blueAccent),
                  SizedBox(width: 6),
                  Text('Medicamentos em Uso Contínuo:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(medicamentosUsoContinuo,
                  style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 8),
            ],

            Text('Prioridade: $color',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
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
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
