import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Importe o pacote de fontes
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
  final days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

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
      _scrollController.jumpTo(0);
    }
  }

  void _prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        selectedDocIds.clear();
        selectionMode = false;
      });
      _scrollController.jumpTo(0);
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

    // As fontes para o PDF precisam ser carregadas separadamente.
    // Primeiro, baixe os arquivos .ttf de 'Roboto-Regular' e 'Roboto-Bold' do Google Fonts
    // e adicione-os a uma pasta 'assets/fonts/' no seu projeto.
    // Depois, declare-os no pubspec.yaml.
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    final Uint8List imageData = await rootBundle
        .load('lib/assets/images/LOGO1.png')
        .then((bd) => bd.buffer.asUint8List());
    final pw.MemoryImage logo = pw.MemoryImage(imageData);

    for (final doc in records) {
      final data = doc.data() as Map<String, dynamic>;

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('FICHA DO PACIENTE',
                            style: pw.TextStyle(font: boldTtf, fontSize: 18)),
                        pw.Text('UPA 24h Tucuruí',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ],
                    ),
                    pw.Image(logo, width: 60, height: 60),
                  ],
                ),
                pw.Divider(thickness: 2, height: 20),

                // Função auxiliar para criar linhas de dados no PDF
                _buildPdfInfoRow('Nome:', data['name'] ?? 'Não informado', ttf),
                _buildPdfInfoRow(
                    'Idade:', (data['age'] ?? '-').toString(), ttf),
                _buildPdfInfoRow('Sexo:', data['sex'] ?? 'Não informado', ttf),
                _buildPdfInfoRow(
                    'Data Nasc:', data['birthDate'] ?? 'Não informada', ttf),
                _buildPdfInfoRow(
                    'CPF/RG:', data['cpfRg'] ?? 'Não informado', ttf),
                _buildPdfInfoRow(
                    'Cartão SUS:', data['susCard'] ?? 'Não informado', ttf),
                pw.SizedBox(height: 12),

                pw.Text('Sintomas / Queixa Principal:',
                    style: pw.TextStyle(font: boldTtf, fontSize: 12)),
                pw.Text(data['symptoms'] ?? 'Não informado',
                    style: pw.TextStyle(font: ttf, fontSize: 11)),
                pw.SizedBox(height: 8),

                pw.Text('Alergias:',
                    style: pw.TextStyle(font: boldTtf, fontSize: 12)),
                pw.Text(data['allergies'] ?? 'Nenhuma informada',
                    style: pw.TextStyle(font: ttf, fontSize: 11)),
                pw.SizedBox(height: 8),

                pw.Text('Medicamentos em Uso:',
                    style: pw.TextStyle(font: boldTtf, fontSize: 12)),
                pw.Text(data['medicamentosUsoContinuo'] ?? 'Nenhum informado',
                    style: pw.TextStyle(font: ttf, fontSize: 11)),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 12),

                pw.Text('Sinais Vitais (${data['horaSinaisVitais'] ?? 'N/A'}):',
                    style: pw.TextStyle(font: boldTtf, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(font: boldTtf, fontSize: 10),
                  cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  data: <List<String>>[
                    <String>['Peso', 'PA (S/D)', 'FC', 'SPO₂', 'Temp', 'FR'],
                    <String>[
                      '${data['weight'] ?? '-'} kg',
                      '${data['pressaoSistolica'] ?? '-'}/${data['pressaoDiastolica'] ?? '-'}',
                      '${data['frequenciaCardiaca'] ?? '-'} bpm',
                      '${data['saturacaoO2'] ?? '-'} %',
                      '${data['temperatura'] ?? '-'} °C',
                      '${data['frequenciaRespiratoria'] ?? '-'} rpm',
                    ],
                  ],
                ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Atendimento finalizado em: ${data['lastUpdate'] ?? 'Data não informada'}',
                    style: pw.TextStyle(
                        font: ttf, fontSize: 9, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildPdfInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font, fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(width: 8),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atendimentos Concluídos',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6C00),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) {
              if (_lastSnapshot == null || !_lastSnapshot!.hasData) {
                return Container();
              }
              final recordsOnPage = (_lastSnapshot!.data!.docs
                      .skip(currentPage * itemsPerPage)
                      .take(itemsPerPage))
                  .toList();
              final isAllSelected = recordsOnPage.isNotEmpty &&
                  selectedDocIds.length == recordsOnPage.length;

              return IconButton(
                icon: Icon(isAllSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                tooltip: isAllSelected ? 'Desmarcar todos' : 'Selecionar todos',
                onPressed: () => toggleSelectAll(recordsOnPage),
              );
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilterDropdown(
                  hint: 'Ano',
                  value: selectedYear,
                  items: years,
                  onChanged: (value) => setState(() {
                    selectedYear = value;
                    currentPage = 0;
                    selectedDocIds.clear();
                  }),
                ),
                _buildFilterDropdown(
                  hint: 'Mês',
                  value: selectedMonth,
                  items: months.map((m) => m.split(' - ')[0]).toList(),
                  displayItems: months,
                  onChanged: (value) => setState(() {
                    selectedMonth = value;
                    currentPage = 0;
                    selectedDocIds.clear();
                  }),
                ),
                _buildFilterDropdown(
                  hint: 'Dia',
                  value: selectedDay,
                  items: days,
                  onChanged: (value) => setState(() {
                    selectedDay = value;
                    currentPage = 0;
                    selectedDocIds.clear();
                  }),
                ),
                Tooltip(
                  message: 'Limpar filtros',
                  child: IconButton(
                    icon: const Icon(Icons.cleaning_services_rounded,
                        color: Colors.grey),
                    onPressed: _clearFilters,
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patient_records')
                  .where('isCompleted', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                _lastSnapshot = snapshot;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhum atendimento concluído.'));
                }

                final allRecords = snapshot.data!.docs;
                final filteredRecords = allRecords.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final lastUpdateStr = data['lastUpdate']?.toString() ?? '';
                  if (lastUpdateStr.isEmpty) return false;

                  DateTime? lastUpdateDate;
                  try {
                    lastUpdateDate =
                        DateFormat('dd/MM/yyyy HH:mm').parse(lastUpdateStr);
                  } catch (_) {
                    return false;
                  }

                  if (selectedYear != null &&
                      lastUpdateDate.year.toString() != selectedYear)
                    return false;
                  if (selectedMonth != null &&
                      lastUpdateDate.month.toString().padLeft(2, '0') !=
                          selectedMonth) return false;
                  if (selectedDay != null &&
                      lastUpdateDate.day.toString().padLeft(2, '0') !=
                          selectedDay) return false;

                  return true;
                }).toList();

                // Ordenação após o filtro
                filteredRecords.sort((a, b) {
                  final dateA =
                      DateFormat('dd/MM/yyyy HH:mm').parse(a['lastUpdate']);
                  final dateB =
                      DateFormat('dd/MM/yyyy HH:mm').parse(b['lastUpdate']);
                  return dateB.compareTo(dateA);
                });

                if (filteredRecords.isEmpty) {
                  return const Center(
                      child: Text(
                          'Nenhum atendimento encontrado para os filtros selecionados.'));
                }

                final maxPage = (filteredRecords.length / itemsPerPage).ceil();
                final pagedRecords = filteredRecords
                    .skip(currentPage * itemsPerPage)
                    .take(itemsPerPage)
                    .toList();

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
                            onLongPress: () => toggleSelection(doc.id),
                            onTap: () {
                              if (selectionMode) {
                                toggleSelection(doc.id);
                              }
                            },
                            child: Card(
                              color: isSelected
                                  ? Colors.orange.shade100
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(data['name'] ?? 'Sem nome',
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                subtitle: Text(
                                    'Finalizado em: ${data['lastUpdate'] ?? '-'}',
                                    style: GoogleFonts.roboto(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                                trailing: selectionMode
                                    ? Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: Colors.orange,
                                      )
                                    : null,
                              ),
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
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                        Text('Página ${currentPage + 1} de $maxPage',
                            style: GoogleFonts.roboto(
                                color: Colors.grey.shade700)),
                        IconButton(
                          onPressed: currentPage < maxPage - 1
                              ? () => _nextPage(maxPage)
                              : null,
                          icon: const Icon(Icons.arrow_forward_ios),
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
      floatingActionButton: selectionMode && selectedDocIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final recordsToExport = _lastSnapshot!.data!.docs
                    .where((doc) => selectedDocIds.contains(doc.id))
                    .toList();
                await generatePdfReport(recordsToExport);
              },
              label: Text('Gerar PDF',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              backgroundColor: const Color(0xFFFF6C00),
            )
          : null,
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    String? value,
    required List<String> items,
    List<String>? displayItems,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 110,
      child: DropdownButtonFormField<String?>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          border: const OutlineInputBorder(),
        ),
        isExpanded: true,
        hint: Text(hint, style: GoogleFonts.roboto(fontSize: 12)),
        onChanged: onChanged,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text('Todos', style: GoogleFonts.roboto(fontSize: 12)),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final itemValue = entry.value;
            final displayValue =
                (displayItems != null && displayItems.length > index)
                    ? displayItems[index]
                    : itemValue;
            return DropdownMenuItem<String?>(
              value: itemValue,
              child:
                  Text(displayValue, style: GoogleFonts.roboto(fontSize: 12)),
            );
          }),
        ],
      ),
    );
  }
}
