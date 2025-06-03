import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;

  final years = ['2023', '2024', '2025']; // Atualize conforme necessidade
  final months = [
    '01 - Janeiro',
    '02 - Fevereiro',
    '03 - Março',
    '04 - Abril',
    '05 - Maio',
    '06 - Junho',
    '07 - Julho',
    '08 - Agosto',
    '09 - Setembro',
    '10 - Outubro',
    '11 - Novembro',
    '12 - Dezembro'
  ];
  final days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  // Paginação
  static const int itemsPerPage = 10;
  int currentPage = 0;

  void _clearFilters() {
    setState(() {
      selectedYear = null;
      selectedMonth = null;
      selectedDay = null;
      currentPage = 0;
    });
  }

  void _nextPage(int maxPages) {
    if (currentPage < maxPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos Concluídos'),
        backgroundColor: const Color(0xFFFF6C00),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros + botão limpar (ícone) em Wrap
            Wrap(
  spacing: 8,
  runSpacing: 8,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    SizedBox(
      width: 90, // menor que antes
      child: DropdownButtonFormField<String?>(
        value: selectedYear,
        decoration: InputDecoration(
          labelText: 'Ano',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(fontSize: 12),
        ),
        isExpanded: true,
        hint: const Text('Ano', style: TextStyle(fontSize: 12)),
        onChanged: (value) {
          setState(() {
            selectedYear = value;
            currentPage = 0;
          });
        },
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todos', style: TextStyle(fontSize: 12)),
          ),
          ...years.map((year) => DropdownMenuItem<String?>(
                value: year,
                child: Text(year, style: const TextStyle(fontSize: 12)),
              )),
        ],
      ),
    ),
    SizedBox(
      width: 110,
      child: DropdownButtonFormField<String?>(
        value: selectedMonth,
        decoration: InputDecoration(
          labelText: 'Mês',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(fontSize: 12),
        ),
        isExpanded: true,
        hint: const Text('Mês', style: TextStyle(fontSize: 12)),
        onChanged: (value) {
          setState(() {
            selectedMonth = value;
            currentPage = 0;
          });
        },
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todos', style: TextStyle(fontSize: 12)),
          ),
          ...months.map((month) => DropdownMenuItem<String?>(
                value: month.split(' - ')[0],
                child: Text(month, style: const TextStyle(fontSize: 12)),
              )),
        ],
      ),
    ),
    SizedBox(
      width: 80,
      child: DropdownButtonFormField<String?>(
        value: selectedDay,
        decoration: InputDecoration(
          labelText: 'Dia',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(fontSize: 12),
        ),
        isExpanded: true,
        hint: const Text('Dia', style: TextStyle(fontSize: 12)),
        onChanged: (value) {
          setState(() {
            selectedDay = value;
            currentPage = 0;
          });
        },
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todos', style: TextStyle(fontSize: 12)),
          ),
          ...days.map((day) => DropdownMenuItem<String?>(
                value: day,
                child: Text(day, style: const TextStyle(fontSize: 12)),
              )),
        ],
      ),
    ),
    Tooltip(
      message: 'Limpar filtros',
      child: IconButton(
        icon: const Icon(Icons.cleaning_services),
        onPressed: _clearFilters,
        splashRadius: 20,
      ),
    ),
  ],
),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patient_records')
                    .where('isCompleted', isEqualTo: true)
                    .orderBy('lastUpdate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar registros.'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum atendimento concluído.'));
                  }

                  final allRecords = snapshot.data!.docs;

                  // Ordenação local por data (mais recente primeiro)
                  allRecords.sort((a, b) {
                    DateTime dateA;
                    DateTime dateB;

                    try {
                      dateA = DateFormat('dd/MM/yyyy').parse(a['lastUpdate']?.toString() ?? '');
                    } catch (_) {
                      dateA = DateTime(1900);
                    }
                    try {
                      dateB = DateFormat('dd/MM/yyyy').parse(b['lastUpdate']?.toString() ?? '');
                    } catch (_) {
                      dateB = DateTime(1900);
                    }

                    return dateB.compareTo(dateA);
                  });

                  // Filtro local
                  final filteredRecords = allRecords.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final lastUpdateStr = data['lastUpdate']?.toString() ?? '';

                    DateTime? lastUpdateDate;
                    try {
                      lastUpdateDate = DateFormat('dd/MM/yyyy').parse(lastUpdateStr);
                    } catch (_) {
                      return true;
                    }

                    if (selectedYear != null && lastUpdateDate.year.toString() != selectedYear) {
                      return false;
                    }
                    if (selectedMonth != null && lastUpdateDate.month.toString().padLeft(2, '0') != selectedMonth) {
                      return false;
                    }
                    if (selectedDay != null && lastUpdateDate.day.toString().padLeft(2, '0') != selectedDay) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (filteredRecords.isEmpty) {
                    return const Center(child: Text('Nenhum atendimento encontrado'));
                  }

                  // Paginação local
                  final maxPage = (filteredRecords.length / itemsPerPage).ceil();
                  final pagedRecords = filteredRecords.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: pagedRecords.length,
                          itemBuilder: (context, index) {
                            final data = pagedRecords[index].data() as Map<String, dynamic>;

                            return Card(
                              color: const Color.fromARGB(255, 255, 192, 141),
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
                                    Text('Idade: ${data['age']}'),
                                    Text('CPF/RG: ${data['cpfRg']}'),
                                    Text('Cartão SUS: ${data['susCard']}'),
                                    Text('Prioridade: ${data['color']}'),
                                    Text('Última atualização: ${data['lastUpdate']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Paginação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: currentPage > 0 ? _prevPage : null,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Text('Página ${currentPage + 1} de $maxPage'),
                          IconButton(
                            onPressed: currentPage < maxPage - 1 ? () => _nextPage(maxPage) : null,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
