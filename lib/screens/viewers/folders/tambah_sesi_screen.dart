import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/data/data_ranting.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';

class ViewerTambahSesiScreen extends StatefulWidget {
  final Map<String, dynamic> trainingData;
  final int sesiNumber;

  const ViewerTambahSesiScreen({
    super.key,
    required this.trainingData,
    required this.sesiNumber,
  });
  static String routeName = '/viewer-tambah-sesi';

  @override
  State<ViewerTambahSesiScreen> createState() => _ViewerTambahSesiScreenState();
}

class _ViewerTambahSesiScreenState extends State<ViewerTambahSesiScreen> {
  bool isSaving = false;

  List<String> _getBarLabels() {
    String subKat = widget.trainingData['subKategori'] ?? '';

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

  Future<void> _simpanSesiLatihan() async {
    setState(() => isSaving = true);

    try {
      String tanggalSekarang = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/training/${widget.trainingData['_id']}/add-sesi',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "namaSesi": "Sesi ke-${widget.sesiNumber}",
          "tanggal": tanggalSekarang,
          "shotsPerSeries": widget.trainingData['shotsPerSeries'] ?? 10,
        }),
      );
      setState(() => isSaving = false);
      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          barrierColor: Colors.black87,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          title: 'BERHASIL',
          desc: 'Sesi ke-${widget.sesiNumber} Berhasil Ditambahkan!',
          btnOkColor: primaryColor,
          btnOkText: "Oke",
          btnOkOnPress: () {
            Navigator.pop(context, true);
          },
        ).show();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambah Sesi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Koneksi Error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String subKat = widget.trainingData['subKategori'] ?? '';
    String katUtama = widget.trainingData['kategoriUtama'] ?? '';
    String tanggalSekarang = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final kamusData = daftarKamusRanting.firstWhere(
      (k) => k['sub_kategori'] == subKat && k['kategori_utama'] == katUtama,
      orElse: () => daftarKamusRanting[0],
    );
    List<String> barLabels = _getBarLabels();
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Sesi Ke-${widget.sesiNumber}", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
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
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tanggalSekarang, style: text14PrimaryBold),
                      const Text("Score: 0", style: text14PrimaryBold),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    kamusData['gambar_target'],
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 15),
                _buildBalisticInfo(Icons.air_rounded, "Windage", "0,0 mm"),
                _buildBalisticInfo(
                  Icons.bar_chart_rounded,
                  "Elevation",
                  "0,0 mm",
                ),
                _buildBalisticInfo(
                  Icons.radar_rounded,
                  "Mean Radius",
                  "0,0 mm",
                ),
                _buildBalisticInfo(
                  Icons.donut_large_rounded,
                  "Max Spread",
                  "0,0 mm",
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: barLabels.map((label) {
                    return Column(
                      children: [
                        Container(
                          height: 2,
                          width: 15,
                          color: Colors.grey.shade400,
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isSaving ? null : _simpanSesiLatihan,
                    child: isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Tambah Sesi Latihan",
                            style: text16WhiteBold,
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
      padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: text14greyBold)),
          Text(value, style: text14greyBold),
        ],
      ),
    );
  }
}
