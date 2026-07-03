import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/screens/juri_screens/match/folder_sesi_peserta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/admin_screens/folders/daftar_juri_ranting_screen.dart';

class PesertaRantingJuriScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;

  const PesertaRantingJuriScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
  });

  @override
  State<PesertaRantingJuriScreen> createState() =>
      _PesertaRantingJuriScreenState();
}

class _PesertaRantingJuriScreenState extends State<PesertaRantingJuriScreen> {
  bool isAuthorized = false;
  bool isCheckingAuth = true;

  List<dynamic> listPeserta = [];
  List<dynamic> filteredPeserta = [];

  final TextEditingController searchController = TextEditingController();

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    listPeserta = widget.rantingData['peserta'] ?? [];
    filteredPeserta = listPeserta;

    _checkAuthorization();
    _fetchFreshData();

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

  Future<void> _checkAuthorization() async {
    final prefs = await SharedPreferences.getInstance();
    final myJuriId = prefs.getString('userId');

    List<dynamic> juriList = widget.rantingData['juriIds'] ?? [];

    for (var juri in juriList) {
      String juriIdDiRanting = juri is Map
          ? juri['_id'].toString()
          : juri.toString();
      if (juriIdDiRanting == myJuriId) {
        isAuthorized = true;
        break;
      }
    }

    if (mounted) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  Future<void> _fetchFreshData() async {
    if (!mounted) return;
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
            if (searchController.text.isEmpty) {
              filteredPeserta = listPeserta;
            } else {
              onSearch(searchController.text);
            }
          });
        }
      }
    } catch (e) {
      // No error
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
            if (searchController.text.isEmpty) {
              filteredPeserta = listPeserta;
            } else {
              onSearch(searchController.text);
            }
          });
        }
      }
    } catch (e) {
      // No error
    }
  }

  void onSearch(String value) {
    final query = value.toLowerCase();
    setState(() {
      filteredPeserta = listPeserta.where((peserta) {
        final nama = (peserta['nama'] ?? '').toString().toLowerCase();
        return nama.contains(query);
      }).toList();
    });
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
        child: isCheckingAuth
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: const Text(
                            "Daftar Peserta",
                            style: text18PrimaryBold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: onSearch,
                                  decoration: const InputDecoration(
                                    hintStyle: text14greyBold,
                                    hintText: 'Cari Nama Peserta...',
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
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: const IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.library_books_outlined,
                                  color: primaryColor,
                                  size: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
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
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Lihat Daftar Juri",
                                    style: text14WhiteBold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
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
                  const SizedBox(height: 5),

                  Expanded(
                    child: RefreshIndicator(
                      color: primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: _fetchFreshData,
                      child: listPeserta.isEmpty
                          ? _buildEmptyState()
                          : filteredPeserta.isEmpty
                          ? _buildSearchEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(15),
                              itemCount: filteredPeserta.length,
                              itemBuilder: (context, index) {
                                final peserta = filteredPeserta[index];
                                return InkWell(
                                  onTap: () {
                                    if (isAuthorized) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FolderSesiScreen(
                                                matchId: widget.matchId,
                                                rantingData: widget.rantingData,
                                                pesertaData: peserta,
                                              ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          elevation: 6,
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 20,
                                          ),
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: redColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          animation: CurvedAnimation(
                                            parent:
                                                const AlwaysStoppedAnimation(1),
                                            curve: Curves.easeInOut,
                                          ),
                                          content: const Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  "Akses Ditolak! Anda hanya sebagai Viewer di Ranting ini.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAuthorized
                                          ? backgroundColor
                                          : Colors.grey.shade100,
                                      border: Border.all(
                                        color: isAuthorized
                                            ? primaryColor
                                            : Colors.grey.shade400,
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
                                                  color: isAuthorized
                                                      ? primaryColor
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.article_rounded,
                                                    size: 20,
                                                    color: isAuthorized
                                                        ? darkColor
                                                        : Colors.grey,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    peserta['nama'] ?? '-',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isAuthorized
                                                          ? darkColor
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isAuthorized
                                              ? Icons.arrow_forward_ios
                                              : Icons.lock_outline,
                                          color: isAuthorized
                                              ? darkColor
                                              : Colors.red.shade300,
                                          size: 25,
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
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Belum ada Daftar Peserta,\nSilahkan tunggu Admin menambahkan\nPeserta terlebih dahulu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Nama tidak ditemukan",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
