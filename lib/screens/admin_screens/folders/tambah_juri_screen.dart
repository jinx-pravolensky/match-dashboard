import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class TambahJuriScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final String kaliberAmunisi;
  final int seriesPerSession;
  final int shotsPerSeries;
  final String kategoriGender;
  final bool skorDesimal;

  const TambahJuriScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.kaliberAmunisi,
    required this.seriesPerSession,
    required this.shotsPerSeries,
    required this.kategoriGender,
    required this.skorDesimal,
  });

  @override
  State<TambahJuriScreen> createState() => _TambahJuriScreenState();
}

class _TambahJuriScreenState extends State<TambahJuriScreen> {
  TextEditingController idController = TextEditingController();

  bool isSearching = false;
  Map<String, dynamic>? pendingJury;
  List<Map<String, dynamic>> selectedJuriList = [];
  
  Future<void> _searchJuri() async {
    String idSearch = idController.text.trim();
    if (idSearch.isEmpty) return;
    setState(() => isSearching = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/search-juri/$idSearch');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool alreadySelected = selectedJuriList.any(
          (juri) => juri['customId'] == data['customId'],
        );
        if (!alreadySelected) {
          setState(() {
            pendingJury = data;
          });
        }
      }
    } catch (e) {
      null;
    }
    setState(() => isSearching = false);
  }

  Future<void> _simpanDataRanting() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      List<String> idJuriSaja = selectedJuriList
          .map((j) => j['_id'].toString())
          .toList();

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/match/${widget.matchId}/add-ranting',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "kategoriUtama": widget.rantingData['kategori_utama'],
          "subKategori": widget.rantingData['sub_kategori'],
          "amunisi": widget.kaliberAmunisi,
          "seriesPerSession": widget.seriesPerSession,
          "shotsPerSeries": widget.shotsPerSeries,
          "kategoriPeserta": widget.kategoriGender,
          "skorDesimal": widget.skorDesimal,
          "juriIds": idJuriSaja,
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'BERHASIL',
          desc: 'Ranting baru beserta Juri berhasil disimpan!',
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkColor: primaryColor,
          btnOkOnPress: () {
            Navigator.of(context)
              ..pop()
              ..pop()
              ..pop()
              ..pop();
          },
        ).show();
      } else {
        print("Gagal: ${response.body}");
      }
    } catch (e) {
      Navigator.pop(context);
      print("Koneksi Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isInputDisabled = pendingJury != null || isSearching;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tambah Juri", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ID Juri",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: idController,
                enabled: !isInputDisabled,
                keyboardType: TextInputType.number,
                style: text14PrimaryBold,
                decoration: InputDecoration(
                  hintText: "Cari ID Juri...",
                  prefixIcon: const Icon(
                    Icons.document_scanner_rounded,
                    color: goldColor,
                  ),
                  filled: isInputDisabled,
                  fillColor: isInputDisabled
                      ? Colors.grey.shade100
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: goldColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInputDisabled
                        ? Colors.grey
                        : primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isInputDisabled ? null : _searchJuri,
                  child: isSearching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Cari ID", style: text16WhiteBold),
                ),
              ),
              const SizedBox(height: 25),
              if (pendingJury != null || selectedJuriList.isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Daftar Juri Terpilih",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                if (pendingJury != null)
                                  _buildJuriCard(
                                    juri: pendingJury!,
                                    isPending: true,
                                    onDelete: () {
                                      setState(() {
                                        pendingJury = null;
                                        idController.clear();
                                      });
                                    },
                                    onAdd: () {
                                      setState(() {
                                        selectedJuriList.add(pendingJury!);
                                        pendingJury = null;
                                        idController.clear();
                                      });
                                    },
                                  ),
                                ...selectedJuriList
                                    .map(
                                      (juri) => _buildJuriCard(
                                        juri: juri,
                                        isPending: false,
                                        onDelete: () {
                                          setState(() {
                                            selectedJuriList.remove(juri);
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                        if (selectedJuriList.isNotEmpty && pendingJury == null)
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _simpanDataRanting();
                                print(
                                  "Simpan Ranting dengan ${selectedJuriList.length} Juri!",
                                );
                              },
                              child: const Text(
                                "Simpan Semua Data",
                                style: text16WhiteBold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuriCard({
    required Map<String, dynamic> juri,
    required bool isPending,
    required VoidCallback onDelete,
    VoidCallback? onAdd,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juri['name'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  juri['customId'] ?? '-',
                  style: const TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isPending)
            InkWell(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
