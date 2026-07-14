import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';

class ViewerSetupRantingScreen extends StatefulWidget {
  final Map<String, dynamic> rantingData;

  const ViewerSetupRantingScreen({super.key, required this.rantingData});

  @override
  State<ViewerSetupRantingScreen> createState() =>
      _ViewerSetupRantingScreenState();
}

class _ViewerSetupRantingScreenState extends State<ViewerSetupRantingScreen> {
  String? selectedAmunisi;

  int seriesPerSession = 6;
  int shotsPerSeries = 10;
  bool isDecimal = false;
  bool isRangkaianSet = false;
  bool isSaving = false;

  List<String> _getDaftarKaliber() {
    String subKategori = widget.rantingData['sub_kategori'];
    String kategoriUtama = widget.rantingData['kategori_utama'];

    if (kategoriUtama == "WRABF") {
      return [
        ".22 LR (5,6 mm)",
        "4,5 mm (.177”) Wadcutter",
        "4,5 mm (.177”) Domed",
        "5,6 mm (.22”) Wadcutter",
        "5,6 mm (.22”) Domed",
        "6,3 mm (.25”) Domed",
      ];
    }
    if (kategoriUtama == "ISSF") {
      if (subKategori == "10m Air Pistol" ||
          subKategori == "10m Air Rifle" ||
          subKategori == "10m Running Target") {
        return [
          "4,5 mm (.177”) Wadcutter",
          "4,5 mm (.177”) Domed",
          "5,6 mm (.22”) Wadcutter",
          "5,6 mm (.22”) Domed",
          "6,3 mm (.25”) Domed",
        ];
      } else if (subKategori == "25m Pistol" ||
          subKategori == "25m Rapid-fire Pistol" ||
          subKategori == "50m Pistol") {
        return [
          ".22 LR (5,6 mm)",
          ".25 ACP FMJ",
          ".32 ACP FMJ",
          "9mm Luger",
          ".32 LWC",
          ".38 LWC",
          ".38 LFLAT",
          ".357 Mag LFP",
          ".40 FMJ FN",
          ".40 S&W Special SWC",
          ".44-40 Win. RNFP",
          ".45 ACP SWC",
        ];
      } else if (subKategori == "25m Center-fire Pistol") {
        return [
          "9mm Luger",
          ".25 ACP FMJ",
          ".32 ACP FMJ",
          ".32 LWC",
          ".38 LWC",
          ".38 LFLAT",
          ".357 Mag LFP",
          ".40 FMJ FN",
          ".40 S&W Special SWC",
          ".44-40 Win. RNFP",
          ".45 ACP SWC",
        ];
      } else if (subKategori == "50m Rifle") {
        return [
          ".22 LR (5,6 mm)",
          ".223 FMJ (5,56x45mm)",
          "6mm BR Norma",
          "6.5x55mm SE FMJ",
          "6.5mm Creedmoor FMJ",
          ".260 Rem. (6.5-08)",
          "7mm-08 Remington FMJ",
          ".264 Win. Mag.",
          ".30 Carbine (7,62x33mm)",
          "8x57 IS Mauser FMJ",
          ".338 FMJ",
          ".357 Mag LFP",
          ".358 Win. SP",
          ".44-40 Win. RNFP",
        ];
      }
    }
    return ["Kaliber Belum Tersedia"];
  }

