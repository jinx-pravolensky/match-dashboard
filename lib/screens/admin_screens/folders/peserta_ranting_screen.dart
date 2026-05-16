import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';
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
  bool isLoading = false;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    listPeserta = widget.rantingData['peserta'] ?? [];
    _fetchFreshData();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _silentFetchData();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
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
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari Nama Peserta...',
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
                      const Icon(
                        Icons.library_books_outlined,
                        color: primaryColor,
                        size: 30,
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
            const SizedBox(height: 5),
            Expanded(
              child: isLoading && listPeserta.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      color: primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: _fetchFreshData,
                      child: listPeserta.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(15),
                              itemCount: listPeserta.length,
                              itemBuilder: (context, index) {
                                final peserta = listPeserta[index];
                                final score = peserta['score'];
                                final isScored =
                                    score != null && score.toString() != '';

                                return InkWell(
                                  onTap: () {
                                    print("Klik: ${peserta['nama']}");
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
                                                          FontWeight.bold,
                                                      color: isScored
                                                          ? Colors.teal
                                                          : darkColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
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
          "Belum ada peserta.\nSilahkan tambahkan terlebih dahulu.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
