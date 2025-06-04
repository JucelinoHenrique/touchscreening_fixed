import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;

  final years = ['2023', '2024', '2025'];
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

  static const int itemsPerPage = 10;
  int currentPage = 0;

  Set<String> selectedDocIds = {};
  bool selectionMode = false;

  AsyncSnapshot<QuerySnapshot>? _lastSnapshot;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      selectedYear = null;
      selectedMonth = null;
      selectedDay = null;
      currentPage = 0;
      selectedDocIds.clear();
      selectionMode = false;
    });
  }

  void _nextPage(int maxPages) {
    if (currentPage < maxPages - 1) {
      setState(() {
        currentPage++;
        selectedDocIds.clear();
        selectionMode = false;
      });
    }
  }

  void _prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        selectedDocIds.clear();
        selectionMode = false;
      });
    }
  }

  void toggleSelectAll(List<DocumentSnapshot> records) {
    setState(() {
      if (selectedDocIds.length == records.length) {
        selectedDocIds.clear();
        selectionMode = false;
      } else {
        selectedDocIds = records.map((doc) => doc.id).toSet();
        selectionMode = true;
      }
    });
  }

  void toggleSelection(String docId) {
    setState(() {
      if (selectedDocIds.contains(docId)) {
        selectedDocIds.remove(docId);
        if (selectedDocIds.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedDocIds.add(docId);
        selectionMode = true;
      }
    });
  }

Future<void> generatePdfReport(List<DocumentSnapshot> records) async {
  final pdf = pw.Document();
  final baseFontSize = 14.0;
  final titleFontSize = 18.0;

  // Carrega a imagem do asset uma vez para reutilizar
  final Uint8List imageData = await rootBundle.load('lib/assets/images/LOGO5.png').then((bd) => bd.buffer.asUint8List());
  final pw.MemoryImage logo = pw.MemoryImage(imageData);

  for (final doc in records) {
    final data = doc.data() as Map<String, dynamic>;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FICHA DO PACIENTE',
                      style: pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('Nome: ${data['name'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize))),
                      pw.SizedBox(width: 12),
                      pw.Expanded(child: pw.Text('Idade: ${data['age'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize))),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('Sexo: ${data['sex'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize))),
                      pw.SizedBox(width: 12),
                      pw.Expanded(child: pw.Text('Estado Civil: ${data['maritalStatus'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize))),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text('Data de Nascimento: ${data['birthDate'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.Text('CPF/RG: ${data['cpfRg'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.Text('Cartão SUS: ${data['susCard'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.Text('Nome da Mãe: ${data['motherName'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.Text('Endereço: ${data['address'] ?? ''}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.SizedBox(height: 12),
                  pw.Divider(),
                  pw.SizedBox(height: 12),
                  pw.Text('Sintomas:', style: pw.TextStyle(fontSize: baseFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['symptoms'] ?? 'Não informado'}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.SizedBox(height: 6),
                  pw.Text('Alergias:', style: pw.TextStyle(fontSize: baseFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['allergies'] ?? 'Não informado'}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.SizedBox(height: 6),
                  pw.Text('Medicamentos em Uso Contínuo:', style: pw.TextStyle(fontSize: baseFontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['medicamentosUsoContinuo'] ?? 'Não informado'}', style: pw.TextStyle(fontSize: baseFontSize)),
                  pw.SizedBox(height: 12),
                  pw.Divider(),
                  pw.SizedBox(height: 12),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Sinais Vitais', style: pw.TextStyle(fontSize: baseFontSize + 2, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Peso: ${data['weight']?.toString() ?? '-'} kg', style: pw.TextStyle(fontSize: baseFontSize)),
                            pw.Text('PA Sistólica: ${data['pressaoSistolica']?.toString() ?? '-'} mmHg', style: pw.TextStyle(fontSize: baseFontSize)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('PA Diastólica: ${data['pressaoDiastolica']?.toString() ?? '-'} mmHg', style: pw.TextStyle(fontSize: baseFontSize)),
                            pw.Text('Frequência Cardíaca: ${data['frequenciaCardiaca']?.toString() ?? '-'} bpm', style: pw.TextStyle(fontSize: baseFontSize)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Saturação O₂: ${data['saturacaoO2']?.toString() ?? '-'} %', style: pw.TextStyle(fontSize: baseFontSize)),
                            pw.Text('Temperatura: ${data['temperatura']?.toString() ?? '-'} °C', style: pw.TextStyle(fontSize: baseFontSize)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Frequência Respiratória: ${data['frequenciaRespiratoria']?.toString() ?? '-'} rpm', style: pw.TextStyle(fontSize: baseFontSize)),
                        pw.Text('Hora da Aferição: ${data['horaSinaisVitais'] ?? '-'}', style: pw.TextStyle(fontSize: baseFontSize)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Prioridade: ${data['color'] ?? '-'}', style: pw.TextStyle(fontSize: baseFontSize, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Última Atualização: ${data['lastUpdate'] ?? '-'}', style: pw.TextStyle(fontSize: baseFontSize)),
                    ],
                  ),
                ],
              ),

              // Imagem no canto superior direito com ajuste para não cobrir a linha
              pw.Positioned(
                top: -10,
                right: 0,
                child: pw.Image(logo, width: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos Concluídos'),
        backgroundColor: const Color(0xFFFF6C00),
        actions: [
          Builder(
            builder: (context) {
              if (_lastSnapshot == null || !_lastSnapshot!.hasData) {
                return Container();
              }
              final allRecords = _lastSnapshot!.data!.docs;

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

              final isAllSelected = filteredRecords.isNotEmpty && selectedDocIds.length == filteredRecords.length;

              return IconButton(
                icon: Icon(isAllSelected ? Icons.check_box : Icons.check_box_outline_blank),
                tooltip: isAllSelected ? 'Desmarcar todos' : 'Selecionar todos',
                onPressed: () => toggleSelectAll(filteredRecords),
              );
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 90,
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
                        selectedDocIds.clear();
                        selectionMode = false;
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
                        selectedDocIds.clear();
                        selectionMode = false;
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
                        selectedDocIds.clear();
                        selectionMode = false;
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
                  _lastSnapshot = snapshot;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar registros.'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum atendimento concluído.'));
                  }
                  final allRecords = snapshot.data!.docs;
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
                  final maxPage = (filteredRecords.length / itemsPerPage).ceil();
                  final pagedRecords = filteredRecords.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: pagedRecords.length,
                          itemBuilder: (context, index) {
                            final doc = pagedRecords[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final isSelected = selectedDocIds.contains(doc.id);

                            return GestureDetector(
                              key: ValueKey(doc.id),
                              onLongPress: () {
                                setState(() {
                                  selectionMode = true;
                                  selectedDocIds.add(doc.id);
                                });
                              },
                              onTap: () {
                                if (selectionMode) {
                                  toggleSelection(doc.id);
                                }
                              },
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color.fromARGB(255, 126, 206, 130).withOpacity(0.7)
                                          : const Color.fromARGB(255, 154, 245, 154),
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
                                  ),
                                  if (selectionMode)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 14,
                                        child: Icon(
                                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: isSelected ? Colors.orange : Colors.grey,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
      floatingActionButton: selectionMode && selectedDocIds.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                if (_lastSnapshot == null || !_lastSnapshot!.hasData) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nenhum dado disponível para gerar PDF')),
                  );
                  return;
                }

                final allRecords = _lastSnapshot!.data!.docs;

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

                final docsToExport = filteredRecords.where((doc) => selectedDocIds.contains(doc.id)).toList();

                if (docsToExport.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nenhum registro selecionado para exportar')),
                  );
                  return;
                }

                await generatePdfReport(docsToExport);

                setState(() {
                  selectionMode = false;
                  selectedDocIds.clear();
                });
              },
              tooltip: 'Gerar PDF dos selecionados',
              backgroundColor: const Color(0xFFFF6C00),
              child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 32, // aumenta o tamanho do ícone (padrão é 24)
            ),
            )
          : null,
    );
  }
}