  void _showRangkaianPicker() {
    int tempSeries = seriesPerSession;
    int tempShots = shotsPerSeries;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Series per\nSession",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<int>(
                            value: tempSeries,
                            dropdownColor: primaryColor,
                            underline: Container(
                              height: 1,
                              color: Colors.white54,
                            ),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            items: List.generate(12, (i) => i + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e"),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setStateDialog(() => tempSeries = val!),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 35),
                        child: Text(
                          "X",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Shots per\nSeries",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<int>(
                            value: tempShots,
                            dropdownColor: primaryColor,
                            underline: Container(
                              height: 1,
                              color: Colors.white54,
                            ),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            items: List.generate(50, (i) => i + 1)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e"),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setStateDialog(() => tempShots = val!),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              seriesPerSession = tempSeries;
                              shotsPerSeries = tempShots;
                              isRangkaianSet = true;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Oke",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _simpanLatihanMandiri() async {
    if (selectedAmunisi == null || !isRangkaianSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lengkapi Amunisi & Atur Rangkaian Tembakan!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      final url = Uri.parse('${ApiConfig.baseUrl}/training/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "kategoriUtama": widget.rantingData['kategori_utama'],
          "subKategori": widget.rantingData['sub_kategori'],
          "amunisi": selectedAmunisi,
          "seriesPerSession": seriesPerSession,
          "shotsPerSeries": shotsPerSeries,
          "skorDesimal": isDecimal,
        }),
      );

      setState(() => isSaving = false);

      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'BERHASIL',
          desc: 'Folder Latihan Mandiri berhasil dibuat!',
          btnOkColor: primaryColor,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkOnPress: () {
            // Karena alurnya: Tambah Ranting -> Validasi -> Setup
            // Maka kita pop 3 kali agar kembali ke Halaman Utama Folders
            Navigator.of(context)
              ..pop()
              ..pop()
              ..pop();
          },
        ).show();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menyimpan latihan."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Koneksi Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputStyle(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: goldColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> amunisiList = _getDaftarKaliber();
    if (selectedAmunisi != null && !amunisiList.contains(selectedAmunisi)) {
      selectedAmunisi = null;
    }

    SizeConfig().init(context);
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
          widget.rantingData['sub_kategori'],
          style: text18PrimaryBold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${widget.rantingData['kategori_utama']} ${widget.rantingData['sub_kategori']}",
                    style: text16blackBold,
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(thickness: 1.5),
                const SizedBox(height: 10),
                const Text("Kaliber Amunisi", style: text12greyBold),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  menuMaxHeight: null,
                  decoration: _inputStyle(Icons.article_rounded),
                  hint: const Text(
                    "Pilih Kaliber...",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  value: selectedAmunisi,
                  dropdownColor: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  iconEnabledColor: primaryColor,
                  selectedItemBuilder: (BuildContext context) {
                    return amunisiList.map<Widget>((String item) {
                      return Text(
                        item,
                        style: text14PrimaryBold,
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                  items: amunisiList.map((amu) {
                    return DropdownMenuItem(
                      value: amu,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white24, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          amu,
                          style: text14WhiteBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedAmunisi = val),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Rangkaian Tembak",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: _showRangkaianPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.library_books_rounded,
                          color: goldColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isRangkaianSet
                                ? "$seriesPerSession x $shotsPerSeries"
                                : "Atur Rangkaian...",
                            style: text14PrimaryBold,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: primaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.only(left: 5, right: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.infoReverse,
                                animType: AnimType.scale,
                                title: 'Info Skor Desimal',
                                desc:
                                    'Jika Anda mengaktifkan Skor Desimal, hasil tembakan akan dinilai lebih presisi menggunakan angka di belakang koma (contoh: 9.4, 8.5).\n\nJika dinonaktifkan, skor akan menggunakan angka bulat penuh (contoh: 10, 9, 8). Sesuaikan dengan disiplin latihan Anda.',
                                btnOkColor: Colors.teal,
                                btnOkText: 'Mengerti',
                                btnOkOnPress: () {},
                              ).show();
                            },
                            child: const Icon(
                              Icons.help_rounded,
                              color: Colors.teal,
                              size: 20,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: const Text(
                              "Skor Desimal",
                              style: text14PrimaryBold,
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          splashRadius: 10,
                          value: isDecimal,
                          inactiveThumbColor: const Color.fromARGB(
                            255,
                            88,
                            88,
                            88,
                          ),
                          inactiveTrackColor: Colors.white,
                          activeThumbColor: const Color.fromARGB(
                            255,
                            6,
                            255,
                            105,
                          ),
                          activeTrackColor: primaryColor,
                          onChanged: (val) => setState(() => isDecimal = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 5),
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
                    onPressed: isSaving ? null : _simpanLatihanMandiri,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text("Simpan Latihan", style: text16WhiteBold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
