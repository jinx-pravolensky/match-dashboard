import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TambahPesertaScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;

  const TambahPesertaScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
  });

  @override
  State<TambahPesertaScreen> createState() => _TambahPesertaScreenState();
}

class _TambahPesertaScreenState extends State<TambahPesertaScreen> {
  TextEditingController namaController = TextEditingController();
  TextEditingController bibController = TextEditingController();
  TextEditingController provinsiController = TextEditingController();
  TextEditingController kotaController = TextEditingController();

  String? selectedGender;
  bool isGenderLocked = false;

  @override
  void initState() {
    super.initState();
    String kategori = widget.rantingData['kategoriPeserta'] ?? '';
    if (kategori == 'Putra') {
      selectedGender = 'Putra';
      isGenderLocked = true;
    } else if (kategori == 'Putri') {
      selectedGender = 'Putri';
      isGenderLocked = true;
    }
  }

  Future<void> _simpanPeserta() async {
    if (namaController.text.isEmpty ||
        bibController.text.isEmpty ||
        selectedGender == null ||
        provinsiController.text.isEmpty ||
        kotaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua data peserta!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      String rantingId = widget.rantingData['_id'];

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/match/${widget.matchId}/ranting/$rantingId/add-peserta',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": namaController.text.trim(),
          "bib": bibController.text.trim(),
          "gender": selectedGender,
          "provinsi": provinsiController.text.trim(),
          "kota": kotaController.text.trim(),
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'BERHASIL',
          desc: 'Data Peserta berhasil disimpan!',
          btnOkColor: primaryColor,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          btnOkOnPress: () {
            Navigator.pop(context, true);
          },
        ).show();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}")));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Koneksi Error! Cek Server.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text("Tambah Peserta", style: text20PrimaryBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                _buildLabel("Nama"),
                _buildTextField(
                  namaController,
                  "Nama Lengkap...",
                  Icons.assignment_ind,
                ),
                const SizedBox(height: 15),

                _buildLabel("Nomor BIB"),
                _buildTextField(
                  bibController,
                  "Nomor BIB...",
                  Icons.assignment_add,
                  isNumber: true,
                ),
                const SizedBox(height: 15),
                _buildLabel("Jenis Kelamin"),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.article_rounded,
                      color: goldColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isGenderLocked ? Colors.grey : primaryColor,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                  ),
                  hint: const Text("Pilih Gender", style: text14PrimaryBold),
                  value: selectedGender,
                  items: ["Putra", "Putri"]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: text14PrimaryBold),
                        ),
                      )
                      .toList(),
                  onChanged: isGenderLocked
                      ? null
                      : (val) => setState(() => selectedGender = val),
                ),
                const SizedBox(height: 15),
                _buildLabel("Asal Provinsi"),
                _buildTextField(
                  provinsiController,
                  "Nama Provinsi...",
                  Icons.assignment_rounded,
                ),
                const SizedBox(height: 15),
                _buildLabel("Asal Kota"),
                _buildTextField(
                  kotaController,
                  "Nama Kota...",
                  Icons.assignment_rounded,
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: greyColor),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _simpanPeserta,
                    child: const Text("Simpan", style: text16WhiteBold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: text14PrimaryBold,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: goldColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
}
