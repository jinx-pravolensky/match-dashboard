import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class AdminFolderSesiScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;

  const AdminFolderSesiScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.pesertaData,
  });

  @override
  State<AdminFolderSesiScreen> createState() => _AdminFolderSesiScreenState();
}

class _AdminFolderSesiScreenState extends State<AdminFolderSesiScreen> {
  List<dynamic> listSesi = [];
  bool isLoading = true;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    listSesi = widget.pesertaData['sesiTembakan'] ?? [];
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

        if (currentRanting != null) {
          final pesertas = currentRanting['peserta'] as List;
          final currentPeserta = pesertas.firstWhere(
            (p) => p['_id'] == widget.pesertaData['_id'],
            orElse: () => null,
          );

          if (currentPeserta != null && mounted) {
            setState(() {
              listSesi = currentPeserta['sesiTembakan'] ?? [];
            });
          }
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

        if (currentRanting != null) {
          final pesertas = currentRanting['peserta'] as List;
          final currentPeserta = pesertas.firstWhere(
            (p) => p['_id'] == widget.pesertaData['_id'],
            orElse: () => null,
          );

          if (currentPeserta != null && mounted) {
            setState(() {
              listSesi = currentPeserta['sesiTembakan'] ?? [];
            });
          }
        }
      }
    } catch (e) {
      // No Error
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
        title: const Text('Sesi Kegiatan', style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Nama dan BIB Peserta (Center)
            const SizedBox(height: 20),
            Text(
              widget.pesertaData['nama'] ?? '-',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.pesertaData['bib'] ?? '-',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Bagian List Data Sesi
            Expanded(
              child: isLoading && listSesi.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : listSesi.isEmpty
                  ? _buildEmptyState()
                  : _buildFilledState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Data Sesi Kosong,\nData akan muncul setelah\nJuri memulai Sesi.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledState() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: _fetchFreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: listSesi.length,
        itemBuilder: (context, index) {
          final sesi = listSesi[index];
          final bool isScored = sesi['score'] != null && sesi['score'] != '-';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sesi['namaSesi'] ?? 'Sesi', style: text14PrimaryBold),
                    Text(sesi['tanggal'] ?? '-', style: text14PrimaryBold),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.article_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(
                              text: "Score : ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (isScored)
                              TextSpan(
                                text: "${sesi['score']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: secondaryColor,
                                ),
                              )
                            else
                              const TextSpan(
                                text: "Juri belum memberikan Score",
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isScored) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Juri: ${sesi['juriName'] ?? '-'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
