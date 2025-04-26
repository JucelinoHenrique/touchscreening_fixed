import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../Auth/provider.dart';
import '../backend/database_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final DatabaseHelper dbHelper = DatabaseHelper();

  late Future<List<Map<String, dynamic>>> _patientRecordsFuture;
  late Future<Map<String, dynamic>?> _nurseDataFuture;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();

  String? selectedPriority;
  int? editingId; // Para identificar o registro sendo editado
  String? selectedPainOrigin; // Nova variável para armazenar a origem da dor
  double painLevel = 0; // Nova variável para o nível da dor

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _patientRecordsFuture = dbHelper.getPatientRecords();
      _nurseDataFuture = dbHelper.getLoggedUserData();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6C00),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('lib/assets/images/logo.png'),
            ),
            const SizedBox(width: 10),
            FutureBuilder<Map<String, dynamic>?>(
              future: _nurseDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Carregando...',
                    style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const Text(
                    'Olá, Enf.',
                    style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }
                final nurseData = snapshot.data!;
                return Text(
                  'Olá, Enf. ${nurseData['name']}',
                  style: const TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldkey.currentState!.openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Enfermeira'),
              accountEmail: Text('email@hospital.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/logo.png'),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFFF6C00),
              ),
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _patientRecordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar registros.'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum registro encontrado.'),
                    );
                  }

                  final records = snapshot.data!;
                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildPatientCard(
                        id: record['id'],
                        name: record['name'],
                        symptoms: record['symptoms'].split(','),
                        lastUpdate: record['lastUpdate'],
                        color: record['color'],
                        painOrigin: record['painOrigin'],
                        painLevel: record['painLevel'],
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
      editingId = data['id'];
    } else {
      nameController.clear();
      ageController.clear();
      symptomsController.clear();
      selectedPriority = null;
      selectedPainOrigin = null;
      painLevel = 0;
      editingId = null;
    }

    // TTS lê informações do formulário
    final FlutterTts flutterTts = FlutterTts();
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
                Semantics(
                  label: 'Título do formulário: Cadastro da Ficha do Paciente',
                  child: const Text(
                    'Cadastro da Ficha do Paciente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Nome do Paciente
                Semantics(
                  label: 'Campo para inserir o nome do paciente.',
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Paciente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo Idade
                Semantics(
                  label: 'Campo para inserir a idade do paciente.',
                  child: TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: 'Idade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),

                // Campo Prioridade (Manchester)
                Semantics(
                  label: 'Campo para selecionar a prioridade do paciente.',
                  child: DropdownButtonFormField<String>(
                    value: selectedPriority,
                    items: const [
                      DropdownMenuItem(
                        value: 'Vermelho',
                        child: Text('Vermelho - Emergência'),
                      ),
                      DropdownMenuItem(
                        value: 'Laranja',
                        child: Text('Laranja - Muito urgente'),
                      ),
                      DropdownMenuItem(
                        value: 'Amarelo',
                        child: Text('Amarelo - Urgente'),
                      ),
                      DropdownMenuItem(
                        value: 'Verde',
                        child: Text('Verde - Pouco urgente'),
                      ),
                      DropdownMenuItem(
                        value: 'Azul',
                        child: Text('Azul - Não urgente'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Prioridade (Manchester)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Origem da Dor
                const Text(
                  'Origem da Dor:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Selecione a origem da dor.',
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      _buildPainOriginButton(Icons.face, 'Cabeça', () {
                        setState(() {
                          selectedPainOrigin = 'Cabeça';
                        });
                        flutterTts.speak('Origem da dor selecionada: Cabeça');
                      }, selectedPainOrigin == 'Cabeça'),
                      _buildPainOriginButton(Icons.accessibility, 'Peito', () {
                        setState(() {
                          selectedPainOrigin = 'Peito';
                        });
                        flutterTts.speak('Origem da dor selecionada: Peito');
                      }, selectedPainOrigin == 'Peito'),
                      _buildPainOriginButton(Icons.accessibility_new, 'Braço',
                          () {
                        setState(() {
                          selectedPainOrigin = 'Braço';
                        });
                        flutterTts.speak('Origem da dor selecionada: Braço');
                      }, selectedPainOrigin == 'Braço'),
                      _buildPainOriginButton(Icons.directions_walk, 'Pernas',
                          () {
                        setState(() {
                          selectedPainOrigin = 'Pernas';
                        });
                        flutterTts.speak('Origem da dor selecionada: Pernas');
                      }, selectedPainOrigin == 'Pernas'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nível da Dor
                Semantics(
                  label: 'Selecione o nível da dor de 0 a 5.',
                  child: Slider(
                    value: painLevel,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: painLevel.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        painLevel = value;
                      });
                      flutterTts.speak('Nível da dor selecionado: $painLevel');
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Sintomas
                Semantics(
                  label: 'Campo para inserir os sintomas do paciente.',
                  child: TextField(
                    controller: symptomsController,
                    decoration: const InputDecoration(
                      labelText: 'Sintomas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Botão Salvar
                Semantics(
                  label: 'Botão para salvar os dados do formulário.',
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          ageController.text.isEmpty ||
                          selectedPriority == null ||
                          selectedPainOrigin == null) {
                        _showErrorDialog('Todos os campos são obrigatórios.');
                        return;
                      }

                      if (editingId == null) {
                        await dbHelper.insertPatientRecord(
                          nameController.text,
                          int.tryParse(ageController.text) ?? 0,
                          symptomsController.text,
                          DateTime.now().toString(),
                          selectedPriority!,
                          selectedPainOrigin!,
                          painLevel,
                        );
                        flutterTts.speak('Dados salvos com sucesso.');
                      } else {
                        await dbHelper.updatePatientRecord(
                          editingId!,
                          nameController.text,
                          int.tryParse(ageController.text) ?? 0,
                          symptomsController.text,
                          DateTime.now().toString(),
                          selectedPriority!,
                          selectedPainOrigin!,
                          painLevel,
                        );
                        flutterTts.speak('Dados atualizados com sucesso.');
                      }

                      Navigator.pop(context);
                      _loadData();
                    },
                    child: const Text('Salvar'),
                  ),
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
    required int id,
    required String name,
    required List<String> symptoms,
    required String lastUpdate,
    required String color,
    required String painOrigin, // Novo campo
    required double painLevel, // Novo campo
  }) {
    final colorMap = {
      'Vermelho': Colors.red,
      'Laranja': Colors.orange,
      'Amarelo': Colors.yellow,
      'Verde': Colors.green,
      'Azul': Colors.blue,
    };

    final textColorMap = {
      'Vermelho': Colors.black,
      'Laranja': Colors.black,
      'Amarelo': Colors.black,
      'Verde': Colors.white,
      'Azul': Colors.white,
    };

    final cardColor = colorMap[color] ?? Colors.grey;
    final textColor = textColorMap[color] ?? Colors.white;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: textColor,
                      onPressed: () {
                        _openPatientForm(data: {
                          'id': id,
                          'name': name,
                          'symptoms': symptoms.join(','),
                          'lastUpdate': lastUpdate,
                          'color': color,
                          'painOrigin': painOrigin, // Novo campo
                          'painLevel': painLevel, // Novo campo
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: textColor,
                      onPressed: () {
                        _showDeleteConfirmationDialog(id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var symptom in symptoms)
              Text(
                '• $symptom',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Origem da Dor: $painOrigin', // Exibe a origem da dor
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nível da Dor: ${painLevel.toInt()} de 5', // Exibe o nível da dor
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última Atualização: $lastUpdate',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Registro'),
          content:
              const Text('Você tem certeza que deseja excluir este registro?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await dbHelper.deletePatientRecord(id);
                _loadData();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
