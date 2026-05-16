import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/juri_screens/match/detail_sesi_screen.dart';
import 'package:ns3_project/screens/juri_screens/match/tambah_sesi_screen.dart';
import 'package:ns3_project/service/api_config.dart';

class ComponentFolderSesi extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;

  const ComponentFolderSesi({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.pesertaData,
  });

  @override
  State<ComponentFolderSesi> createState() => _ComponentFolderSesiState();
}

class _ComponentFolderSesiState extends State<ComponentFolderSesi> {
  List<dynamic> listSesi = [];
  bool isLoading = false;
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

  bool isEmptyScore(dynamic score) {
    return score == null || score.toString() == '-';
  }

  Color getScoreColor(dynamic score) {
    return isEmptyScore(score) ? primaryColor : Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && listSesi.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (listSesi.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFilledState();
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: _fetchFreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum ada Sesi Kegiatan untuk\nPeserta ini.",
                textAlign: TextAlign.center,
                style: text14PrimaryBold,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _goToTambahSesi,
                child: const Text("Tambah Sesi", style: text14WhiteBold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(widget.pesertaData['nama'] ?? '-', style: text16PrimaryBold),
              Text(widget.pesertaData['bib'] ?? '-', style: text14greyBold),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _fetchFreshData,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listSesi.length,
              itemBuilder: (context, index) {
                final sesi = listSesi[index];
                final score = sesi['score'];
                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailSesiScreen(
                          matchId: widget.matchId,
                          rantingData: widget.rantingData,
                          pesertaData: widget.pesertaData,
                          sesiData: sesi,
                        ),
                      ),
                    );
                    _fetchFreshData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF7A7979),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                sesi['namaSesi'] ?? 'Sesi',
                                style: text14PrimaryBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: getScoreColor(score),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Score: ${score ?? '-'}",
                                style: text14WhiteBold,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Text(
                              sesi['tanggal'] ?? '-',
                              style: text14PrimaryBold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(height: 1, color: const Color(0xFFABABAB)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: goldColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "${sesi['jumlahLubang'] ?? 0}",
                                style: text14WhiteBold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "${sesi['shotsPerSeries'] ?? 0} Tembakan per Sesi",
                                style: text14blackBold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.info,
                                  animType: AnimType.scale,
                                  title: 'Coming Soon',
                                  desc: 'Fitur Delete Sedang Dikembangkan',
                                  btnOkColor: primaryColor,
                                  btnOkOnPress: () {},
                                ).show();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 199, 43, 43),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Juri: ${sesi['juriName'] ?? '-'}",
                          style: text14greyBold,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: _goToTambahSesi,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToTambahSesi() async {
    int maxSesi = widget.rantingData['seriesPerSession'] ?? 0;

    if (listSesi.length >= maxSesi) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.infoReverse,
        animType: AnimType.scale,
        title: 'Batas Sesi Tercapai!',
        desc: 'Peserta ini telah mencapai maksimal $maxSesi sesi.',
        btnOkColor: primaryColor,
        btnOkText: 'Mengerti',
        btnOkOnPress: () {},
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();
      return;
    }

    int nextSesiNumber = listSesi.length + 1;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahSesiScreen(
          matchId: widget.matchId,
          rantingData: widget.rantingData,
          pesertaData: widget.pesertaData,
          sesiNumber: nextSesiNumber,
        ),
      ),
    );

    if (result == true) {
      _fetchFreshData();
    }
  }
}
