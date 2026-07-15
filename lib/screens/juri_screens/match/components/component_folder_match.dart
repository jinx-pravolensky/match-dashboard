import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/juri_screens/match/folder_ranting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/screens/juri_screens/match/detail_pertandingan_screen.dart';

class ComponentFolderDataMatch extends StatefulWidget {
  const ComponentFolderDataMatch({super.key});

  @override
  State<ComponentFolderDataMatch> createState() =>
      _ComponentFolderDataMatchState();
}

class _ComponentFolderDataMatchState extends State<ComponentFolderDataMatch> {
  bool isLoading = true;
  Timer? _autoRefreshTimer;
  List<dynamic> allMatch = [];
  List<dynamic> listMatch = [];

  final TextEditingController searchController = TextEditingController();
  String currentSort = "Data Terlama";

  @override
  void initState() {
    super.initState();
    _fetchJuriMatches();

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
    List<dynamic> temp = List.from(allMatch);

    if (searchController.text.isNotEmpty) {
      final keyword = searchController.text.toLowerCase();
      temp = temp.where((match) {
        final id = (match['matchCustomId'] ?? '').toString().toLowerCase();
        final title = (match['title'] ?? '').toString().toLowerCase();
        return id.contains(keyword) || title.contains(keyword);
      }).toList();
    }

    if (currentSort == 'Data Terbaru') {
      temp = temp.reversed.toList();
    } else if (currentSort == 'Nama A-Z') {
      temp.sort((a, b) {
        final titleA = (a['title'] ?? '').toString().toLowerCase();
        final titleB = (b['title'] ?? '').toString().toLowerCase();
        return titleA.compareTo(titleB);
      });
    }

    setState(() {
      listMatch = temp;
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

  Future<void> _fetchJuriMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final juriId = prefs.getString('userId');

      if (juriId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/match/juri/$juriId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            allMatch = data;
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
      final juriId = prefs.getString('userId');
      if (juriId == null) return;
      final url = Uri.parse('${ApiConfig.baseUrl}/match/juri/$juriId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            allMatch = data;
            _applySearchAndSort();
          });
        }
      }
    } catch (e) {}
  }

  String _formatTanggalIndo(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      String day = parts[0];
      String month = parts[1];
      String year = parts[2];
      List<String> namaBulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      int monthIndex = int.parse(month);
      if (monthIndex >= 1 && monthIndex <= 12) {
        return '$day ${namaBulan[monthIndex]} $year';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    if (allMatch.isEmpty) {
      return _buildEmptyState();
    }
    return _buildFilledState();
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: _fetchJuriMatches,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: const Text(
            "Belum ada data saat ini,\ndata akan tampil ketika admin\nmenambahkan Anda ke dalam pertandingan.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: const Text(
              "Daftar Match Berlangsung",
              style: text16PrimaryBold,
            ),
          ),
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
                    controller: searchController,
                    onChanged: (value) {
                      _applySearchAndSort();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari ID atau Nama...',
                      hintStyle: text14greyBold,
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Theme(
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: Colors.white,
              onRefresh: _fetchJuriMatches,
              child: listMatch.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Match tidak ditemukan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: listMatch.length,
                      itemBuilder: (context, index) {
                        final match = listMatch[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FolderRantingJuriScreen(
                                          matchId: match['_id'],
                                          matchTitle:
                                              match['title'] ?? 'Pertandingan',
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                match['title'] ?? 'Tanpa Judul',
                                                style: const TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: goldColor.withOpacity(
                                                    0.15,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  "ID : ${match['matchCustomId'] ?? '-'}",
                                                  style: const TextStyle(
                                                    color: goldColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailPertandinganScreen(
                                                      matchData: match,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.info_outline_rounded,
                                              color: secondaryColor,
                                              size: 26,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildModernInfoRow(
                                      Icons.location_on_rounded,
                                      match['location'] ?? '-',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernInfoRow(
                                      Icons.calendar_month_rounded,
                                      _formatTanggalIndo(match['date'] ?? '-'),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernInfoRow(
                                      Icons.groups_rounded,
                                      match['organizer'] ?? '-',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: secondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
