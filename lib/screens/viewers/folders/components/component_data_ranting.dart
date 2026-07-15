import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/screens/viewers/folders/folder_sesi_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/data/data_ranting.dart';
import 'package:ns3_project/screens/viewers/folders/tambah_ranting_screen.dart';

class ComponentDataRantingViewer extends StatefulWidget {
  const ComponentDataRantingViewer({super.key});

  @override
  State<ComponentDataRantingViewer> createState() =>
      _ComponentDataRantingViewerState();
}

class _ComponentDataRantingViewerState
    extends State<ComponentDataRantingViewer> {
  List<dynamic> listRanting = [];
  List<dynamic> filteredRanting = [];
  bool isLoading = true;
  Timer? _autoRefreshTimer;

  final TextEditingController searchController = TextEditingController();
  String currentSort = "Data Terlama";

  @override
  void initState() {
    super.initState();
    fetchTrainingData();
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
        return subKategori.contains(query);
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

  Future<void> fetchTrainingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/training/user/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listRanting = data;
            _applySearchAndSort();
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/training/user/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listRanting = data;
            _applySearchAndSort();
          });
        }
      }
    } catch (e) {}
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
      onRefresh: fetchTrainingData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Folder Ranting Kosong,\nSilahkan buat Folder Ranting\nterlebih dahulu.",
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
                      builder: (context) => const ViewerTambahRanting(),
                    ),
                  );
                  fetchTrainingData();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8),
                    Icon(Icons.add, color: Colors.white),
                    Text("Buat Folder Latihan", style: text14WhiteBold),
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
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text(
                  "Data Folder Ranting",
                  style: text16PrimaryBold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor, width: 1),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          _applySearchAndSort();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari Ranting...',
                          hintStyle: text14greyBold,
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                        Icons.library_books_rounded,
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
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: fetchTrainingData,
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
                            final int totalSesi =
                                (ranting['sesiTembakan'] as List?)?.length ?? 0;
                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewerFolderSesiScreen(
                                          trainingData: ranting,
                                        ),
                                  ),
                                );
                                fetchTrainingData();
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade300,
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
                                          Icons.arrow_forward_ios_rounded,
                                          color: secondaryColor,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '${ranting['amunisi']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: Colors.teal,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  "$totalSesi Sesi Latihan Tersimpan",
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.teal,
                                                  ),
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
          bottom: 25,
          right: 25,
          child: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewerTambahRanting(),
                ),
              );
              fetchTrainingData();
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
          ),
        ),
      ],
    );
  }
}
