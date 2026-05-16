import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/data/data_ranting.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/screens/juri_screens/match/scan/camera_scan_screen.dart';

class DetailSesiScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;
  final Map<String, dynamic> sesiData;

  const DetailSesiScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.pesertaData,
    required this.sesiData,
  });

  @override
  State<DetailSesiScreen> createState() => _DetailSesiScreenState();
}

class _DetailSesiScreenState extends State<DetailSesiScreen> {
  late Map<String, dynamic> currentSesiData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentSesiData = widget.sesiData;
    _fetchFreshData();
  }

  Future<void> _fetchFreshData() async {
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

          if (currentPeserta != null) {
            final sesis = currentPeserta['sesiTembakan'] as List;
            final updatedSesi = sesis.firstWhere(
              (s) => s['_id'] == currentSesiData['_id'],
              orElse: () => null,
            );

            if (updatedSesi != null) {
              setState(() {
                currentSesiData = updatedSesi;
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error Refresh Data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> _getBarLabels() {
    String subKat =
        widget.rantingData['subKategori'] ?? widget.rantingData['sub_kategori'];
    List<String> list10to1 = [
      '10m Air Pistol',
      '10m Air Rifle',
      '10m Running Target',
      '25m Pistol',
      '50m Pistol',
      '50m Rifle',
    ];
    if (list10to1.contains(subKat)) {
      return ['X', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1'];
    } else {
      return ['X', '10', '9', '8', '7', '6', '5'];
    }
  }

  @override
  Widget build(BuildContext context) {
    String subKat =
        widget.rantingData['subKategori'] ?? widget.rantingData['sub_kategori'];
    String katUtama =
        widget.rantingData['kategoriUtama'] ??
        widget.rantingData['kategori_utama'];

    final kamusData = daftarKamusRanting.firstWhere(
      (k) => k['sub_kategori'] == subKat && k['kategori_utama'] == katUtama,
      orElse: () => daftarKamusRanting[0],
    );

    List<String> barLabels = _getBarLabels();

    bool isScanned = currentSesiData['score'] != '-';

    String displayScore = isScanned ? currentSesiData['score'].toString() : "0";
    String windage = isScanned ? currentSesiData['windage'] : "0,0 mm";
    String elevation = isScanned ? currentSesiData['elevation'] : "0,0 mm";
    String meanRadius = isScanned ? currentSesiData['meanRadius'] : "0,0 mm";
    String maxSpread = isScanned ? currentSesiData['maxSpread'] : "0,0 mm";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context, isScanned),
        ),
        title: Text(
          currentSesiData['namaSesi'] ?? 'Session',
          style: text20PrimaryBold,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(kamusData['logo'], height: 25),
                          const SizedBox(width: 10),
                          Text(katUtama, style: text18PrimaryBold),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentSesiData['tanggal'] ?? '-',
                            style: text14PrimaryBold,
                          ),
                          Text(
                            "Score: $displayScore",
                            style: text14PrimaryBold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          kamusData['gambar_target'],
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildBalisticInfo(Icons.air_rounded, "Windage", windage),
                      _buildBalisticInfo(
                        Icons.bar_chart_rounded,
                        "Elevation",
                        elevation,
                      ),
                      _buildBalisticInfo(
                        Icons.radar_rounded,
                        "Mean Radius",
                        meanRadius,
                      ),
                      _buildBalisticInfo(
                        Icons.donut_large_rounded,
                        "Max Spread",
                        maxSpread,
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: barLabels.map((label) {
                          List<dynamic> skorDetail =
                              currentSesiData['skorDetail'] ?? [];
                          int jumlahTembakanDiNilaiIni = 0;
                          for (var skor in skorDetail) {
                            if (skor.toString() == label) {
                              jumlahTembakanDiNilaiIni++;
                            }
                          }
                          double barHeight = jumlahTembakanDiNilaiIni > 0
                              ? (jumlahTembakanDiNilaiIni * 15.0) + 5.0
                              : 2.0;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height:
                                    barHeight, // <-- SEKARANG TINGGINYA NYATA BRO!
                                width: 15,
                                color: jumlahTembakanDiNilaiIni > 0
                                    ? Colors.black87
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            int shotsPerSeries =
                                widget.rantingData['shotsPerSeries'] ?? 10;
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScanScreen(
                                  matchId: widget.matchId,
                                  rantingData: widget.rantingData,
                                  pesertaData: widget.pesertaData,
                                  sesiData: currentSesiData,
                                  defaultShots: shotsPerSeries,
                                ),
                              ),
                            );
                            if (result == true) {
                              _fetchFreshData();
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text("Mulai Sesi", style: text16WhiteBold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBalisticInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: text14greyBold)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
