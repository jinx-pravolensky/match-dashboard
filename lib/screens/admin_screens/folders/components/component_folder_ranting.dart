import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/data/data_ranting.dart';
import 'package:ns3_project/screens/admin_screens/folders/pilih_ranting_screen.dart';
import 'package:ns3_project/screens/admin_screens/folders/peserta_ranting_screen.dart';

class ComponentFolderRanting extends StatefulWidget {
  final String matchId;
  const ComponentFolderRanting({super.key, required this.matchId});

  @override
  State<ComponentFolderRanting> createState() => _ComponentFolderRantingState();
}

class _ComponentFolderRantingState extends State<ComponentFolderRanting> {
  List<dynamic> listRanting = [];
  List<dynamic> filteredRanting = [];
  bool isLoading = true;
  Timer? _autoRefreshTimer;
  final TextEditingController searchController = TextEditingController();
  String currentSort = "Data Terlama";

  @override
  void initState() {
    super.initState();
    fetchMatchData();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _silentFetchData();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _applySearchAndSort() {
    List<dynamic> temp = List.from(listRanting);
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      temp = temp.where((ranting) {
        final subKategori = (ranting['subKategori'] ?? '')
            .toString()
            .toLowerCase();
        final kategoriUtama = (ranting['kategoriUtama'] ?? '')
            .toString()
            .toLowerCase();
        return subKategori.contains(query) || kategoriUtama.contains(query);
      }).toList();
    }
    if (currentSort == 'Data Terbaru') {
      temp = temp.reversed.toList();
    } else if (currentSort == 'Nama A-Z') {
      temp.sort((a, b) {
        final titleA = (a['subKategori'] ?? '').toString().toLowerCase();
        final titleB = (b['subKategori'] ?? '').toString().toLowerCase();
        return titleA.compareTo(titleB);
      });
    }

    setState(() {
      filteredRanting = temp;
    });
  }

  // Widget Item untuk Dropdown Pop-Up
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
  // -----------------------------

  Future<void> fetchMatchData() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/match/${widget.matchId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listRanting = data['ranting'] ?? [];
            _applySearchAndSort(); // Panggil fungsi gabungan
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _silentFetchData() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/match/${widget.matchId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listRanting = data['ranting'] ?? [];
            _applySearchAndSort(); // Panggil fungsi gabungan
          });
        }
      }
    } catch (e) {
      // Abaikan error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    if (listRanting.isEmpty) {
      return _buildEmptyState();
    }
    return _buildFilledState();
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: fetchMatchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum ada Data,\nSilahkan tambahkan Ranting\nterlebih dahulu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PilihRantingScreen(matchId: widget.matchId),
                    ),
                  );
                  fetchMatchData();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8),
                    Icon(Icons.add, color: Colors.white),
                    Text("Tambahkan Ranting", style: text14WhiteBold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledState() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daftar Ranting", style: text18PrimaryBold),
              const SizedBox(height: 15),
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
                        controller: searchController,
                        onChanged: (value) {
                          _applySearchAndSort(); // Panggil fungsi gabungan
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari Nama Ranting...',
                          hintStyle: text14greyBold,
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  // --- TAMPILAN DROPDOWN POPUP MENU BUTTON ---
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
                      color: primaryColor, // Background kotak pop up
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // Sudut melengkung
                      ),
                      offset: const Offset(
                        0,
                        50,
                      ), // Geser agar tampil tepat di bawah Icon
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
                  // -------------------------------------------
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: fetchMatchData,
                  child: filteredRanting.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              "Data tidak ditemukan",
                              style: text14PrimaryBold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredRanting.length,
                          itemBuilder: (context, index) {
                            final ranting = filteredRanting[index];

                            final kamusData = daftarKamusRanting.firstWhere(
                              (k) =>
                                  k['sub_kategori'] == ranting['subKategori'] &&
                                  k['kategori_utama'] ==
                                      ranting['kategoriUtama'],
                              orElse: () => daftarKamusRanting[0],
                            );
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PesertaRantingScreen(
                                      matchId: widget.matchId,
                                      rantingData: ranting,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          kamusData['logo'],
                                          height: 20,
                                          errorBuilder: (c, e, s) =>
                                              const Icon(Icons.image),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          ranting['kategoriUtama'],
                                          style: text16PrimaryBold,
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.info_outline,
                                          color: secondaryColor,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            kamusData['gambar_target'],
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                Container(
                                                  height: 70,
                                                  width: 70,
                                                  color: Colors.amber.shade100,
                                                  child: const Icon(
                                                    Icons.adjust,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ranting['subKategori'],
                                                style: text14PrimaryBold,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Ajang ${ranting['kategoriPeserta']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "${(ranting['juriIds'] as List).length} Juri Pertandingan",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 35,
          child: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PilihRantingScreen(matchId: widget.matchId),
                ),
              );
              fetchMatchData();
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
          ),
        ),
      ],
    );
  }
}
