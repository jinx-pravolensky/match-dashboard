import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/admin_screens/folders/folder_sesi_screen.dart';
import 'package:ns3_project/screens/admin_screens/folders/tambah_peserta_screen.dart';
import 'package:ns3_project/screens/admin_screens/folders/daftar_juri_ranting_screen.dart';

class PesertaRantingScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;

  const PesertaRantingScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
  });

  @override
  State<PesertaRantingScreen> createState() => _PesertaRantingScreenState();
}

class _PesertaRantingScreenState extends State<PesertaRantingScreen> {
  List<dynamic> listPeserta = [];
  List<dynamic> displayPeserta = [];
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String currentSort = "Data Terlama";

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    listPeserta = widget.rantingData['peserta'] ?? [];
    _applySearchAndSort();
    _fetchFreshData();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _silentFetchData();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applySearchAndSort() {
    List<dynamic> temp = List.from(listPeserta);
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      temp = temp.where((p) {
        final nama = (p['nama'] ?? '').toString().toLowerCase();
        final bib = (p['bib'] ?? '').toString().toLowerCase();
        return nama.contains(query) || bib.contains(query);
      }).toList();
    }
    if (currentSort == 'Data Terbaru') {
      temp = temp.reversed.toList();
    } else if (currentSort == 'Nama A-Z') {
      temp.sort((a, b) {
        final nameA = (a['nama'] ?? '').toString().toLowerCase();
        final nameB = (b['nama'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });
    }
    setState(() {
      displayPeserta = temp;
    });
  }

  PopupMenuItem<String> _buildPopupItem(String title) {
    final isSelected = currentSort == title;
    return PopupMenuItem<String>(
      value: title,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchFreshData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/match/${widget.matchId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rantings = data['ranting'] as List;

        final currentRanting = rantings.firstWhere(
          (r) => r['_id'] == widget.rantingData['_id'],
          orElse: () => null,
        );
        if (currentRanting != null && mounted) {
          setState(() {
            listPeserta = currentRanting['peserta'] ?? [];
            _applySearchAndSort();
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _silentFetchData() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/match/${widget.matchId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rantings = data['ranting'] as List;

        final currentRanting = rantings.firstWhere(
          (r) => r['_id'] == widget.rantingData['_id'],
          orElse: () => null,
        );
        if (currentRanting != null && mounted) {
          setState(() {
            listPeserta = currentRanting['peserta'] ?? [];
            _applySearchAndSort();
          });
        }
      }
    } catch (e) {
      // Abaikan error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.rantingData['subKategori'] ?? 'Ranting',
          style: text20PrimaryBold,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Daftar Peserta", style: text18PrimaryBold),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: primaryColor, width: 2),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                                _applySearchAndSort();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Cari Nama atau BIB...',
                              hintStyle: text14greyBold,
                              prefixIcon: Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.library_books_outlined,
                            color: primaryColor,
                            size: 35,
                          ),
                          color: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          offset: const Offset(0, 50),
                          elevation: 5,
                          onSelected: (String value) {
                            setState(() {
                              currentSort = value;
                              _applySearchAndSort();
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              _buildPopupItem('Data Terlama'),
                              _buildPopupItem('Data Terbaru'),
                              _buildPopupItem('Nama A-Z'),
                            ];
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarJuriRantingScreen(
                            rantingData: widget.rantingData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.assignment_outlined, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lihat Daftar Juri",
                              style: text14WhiteBold,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade400,
              margin: const EdgeInsets.symmetric(horizontal: 30),
            ),
            Expanded(
              child: isLoading && displayPeserta.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      color: primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: _fetchFreshData,
                      child: displayPeserta.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(15),
                              itemCount: displayPeserta.length,
                              itemBuilder: (context, index) {
                                final peserta = displayPeserta[index];
                                int totalScore = 0;
                                if (peserta['sesiTembakan'] != null) {
                                  for (var sesi in peserta['sesiTembakan']) {
                                    if (sesi['score'] != null &&
                                        sesi['score'] != '-') {
                                      totalScore +=
                                          int.tryParse(
                                            sesi['score'].toString(),
                                          ) ??
                                          0;
                                    }
                                  }
                                }
                                String displayScore = totalScore.toString();
                                final isScored = totalScore > 0;
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminFolderSesiScreen(
                                              matchId: widget.matchId,
                                              rantingData: widget.rantingData,
                                              pesertaData: peserta,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isScored
                                          ? Colors.teal.shade50
                                          : backgroundColor,
                                      border: Border.all(
                                        color: isScored
                                            ? Colors.teal
                                            : primaryColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                peserta['bib'] ?? '-',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                  color: isScored
                                                      ? Colors.teal
                                                      : primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.article_rounded,
                                                    size: 20,
                                                    color: isScored
                                                        ? Colors.teal
                                                        : darkColor,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    peserta['nama'] ?? '-',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: isScored
                                                          ? Colors.teal
                                                          : darkColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Score: ",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: secondaryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    displayScore,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: secondaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                          color: darkColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahPesertaScreen(
                matchId: widget.matchId,
                rantingData: widget.rantingData,
              ),
            ),
          );

          if (result == true) {
            _fetchFreshData();
          }
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text(
          "Belum ada peserta atau pencarian tidak ditemukan.\nSilahkan periksa kembali.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
