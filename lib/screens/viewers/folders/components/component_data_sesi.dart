import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/screens/viewers/folders/detail_sesi_screen.dart';
import 'package:ns3_project/screens/viewers/folders/tambah_sesi_screen.dart';
import 'package:ns3_project/service/api_config.dart';

class ComponentFolderSesiViewer extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const ComponentFolderSesiViewer({super.key, required this.trainingData});

  @override
  State<ComponentFolderSesiViewer> createState() =>
      _ComponentFolderSesiViewerState();
}

class _ComponentFolderSesiViewerState extends State<ComponentFolderSesiViewer> {
  List<dynamic> listSesi = [];
  bool isLoading = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    listSesi = widget.trainingData['sesiTembakan'] ?? [];
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
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/training/${widget.trainingData['_id']}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listSesi = data['sesiTembakan'] ?? [];
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
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/training/${widget.trainingData['_id']}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            listSesi = data['sesiTembakan'] ?? [];
          });
        }
      }
    } catch (e) {
      // No Error
    }
  }

  Future<void> _goToTambahSesi() async {
    int maxSesi = widget.trainingData['seriesPerSession'] ?? 0;
    if (listSesi.length >= maxSesi) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.infoReverse,
        animType: AnimType.scale,
        title: 'Batas Sesi Tercapai!',
        desc:
            'Latihan ini telah mencapai maksimal $maxSesi rangkaian tembakan (Series).',
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
        builder: (context) => ViewerTambahSesiScreen(
          trainingData: widget.trainingData,
          sesiNumber: nextSesiNumber,
        ),
      ),
    );
    if (result == true) {
      _fetchFreshData();
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
                "Belum ada Sesi Latihan.\nSilahkan tambahkan Sesi baru.",
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
              Text(
                "${widget.trainingData['kategoriUtama']} - ${widget.trainingData['subKategori']}",
                style: text16PrimaryBold,
              ),
              const SizedBox(height: 5),
              Text(
                "Amunisi: ${widget.trainingData['amunisi']}",
                style: text14greyBold,
              ),
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
                        builder: (context) => ViewerDetailSesiScreen(
                          trainingData: widget.trainingData,
                          sesiData: sesi,
                        ),
                      ),
                    );
                    _fetchFreshData();
                    print("Buka Sesi: ${sesi['namaSesi']}");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
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
                      border: Border.all(color: Colors.grey.shade300, width: 2),
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
                            const SizedBox(width: 10),
                            Text(
                              sesi['tanggal'] ?? '-',
                              style: text14PrimaryBold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(height: 1, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
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
                                  desc: 'Fitur Hapus Sesi Sedang Dikembangkan',
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
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
